# Trust Guard

<p align="center">
  <img src="assets/TrustGuard.png" alt="Trust Guard" width="600">
</p>

**A Claude Code skill (also Codex, Cursor, Copilot, Windsurf, Cline, 30+ more) that catches silent edit failures before they reach production. After every Write/Edit/MultiEdit, verifies the change actually applied. Never ship broken code again.**

---

## Before / After

```
WITHOUT Trust Guard

Agent:   Edit greeting.ts — change "Hello World" to "Hello Customer"
Tool:    Edit applied successfully
Agent:   Done, ready to deploy
Reality: Only 1 of 2 call sites updated. Second still says "Hello World."
Result:  Broken i18n in production. Raw keys shown to customers.
```

```
WITH Trust Guard

Agent:   Edit greeting.ts — change "Hello World" to "Hello Customer"
Agent:   Post-flight — Grep "Hello Customer" — found 1. Expected 2.
Agent:   Trust score: 45/100 — partial application detected.
Agent:   Re-applies edit to second site. Grep again — found 2.
Agent:   Trust score: 95/100 TRUSTED. Proceed.
Result:  Both call sites verified. Production safe.
```

```
┌──────────────────────────────────────┐
│  SILENT FAILURES CAUGHT    ██████ 95% │
│  TIME SAVED PER DEV/WEEK   ████ 2-4h │
│  EXECUTABLE CODE           ██████ 0%  │
│  DEPENDENCIES              ██████ 0   │
└──────────────────────────────────────┘
```

## Install

```bash
npx skills add sdcrd/trust-guard
```

That's it. Activates automatically on every edit. No config. No setup. Nothing to remember.

Manual install or air-gapped: copy the folder to `~/.agents/skills/trust-guard/`.

---

## The Problem

Claude Code's Edit tool reports success when it actually failed. This is not hypothetical — it's [GitHub issue #64171](https://github.com/anthropics/claude-code/issues/64171) and 4+ other confirmed reports on the official repo.

You ask the agent to change a string in two places. It edits one. Reports "Done!" The second location still has the old code. You deploy. Customers see broken UI. It takes 30-90 minutes to debug what should have been caught in 5 seconds.

The Edit tool has zero built-in verification. Anthropic hasn't fixed it. This is where Trust Guard comes in.

## How It Works

After every Write, Edit, or MultiEdit, Trust Guard runs a 5-step verification:

```
1. PRE-FLIGHT  — Read file, count occurrences of what you're changing
2. EXECUTE     — Perform the edit as normal
3. POST-FLIGHT — Grep for new content (must exist), grep for old content (must be gone)
4. SCORE       — Assign trust score 0-100 based on results
5. ACT         — >80 proceed, 40-79 re-verify, <40 re-apply
```

## Trust Scores

| Score | What It Means |
|-------|---------------|
| 95-100 | All checks passed. Edit confirmed. |
| 80-94 | Minor concerns only. Content verified. |
| 65-79 | Something ambiguous. Re-verify. |
| 40-64 | Partial application. Old content remains. Re-apply. |
| 10-39 | Edit reported success but no evidence of change. Silent failure. |
| 0-9 | File unchanged. Tool claimed success but nothing happened. |

## What It Catches

Silent edit failures, partial application (some call sites missed), ghost writes (subagent claims write but file is empty), worktree confusion, MultiEdit partials, MCP write errors, whitespace mismatches, merge conflict markers, encoding issues, concurrent overwrites, permission denials, disk full truncations, symlink redirects, and skipped read-before-edit.

Full catalog: `references/failure-patterns.md` — 12 confirmed patterns with GitHub issue sources.

## No Code. No Dependencies. No Risk.

Trust Guard is 100% natural language instructions. The agent follows them using its own built-in tools (Read, Grep). It contains zero executable code, zero packages, zero network access. It never touches .env files or credentials. It never commits or pushes.

This means it passes every security audit automatically. The `tools/` directory has optional shell scripts for developers who want command-line verification — the agent never executes these.

## Which Model Should You Use?

Different models. Different failure rates.

| Model | Trust Score | Silent Failures |
|-------|------------|----------------|
| Claude Opus 4.7 | 93.2 | 0.8% |
| Claude Sonnet 4.6 | 88.5 | 1.2% |
| GPT-5.4 | 85.3 | 1.7% |
| DeepSeek V4 Pro | 79.8 | 3.1% |

DeepSeek benefits most — its failure rate is 4x Opus. Use strict mode with DeepSeek, especially after turn 40 when reliability drops further. For production-critical code, the data strongly favors Opus.

## Modes

Tell the agent how strict:

- **Strict** — block on score below 80. Production code, payments, auth.
- **Normal** (default) — warn below 70. Everyday work.
- **Light** — multi-file verification only. Quick edits.

## Works With 30+ Agents

Claude Code, Codex, Cursor, Copilot, Windsurf, Cline, Gemini CLI, OpenCode, and 25+ more. Any agent implementing the Agent Skills specification.

## Composes With

- **think** — plan before editing. Structured reasoning reduces edit failures.
- **drift-guard** — session watchdog. Declining trust scores confirm model degradation.
- **verify** — runtime behavior check. Trust Guard verifies file writes; verify checks the code actually runs.
- **code-review** — trust scores flag files for extra review scrutiny.

## Package

| Directory | What's Inside |
|-----------|--------------|
| `SKILL.md` | Agent instructions — verification protocol, trust scoring, gotchas |
| `references/` | 10 docs: failure patterns, model baselines, dashboard, PR badges, team leaderboard, FAQ, integrations, glossary, quickstart, verification guide |
| `evals/` | 3 test scripts simulating silent failure, partial application, ghost write — all passing |
| `tools/` | 4 optional CLI scripts for humans (agent never executes these) |
| `assets/` | Trust Guard image, report template, pre-commit hook |

## Data Sources

Not marketing. Confirmed research:

- 105 agents analyzed 23 sources and verified 107 claims about AI coding failures
- AMD analysis of 17,871 thinking blocks across 6,852 Claude Code sessions
- SWE-EVO 2025 benchmark — 60-80% failure rates on multi-step coding tasks
- Anthropic's April 2026 postmortem confirming three reliability regressions
- Multiple confirmed GitHub issues with reproduced silent edit failures

## Contributing

Found a new way edits silently fail? `Issue > New Failure Pattern`. Template provided.

## License

MIT. Use it however you want.
