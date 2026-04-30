---
description: Java 代码审查 — 支持三层规范体系、批量/交互模式、自动修复与回滚
allowed-tools: Bash(git *), Bash(find *), Bash(grep *), Bash(wc *), Bash(chmod *), Bash(cat *), Read, Edit, Write, Agent, AskUserQuestion
argument-hint: [interactive|fix|rollback|init]
---

Perform Java code review using a three-layer specification system.

## Argument Dispatch

Parse `$ARGUMENTS` to determine the sub-command:

- No arguments or empty → **Batch Scan** mode
- `interactive` → **Interactive** mode
- `fix` → **Fix** mode (select issues to fix from existing report)
- `rollback` → **Rollback** mode (revert applied fixes)
- `init` → **Init** mode (scan project architecture, generate coding standards)

## Reference Files

The following reference files are bundled with this command. Read them as needed:

- `${CLAUDE_PLUGIN_ROOT}/references/bilibili-standards.md` — Bilibili development standards (HIGHEST priority, B-001 ~ B-107)
- `${CLAUDE_PLUGIN_ROOT}/references/alibaba-huangshan.md` — Alibaba Java Handbook Huangshan Edition (BASELINE priority, A-001 ~ A-057)
- `${CLAUDE_PLUGIN_ROOT}/references/review-templates.md` — Output document format templates

Helper script:
- `${CLAUDE_PLUGIN_ROOT}/scripts/diff-helper.sh` — Git diff extraction utilities

## Three-Layer Specification Priority

```
Priority 1 (HIGHEST): Bilibili standards (references/bilibili-standards.md)
Priority 2:           Project standards ({module}/docs/project-standards.md)
Priority 3 (BASELINE): Alibaba Huangshan (references/alibaba-huangshan.md)
```

When rules conflict, higher priority wins. Rules from lower priority that are not overridden still apply.

## Severity Mapping

Map specification markers to severity levels:
- **error**: 【强制】【必须】【绝对禁止】【禁止】
- **warning**: 【推荐】【强烈建议】
- **info**: 【可选】【尽量避免】

## First-Time Setup

Before executing any sub-command, check if this is the first run:

1. Run `bash ${CLAUDE_PLUGIN_ROOT}/scripts/diff-helper.sh base-candidates` to detect candidate base branches
2. Check if any `docs/project-standards.md` exists in the project
3. If not found:
   a. Ask the user to confirm the base branch name (main/master/other)
   b. Run `/java-review init` automatically to scan architecture and generate `docs/project-standards.md` for each module
   c. If user explicitly skips init, create a minimal `docs/project-standards.md` with just the base_branch setting

## Module Confirmation (multi-module projects)

Before scanning, detect and confirm module scope. This applies to EVERY run, not just first-time:

1. **Detect project structure**:
   - Check for `settings.gradle` / `settings.gradle.kts` → Gradle multi-module
   - Check for `pom.xml` with `<modules>` → Maven multi-module
2. **If multi-module**: list all detected modules and ask user to confirm which modules to include in this review
3. **If single-module**: use project root as the only module, no confirmation needed
4. Only scan changed files that belong to confirmed modules

## Batch Scan Mode (default, no arguments)

Execute these steps in order:

1. **Get base branch** from `docs/project-standards.md` frontmatter (`base_branch` field)
2. **Get current branch**: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/diff-helper.sh branch`
3. **Module confirmation**: Run the Module Confirmation steps above to determine review scope
4. **Get changed files**: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/diff-helper.sh files {base_branch}`, filter to confirmed modules only
5. **Read specifications**: Read bilibili-standards.md and alibaba-huangshan.md from references. Read each confirmed module's `docs/project-standards.md` if it exists.
6. **For each changed file**:
   a. Get the diff: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/diff-helper.sh diff {base_branch} {file}`
   b. Read the full file for context
   c. Identify file type and layer (controller/service/dao/entity/mapper XML/SQL etc.)
   d. Review against applicable rules from all three specification layers
   e. For each issue found, record: file, line, rule ID, severity, description, suggested fix
7. **Duplicate code detection (B-107)**: Extract code blocks ≥4 lines from this diff (new/modified lines only). Search the entire module for similar existing code. Only flag duplicates where at least one side is part of this change — skip pre-existing duplicates that were not modified in this branch.
8. **Aggregate similar issues**: Group issues with same rule ID + same fix pattern into groups (G-NNN)
9. **Generate output files** in `{module}/docs/{branch-name}/`:
   - Read `${CLAUDE_PLUGIN_ROOT}/references/review-templates.md` for exact format
   - Write `review-report.md` — issue summary
   - Write `review-fixes.md` — fix comparison with markdown table + unified diff
   - Write `review-changes.patch` — patch file with issue/group markers for selective rollback
10. **Output summary**: Print total issues by severity, list of modules scanned

Do NOT modify any source code in this mode.

## Interactive Mode (`interactive` argument)

1. Execute Batch Scan steps 1-8 (including Module Confirmation)
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
2. **For each confirmed module**, scan `src/main/java/` directory:
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
   c. For unrecognized packages, ask the user via AskUserQuestion
3. **Scan dependencies**:
   - Read `build.gradle` or `pom.xml` for each module
   - Identify: Spring Boot version, ORM (MyBatis/JPA), cache (Redis), MQ (Kafka/RocketMQ), database
4. **Generate `docs/project-standards.md`** for each module with:
   - Frontmatter: project name, build tool, base branch, timestamps
   - Module structure table
   - Layer architecture table with responsibilities and conventions
   - Tech stack table
   - Project-level coding conventions (inferred from structure)
5. **Ask user to review** the generated standards and confirm

## Cross-Module Duplicate Detection

When duplicate code is detected across modules:

1. Ask user: "检测到跨模块重复代码：{module-A}/{file}:{lines} 和 {module-B}/{file}:{lines}。{module-B} 尚未生成项目编码规范，是否为该模块生成？"
2. If yes: run init for that module, then include cross-module issues in both module reports with cross-references
3. If no: only note the cross-module duplicate as a comment in the current module's report
