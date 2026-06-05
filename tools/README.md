# Tools — Optional Human-Run Scripts

These scripts are for **human developers only.** The AI agent **never executes these.**

They're provided if you want to run trust verification manually in your own terminal. All automated verification is done by the agent following the natural language instructions in SKILL.md.

## Available Tools

| Tool | Purpose | Usage |
|------|---------|-------|
| `verify-edit.sh` | Single-file post-edit verification | `bash tools/verify-edit.sh <file> "<expected_new>" "<expected_old>"` |
| `trust-check.sh` | Full session trust scanner | `bash tools/trust-check.sh --session` |
| `diff-guard.sh` | Diff vs intent comparison | `bash tools/diff-guard.sh <file> "<intent>"` |

## Why Separate?

Trust Guard passes Gen Agent Trust Hub and Socket security audits specifically because these scripts are never executed by the agent. Keeping them in `tools/` with this README maintains that separation clearly.
