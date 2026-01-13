# 步骤5：乐观锁实现

## 实验说明
通过简化的并发事务演示乐观锁的核心原理：基于版本号的冲突检测。

### 环境准备
1. 打开两个MySQL终端窗口（终端A和终端B）
2. 两个终端都执行：`USE iso_test;`
3. 设置隔离级别为REPEATABLE READ

## 乐观锁核心概念
- **基于版本号**：通过version字段标识数据版本
- **不主动加锁**：操作时不加锁，提交时检测冲突
- **冲突检测**：通过WHERE条件中的版本号匹配实现
- **适用场景**：读多写少的并发场景

## 实验1：简化版乐观锁演示

### 终端A执行：
```sql
-- 1. 开始事务
START TRANSACTION;

-- 2. 查询数据和版本号
SELECT id, name, stock, version FROM products WHERE id = 1;
-- 记录当前version值，假设为1
```

### 终端B执行：
```sql
-- 1. 开始事务
START TRANSACTION;

-- 2. 查询数据和版本号
SELECT id, name, stock, version FROM products WHERE id = 1;
-- 同样看到version=1
```

### 终端A执行：
```sql
-- 3. 使用版本号更新（直接使用查询到的version值）
UPDATE products SET stock = stock - 10, version = version + 1 WHERE id = 1 AND version = 1;

-- 4. 查看结果
SELECT ROW_COUNT() AS affected_rows; -- 预期返回1

-- 5. 提交事务
COMMIT;
```

### 终端B执行：
```sql
-- 3. 尝试使用相同版本号更新
UPDATE products SET stock = stock - 5, version = version + 1 WHERE id = 1 AND version = 1;

-- 4. 查看结果
SELECT ROW_COUNT() AS affected_rows; -- 预期返回0（更新失败）

-- 5. 查看最新数据
SELECT id, name, stock, version FROM products WHERE id = 1; -- 看到version=2

-- 6. 提交事务
COMMIT;
```

### 观察现象：
- 终端A更新成功，返回`affected_rows = 1`
- 终端B更新失败，返回`affected_rows = 0`
- 乐观锁通过版本号检测到了并发冲突

## 实验2：乐观锁与悲观锁对比（简化版）

### 悲观锁实现：
```sql
-- 终端A：加锁并更新
START TRANSACTION;
SELECT * FROM products WHERE id = 2 FOR UPDATE; -- 加排他锁
DO SLEEP(3); -- 模拟长时间处理
UPDATE products SET stock = stock - 10 WHERE id = 2;
COMMIT;

-- 终端B：尝试更新，会被阻塞
START TRANSACTION;
UPDATE products SET stock = stock - 5 WHERE id = 2; -- 被阻塞3秒
COMMIT;
```

### 乐观锁实现：
```sql
-- 终端A：无锁更新
START TRANSACTION;
SELECT version FROM products WHERE id = 2 INTO @v; -- 假设@v=1
DO SLEEP(3); -- 模拟长时间处理
UPDATE products SET stock = stock - 10, version = version + 1 WHERE id = 2 AND version = @v;
COMMIT;

-- 终端B：同时更新，不会阻塞
START TRANSACTION;
SELECT version FROM products WHERE id = 2 INTO @v; -- @v=1
UPDATE products SET stock = stock - 5, version = version + 1 WHERE id = 2 AND version = @v;
COMMIT;
```

### 观察现象对比：
- **悲观锁**：终端B被阻塞，直到终端A释放锁
- **乐观锁**：终端B不会阻塞，直接返回更新结果

## 乐观锁核心原理总结

### 工作流程
1. **读取版本**：查询数据时获取当前version
2. **执行业务**：进行业务逻辑处理
3. **提交更新**：使用WHERE id=? AND version=? 条件更新
4. **冲突检测**：通过ROW_COUNT()判断是否成功
5. **结果处理**：成功则完成，失败则重试或报错

### 核心SQL语句
```sql
-- 读取版本号
SELECT version FROM products WHERE id = ? INTO @current_version;

-- 乐观锁更新（核心）
UPDATE products 
SET stock = stock - ?, version = version + 1 
WHERE id = ? AND version = @current_version;

-- 检查结果
SELECT ROW_COUNT() AS success; -- 1=成功，0=失败
```

## 乐观锁最佳实践
1. **使用递增版本号**：确保每次更新后版本号唯一且递增
2. **简化更新语句**：避免复杂子查询，使用变量或直接值
3. **添加重试机制**：失败时可重试几次，提高成功率
4. **适合读多写少场景**：减少锁竞争，提高并发性能
5. **业务层处理冲突**：失败时给用户友好提示

## 清理：
无需额外操作
