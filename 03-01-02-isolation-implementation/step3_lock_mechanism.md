# 步骤3：锁机制实践

## 实验说明
通过并发事务演示不同类型的锁机制及其行为特性。

### 环境准备
1. 打开两个MySQL终端窗口（终端A和终端B）
2. 两个终端都执行：`USE iso_test;`
3. 设置默认隔离级别：`SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;`

## 实验1：排他锁（X-Lock）演示

### 终端A执行：
```sql
-- 开始事务
START TRANSACTION;

-- 更新操作会自动加排他锁
UPDATE products SET stock = stock - 10 WHERE id = 1;

-- 查询当前锁信息（需要SUPER权限）
-- SHOW ENGINE INNODB STATUS;
```

### 终端B执行：
```sql
-- 开始事务
START TRANSACTION;

-- 尝试更新同一行数据，观察是否会阻塞
UPDATE products SET stock = stock - 5 WHERE id = 1;
```

### 终端A执行：
```sql
-- 提交事务，释放锁
COMMIT;
```

### 观察现象：
- 终端B的更新操作会被阻塞，直到终端A提交事务释放排他锁
- 排他锁保证了同一时间只有一个事务能修改同一行数据

### 清理：
无需额外操作

## 实验2：共享锁（S-Lock）演示

### 终端A执行：
```sql
-- 开始事务
START TRANSACTION;

-- 使用SELECT ... FOR SHARE获取共享锁
SELECT * FROM products WHERE id = 1 FOR SHARE;
```

### 终端B执行：
```sql
-- 开始事务
START TRANSACTION;

-- 尝试获取同一行的共享锁，观察是否允许
SELECT * FROM products WHERE id = 1 FOR SHARE;

-- 尝试获取同一行的排他锁，观察是否会阻塞
UPDATE products SET stock = stock - 5 WHERE id = 1;
```

### 终端A执行：
```sql
-- 提交事务，释放共享锁
COMMIT;
```

### 观察现象：
- 多个事务可以同时获取同一行的共享锁
- 共享锁与排他锁互斥，获取排他锁时会被阻塞

### 清理：
终端B执行：`COMMIT;`

## 实验3：行锁与表锁对比

### 行锁演示：

#### 终端A执行：
```sql
-- 开始事务
START TRANSACTION;

-- 更新id=1的行，加行锁
UPDATE products SET stock = stock - 10 WHERE id = 1;
```

#### 终端B执行：
```sql
-- 开始事务
START TRANSACTION;

-- 更新不同行的数据，观察是否会阻塞
UPDATE products SET stock = stock - 5 WHERE id = 2;
```

#### 观察现象：
- 终端B的更新操作不会被阻塞，因为操作的是不同行
- 行锁只锁定被修改的行，允许并发修改其他行

#### 清理：
两个终端都执行：`COMMIT;`

### 表锁演示：

#### 终端A执行：
```sql
-- 开始事务
START TRANSACTION;

-- 使用LOCK TABLES获取表锁
LOCK TABLES products WRITE;

-- 修改数据
UPDATE products SET stock = stock - 10 WHERE id = 1;
```

#### 终端B执行：
```sql
-- 开始事务
START TRANSACTION;

-- 尝试访问products表的任何行，观察是否会阻塞
SELECT * FROM products WHERE id = 2;
```

#### 终端A执行：
```sql
-- 释放表锁
UNLOCK TABLES;

-- 提交事务
COMMIT;
```

#### 观察现象：
- 终端B的查询操作会被阻塞，直到终端A释放表锁
- 表锁锁定整个表，不允许其他事务访问

#### 清理：
终端B执行：`COMMIT;`

## 实验4：意向锁演示

### 终端A执行：
```sql
-- 开始事务
START TRANSACTION;

-- 获取行级排他锁
UPDATE products SET stock = stock - 10 WHERE id = 1;
```

### 终端B执行：
```sql
-- 开始事务
START TRANSACTION;

-- 尝试获取表级共享锁，观察是否会阻塞
LOCK TABLES products READ;
```

### 终端A执行：
```sql
-- 提交事务，释放行锁
COMMIT;
```

### 观察现象：
- 终端B的LOCK TABLES操作会被阻塞
- 意向锁确保了行锁和表锁之间的兼容性

### 清理：
终端B执行：`UNLOCK TABLES; COMMIT;`

## 锁机制总结

| 锁类型 | 特点 | 适用场景 |
|-------|------|----------|
| 排他锁（X-Lock） | 独占锁定，同一时间只能有一个事务持有 | 写操作（UPDATE、DELETE、INSERT） |
| 共享锁（S-Lock） | 共享锁定，多个事务可以同时持有 | 读操作（需要保证数据一致性时） |
| 行锁 | 只锁定被访问的行 | 并发度要求高的场景 |
| 表锁 | 锁定整个表 | 批量操作或低并发场景 |
| 意向锁 | 表示事务想要获取的锁类型 | 协调行锁和表锁之间的关系 |

## 锁兼容性矩阵

| 请求锁类型 | 现有共享锁 | 现有排他锁 |
|-----------|-----------|-----------|
| 共享锁 | 兼容 | 冲突 |
| 排他锁 | 冲突 | 冲突 |