# Java Code Review Skill 设计文档

## 概述

创建一个 Claude Code skill `/java-review`，为 Java 项目提供基于三层规范体系的自动化代码审查能力。支持批量扫描与交互式修复两种模式，具备问题报告、修复对比、patch 回滚等完整工作流，以及项目架构自动扫描与编码规范生成功能。

## 1. Skill 结构与文件布局

### 1.1 Skill 目录

```
~/.claude/skills/java-review/
├── SKILL.md                          # 主 skill 定义（命令入口、参数解析、流程控制）
├── references/
│   ├── bilibili-standards.md         # bilibili 开发规范（B-001 ~ B-107，最高优先级）
│   ├── alibaba-huangshan.md          # 阿里巴巴 Java 开发手册黄山版核心规则摘录
│   └── review-templates.md           # 输出文档模板（report / fixes / patch 格式定义）
└── scripts/
    └── diff-helper.sh                # git diff 提取辅助脚本
```

### 1.2 项目运行时目录（在用户项目中生成）

```
{module}/docs/
├── project-standards.md              # /java-review init 生成的项目编码规范
└── {branch-name}/
    ├── review-report.md              # 问题汇总报告
    ├── review-fixes.md               # 修复对比文档
    └── review-changes.patch          # 完整 patch（支持 git apply / git apply -R）
```

### 1.3 SKILL.md frontmatter

```yaml
---
name: java-review
description: Java 代码审查，支持三层规范体系、批量/交互模式、自动修复与回滚
allowed-tools: Bash(git *), Bash(find *), Bash(grep *), Read, Edit, Write, Agent
---
```

## 2. 命令体系与参数设计

### 2.1 子命令一览

| 命令 | 说明 |
|------|------|
| `/java-review` | 默认批量扫描，生成报告（不修改源码） |
| `/java-review interactive` | 交互式逐个问题确认修复 |
| `/java-review fix` | 根据已生成的报告，选择要修复的问题（支持按编号或按组） |
| `/java-review rollback` | 回滚修复（全量或按问题编号） |
| `/java-review init` | 扫描项目架构，生成项目编码规范到模块 `docs/` |

### 2.2 `/java-review`（批量扫描）

1. 首次使用时，确认 main 分支名（`main` / `master` / 其他），持久化到 `docs/project-standards.md`
2. 执行 `git diff {main}...HEAD --name-only -- '*.java' '*.xml' '*.sql'` 获取变更文件列表
3. 对每个变更文件，获取 diff 内容
4. 按三层规范优先级逐条审查
5. 对变更代码中 ≥4 行的连续代码段，在当前模块所有 `.java` 文件中搜索重复代码（B-107）
6. 同类问题聚合（相同规范编号 + 相同修复模式归为一组）
7. 为每个问题标注严重级别（error / warning / info）和规范编号
8. 生成三个文件到 `docs/{branch-name}/`
9. 输出扫描摘要

### 2.3 `/java-review interactive`（交互模式）

1. 执行步骤 1-7 同批量扫描
2. 逐个问题展示：问题描述 → 原代码 → 建议修复 → 规范引用
3. 用户选择：修复 / 跳过 / 修改后修复
4. 所有问题处理完毕后，生成三个输出文件
5. 已修复的问题直接应用到源码

### 2.4 `/java-review fix`（选择性修复）

1. 读取已有的 `docs/{branch-name}/review-report.md`
2. 展示问题列表，用户选择要修复的问题编号（支持多选、全选、按组 G-NNN 选择）
3. 对选中的问题应用修复（同组问题包含公共类创建 + 各处替换）
4. 更新 `review-fixes.md` 和 `review-changes.patch`（追加本次修复内容）

### 2.5 `/java-review rollback`（回滚）

1. 读取 `docs/{branch-name}/review-changes.patch`
2. 两种模式：
   - 全量回滚：`git apply -R review-changes.patch`
   - 按问题编号回滚：解析 patch 中 `# --- Issue #NNN ---` 分隔标记，提取对应段落生成临时 patch 后 `git apply -R`
   - 按组回滚：解析 `# --- Group G-NNN ---` 标记，回滚整组（含公共类和各处替换）
3. 回滚后更新 `review-fixes.md` 和 `review-changes.patch`（移除已回滚内容）

### 2.6 `/java-review init`（项目架构扫描）

1. 识别项目类型（Gradle / Maven）和子模块列表
2. 逐模块扫描 `src/main/java` 下的 package 结构
3. 自动识别分层架构：
   - controller / api → 接口层
   - service / biz → 业务逻辑层
   - dao / mapper / repository → 数据访问层
   - validator / checker → 校验层
   - config / configuration → 配置层
   - entity / model / po → 持久化对象
   - dto / vo / request / response → 数据传输对象
   - common / util / helper → 公共工具
   - interceptor / filter / aspect → 切面/拦截器
4. 扫描依赖（build.gradle / pom.xml）识别技术栈
5. 不确定的 package 通过问答让开发者确认
6. 生成 `docs/project-standards.md`，包含模块划分、分层架构、技术栈、编码约定
7. 持久化基准分支名

## 3. 三层规范优先级与审查规则引擎

### 3.1 规范优先级

```
优先级 1（最高）: bilibili 开发规范（references/bilibili-standards.md）
优先级 2:         项目编码规范（{module}/docs/project-standards.md）
优先级 3（baseline）: 阿里巴巴 Java 开发手册黄山版（references/alibaba-huangshan.md）
```

**冲突处理原则：**

- 高优先级规范覆盖低优先级。如 bilibili 规范要求索引前缀用 `ix_`，阿里巴巴规范要求 `idx_`，以 bilibili 为准
- 低优先级规范中未被高优先级覆盖的规则仍然生效
- 项目级规范可以放宽或收紧 baseline 规则（如某项目允许特定场景使用 SELECT *）

### 3.2 审查范围

按变更文件类型分类审查：

| 文件类型 | 审查重点 |
|---------|---------|
| `.java`（Controller） | 接口规范、参数校验、异常处理、安全性 |
| `.java`（Service） | 业务逻辑、事务管理、异常处理、复杂度 |
| `.java`（DAO/Mapper 接口） | 方法命名、返回类型 |
| `.xml`（MyBatis Mapper） | SQL 规范（B-036 ~ B-055）、索引使用、禁止 SELECT * 等 |
| `.java`（Entity/DTO/VO） | 命名规范、字段类型匹配 |
| `.sql`（DDL/DML） | 建表规范、ALTER 规范、语句书写规范（Section 五全部） |
| `.java`（其他） | 通用编码规范、命名、注释、复杂度 |

### 3.3 严重级别定义

| 级别 | 含义 | 对应规范标记 | 示例 |
|------|------|------------|------|
| **error** | 必须修复 | 【强制】【必须】【绝对禁止】【禁止】 | SELECT *、无主键、ENUM 类型、子查询 |
| **warning** | 建议修复 | 【推荐】【强烈建议】 | 未逻辑删除、数据库排序、提交说明过长 |
| **info** | 提示信息 | 【可选】【尽量避免】 | 冗余索引、浮点型使用、JOIN 查询 |

### 3.4 单文件审查流程

1. 获取文件 diff（新增/修改的行）
2. 识别文件类型和所属层级
3. 加载适用的规范规则集（按文件类型过滤）
4. 按优先级逐条匹配：
   - bilibili 规范中匹配的规则 → 标记规范编号（如 B-039）
   - 项目规范中匹配的规则 → 标记来源
   - 阿里巴巴规范中匹配的规则 → 标记来源
5. 去重：同一问题被多层规范命中时，只保留最高优先级的引用
6. 标注严重级别
7. 生成建议修复代码

### 3.5 重复代码检测（B-107）

**扫描策略分两层：**

1. **diff 内重复** — 本次变更的多个文件之间是否有重复代码（快，默认执行）
2. **全模块重复** — 变更的代码是否与模块内已有代码重复（扫描当前模块所有 `.java` 文件）

**全模块扫描流程：**

1. 从 diff 中提取本次新增/修改的代码块（≥4 行的连续代码段）
2. 在当前模块的所有 `.java` 文件中搜索相似代码段
3. 匹配到相似度高的已有代码时，标记为 B-107 违规
4. 建议抽取公共方法，并指出已有代码的位置

### 3.6 同类问题聚合

扫描完成后、生成报告前，增加聚合步骤：

1. **识别同类问题** — 相同规范编号 + 相同修复模式的问题归为一组（G-NNN）
2. **分析可复用性** — 判断是否可以抽取公共方案：
   - SQL 层面：多处 SELECT * → 各表独立替换
   - Java 层面：多处重复校验逻辑 → 建议抽取公共校验方法/工具类
   - 配置层面：多处相同常量硬编码 → 建议抽取常量类或配置项
3. **在报告中体现聚合关系** — 组内问题统一展示，修复策略统一说明

## 4. 输出文档格式

### 4.1 review-report.md（问题汇总报告）

```markdown
# Code Review Report

- **分支:** feature/order-refactor
- **基准分支:** main
- **扫描时间:** 2026-04-30 15:30:00
- **扫描文件数:** 12
- **问题总数:** 8 (error: 3, warning: 3, info: 2)

## 问题列表

### #001 [error] SELECT * 违规
- **文件:** src/main/resources/mapper/OrderMapper.xml:25
- **规范:** B-039 禁用 SELECT *【必须】
- **说明:** 禁止使用 SELECT * 查询所有字段数据，只查询需要的字段数据

### #002 [error] 使用 ENUM 类型
- **文件:** src/main/resources/sql/V1__create_order.sql:8
- **规范:** B-029 禁用 ENUM【强制】
- **说明:** 列的类型不能使用 ENUM，应使用 TINYINT 替换

## 同类问题组

### G-001: SELECT * 违规 (共 5 处)
- **规范:** B-039
- **涉及:** #001, #003, #007, #009, #011
- **修复策略:** 各文件独立替换为具体字段列表

### G-002: 重复参数校验逻辑 (共 3 处)
- **规范:** B-107
- **涉及:** #004, #006, #008
- **修复策略:** 抽取公共校验方法到 OrderValidator
```

### 4.2 review-fixes.md（修复对比文档）

```markdown
# Code Review Fixes

- **分支:** feature/order-refactor
- **关联报告:** review-report.md

## #001 [error] SELECT * 违规

**文件:** src/main/resources/mapper/OrderMapper.xml:25
**规范:** B-039 禁用 SELECT *【必须】

### 对比
| 原代码 | 修复后 |
|--------|--------|
| `SELECT * FROM order_info WHERE id = #{id}` | `SELECT id, order_no, status, amount, ctime, mtime FROM order_info WHERE id = #{id}` |

### Diff
​```diff
--- a/src/main/resources/mapper/OrderMapper.xml
+++ b/src/main/resources/mapper/OrderMapper.xml
@@ -23,7 +23,7 @@
 <select id="getOrderById" resultType="OrderInfo">
-    SELECT * FROM order_info
+    SELECT id, order_no, status, amount, ctime, mtime FROM order_info
     WHERE id = #{id}
 </select>
​```

---

## G-002 重复参数校验逻辑（组修复）

**修复策略:** 抽取公共校验方法

**新增文件:** src/main/java/com/xxx/common/validator/OrderValidator.java

### 各处修复对比
| 文件 | 原代码 | 修复后 |
|------|--------|--------|
| OrderService.java:45 | `if (amount == null \|\| ...) throw ...` | `OrderValidator.validateAmount(amount);` |
| SkuService.java:32 | `if (amount == null \|\| ...) throw ...` | `OrderValidator.validateAmount(amount);` |
```

### 4.3 review-changes.patch（完整 patch 文件）

```patch
# java-review patch file
# Generated: 2026-04-30 15:30:00
# Branch: feature/order-refactor
# Issues: #001, #002, #005
# Groups: G-002

# --- Issue #001: SELECT * 违规 (B-039) ---
--- a/src/main/resources/mapper/OrderMapper.xml
+++ b/src/main/resources/mapper/OrderMapper.xml
@@ -23,7 +23,7 @@
 <select id="getOrderById" resultType="OrderInfo">
-    SELECT * FROM order_info
+    SELECT id, order_no, status, amount, ctime, mtime FROM order_info
     WHERE id = #{id}
 </select>

# --- Group G-002: Issue #004, #006, #008 ---
# --- G-002 新增文件: OrderValidator.java ---
--- /dev/null
+++ b/src/main/java/com/xxx/common/validator/OrderValidator.java
@@ -0,0 +1,8 @@
+public class OrderValidator {
+    public static void validateAmount(BigDecimal amount) {
+        Preconditions.checkArgument(amount != null && amount.compareTo(BigDecimal.ZERO) > 0,
+            "金额必须大于0");
+    }
+}

# --- G-002 替换: OrderService.java ---
--- a/src/main/java/com/xxx/pur/order/service/OrderService.java
+++ b/src/main/java/com/xxx/pur/order/service/OrderService.java
@@ -43,5 +43,2 @@
-    if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
-        throw new IllegalArgumentException("金额必须大于0");
-    }
+    OrderValidator.validateAmount(amount);
```

**patch 关键设计：**

- 每个问题用 `# --- Issue #NNN ---` 注释分隔
- 组修复用 `# --- Group G-NNN ---` 标记，包含新增文件和各处替换
- 全量回滚：`git apply -R docs/{branch-name}/review-changes.patch`
- 单个回滚：解析 patch 提取指定编号段落，生成临时 patch 后 `git apply -R`
- 组回滚：提取 Group 标记下所有段落，一次性回滚

## 5. 项目架构扫描（init 命令）

### 5.1 扫描流程

1. **识别项目类型**
   - 检测 `build.gradle` / `settings.gradle` → Gradle 多模块
   - 检测 `pom.xml` → Maven 多模块
   - 识别所有子模块列表

2. **逐模块扫描**
   - 扫描 `src/main/java` 下的 package 结构
   - 按 package 名称 + 类注解识别分层架构：
     - controller / api → 接口层
     - service / biz → 业务逻辑层
     - dao / mapper / repository → 数据访问层
     - validator / checker → 校验层
     - config / configuration → 配置层
     - entity / model / po → 持久化对象
     - dto / vo / request / response → 数据传输对象
     - common / util / helper → 公共工具
     - interceptor / filter / aspect → 切面/拦截器
   - 扫描依赖（build.gradle / pom.xml）识别技术栈
   - 扫描配置文件（application.yml / properties）

3. **不确定的 package 通过问答确认**
   - 例："检测到 package com.xxx.pur.order.processor，该层级的职责是什么？"
   - 提供选项：异步任务处理 / 消息消费处理 / 数据加工转换 / 其他

### 5.2 生成的 project-standards.md 格式

```markdown
# 项目编码规范

- **项目名称:** pur-center
- **构建工具:** Gradle
- **基准分支:** main
- **生成时间:** 2026-04-30
- **最后更新:** 2026-04-30

## 模块结构

| 模块 | 路径 | 职责 |
|------|------|------|
| pur-order | app/pur-order | 采购订单 |
| pur-sku | app/pur-sku | 采购商品 |
| pur-requisition | app/pur-requisition | 采购申请 |

## 分层架构

| 层级 | Package | 职责 | 规范要点 |
|------|---------|------|---------|
| 接口层 | controller | HTTP 接口入口 | 禁止包含业务逻辑，必须做参数校验 |
| 业务层 | service | 核心业务逻辑 | 单一职责，方法不超过 80 行 |
| 校验层 | validator | 业务规则校验 | 校验逻辑集中管理 |
| 数据层 | dao | 数据库访问 | 禁止包含业务逻辑 |
| 实体层 | entity | 数据库映射对象 | 与表结构一一对应 |
| DTO 层 | dto | 数据传输对象 | 禁止直接暴露 Entity |
| 工具层 | util | 公共工具方法 | 无状态，可跨模块复用 |

## 技术栈

| 类别 | 技术 | 版本 |
|------|------|------|
| Web 框架 | Spring Boot | 2.7.x |
| ORM | MyBatis-Plus | 3.5.x |
| 缓存 | Redis | - |
| 消息队列 | Kafka | - |
| 数据库 | MySQL 5.7 | - |

## 项目级编码约定

- Controller 层禁止直接调用 DAO，必须通过 Service
- Service 层方法必须添加事务注解（涉及写操作时）
- 所有对外接口必须有参数校验
- Entity 与 DTO 之间使用 MapStruct 或手动转换，禁止直接返回 Entity
```

## 6. 首次使用流程与状态管理

### 6.1 首次使用检测

执行任何 `/java-review` 子命令时，先检测是否已初始化：

- 检测 `{module}/docs/project-standards.md` 是否存在
  - 不存在 → 进入首次使用流程
  - 存在 → 读取配置，正常执行

### 6.2 首次使用流程

1. **确认基准分支** — 检测远程分支，询问用户确认（main / master / 其他）
2. **提示执行 init** — 建议先执行 `/java-review init` 扫描项目架构。也可跳过，直接使用 bilibili 规范 + 阿里巴巴黄山版进行审查

### 6.3 状态持久化

不单独维护状态文件，所有持久化信息存在 `docs/project-standards.md` 的 frontmatter 中：

```yaml
---
project: pur-center
base_branch: main
created: 2026-04-30
updated: 2026-04-30
---
```

### 6.4 多模块处理策略

```
pur-center/
├── app/
│   ├── pur-order/
│   │   └── docs/
│   │       ├── project-standards.md
│   │       └── feature/order-refactor/
│   │           ├── review-report.md
│   │           ├── review-fixes.md
│   │           └── review-changes.patch
│   ├── pur-sku/
│   │   └── docs/
│   │       └── project-standards.md
│   └── pur-requisition/
│       └── docs/
│           └── project-standards.md
```

- 根据 `git diff` 变更文件路径，自动识别涉及哪些模块
- 每个模块独立生成报告到各自的 `docs/{branch-name}/`

### 6.5 跨模块问题处理

检测到跨模块重复代码时，通过问答让开发者决定：

1. 询问是否为未初始化的相关模块生成项目编码规范
2. 选择"是"→ 扫描该模块并生成 `docs/project-standards.md`，跨模块问题分别写入各自模块的报告中，通过交叉引用指向对方
3. 选择"否"→ 仅在当前模块报告中标注跨模块提示

## 7. 规范文件说明

### 7.1 bilibili-standards.md（已完成）

已录入 B-001 ~ B-107，覆盖：

| Section | 内容 | 规则编号 |
|---------|------|---------|
| 三、代码提交规范 | 提交频率、说明前缀、字数、标点、状态变更加锁 | B-001 ~ B-006 |
| B-107 | 重复代码超过 4 行强制抽象 | B-107 |
| 四、数据库规范 | 命名、表设计、列设计、索引、DDL、SQL 开发、强烈建议、尽量避免、绝对禁止 | B-007 ~ B-074 |
| 五、语句书写规范 | CREATE/ALTER/INDEX/SELECT/INSERT/UPDATE/DELETE/其他 | B-075 ~ B-084 |
| 六、程序操作数据库设置规范 | 长连接、TIMEOUT、字符集、禁止程序 DDL | B-085 ~ B-088 |
| 七、行为规范 | 禁止手工访问线上库、大型活动沟通、批量清洗、禁止主库统计 | B-089 ~ B-092 |
| 八、分库分表命名规则 | 自增数字/按年/按月/按天 | B-093 |
| 九、常用字段数据类型范围 | 数值/字符/时间类型参考 | — |
| 十、CR 规范 | 时间点、关注点（设计/功能/复杂度/测试/命名/注释/风格/文档/安全/可重用性等）、总结、执行流程 | B-094 ~ B-106 |
| 十一、注意事项 | 良好氛围、积极态度、享受 CR、编码标准自律 | — |
| B-013 | 个人信息字段命名规范 | B-013 |

### 7.2 alibaba-huangshan.md（待实现）

从阿里巴巴 Java 开发手册黄山版中提取核心规则，作为 baseline。重点章节：

- 编程规约（命名风格、常量定义、代码格式、OOP 规约、集合处理、并发处理、控制语句）
- 异常日志（异常处理、日志规约）
- 单元测试
- 安全规约
- MySQL 数据库（与 bilibili 规范重叠部分以 bilibili 为准）
- 工程结构

### 7.3 review-templates.md（待实现）

定义三个输出文件的标准模板，确保格式一致性。
