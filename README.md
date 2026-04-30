# java-review-plugin

Claude Code 插件 — Java 代码审查工具，基于三层规范体系自动扫描代码问题，支持批量/交互模式、自动修复与回滚。

## 特性

- **三层规范体系**：Bilibili 开发规范（最高优先级）> 项目编码规范 > 阿里巴巴 Java 开发手册黄山版（baseline）
- **多种审查模式**：批量扫描、交互式逐个确认
- **选择性修复**：生成报告后由开发者 check，再通过命令选择修复
- **回滚支持**：基于 patch 文件，支持全量回滚、按问题编号回滚、按组回滚
- **项目架构扫描**：自动识别 Gradle/Maven 多模块项目的分层架构，生成项目编码规范
- **重复代码检测**：扫描本次变更中 ≥4 行的代码段是否与模块内已有代码重复，未修改的历史重复跳过（B-107）
- **同类问题聚合**：相同规范 + 相同修复模式的问题归组，统一修复

## 安装

```bash
claude plugin marketplace add github:xinxin1112/java-review-plugin
claude plugin install java-review
```

安装后重启 Claude Code 即可使用。

## 使用

在 Java 项目目录下：

```bash
# 首次使用，扫描项目架构并生成编码规范
/java-review init

# 批量扫描（只生成报告，不修改源码）
/java-review

# 交互式审查（逐个问题确认是否修复）
/java-review interactive

# 根据报告选择性修复
/java-review fix

# 回滚已应用的修复
/java-review rollback
```

## 命令说明

| 命令 | 说明 |
|------|------|
| `/java-review` | 扫描当前分支 vs 基准分支的变更文件，生成审查报告，不修改源码 |
| `/java-review interactive` | 逐个问题展示并确认：修复 / 跳过 / 修改后修复 |
| `/java-review fix` | 读取已有报告，选择要修复的问题编号、范围或组 |
| `/java-review rollback` | 回滚已应用的修复（全量 / 按编号 / 按组） |
| `/java-review init` | 扫描项目架构，生成 `docs/project-standards.md` |

## 输出文件

每次审查在 `{module}/docs/{branch-name}/` 下生成三个文件：

| 文件 | 用途 |
|------|------|
| `review-report.md` | 问题汇总报告，含严重级别、规范引用、同类问题组 |
| `review-fixes.md` | 修复对比文档，原代码 vs 修复后代码的表格和 diff |
| `review-changes.patch` | 完整 patch 文件，支持 `git apply -R` 回滚 |

## 规范体系

**优先级从高到低：**

1. **Bilibili 开发规范**（B-001 ~ B-107）— 代码提交、数据库、SQL 书写、CR 规范等
2. **项目编码规范**（`docs/project-standards.md`）— 由 `/java-review init` 生成，可手动编辑
3. **阿里巴巴 Java 开发手册黄山版**（A-001 ~ A-057）— 命名、OOP、集合、并发、异常、安全等

高优先级规范覆盖低优先级，未被覆盖的规则仍然生效。

## 严重级别

| 级别 | 对应标记 | 含义 |
|------|---------|------|
| error | 【强制】【必须】【绝对禁止】【禁止】 | 必须修复 |
| warning | 【推荐】【强烈建议】 | 建议修复 |
| info | 【可选】【尽量避免】 | 提示信息 |

## License

MIT
