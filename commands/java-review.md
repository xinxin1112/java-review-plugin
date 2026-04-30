---
description: Java 代码审查 — 支持三层规范体系、批量/交互模式、自动修复与回滚
allowed-tools: Bash(git *), Bash(find *), Bash(grep *), Bash(wc *), Bash(chmod *), Bash(cat *), Read, Edit, Write, Agent, AskUserQuestion
argument-hint: [interactive|fix|rollback|init]
---

Perform Java code review using a three-layer specification system.

## Phase Gate — EXECUTE FIRST

Check conditions below IN ORDER. Execute ONLY the first matching phase. Ignore all non-matching sections entirely.

| # | Condition | Action |
|---|-----------|--------|
| A | No `docs/project-standards.md` exists anywhere in project | Execute ONLY "Phase A: First-Time Setup" below. Nothing else. |
| B | `docs/project-standards.md` exists | Skip to "Argument Dispatch" and execute the matching mode. |

---

## Phase A: First-Time Setup

**Scope: This is your COMPLETE and ONLY task for this response. There are no follow-up steps.**

1. Run `bash ${CLAUDE_PLUGIN_ROOT}/scripts/diff-helper.sh base-candidates` to detect candidate branches
2. Tell user: "检测到项目尚未初始化 project-standards.md，需要先确认生产分支。"
3. Call AskUserQuestion with the detected branches:
   - If multiple candidates: question="检测到以下候选生产分支，请选择：" with each branch name as an option
   - If one candidate: question="检测到生产分支为 {branch}，是否正确？" with options "是" and "手动输入其他分支"
   - If no candidates: question="请输入项目的生产分支名称：" with options "main", "master", "develop"

**AskUserQuestion is your final action. Do not output anything after it. Your response is complete.**

When the user answers (in their next message), execute `/java-review init` with the selected branch to generate project-standards.md.

---

## Argument Dispatch

Parse `$ARGUMENTS` to determine the sub-command:

- No arguments or empty → **Batch Scan** mode
- `interactive` → **Interactive** mode
- `fix` → **Fix** mode (select issues to fix from existing report)
- `rollback` → **Rollback** mode (revert applied fixes)
- `init` → **Init** mode (scan project architecture, generate coding standards)

## Reference Files

Rule files are split by category under `${CLAUDE_PLUGIN_ROOT}/references/`. Load only the categories relevant to the current file being reviewed (see Rule Loading Mapping Table below).

**Alibaba categories** (`references/alibaba/`):
- `naming.md` — A-001~A-010 命名风格
- `constants.md` — A-011~A-012 常量定义
- `format.md` — A-013~A-015 代码格式
- `oop.md` — A-016~A-023 OOP 规约
- `collections.md` — A-024~A-029 集合处理
- `concurrency.md` — A-030~A-034 并发处理
- `control.md` — A-035~A-038 控制语句
- `exception.md` — A-039~A-043 异常处理
- `logging.md` — A-044~A-046 日志规约
- `unit-test.md` — A-047~A-050 单元测试
- `security.md` — A-051~A-055 安全规约
- `project-structure.md` — A-056~A-057 工程结构（仅 init 时使用）

**Bilibili categories** (`references/bilibili/`):
- `code-commit.md` — B-001~B-006, B-107 代码提交规范
- `db-naming.md` — B-007~B-013 数据库命名规范
- `db-table-design.md` — B-014~B-022 表设计规范
- `db-column-design.md` — B-023~B-031 列设计规范
- `db-index.md` — B-032~B-035 索引+DDL 规范
- `db-sql-dev.md` — B-036~B-055 SQL 开发规范
- `db-recommendations.md` — B-056~B-064 强烈建议+尽量避免
- `db-forbidden.md` — B-065~B-074 绝对禁止
- `sql-writing.md` — B-075~B-084 语句书写规范
- `db-operation.md` — B-085~B-088 程序操作数据库规范
- `behavior.md` — B-089~B-092 行为规范
- `sharding.md` — B-093 分库分表命名
- `field-types.md` — B-102~B-103 常用字段数据类型
- `code-review.md` — B-094~B-106 CR 规范

**Other references:**
- `${CLAUDE_PLUGIN_ROOT}/references/review-templates.md` — Output document format templates

Helper script:
- `${CLAUDE_PLUGIN_ROOT}/scripts/diff-helper.sh` — Git diff extraction utilities

## Three-Layer Specification Priority

```
Priority 1 (HIGHEST): Bilibili standards (references/bilibili/)
Priority 2:           Project standards ({module}/docs/project-standards.md)
Priority 3 (BASELINE): Alibaba Huangshan (references/alibaba/)
```

When rules conflict, higher priority wins. Rules from lower priority that are not overridden still apply.

## Severity Mapping

Map specification markers to severity levels:
- **error**: 【强制】【必须】【绝对禁止】【禁止】
- **warning**: 【推荐】【强烈建议】
- **info**: 【可选】【尽量避免】

## Rule Loading Mapping Table

Do NOT load all rule files for every file. Use this two-level mapping to determine which categories to load:

### Level 1: File Type

| File Pattern | Load Strategy |
|---|---|
| `*.java` | Use Level 2 (layer mapping) below |
| `*.sql` | Alibaba: (none). Bilibili: db-naming, db-table-design, db-column-design, db-index, db-sql-dev, db-recommendations, db-forbidden, sql-writing, field-types, sharding |
| `*.xml` (MyBatis mapper) | Alibaba: (none). Bilibili: db-sql-dev, db-recommendations, db-forbidden, sql-writing |

### Level 2: Java File Layer Mapping

Detect layer from the file's package path (match keywords). Then load:

| Layer | Alibaba | Bilibili |
|---|---|---|
| controller / api | naming, format, oop, control, exception, logging, security | code-commit, code-review |
| service / biz | naming, format, oop, collections, concurrency, control, exception, logging | code-commit, db-operation |
| dao / mapper / repository | naming, format, oop, exception | code-commit, db-naming, db-sql-dev, db-operation |
| entity / model / po | naming, format, oop | code-commit, db-naming |
| dto / vo / request / response | naming, format, oop | code-commit |
| config / configuration | naming, format, security | code-commit |
| common / util / helper | naming, constants, format, oop, collections, concurrency, control | code-commit |
| test (src/test/) | naming, format, unit-test | code-commit |
| (默认/未识别) | naming, constants, format, oop, control, exception, logging | code-commit |

### Caching

Within a single review session, cache already-read rule files. If a category file was loaded for a previous file in the same session, do not re-read it.

### Project Standards Selective Loading

When reading `{module}/docs/project-standards.md`:
1. Always read: frontmatter + module structure table + 项目级编码约定 section
2. Only read the layer section matching the current file's detected layer (e.g., `### 接口层` for controller files)
3. If no section markers found (old format), fall back to reading the entire file

## AskUserQuestion Protocol

Every AskUserQuestion call MUST be your final action in the current response. The runtime cannot render the interactive dialog until your response stream ends. If you generate anything after it, the dialog stays in "pending" state and the user cannot interact with it.

## Module Confirmation (multi-module projects)

Detect and confirm module scope. Behavior differs between first-time init and subsequent runs:

1. **Detect project structure**:
   - Check for `settings.gradle` / `settings.gradle.kts` → Gradle multi-module
   - Check for `pom.xml` with `<modules>` → Maven multi-module
2. **If single-module**: use project root as the only module, no confirmation needed
3. **If multi-module (first-time init)**:
   - List all detected modules
   - Call AskUserQuestion with multiSelect:true to let user select which modules to initialize. Each module name should be an option.
   - **AskUserQuestion is your final action.** When user answers, only init selected modules.
4. **If multi-module (subsequent review runs)**:
   - Identify which modules already have `docs/project-standards.md` (已初始化)
   - Only review changed files belonging to已初始化 modules
   - If diff contains changes in未初始化 modules: call AskUserQuestion to ask "以下模块尚未初始化：{modules}，是否现在初始化？" with options "是，初始化这些模块" and "跳过，只审查已初始化模块".
   - **AskUserQuestion is your final action.** When user answers: yes → init those modules then review; no → skip them.

## Batch Scan Mode (default, no arguments)

Execute these steps in order:

1. **Get base branch** from `docs/project-standards.md` frontmatter (`base_branch` field)
2. **Get current branch**: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/diff-helper.sh branch`
3. **Module confirmation**: Run the Module Confirmation steps above to determine review scope
4. **Get changed files**: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/diff-helper.sh files {base_branch}`, filter to confirmed modules only
5. **For each changed file**:
   a. Get the diff: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/diff-helper.sh diff {base_branch} {file}`
   b. Read the full file for context
   c. **Determine file type and layer**: identify extension (.java/.sql/.xml) and layer from package path (match keywords: controller, service, dao, entity, dto, config, util, test, etc.)
   d. **Load applicable rules**: use the Rule Loading Mapping Table to determine which category files to read from `references/alibaba/` and `references/bilibili/`. Skip files already cached in this session.
   e. **Load project standards selectively**: read only the relevant layer section from `{module}/docs/project-standards.md` (see Rule Loading Mapping Table → Project Standards Selective Loading)
   f. Review against applicable rules from all three specification layers
   g. For each issue found, record: file, line, rule ID, severity, description, suggested fix
6. **Duplicate code detection (B-107)**: Extract code blocks ≥4 lines from this diff (new/modified lines only). Search the entire module for similar existing code. Only flag duplicates where at least one side is part of this change — skip pre-existing duplicates that were not modified in this branch.
7. **Aggregate similar issues**: Group issues with same rule ID + same fix pattern into groups (G-NNN)
8. **Generate output files** in `{module}/docs/{branch-name}/`:
   - Read `${CLAUDE_PLUGIN_ROOT}/references/review-templates.md` for exact format
   - Write `review-report.md` — issue summary
   - Write `review-fixes.md` — fix comparison with markdown table + unified diff
   - Write `review-changes.patch` — patch file with issue/group markers for selective rollback
9. **Output summary**: Print total issues by severity, list of modules scanned

Do NOT modify any source code in this mode.

## Interactive Mode (`interactive` argument)

1. Execute Batch Scan steps 1-7 (including Module Confirmation)
2. For each issue (ordered by severity: error first, then warning, then info):
   a. Display: issue number, severity, file:line, rule reference, description
   b. Show: original code vs suggested fix (markdown table + diff)
   c. Ask user: "修复 / 跳过 / 修改后修复"
   d. If "修复": apply the fix to the source file using Edit tool
   e. If "修改后修复": let user describe changes, then apply
   f. If "跳过": move to next issue
3. After all issues processed, generate the three output files (only including issues that were fixed)
4. Output summary

## Fix Mode (`fix` argument)

1. Read existing `docs/{branch-name}/review-report.md`
2. If not found, tell user to run `/java-review` first
3. Display the issue list from the report
4. Ask user which issues to fix: support individual numbers (#001), ranges (#001-#005), groups (G-001), or "all"
5. For each selected issue:
   a. Read the suggested fix from `review-fixes.md`
   b. Apply the fix to the source file using Edit tool
   c. For group fixes: create new files (e.g., utility classes) first, then replace call sites
6. Update `review-fixes.md` — mark fixed issues
7. Update `review-changes.patch` — append new fix sections with proper issue/group markers
8. Output summary of what was fixed

## Rollback Mode (`rollback` argument)

1. Read existing `docs/{branch-name}/review-changes.patch`
2. If not found, tell user no fixes have been applied
3. Ask user what to rollback:
   - "all" → full rollback: `git apply -R docs/{branch-name}/review-changes.patch`
   - Issue numbers (#001, #003) → extract those sections from patch, write to temp file, `git apply -R`
   - Group (G-001) → extract group section from patch, write to temp file, `git apply -R`
4. After rollback, update `review-fixes.md` and `review-changes.patch` to remove rolled-back content
5. Output summary of what was rolled back

## Init Mode (`init` argument)

1. **Module confirmation**: Run the Module Confirmation steps above to determine which modules to initialize
2. **For each selected module**, scan `src/main/java/` directory:
   a. List all packages using `find {module}/src/main/java -type d`
   b. Auto-classify packages by name:
      - controller, api → 接口层
      - service, biz → 业务逻辑层
      - dao, mapper, repository → 数据访问层
      - validator, checker → 校验层
      - config, configuration → 配置层
      - entity, model, po → 持久化对象
      - dto, vo, request, response → 数据传输对象
      - common, util, helper → 公共工具
      - interceptor, filter, aspect → 切面/拦截器
   c. Collect all unrecognized packages across all modules into a single list
3. **Batch confirm unrecognized packages** (if any):
   - Call AskUserQuestion to present all unrecognized packages in one question. List them in the question text as `{module}/{package-path} → ?`, and provide layer options (接口层/业务逻辑层/数据访问层/公共工具/忽略) for user to choose.
   - **AskUserQuestion is your final action.** When user answers, apply their classifications and continue to step 4.
4. **Scan dependencies**:
   - Read `build.gradle` or `pom.xml` for each module
   - Identify: Spring Boot version, ORM (MyBatis/JPA), cache (Redis), MQ (Kafka/RocketMQ), database
5. **Generate `docs/project-standards.md`** for each module with:
   - Frontmatter: project name, build tool, base branch, timestamps
   - Module structure table
   - Layer architecture table with responsibilities and conventions
   - Tech stack table
   - Project-level coding conventions (inferred from structure)
6. **Ask user to review** the generated standards and confirm

## Cross-Module Duplicate Detection

When duplicate code is detected across modules:

1. Ask user: "检测到跨模块重复代码：{module-A}/{file}:{lines} 和 {module-B}/{file}:{lines}。{module-B} 尚未生成项目编码规范，是否为该模块生成？"
2. If yes: run init for that module, then include cross-module issues in both module reports with cross-references
3. If no: only note the cross-module duplicate as a comment in the current module's report
