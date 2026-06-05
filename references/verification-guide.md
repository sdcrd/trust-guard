# Trust Guard — Verification Guide

How to verify each Claude Code tool type after execution.

## Why Verification Matters

Claude Code's Edit tool has **zero built-in post-edit verification**. The tool returns success based on:
1. old_string was found (at least once)
2. new_string was written

But it does NOT check:
- All call sites were updated
- The edit actually persisted to disk
- The file wasn't modified by something else
- The edit didn't break syntax

## Verification by Tool Type

### Write
```
Risk: LOW — write is relatively reliable
Verify: re-read first 10 lines, check line count matches expected, grep for key content
```

### Edit
```
Risk: MEDIUM — can fail silently on whitespace/partial match
Verify: grep for new_string (must exist), grep for old_string (must not exist),
        for multi-call-site: grep count of new_string = expected call sites
```

### MultiEdit
```
Risk: HIGH — partial application common
Verify: verify EACH edit in the batch independently
```

### Task (Subagent)
```
Risk: HIGH — worst offender for silent failures
Verify: check ALL claimed output files exist and are non-empty,
        re-read any file the subagent claimed to modify
```

### MCP Tool Writes
```
Risk: MEDIUM-HIGH — errors may not propagate
Verify: always re-read after MCP writes, stat the file for modification time
```

## Pre-Commit Trust Gate

Before `git commit`, run:
```bash
bash scripts/trust-check.sh --pre-commit --min-score 70
```

If score < 70: investigate each failed file. Re-read, compare with git diff, verify intent matches output.

## Continuous Trust Monitoring

For long sessions (>30 turns), trust scores tend to decline as model reliability drops. Combine with `/drift-guard` for full session health monitoring.

Trust score trend alert: if average trust score drops >15 points in 10 turns, session may be degrading.
