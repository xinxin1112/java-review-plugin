# Review Output Templates

These templates define the exact format for java-review output documents. Follow them precisely when generating reports.

## 1. review-report.md Template

``````markdown
# Code Review Report

- **分支:** {current-branch}
- **基准分支:** {base-branch}
- **扫描时间:** {YYYY-MM-DD HH:mm:ss}
- **扫描文件数:** {count}

## 问题汇总

| 级别 | 数量 | 已修复 |
|------|------|--------|
| 🔴 阻断（必须修改） | {n} | {fixed_n} |
| 🟡 警告（建议修改） | {n} | {fixed_n} |
| 🔵 建议（可选优化） | {n} | {fixed_n} |

## 总体评价

{2-3 句话概括本次变更的整体质量、主要风险点和建议优先处理方向}

## 详细问题

### 🔴 阻断问题

#### #{NNN} {brief-title}
- **位置：** `{ClassName}.{methodName}()` — {行为描述}
- **问题描述：** {具体违反了什么规范，为什么是问题}
- **修改建议：** {如何修复}
- **规范：** {rule-id}【{level}】

#### #{NNN} {brief-title}
...

### 🟡 警告问题

#### #{NNN} {brief-title}
- **位置：** `{ClassName}.{methodName}()` — {行为描述}
- **问题描述：** {具体违反了什么规范，为什么是问题}
- **修改建议：** {如何修复}
- **规范：** {rule-id}【{level}】

### 🔵 建议优化

#### #{NNN} {brief-title}
- **位置：** `{ClassName}.{methodName}()` — {行为描述}
- **问题描述：** {具体违反了什么规范，为什么是问题}
- **修改建议：** {如何修复}
- **规范：** {rule-id}【{level}】

## 同类问题组

### G-{NNN}: {description} (共 {count} 处)
- **规范:** {rule-id}
- **涉及:** #{NNN}, #{NNN}, ...
- **修复策略:** {strategy-description}
``````

### Numbering Rules
- Issues: `#001`, `#002`, ... (zero-padded 3 digits)
- Groups: `G-001`, `G-002`, ... (zero-padded 3 digits)
- Severity mapping: `error` → 🔴 阻断, `warning` → 🟡 警告, `info` → 🔵 建议

### Dynamic Update
- When fixes are applied (via `fix` mode), update the "已修复" column in the summary table
- Mark fixed issues with ~~strikethrough~~ on the title line: `#### ~~#{NNN} {title}~~ ✅`

## 2. review-fixes.md Template

``````markdown
# Code Review Fixes

- **分支:** {current-branch}
- **关联报告:** review-report.md

## #{NNN} [{severity}] {brief-description}

**文件:** {relative-path}:{line-number}
**规范:** {rule-id} {rule-title}【{level}】

### 对比
| 原代码 | 修复后 |
|--------|--------|
| `{original-code}` | `{fixed-code}` |

### Diff
```diff
--- a/{file-path}
+++ b/{file-path}
@@ -{start},{count} +{start},{count} @@
 {context-line}
-{removed-line}
+{added-line}
 {context-line}
```

---

## G-{NNN} {description}（组修复）

**修复策略:** {strategy}

**新增文件:** {path} (if applicable)

### 各处修复对比
| 文件 | 原代码 | 修复后 |
|------|--------|--------|
| {file}:{line} | `{original}` | `{fixed}` |
``````

## 3. review-changes.patch Template

``````patch
# java-review patch file
# Generated: {YYYY-MM-DD HH:mm:ss}
# Branch: {current-branch}
# Issues: #{NNN}, #{NNN}, ...
# Groups: G-{NNN}, ...

# --- Issue #{NNN}: {description} ({rule-id}) ---
--- a/{file-path}
+++ b/{file-path}
@@ -{start},{count} +{start},{count} @@
 {context}
-{removed}
+{added}
 {context}

# --- Group G-{NNN}: Issue #{NNN}, #{NNN}, ... ---
# --- G-{NNN} New file: {path} ---
--- /dev/null
+++ b/{file-path}
@@ -0,0 +1,{lines} @@
+{content}

# --- G-{NNN} Replace: {file} ---
--- a/{file-path}
+++ b/{file-path}
@@ -{start},{count} +{start},{count} @@
-{removed}
+{added}
``````

### Patch Conventions
- Each issue separated by `# --- Issue #{NNN}: {desc} ({rule}) ---`
- Group fixes separated by `# --- Group G-{NNN}: Issue #{NNN}, ... ---`
- Sub-sections within groups: `# --- G-{NNN} New file: {path} ---` and `# --- G-{NNN} Replace: {file} ---`
- These comment markers enable selective rollback by parsing specific sections
