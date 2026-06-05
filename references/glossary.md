# Trust Guard — Glossary

## Core Terms

| Term | Definition |
|------|-----------|
| **Silent Failure** | Edit/Write tool reports success but the change did not persist to disk. The most dangerous failure mode because neither the agent nor the user knows it happened. |
| **Trust Score** | 0-100 rating of how confident we are that an edit actually applied. Based on post-edit verification checks. 100 = all checks pass. 0 = file unchanged. |
| **Post-Flight Verification** | Checks performed AFTER an edit to confirm it applied. The core of Trust Guard. |
| **Pre-Flight Check** | Checks performed BEFORE an edit: reading the file, counting old_string occurrences, noting multi-site patterns. |
| **Ghost Write** | Subagent (Task tool) claims to write a file, but the file is empty or unchanged. Confirmed pattern in GitHub issue #64171. |
| **Partial Application** | When editing a string that appears in multiple locations, the Edit tool updates some call sites but not others. Reports success. |
| **Call Site** | A location in code where a particular string, function, or pattern appears. Multi-call-site edits are the highest risk for partial application. |
| **old_string** | The exact string the Edit tool searches for to replace. Must match byte-for-byte including whitespace. |
| **new_string** | The replacement text the Edit tool writes in place of old_string. |
| **MultiEdit** | Claude Code tool that performs multiple edits in a single call. Higher risk than single Edit because partial application within the batch is common. |

## Verification Check Types

| Check | What It Does | Trust Score Impact |
|-------|-------------|-------------------|
| **Content Exists (Check A)** | Grep for new content fragment in target file | -90 if not found (critical) |
| **Old Content Removed (Check B)** | Grep for old content fragment — must be gone | -40 if still present |
| **Multi-Site Count (Check C)** | Compare new content occurrence count with expected | -40 if mismatch |
| **File Integrity (Check D)** | Check for merge conflicts, empty files, syntax errors | -10 to -30 per issue |
| **Subagent Output (Check E)** | Verify every file a subagent claims to have written | -90 if ghost write (critical) |
| **MCP Write (Check F)** | Re-read after MCP tool writes | -30 if not verified |

## Trust Score Ranges

| Range | Label | Meaning |
|-------|-------|---------|
| 95-100 | TRUSTED | All checks passed. Proceed. |
| 80-94 | TRUSTED | Minor concerns only. Content verified. |
| 65-79 | SUSPECT | Something ambiguous. Re-verify before next step. |
| 40-64 | UNTRUSTED | Partial application. Old content remains. Re-apply edit. |
| 10-39 | BROKEN | Edit reported success but verification found no evidence of change. |
| 0-9 | CRITICAL | File unchanged. Tool claimed success but nothing happened. |

## Failure Pattern Names

| Pattern | Description |
|---------|-------------|
| **Partial Match** | old_string matches but only partially — some occurrences updated, some not |
| **Ghost Write** | Subagent claims success, file is empty |
| **Worktree Confusion** | Edit applies to wrong git worktree |
| **Multi-Edit Partial** | Some edits in a MultiEdit batch fail silently |
| **MCP Silence** | MCP write error not propagated to agent |
| **Read-Skip** | Edit performed without reading file first — 33.7% of edits |
| **Whitespace Invisibility** | Tabs vs spaces mismatch breaks old_string match |
| **Encoding Mismatch** | BOM or line ending differences break match |
| **Concurrent Overwrite** | Two agents or agent+human edit same file |
| **Permission Denied** | OS blocks write, tool reports success |
| **Disk Full** | Write truncated by disk space or quota |
| **Symlink Redirect** | Edit writes through symlink to unexpected location |

## Architecture Terms

| Term | Definition |
|------|-----------|
| **Agent-Native Verification** | Verification performed by the AI agent using its own built-in tools (Read, Grep, Bash) — no external scripts or packages. |
| **Optional Tools** | Human-run shell scripts in `tools/` that the agent never executes. Provided for developers who want terminal-based verification. |
| **Progressive Disclosure** | Agent Skills spec pattern: SKILL.md loads on activation, reference files load on demand. Keeps context small. |
| **Trust Gate** | A checkpoint that blocks progress until trust score meets threshold. Pre-commit trust gate blocks commit if score too low. |
