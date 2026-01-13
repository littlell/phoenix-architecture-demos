# 步骤4：MVCC（多版本并发控制）原理演示

## 实验说明
通过并发事务演示MVCC的工作原理，包括多版本数据的生成、版本链的维护以及可见性规则。

### 环境准备
1. 打开两个MySQL终端窗口（终端A和终端B）
2. 两个终端都执行：`USE iso_test;`
3. 设置隔离级别为REPEATABLE READ（InnoDB默认级别）

## MVCC核心概念
- 事务ID（transaction id）：递增的唯一标识符
- 版本链：每行数据的多个版本通过指针链接
- 回滚段：存储旧版本数据
- Read View：决定事务能看到哪些版本的数据

## 实验1：多版本数据的生成与读取

### 终端A执行：
```sql
-- 开始事务
START TRANSACTION;

-- 查询Product A的初始数据
SELECT * FROM products WHERE id = 1;
```

### 终端B执行：
```sql
-- 开始事务
START TRANSACTION;

-- 修改Product A的库存（版本1→版本2）
UPDATE products SET stock = stock - 10, version = version + 1 WHERE id = 1;

-- 提交事务
COMMIT;

-- 再次开始事务，再次修改（版本2→版本3）
START TRANSACTION;
UPDATE products SET stock = stock - 5, version = version + 1 WHERE id = 1;
COMMIT;
```

### 终端A执行：
```sql
-- 再次查询，观察是否能看到新版本
SELECT * FROM products WHERE id = 1;

-- 查看版本号，确认读取的是旧版本
SELECT id, name, stock, version FROM products WHERE id = 1;

-- 提交事务后再次查询
COMMIT;
SELECT * FROM products WHERE id = 1;
```

### 观察现象：
- 终端A在事务期间始终读取到初始版本的数据
- 即使其他事务修改并提交了数据，终端A仍能看到一致的版本
- 事务提交后才能看到最新版本

### 清理：
无需额外操作

## 实验2：MVCC可见性规则演示

### 终端A执行：
```sql
-- 开始事务（事务A）
START TRANSACTION;

-- 查询Product B的数据
SELECT * FROM products WHERE id = 2;
```

### 终端B执行：
```sql
-- 开始事务（事务B）
START TRANSACTION;

-- 修改Product B的数据
UPDATE products SET stock = 150, version = version + 1 WHERE id = 2;

-- 提交事务
COMMIT;
```

### 终端C执行（打开第三个终端）：
```sql
-- 切换到测试数据库
USE iso_test;

-- 开始事务（事务C）
START TRANSACTION;

-- 修改Product B的数据
UPDATE products SET stock = 120, version = version + 1 WHERE id = 2;
```

### 终端A执行：
```sql
-- 再次查询，观察能看到哪个版本
SELECT * FROM products WHERE id = 2;

-- 提交事务
COMMIT;

-- 再次查询，观察最新版本
SELECT * FROM products WHERE id = 2;
```

### 终端C执行：
```sql
-- 提交事务
COMMIT;
```

### 观察现象：
- 终端A在事务期间只能看到初始版本
- 事务提交后能看到终端B提交的版本，但看不到终端C未提交的版本
- MVCC通过Read View机制决定了数据的可见性

### 清理：
无需额外操作

## 实验3：MVCC与锁的协同工作

### 终端A执行：
```sql
-- 开始事务
START TRANSACTION;

-- 使用普通SELECT（MVCC读取，不加锁）
SELECT * FROM products WHERE id = 3;
```

### 终端B执行：
```sql
-- 开始事务
START TRANSACTION;

-- 修改同一行数据
UPDATE products SET stock = stock - 10, version = version + 1 WHERE id = 3;

-- 提交事务
COMMIT;
```

### 终端A执行：
```sql
-- 再次使用普通SELECT（仍能看到旧版本）
SELECT * FROM products WHERE id = 3;

-- 使用加锁读取（能看到最新版本）
SELECT * FROM products WHERE id = 3 FOR UPDATE;

-- 提交事务
COMMIT;
```

### 观察现象：
- 普通SELECT使用MVCC读取，不加锁，能看到事务开始时的版本
- 加锁SELECT会读取最新版本，并加锁
- MVCC实现了读不加锁，提高了并发性能

## MVCC原理总结

1. **版本链生成**：
   - 每次更新数据时，InnoDB会保存旧版本到回滚段
   - 每行数据包含指向旧版本的指针，形成版本链

2. **Read View机制**：
   - 事务开始时生成Read View，包含当前活跃事务列表
   - 可见性规则：
     - 版本的事务ID < 最小活跃事务ID：可见
     - 版本的事务ID > 最大活跃事务ID：不可见
     - 版本的事务ID在活跃列表中：不可见
     - 版本的事务ID不在活跃列表中：可见

3. **隔离级别与MVCC**：
   - READ COMMITTED：每次查询生成新的Read View
   - REPEATABLE READ：事务期间使用同一个Read View

4. **优点**：
   - 读不加锁，提高并发性能
   - 避免了读-写冲突
   - 实现了不同隔离级别的需求

## 清理：
无需额外操作
