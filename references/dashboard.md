# Trust Guard — History Dashboard

Track trust scores across sessions, files, and time. Identifies degradation patterns before they cause problems.

## Dashboard Data Model

Trust history is stored as JSON in `.trust-guard/history.json`:

```json
{
  "version": "1.0",
  "sessions": [
    {
      "session_id": "abc123",
      "date": "2026-06-05T14:30:00Z",
      "model": "deepseek-v4-pro",
      "duration_minutes": 45,
      "files_changed": 12,
      "trust_scores": [
        {"file": "src/auth/login.ts", "score": 95, "tool": "Edit", "timestamp": "2026-06-05T14:32:00Z"},
        {"file": "src/auth/login.ts", "score": 72, "tool": "MultiEdit", "timestamp": "2026-06-05T14:38:00Z"},
        {"file": "src/api/routes.ts", "score": 100, "tool": "Write", "timestamp": "2026-06-05T14:45:00Z"},
        {"file": "src/components/Header.tsx", "score": 45, "tool": "Edit", "timestamp": "2026-06-05T14:52:00Z"}
      ],
      "summary": {
        "avg_score": 78,
        "min_score": 45,
        "max_score": 100,
        "silent_failures": 0,
        "partial_applications": 1,
        "reapplied_edits": 2
      }
    }
  ],
  "aggregates": {
    "total_sessions": 47,
    "total_files_changed": 523,
    "overall_avg_score": 87,
    "trend_7d": "+2.3",
    "trend_30d": "+1.8",
    "worst_file": "src/components/Header.tsx",
    "best_model": "claude-opus-4-7",
    "worst_model": "deepseek-v4-pro"
  },
  "per_file_stats": {
    "src/auth/login.ts": {"edits": 15, "avg_score": 82, "failures": 3, "last_score": 95},
    "src/api/routes.ts": {"edits": 8, "avg_score": 94, "failures": 0, "last_score": 100},
    "src/components/Header.tsx": {"edits": 23, "avg_score": 68, "failures": 7, "last_score": 55}
  }
}
```

## Dashboard Views

### View 1: Session Trust Trend (Last 10 Sessions)

```
Session Trust Scores (Last 10 Sessions)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Session  Date       Model         Score  Trend
───────  ────       ─────         ─────  ─────
abc123   06-05      deepseek-v4   78     ████████████████░░░░
def456   06-04      deepseek-v4   85     █████████████████░░░
ghi789   06-04      claude-opus   92     ██████████████████░░
jkl012   06-03      deepseek-v4   71     ██████████████░░░░░░  ⚠️
mno345   06-03      claude-opus   94     ███████████████████░
pqr678   06-02      deepseek-v4   88     █████████████████░░░
...
─────────────────────────────────────────
7-day average: 84.7  ↗️ +2.1 from previous week
30-day average: 82.3 ↗️ +4.5 from previous month
```

### View 2: Per-File Trust Heatmap

```
File Trust Scores (This Session)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

File                          Score   Edits   Failures   Health
──────────────────────────────────────────────────────────────
src/auth/login.ts             ████████████████████ 95   3    0    🟢
src/api/routes.ts             ████████████████████ 100  1    0    🟢
src/components/Header.tsx     ████████████░░░░░░░░ 55   5    2    🔴
src/utils/helpers.ts          ██████████████████░░ 88   2    0    🟢
src/styles/theme.css          ███████████████████░ 92   1    0    🟢
──────────────────────────────────────────────────────────────
🟢 Healthy (80+)  🟡 Suspect (65-79)  🔴 At Risk (<65)
```

### View 3: Model Comparison

```
Average Trust Score by Model (All Time)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

claude-opus-4-7     ████████████████████ 93.2   (12 sessions, 234 edits)
deepseek-v4-pro     ████████████████░░░░ 79.8   (28 sessions, 412 edits)
claude-sonnet-4-6   ██████████████████░░ 88.5   (7 sessions, 89 edits)
────────────────────────────────────────────
DeepSeek: 13.4 points lower than Opus.
Recommendation: Use Opus for production-critical edits.
```

### View 4: Time-of-Day Trust Pattern

```
Trust Score by Hour of Day
━━━━━━━━━━━━━━━━━━━━━━━━━━━

06:00  ████████████████░░░░  82
08:00  ██████████████████░░  90  ← peak
10:00  ███████████████████░  93  ← peak
12:00  ██████████████████░░  88
14:00  █████████████████░░░  85
16:00  ████████████████░░░░  80
18:00  ██████████████░░░░░░  72  ⚠️
20:00  ████████████░░░░░░░░  65  ⚠️ fatigue zone
22:00  ██████████░░░░░░░░░░  58  🔴 high risk
00:00  ████████░░░░░░░░░░░░  51  🔴 dangerous
────────────────────────────────
Pattern: Trust scores drop 35% after 6pm.
Recommendation: Avoid production edits after 6pm.
```

## Dashboard Generation

The agent can generate these views on demand:

```
/trust-guard dashboard              — All views
/trust-guard dashboard session      — Session trend (View 1)
/trust-guard dashboard files        — Per-file heatmap (View 2)
/trust-guard dashboard models       — Model comparison (View 3)
/trust-guard dashboard time         — Time-of-day pattern (View 4)
```

## Alert Thresholds

Trust Guard can alert when patterns emerge:

| Alert | Trigger | Action |
|-------|---------|--------|
| **File Degradation** | File trust score drops >20 points in 3 edits | Flag file for review |
| **Session Decline** | Avg score drops >15 points in 10 turns | Trigger /drift-guard check |
| **Model Regression** | Model's 7-day avg drops >10 points | Escalate to better model |
| **Time-of-Day Risk** | Current hour is in "danger zone" | Warn before critical edits |
| **Silent Failure Spike** | >2 silent failures in one session | Halt, full restart |
