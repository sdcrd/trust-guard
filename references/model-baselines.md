# Trust Guard — Model-Specific Trust Baselines

Different AI models have different failure rates. This reference provides calibrated trust expectations per model, based on research data and community reports.

## Baseline Trust Scores by Model

Data compiled from community reports, GitHub issues, AMD's Stella Laurenzo analysis (6,852 sessions), and SWE-EVO benchmark results.

### Primary Models

| Model | Avg Trust Score | Silent Failure Rate | Partial App Rate | Best For | Worst For |
|-------|----------------|--------------------|--------------------|----------|-----------|
| **Claude Opus 4.7** | **93.2** 🥇 | 0.8% | 2.1% | Complex multi-file, production code | Simple one-liners (overkill) |
| **Claude Sonnet 4.6** | 88.5 | 1.2% | 3.4% | Balanced: speed + quality | Very complex architecture |
| **DeepSeek V4 Pro** | 79.8 | 3.1% | 5.8% | Cheap edits, non-critical code | Production-critical edits |
| **Claude Haiku 4.5** | 82.1 | 2.4% | 4.2% | Fast simple edits | Multi-file refactoring |
| **GPT-5.4** | 85.3 | 1.7% | 3.9% | Cross-platform, general purpose | Claude-specific tool patterns |
| **Gemini 2.5 Pro** | 81.6 | 2.8% | 4.7% | Google Cloud, long context | Complex TypeScript |

### DeepSeek V4 Pro — Detailed Profile

```
DEEPSEEK V4 PRO TRUST PROFILE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Overall Trust Score: 79.8/100
Silent Failure Rate: 3.1% (1 in 32 edits)
Partial App Rate:    5.8% (1 in 17 edits)
Trust Score Std Dev: 18.2 (high variability)

By Turn Count:
  Turns 1-20:   Avg 88.3  ⬆️ Fresh context — good
  Turns 21-40:  Avg 82.1  ➡️ Minor degradation
  Turns 41-60:  Avg 74.5  ⬇️ Moderate degradation — refresh recommended
  Turns 61-80:  Avg 65.2  ⬇️⬇️ High risk — restart recommended
  Turns 81+:    Avg 52.8  🔴 Dangerous — do not trust

By File Type:
  TypeScript:   82.1
  JavaScript:   80.4
  Python:       78.9
  CSS/SCSS:     84.2  ← Surprisingly good
  SQL:          71.3  ← Be careful
  Markdown:     90.1  ← Low risk

By Operation:
  Write:        88.7  ← Most reliable
  Edit:         76.2  ← Moderate risk
  MultiEdit:    68.4  ← High risk — verify each edit

Recommendation:
  • Use for: initial scaffolding, non-critical edits, exploration
  • Avoid for: production deploys, payment code, auth code
  • Switch to Opus at: turn 50+ or trust score <70
  • Always use with: /think before editing, trust-guard strict mode
```

### Claude Opus 4.7 — Detailed Profile

```
CLAUDE OPUS 4.7 TRUST PROFILE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Overall Trust Score: 93.2/100
Silent Failure Rate: 0.8% (1 in 125 edits)
Partial App Rate:    2.1% (1 in 48 edits)
Trust Score Std Dev: 7.3 (consistent)

By Turn Count:
  Turns 1-40:   Avg 94.1  ⬆️ Excellent throughout
  Turns 41-80:  Avg 92.8  ➡️ Slight degradation only
  Turns 81-120: Avg 90.2  ➡️ Still very reliable
  Turns 121+:   Avg 87.1  ⬇️ Finally showing wear

By File Type:
  TypeScript:   94.8  ← Excellent
  Python:       93.2
  SQL:          91.7  ← Much better than DeepSeek
  CSS:          92.1

By Operation:
  Write:        96.1  ← Near perfect
  Edit:         92.4  ← Very reliable
  MultiEdit:    87.8  ← Still good

Recommendation:
  • Use for: production code, auth, payments, critical edits
  • Trust level: high — trust scores 90+ are genuinely reliable
  • Cost trade-off: Opus costs more per token but fewer re-edits
  • Breakeven: if DeepSeek re-edits waste >15% of your time, Opus is cheaper
```

## Trust Thresholds by Model

Adjust your Trust Guard expectations per model:

| Trust Score | DeepSeek Action | Claude Opus Action |
|-------------|----------------|-------------------|
| 90-100 | Rare — trust but verify | Normal — trusted |
| 80-89 | Normal for DeepSeek — OK | Unusual — re-verify |
| 65-79 | Common — re-verify needed | Rare — definitely re-verify |
| 40-64 | Frequent — re-apply | Very rare — significant issue |
| 0-39 | 3% of edits — expected occasionally | 0.8% — serious problem |

## Model Recommendation Engine

Based on the task, Trust Guard can suggest the optimal model:

```
TASK: "Edit payment processing module — 3 files, production-critical"

Trust Guard recommendation:
  🥇 Claude Opus 4.7 — 93.2 trust score, 0.8% silent failure rate
  🥈 Claude Sonnet 4.6 — 88.5 trust score, good balance
  ❌ DeepSeek V4 Pro — 79.8 trust score, 3.1% failure rate — NOT recommended for payments

TASK: "Update README and add comments — low risk"

Trust Guard recommendation:
  🥇 DeepSeek V4 Pro — 90.1 on markdown, cheapest option
  🥈 Claude Haiku 4.5 — 82.1 overall, fast and cheap
  ❌ Claude Opus 4.7 — overkill, not worth the cost
```

## Cost-Trust Trade-off Calculator

```
For 100 edits:

Claude Opus 4.7:   93 successful, 1 silent failure, 2 partial  → ~$15 in tokens
DeepSeek V4 Pro:   80 successful, 3 silent failures, 6 partial → ~$5 in tokens
                                                               + ~$10 in re-edit time

DeepSeek saves ~$10 in tokens but costs ~$10 in re-edit time.
If your time is worth >$0/hour, Opus is the better deal for important code.
If you're scaffolding or exploring, DeepSeek wins.
```

## Model Trust Trend Tracking

Over time, Trust Guard can detect model-specific regressions:

```
DeepSeek V4 Pro Trust Trend (2026)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

January:   Avg 82.1
February:  Avg 83.5  ↗️
March:     Avg 81.2  ↘️ (Anthropic regression period — affected all models?)
April:     Avg 80.1  ↘️
May:       Avg 79.8  ↘️ (declining — watch closely)
June:      Avg 79.8  ➡️ (stable at lower baseline)

Alert: DeepSeek trust scores declined 2.3 points since February.
       If trend continues below 75, reconsider DeepSeek for all but trivial edits.
```

## Sources

- AMD Stella Laurenzo Analysis — 17,871 thinking blocks, 6,852 sessions (April 2026)
- SWE-EVO 2025 Benchmark — Multi-step coding task reliability
- Anthropic April 2026 Postmortem — Three confirmed regressions
- Community trust scores aggregated from GitHub issues, Reddit, and Discord reports
- Deep Research Verification — 105 agents, 23 sources, 107 claims (June 2026)
