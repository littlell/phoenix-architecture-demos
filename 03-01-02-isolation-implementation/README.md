# 《凤凰架构》3.1.2 实现隔离性 学习实践

## 学习资源说明

本仓库包含了《凤凰架构》3.1.2节"实现隔离性"的实践学习资源，通过逐步实验帮助理解事务隔离性的实现机制。

## 文件结构

```
├── iso_learning_plan.md    # 学习计划和目标
├── step1_init.sql          # 步骤1：基础环境搭建
├── step2_isolation_levels.md # 步骤2：事务隔离级别演示
├── step3_lock_mechanism.md # 步骤3：锁机制实践
├── step4_mvcc.md           # 步骤4：MVCC原理演示
├── step5_optimistic_lock.md # 步骤5：乐观锁实现
└── README.md               # 本说明文档
```

## 环境要求

- MySQL 8.0+
- InnoDB存储引擎（默认）
- 终端工具（如MySQL客户端、Navicat等）

## 学习步骤

### 1. 基础环境搭建

执行 `step1_init.sql` 脚本，创建测试数据库和表：

```bash
mysql -u root -p < step1_init.sql
```

### 2. 逐步实践学习

按照 `iso_learning_plan.md` 中的计划，依次学习每个步骤：

#### 步骤2：事务隔离级别

阅读 `step2_isolation_levels.md`，打开两个终端窗口，按照文档中的步骤执行SQL命令，观察不同隔离级别下的行为差异。

#### 步骤3：锁机制

阅读 `step3_lock_mechanism.md`，通过并发事务演示排他锁、共享锁、行锁与表锁的特性。

#### 步骤4：MVCC原理

阅读 `step4_mvcc.md`，理解多版本并发控制的核心概念和工作原理。

#### 步骤5：乐观锁实现

阅读 `step5_optimistic_lock.md`，学习基于版本号的乐观锁实现和冲突处理机制。

## 学习建议

1. **循序渐进**：按照步骤顺序进行学习，每个步骤理解后再进入下一个步骤
2. **亲自动手**：务必打开两个终端窗口进行并发实验，观察实际效果
3. **记录现象**：将每个实验的观察结果记录下来，加深理解
4. **对比分析**：对比不同隔离级别、不同锁机制的优缺点和适用场景
5. **查阅文档**：遇到不理解的概念，查阅MySQL官方文档或相关资料

## 核心概念回顾

- **事务隔离级别**：READ UNCOMMITTED、READ COMMITTED、REPEATABLE READ、SERIALIZABLE
- **锁机制**：排他锁（X-Lock）、共享锁（S-Lock）、行锁、表锁、意向锁
- **MVCC**：多版本并发控制，通过版本链和Read View实现读不加锁
- **乐观锁**：基于版本号或时间戳，提交时检测冲突

## 额外学习资源

- MySQL官方文档：https://dev.mysql.com/doc/refman/8.0/en/
- 《凤凰架构》官方网站：https://icyfenix.cn/
- InnoDB锁机制详解：https://dev.mysql.com/doc/refman/8.0/en/innodb-locking.html
- MVCC原理深入分析：https://dev.mysql.com/doc/refman/8.0/en/innodb-multi-versioning.html

## 注意事项

1. 实验前确保已备份重要数据
2. 建议在测试环境中进行实验，避免影响生产环境
3. 实验完成后可以删除测试数据库：`DROP DATABASE iso_test;`
4. 如遇到问题，检查MySQL版本和配置是否符合要求

## 学习目标

通过本实践学习，你将能够：

- 理解事务隔离性的实现机制
- 掌握不同隔离级别的特点和适用场景
- 理解锁机制的工作原理和使用方法
- 掌握MVCC的核心概念和实现原理
- 能够根据业务场景选择合适的并发控制机制

祝你学习愉快！