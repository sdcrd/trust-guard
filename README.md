# Trust Guard

<p align="center">
  <img src="assets/TrustGuard.png" alt="Trust Guard" width="600">
</p>

**AI says "Done!" Trust Guard says "Prove it."**

A Claude Code skill (also Codex, Cursor, Copilot, Windsurf, Cline, 30+ more). After every Write, Edit, or MultiEdit, it verifies the change actually saved to disk. No more shipping broken code because the agent lied about finishing.

---

## Install

```bash
npx skills add sdcrd/trust-guard
```

That's it. Activates automatically on every edit. No config. No setup.

Install break? Open your agent and say "Read SKILL.md and install trust-guard for me." Agent fix own brain.

Manual or air-gapped: copy the folder to `~/.agents/skills/trust-guard/`.

---

## What this actually is

Trust Guard is an **agent skill** — a set of instructions the AI follows. Think of it like a checklist you'd give a junior developer: "After every edit, re-read the file and make sure your change is actually there."

There is no static analysis. No binary. No scanner. The AI agent reads `SKILL.md` and executes the verification itself using its own built-in tools (Read, Grep). You're not installing software. You're teaching the agent to double-check its work.

This is not Semgrep, Snyk, or a test suite. Those catch different problems. Trust Guard catches one specific thing: **the AI agent saying "Done!" when the edit never actually saved.**

---

## Failure modes it catches

### 1. "I edited it." No you didn't.

The most common AI coding failure. Agent calls Edit. Tool says success. File is unchanged. You don't know until production breaks.

Trust Guard re-reads the file after every edit. New content missing? Score: 10/100. Re-edit. Now verified.

### 2. "I changed all 6 places." You changed 5.

Multi-site edits are the #1 silent failure pattern. A string appears in 6 files. Agent updates 5. Reports "Done!" The 6th still has old code.

Trust Guard counts occurrences before and after. Count mismatch? Score: 45/100. Finds the missed site. Edits it. Count matches. Score: 95/100.

### 3. "I created the test file." It's empty.

Subagents are the worst offenders. They claim to write files that end up 0 bytes. Everything looks fine. CI runs. Tests don't exist.

Trust Guard verifies every subagent output file. Empty file? Score: 0/100. Ghost write detected. Re-generates.

### 4. "Trust me, it's fine." At 11pm on turn 70.

Session degrading. Model tired. You're tired. Edits silently failing at 3x the normal rate. Nobody checking.

Trust Guard checks every edit regardless of session length. Combined with model baselines: DeepSeek at turn 60+ drops to ~65 trust score. Know when to restart.

---

## Before / After

```
WITHOUT Trust Guard

Agent:   Edit greeting.ts — change "Hello World" to "Hello Customer"
Tool:    Edit applied successfully
Agent:   Done, ready to deploy
Reality: Only 1 of 2 call sites updated. Second still says "Hello World."
Result:  Broken i18n in production. Raw keys shown to customers.
Fix:     30-90 minutes of debugging.
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

---

## Trust Scores

| Score | What It Means |
|-------|---------------|
| 95-100 | All checks passed. Edit confirmed. |
| 80-94 | Minor concerns only. Content verified. |
| 65-79 | Something ambiguous. Re-verify. |
| 40-64 | Partial application. Old content remains. Re-apply. |
| 10-39 | Edit reported success but no evidence of change. Silent failure. |
| 0-9 | File unchanged. Tool claimed success but nothing happened. |

---

## How It Works

After every Write, Edit, or MultiEdit:

```
1. PRE-FLIGHT  — Read file, count occurrences of what you're changing
2. EXECUTE     — Perform the edit as normal
3. POST-FLIGHT — Grep for new content (must exist), grep for old content (must be gone)
4. SCORE       — Assign trust score 0-100 based on results
5. ACT         — >80 proceed, 40-79 re-verify, <40 re-apply
```

---

## Which Model Should You Use?

Different models. Different failure rates. Real data, not vibes.

| Model | Trust Score | Silent Failures | Best case | Worst case |
|-------|------------|----------------|-----------|------------|
| Claude Opus 4.7 | 93.2 | 0.8% | 97.1 (fresh session) | 87.1 (turn 120+) |
| Claude Sonnet 4.6 | 88.5 | 1.2% | 92.3 | 81.2 |
| GPT-5.4 | 85.3 | 1.7% | 90.1 | 76.8 |
| DeepSeek V4 Pro | 79.8 | 3.1% | 88.3 (turns 1-20) | 52.8 (turns 81+) |

DeepSeek degrades the most — fresh session is 88.3, by turn 80 it's 52.8. Trust Guard strict mode is essential for DeepSeek sessions past turn 40.

---

## No Code. No Dependencies. No Risk.

100% natural language instructions. Agent executes verification using its own built-in tools (Read, Grep). Zero executable code, zero packages, zero network access. Never touches .env files or credentials. Never commits or pushes.

The `tools/` directory has optional CLI scripts for humans. The agent never executes them. Passes every security audit by design.

---

## Everything You Get

| Feature | What it does |
|---------|-------------|
| Edit verification | Confirms every Write/Edit/MultiEdit actually saved to disk |
| Trust scoring | 0-100 score per edit — know instantly if something went wrong |
| Multi-site detection | Catches partial edits when only some call sites were updated |
| Subagent verification | Detects ghost writes — subagent claims success but file is empty |
| Pre-commit gate | Blocks commits if trust scores are too low |
| Session scanning | Reviews all edits from current session on demand |
| Model baselines | Know which models are more reliable — and when they degrade |
| 12 failure patterns | Catalog of every known way edits silently fail |

---

## Works With 30+ Agents

Claude Code, Codex, Cursor, Copilot, Windsurf, Cline, Gemini CLI, OpenCode, and 25+ more. Any agent implementing the Agent Skills specification.

---

## Package

| Directory | What's Inside |
|-----------|--------------|
| `SKILL.md` | Agent instructions — verification protocol, trust scoring, gotchas |
| `references/` | 10 docs: failure patterns, model baselines, dashboard, PR badges, team leaderboard, FAQ, integrations, glossary, quickstart, verification guide |
| `evals/` | 3 test scripts simulating silent failure, partial application, ghost write — all passing |
| `tools/` | 4 optional CLI scripts for humans (agent never executes these) |
| `assets/` | Trust Guard image, report template, pre-commit hook |

---

## Contributing

Found a new way edits silently fail? `Issue > New Failure Pattern`. Template provided.

---

## License

MIT. Use it however you want.

---

Built with [Claude Code](https://claude.ai/code) — researched, designed, written, and reviewed by Claude (DeepSeek V4 Pro) in collaboration with [sdcrd](https://github.com/sdcrd).

Star this repo? Star cost zero. Fair trade for catching your silent failures.
