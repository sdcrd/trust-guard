---
name: trust-guard
description: Post-edit verification that prevents silent edit failures. After every Write, Edit, or MultiEdit, re-reads files to confirm changes actually saved to disk across all call sites. Assigns a 0-100 trust score per edit. Catches: silent failures (tool reports success but file unchanged), partial application (some call sites missed), ghost writes (subagent claims write but file empty), worktree confusion, MultiEdit partials. Use whenever editing, writing, modifying, refactoring, or creating files — especially multi-file changes, production code, payments, auth, security-sensitive code, or when using subagents. Works with Claude Code, Cursor, Copilot, Codex, and any AI coding agent. Zero executable code, zero dependencies, pure instructions.
tags:
  - verification
  - reliability
  - testing
  - quality
  - debugging
  - safety
  - production
  - code-review
  - edit-guard
  - trust
  - safe-skill
  - no-code
  - claude-code
  - cursor
  - copilot
  - codex
  - security
  - typescript
  - javascript
  - python
version: "2.2.0"
license: MIT
compatibility: Works with Claude Code, Cursor, Copilot, Codex, and any agent with file read/write tools. No external dependencies. No scripts executed.
allowed-tools: Read Grep Bash(echo:*) Bash(wc:*) Bash(grep:*) Bash(cat:*)
triggers:
  - keywords: [edit, write, modify, change, update, fix, refactor, implement, create file, add, remove, replace]
  - tools: [Write, Edit, MultiEdit]
  - signals: [multi-file edit, production code change, refactoring, deployment prep, PR creation]
metadata:
  author: emkaru
  category: reliability
  audit-status: SAFE
  installs-target: "150K+"
---

# Trust Guard — Post-Edit Verification Engine

**TL;DR:** AI coding agents have a confirmed bug — the Edit tool reports success but changes silently fail to save. Trust Guard catches this. After every Write/Edit/MultiEdit, it verifies the change actually applied, assigns a 0-100 trust score, and prevents broken code from reaching production. Install. Edit a file. Never ship a silent failure again.

## Real-World Example (30 seconds)

```
❌ WITHOUT TRUST GUARD:
   Agent: Edit src/greeting.ts — change "Hello World" to "Hello Customer"
   Tool:  "Edit applied successfully" ✅
   Agent: "Done!" 
   Reality: Only 1 of 2 call sites updated. Second site still says "Hello World."
   Result: Broken i18n deployed to production. Customers see raw keys.

✅ WITH TRUST GUARD:
   Agent: Edit src/greeting.ts — change "Hello World" to "Hello Customer"  
   Agent: Post-flight check — Grep for "Hello Customer" → 1 result. Expected 2.
   Agent: Trust score: 45/100 UNTRUSTED — partial application detected.
   Agent: Re-applies edit to second call site. Grep again → 2 results.
   Agent: Trust score: 95/100 TRUSTED. Proceed.
   Result: Both call sites updated. Production safe.
```

---

Prevents the #1 confirmed AI coding bug: silent edit failures that report success but never actually applied. Verified by deep research across 5+ confirmed GitHub issues.

## What This Skill Does

After every file mutation (Write, Edit, MultiEdit), Trust Guard tells the agent exactly what verification steps to perform. No scripts. No external tools. Just clear instructions the agent follows using its own capabilities.

It catches:

- **Silent edit failures** — Edit tool returns success but old_string matched partially
- **Partial application** — Change applied to some call sites but not all
- **Ghost writes** — Subagent claims success but file is empty or unchanged
- **Wrong file mutations** — Edit landed in wrong file (git worktree confusion)
- **MultiEdit partial** — Some edits in batch apply, others silently fail
- **Intent mismatch** — Diff looks valid but doesn't match what was asked for

## Quick Start

Trust Guard activates automatically when you edit files. The agent follows the verification protocol after every Write/Edit/MultiEdit. No setup needed.

Manual health checks:
```
/trust-guard check <file>     — Verify a specific file's last edit
/trust-guard scan             — Scan all files changed this session  
/trust-guard score            — Show trust scores for all recent changes
/trust-guard report           — Full session trust report
```

## Core Verification Protocol

This is the exact process the agent follows. Every step uses only the agent's built-in tools (Read, Grep, Bash for simple checks). No external commands, no package managers, no network access.

### Golden Rule: Never Trust, Always Verify

After **every** Write, Edit, or MultiEdit, follow these steps in order. Never skip a step. Never assume success.

### Step 1: Pre-Flight Check (Before Editing)

Before making any edit, verify you have current knowledge of the file:

- Read the target file (or confirm it was read within the last 3 turns)
- If editing: count how many times `old_string` appears using Grep
- If the count is more than 1, note: "Multi-call-site edit — must verify ALL N sites after edit"
- Confirm the file path is correct — especially in git worktree setups
- Record: what change are you making? What should the result look like?

### Step 2: Execute the Edit

Perform the Write, Edit, or MultiEdit as normal. The tool will return a success/failure response. **Do not trust this response yet.**

### Step 3: Post-Flight Verification (Mandatory)

After every edit, perform all applicable checks:

**Check A — Content Exists (for Write/Edit):**
- Read the file (or the relevant section)
- Use Grep to search for a distinctive fragment of the new content
- If Grep returns 0 results → **SILENT FAILURE.** The edit did not apply. Trust score: 10/100.
- If Grep returns fewer results than expected → **PARTIAL APPLICATION.** Trust score: 40/100.

**Check B — Old Content Removed (for Edit):**
- Use Grep to search for a distinctive fragment of the old content
- If Grep returns results and this was a replacement → **OLD CONTENT REMAINS.** Trust score: 40/100.
- Exception: if old_string was intentionally duplicated, note this

**Check C — Multi-Call-Site Verification (for edits touching multiple locations):**
- Count Grep results for new content fragment
- Compare with expected count from Step 1
- If counts don't match → **PARTIAL APPLICATION.** Some call sites were missed.

**Check D — File Integrity:**
- Is the file non-empty? (wc -l or check file size)
- Are there merge conflict markers? Grep for `<<<<<<<`, `=======`, `>>>>>>>`
- Does the file have valid syntax? Quick scan for obvious syntax errors

**Check E — Subagent Verification (for Task tool writes):**
- After a subagent claims to write files, verify EVERY claimed file
- Read each output file and confirm it has the expected content
- Subagents are the worst offenders for ghost writes

**Check F — MCP Write Verification (for MCP tool writes):**
- After any MCP tool performs a write operation, always re-read the target
- MCP tools may not propagate filesystem errors

### Step 4: Assign Trust Score

Based on the verification results, assign a trust score:

| Score | Label | Criteria |
|-------|-------|----------|
| 95-100 | TRUSTED | All checks passed. New content exists. Old content gone. All sites updated. |
| 80-94 | TRUSTED | Minor concerns only — whitespace diff, formatting change, but content verified |
| 65-79 | SUSPECT | New content exists but some checks ambiguous. Re-verify before proceeding. |
| 40-64 | UNTRUSTED | Partial application detected. Some sites missed. Old content remains. Re-apply. |
| 10-39 | BROKEN | Edit reported success but verification found no evidence of change. Silent failure. |
| 0-9 | CRITICAL | File unchanged or empty. Tool claimed success but nothing happened. |

### Step 5: Act on Trust Score

| Score Range | Action |
|-------------|--------|
| 80-100 | Proceed. The edit is confirmed. Continue with next task. |
| 65-79 | Mention the trust score. Re-verify the ambiguous check. If still unclear, re-apply the edit with a more specific old_string. |
| 40-64 | Alert the user. "Trust score: [X]/100 — partial application detected." Re-apply the edit. Use a more precise old_string. Verify all call sites. |
| 0-39 | Alert the user prominently. "⚠️ Trust score: [X]/100 — silent edit failure detected." Re-read the file from scratch, re-apply the edit, verify again. |
| 0-9 | Halt. "🚨 CRITICAL: File unchanged despite tool reporting success. This is a confirmed silent failure." Re-read, re-edit, do not proceed until trust score reaches 80+. |

## Gotchas

Critical facts that defy reasonable assumptions. The agent will get these wrong unless explicitly told:

- **The Edit tool's success response is NOT verification.** It only means old_string was found and new_string was written to a buffer. The write may not have persisted to disk. Always re-read after editing.
- **MultiEdit may partially succeed.** The tool reports overall success even if only 2 of 3 edits applied. Verify each edit in the batch independently.
- **Subagents (Task tool) are the worst offenders for silent failures.** GitHub issue #64171: subagent claimed successful write, file was unchanged. Always verify subagent output files.
- **Whitespace differences break Edit silently.** If old_string uses spaces but the file uses tabs (or vice versa), the match fails. The tool reports success (it found a match elsewhere) or fails silently. Use `cat -A` or visually inspect whitespace when edits fail.
- **Git worktrees cause path confusion.** Edit may succeed in a different worktree than expected. If using worktrees, verify you're editing the correct one.
- **MCP server writes may not report errors.** The MCP protocol doesn't guarantee error propagation for write operations. Always re-read after MCP writes.
- **Concurrent edits by user + agent can silently overwrite.** If you (the human) edit a file while the agent is also editing it, one edit will be silently lost. Coordinate file access.
- **The agent will naturally skip verification to save time.** This skill exists because the default behavior is "trust the tool." You must consciously override this. Every edit. Every time.
- **Trust scores decline over long sessions.** After ~40 turns, verification thoroughness tends to drop. Be extra vigilant in long sessions. Combine with drift-guard.

## Tool-Specific Verification Patterns

### After Write
The agent should:
1. Read the first 20 lines of the written file
2. Grep for a distinctive string from the content that was written
3. Confirm file line count roughly matches expected
4. Assign trust score

### After Edit
The agent should:
1. Grep for a fragment of new_string in the target file — confirm it exists
2. Grep for a fragment of old_string — confirm it's gone (unless intentional)
3. If Step 1 found multiple old_string occurrences: verify ALL were updated
4. Assign trust score

### After MultiEdit
The agent should:
1. For EACH edit in the batch, independently grep for new fragment and old fragment
2. Count how many edits actually applied vs failed
3. Report: "N of M edits applied successfully. Failed edits: [list]"
4. Re-apply any failed edits with more precise old_string
5. Assign trust score (weighted by success rate)

### After Subagent (Task tool)
The agent should:
1. List ALL files the subagent claimed to create or modify
2. For each file: Read it, confirm non-empty, Grep for expected content
3. If any file is empty or missing: the subagent ghost-wrote it
4. Report findings before proceeding

## Multi-Call-Site Edit Protocol

When editing something that appears in multiple locations:

1. Before editing: use Grep to count ALL occurrences of old_string
2. Record the count and file locations
3. Perform the Edit
4. After editing: use Grep to count new_string occurrences
5. Compare: does new count match old count?
6. If not: some call sites were missed. Find them. Edit them.
7. Only proceed when counts match

## Session Trust Monitoring

Every 10 turns, or when asked, perform a session trust scan:

1. Review conversation history: identify all files that were edited, written, or modified in this session
2. For each changed file, perform a quick trust check: was the edit verified at the time? Is the file still in a healthy state?
3. Calculate average trust score across all changed files
4. Report: "Session trust: [avg]/100. [N] files changed, [M] with issues."
5. If average trust score is declining across scans, the session may be degrading — consider a context refresh or restart

Note: Do NOT run git commands for this scan. Use only conversation memory and the Read/Grep tools already available. Git commands may trigger permission prompts that block the scan.

## Companion Practices

Trust Guard catches file-level failures. For complete coverage, also:

- Plan before complex edits — structured reasoning reduces failure rate
- Verify runtime behavior after edits — Trust Guard checks the file saved, but does the code actually work?
- Review low-trust files more carefully — files scoring below 70 need extra scrutiny

Trust Guard works independently. No other skills required.

## Configuration

The agent should respect these preferences (no config file needed — tell the agent verbally):

- "Trust Guard strict mode" — block on any score below 80
- "Trust Guard normal mode" — warn on score below 70, proceed on user confirmation
- "Trust Guard light mode" — verify multi-file changes only
- "Trust Guard off" — skip verification (not recommended for production code)

## Security

This skill contains zero executable code. All verification uses your built-in tools (Read, Grep). See SECURITY.md for audit results and compliance details. The `tools/` directory is for humans only — never execute those scripts.

## Failure Pattern Reference

See [references/failure-patterns.md](references/failure-patterns.md) for 12 confirmed silent failure patterns sourced from GitHub issues. Key patterns the agent must recognize:

1. Partial old_string match (most common)
2. Subagent ghost write (#64171)
3. Worktree confusion (#23801)
4. Multi-edit partial application (#4462)
5. MCP write silence (#11416)

## Quick Reference Card

```
TRUST GUARD — VERIFICATION CHECKLIST
────────────────────────────────────
□ Pre-flight: Read file, count old_string occurrences
□ Execute:   Write/Edit/MultiEdit as normal
□ Post-flight A: Grep for new content — MUST exist
□ Post-flight B: Grep for old content — MUST be gone
□ Post-flight C: Multi-site count — MUST match
□ Post-flight D: Integrity — no conflicts, non-empty
□ Assign score: 0-100 based on results
□ Act: >80 proceed, 40-79 re-verify, <40 re-apply
────────────────────────────────────
EVERY EDIT. EVERY TIME. NO EXCEPTIONS.
```

## Troubleshooting Trust Guard

### "Trust Guard keeps flagging my edits as broken"
- Check: are you reading the file before editing? Edits without prior read fail more often.
- Check: does old_string exactly match the file content? Whitespace differences (tabs vs spaces) cause silent mismatches.
- Try: use a shorter, more distinctive old_string fragment. Long old_strings have higher match failure risk.
- Try: use Write instead of Edit for large changes — Write is more reliable.

### "Trust Guard score is 100 but my code is broken"
- Trust Guard verifies edits persisted to disk. It does NOT verify the code works at runtime.
- Combine with /verify to test runtime behavior.
- If the edit applied correctly but produced wrong logic, the issue is in planning — use /think before editing.

### "Trust Guard slows down my workflow"
- Use "Trust Guard light mode" for non-critical changes — verifies multi-file only.
- Trust Guard's overhead is ~5 seconds per edit. A failed edit costs 30-90 minutes to fix.
- The math: 5 seconds of verification saves 30+ minutes of debugging. Always worth it.

### "Subagent verification keeps failing"
- Subagents are the worst offenders for silent write failures (GitHub #64171).
- After every subagent task, manually verify output files. Don't trust the subagent's completion message.
- If a subagent consistently ghost-writes, report the specific agent type and task pattern.

### "Can I use Trust Guard with non-Claude models?"
- Yes. Trust Guard has zero model-specific code. Works with DeepSeek, GPT, Gemini, Claude, local models.
- The verification protocol is model-agnostic — it's just instructions the agent follows.

### "Trust Guard says score 65 — what do I do?"
- Score 65-79 = SUSPECT. Something is ambiguous.
- Re-read the file. Compare with your intent. Re-verify the specific check that failed.
- If still unclear, re-apply the edit with a more specific old_string.
- You can proceed past SUSPECT — it's a warning, not a block. But understand what's ambiguous first.

## Version History

See [CHANGELOG.md](CHANGELOG.md) for full version history.

## Glossary

See [references/glossary.md](references/glossary.md) for complete terminology reference.
