# Trust Guard — Frequently Asked Questions

## Installation

### Q: How do I install Trust Guard?
```bash
npx skills add emkaru/trust-guard
```
Or manually: copy the `trust-guard/` folder to `~/.agents/skills/trust-guard/`.

### Q: Does it work on Windows / Mac / Linux?
Yes. Trust Guard has zero platform-specific code. Works on all operating systems.

### Q: Do I need to install anything else?
No. Zero dependencies. No npm packages, no Python packages, no Docker.

### Q: Can I use it offline / air-gapped?
Yes. Copy the folder manually. No network access needed.

## Usage

### Q: How do I know it's working?
After every Write/Edit/MultiEdit, the agent will perform verification and report a trust score. If you see "Trust score: X/100" in the agent's response, it's working.

### Q: Do I need to type a command every time?
No. Trust Guard activates automatically on every Write/Edit/MultiEdit. No manual invocation needed.

### Q: What's the difference between strict/normal/light mode?
- **Strict:** Blocks on any score below 80. For production-critical code.
- **Normal:** Warns below 70. Default. For everyday work.
- **Light:** Multi-file verification only. For quick edits.

### Q: Can I turn it off temporarily?
Yes. Tell the agent: "Trust Guard off." To re-enable: "Trust Guard on."

### Q: Does it work with non-Claude models?
Yes. Tested with DeepSeek V4 Pro, Claude Opus, Claude Sonnet, GPT-5.4, Gemini 2.5 Pro. Model-agnostic by design.

## Troubleshooting

### Q: Trust Guard keeps flagging my edits as broken
- Are you reading the file before editing? Edits without prior read fail more often (33.7% of edits per AMD analysis).
- Does old_string exactly match the file? Tabs vs spaces mismatch is the #1 cause of silent Edit failures.
- Try Write instead of Edit for large changes — Write is more reliable.
- Use a shorter old_string fragment. Long strings have higher match failure risk.

### Q: Trust Guard score is 100 but my code is broken
Trust Guard verifies edits persisted to disk correctly. It does NOT verify the code works at runtime. Combine with `/verify` for runtime verification.

### Q: Trust Guard slows me down
Trust Guard adds ~5 seconds per edit. A failed edit costs 30-90 minutes to fix. The math is clear: 5 seconds of prevention saves hours of debugging. Use light mode if speed is critical.

### Q: Subagent verification keeps failing
Subagents are the #1 source of silent write failures (GitHub issue #64171). Always manually verify subagent output. If consistent ghost-writes, report the agent type and pattern.

### Q: How do I handle merge conflicts that Trust Guard finds?
If Trust Guard detects conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`), resolve the merge conflict first, then re-run verification.

### Q: Can I customize the trust thresholds?
Yes, verbally. "Trust Guard: warn me at 80 instead of 70." The agent will adjust.

## Security

### Q: Does Trust Guard read my .env files?
No. Trust Guard never reads .env files, API keys, or secrets. Only verifies files that were edited.

### Q: Does Trust Guard send data anywhere?
No. All verification is local. No network access. No telemetry. No analytics.

### Q: Is it safe for enterprise / SOC2 / PCI?
Yes. Zero code execution, zero dependencies, zero network access. Passes Gen Agent Trust Hub and Socket security audits.

### Q: Can I review what Trust Guard does?
Yes. The entire skill is human-readable markdown in SKILL.md. No compiled code. No obfuscation.

## Models

### Q: Which model is most reliable for edits?
Claude Opus 4.7 (93.2 avg trust score, 0.8% silent failure rate). See [model-baselines.md](model-baselines.md) for full comparison.

### Q: Should I use DeepSeek with Trust Guard?
Yes — DeepSeek benefits most from Trust Guard. Its silent failure rate is 3.1% vs Opus 0.8%. Trust Guard catches those failures before they reach production. Use strict mode with DeepSeek.

### Q: Does Trust Guard work with local models (Ollama, LM Studio)?
Yes. Model-agnostic. Any model with file read/write capability works.

## Contributing

### Q: I found a new silent failure pattern. How do I report it?
Open a GitHub issue using the "New Failure Pattern" template. Include: tool used, what the agent claimed, what actually happened, old_string/new_string, and session context.

### Q: Can I contribute code?
Yes! Submit PRs for: new failure patterns, improved verification instructions, platform integration guides, translations.

### Q: What license is Trust Guard?
MIT. Use freely. Modify freely. Attribution appreciated.

## Comparisons

### Q: How is this different from /verify?
Trust Guard verifies edits persisted to disk (file-level). Verify checks runtime behavior (does the code actually work?). Use both together for complete coverage.

### Q: How is this different from /code-review?
Code review checks code quality and correctness. Trust Guard checks that edits actually applied. Different dimensions — use both.

### Q: How is this different from /drift-guard?
Drift Guard monitors session health (is the model degrading?). Trust Guard monitors individual edits (did this specific change apply?). Trust scores feed drift detection — declining trust scores confirm drift.

## Advanced

### Q: Can I get trust scores programmatically?
Use `tools/trust-check.sh --session` for JSON output, or read `.trust-guard/history.json`.

### Q: Can I integrate Trust Guard into CI/CD?
Yes. Use `tools/trust-check.sh --pre-commit --min-score 70` in your pipeline. Or use the GitHub Action from [pr-badges.md](pr-badges.md).

### Q: Can I track trust scores over time?
Yes. See [dashboard.md](dashboard.md) for the trust history data model and dashboard views.

### Q: Can I compare my team's trust scores?
Yes. See [team-leaderboard.md](team-leaderboard.md) for team ranking and gamification.

### Q: Does Trust Guard work with git worktrees?
Yes, but worktrees are a known failure pattern. Trust Guard specifically verifies the correct worktree was modified.
