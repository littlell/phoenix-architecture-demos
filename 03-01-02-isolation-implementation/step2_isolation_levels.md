# 步骤2：事务隔离级别演示

## 实验说明
通过两个并发事务，观察不同隔离级别下的读写行为差异。

### 环境准备
1. 打开两个MySQL终端窗口（终端A和终端B）
2. 两个终端都执行：`USE iso_test;`

## 隔离级别1：READ UNCOMMITTED（读未提交）

### 终端A执行：
```sql
-- 设置隔离级别为READ UNCOMMITTED
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- 开始事务
START TRANSACTION;

-- 查询Product A的库存
SELECT * FROM products WHERE id = 1;
```

### 终端B执行：
```sql
-- 设置隔离级别为READ UNCOMMITTED
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- 开始事务
START TRANSACTION;

-- 修改Product A的库存，但不提交
UPDATE products SET stock = stock - 10 WHERE id = 1;

-- 查询修改后的库存
SELECT * FROM products WHERE id = 1;
```

### 终端A再次执行：
```sql
-- 再次查询Product A的库存，观察是否能看到未提交的修改
SELECT * FROM products WHERE id = 1;
```

### 观察现象：
- 终端A能看到终端B未提交的修改（脏读）

### 清理：
两个终端都执行：`ROLLBACK;`

## 隔离级别2：READ COMMITTED（读已提交）

### 终端A执行：
```sql
-- 设置隔离级别为READ COMMITTED
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- 开始事务
START TRANSACTION;

-- 查询Product A的库存
SELECT * FROM products WHERE id = 1;
```

### 终端B执行：
```sql
-- 设置隔离级别为READ COMMITTED
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- 开始事务
START TRANSACTION;

-- 修改Product A的库存
UPDATE products SET stock = stock - 10 WHERE id = 1;

-- 提交事务
COMMIT;

-- 查询修改后的库存
SELECT * FROM products WHERE id = 1;
```

### 终端A再次执行：
```sql
-- 再次查询Product A的库存，观察是否能看到已提交的修改
SELECT * FROM products WHERE id = 1;
```

### 观察现象：
- 终端A能看到终端B已提交的修改
- 同一事务内多次读取结果不一致（不可重复读）

### 清理：
终端A执行：`ROLLBACK;`

## 隔离级别3：REPEATABLE READ（可重复读）

### 终端A执行：
```sql
-- 设置隔离级别为REPEATABLE READ
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- 开始事务
START TRANSACTION;

-- 查询Product A的库存
SELECT * FROM products WHERE id = 1;
```

### 终端B执行：
```sql
-- 设置隔离级别为REPEATABLE READ
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- 开始事务
START TRANSACTION;

-- 修改Product A的库存
UPDATE products SET stock = stock - 10 WHERE id = 1;

-- 提交事务
COMMIT;

-- 查询修改后的库存
SELECT * FROM products WHERE id = 1;
```

### 终端A再次执行：
```sql
-- 再次查询Product A的库存，观察结果是否一致
SELECT * FROM products WHERE id = 1;

-- 提交事务后再次查询
COMMIT;
SELECT * FROM products WHERE id = 1;
```

### 观察现象：
- 同一事务内多次读取结果一致（可重复读）
- 事务提交后才能看到其他事务的修改

### 清理：
无需额外操作

## 隔离级别4：SERIALIZABLE（串行化）

### 终端A执行：
```sql
-- 设置隔离级别为SERIALIZABLE
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- 开始事务
START TRANSACTION;

-- 查询Product A的库存
SELECT * FROM products WHERE id = 1;
```

### 终端B执行：
```sql
-- 设置隔离级别为SERIALIZABLE
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- 开始事务
START TRANSACTION;

-- 尝试修改Product A的库存，观察是否会阻塞
UPDATE products SET stock = stock - 10 WHERE id = 1;
```

### 终端A执行：
```sql
-- 提交事务
COMMIT;
```

### 观察现象：
- 终端B的修改操作会被阻塞，直到终端A提交事务
- 事务串行执行，避免了所有并发问题

### 清理：
终端B执行：`COMMIT;`

## 实验总结
| 隔离级别 | 脏读 | 不可重复读 | 幻读 |
|---------|------|------------|------|
| READ UNCOMMITTED | 允许 | 允许 | 允许 |
| READ COMMITTED | 禁止 | 允许 | 允许 |
| REPEATABLE READ | 禁止 | 禁止 | 允许（InnoDB通过MVCC解决） |
| SERIALIZABLE | 禁止 | 禁止 | 禁止 |
