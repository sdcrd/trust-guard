# Trust Guard — Team Trust Leaderboard

Track trust scores across team members to identify patterns, share best practices, and gamify quality.

## Data Model

Team data stored in `.trust-guard/team.json`:

```json
{
  "team": "emkaru",
  "members": [
    {
      "id": "dev-alice",
      "name": "Alice",
      "sessions": 45,
      "total_edits": 892,
      "avg_trust_score": 91.3,
      "silent_failures_caught": 12,
      "favorite_tool": "Edit",
      "best_category": "frontend",
      "trend": "+2.1"
    },
    {
      "id": "dev-bob",
      "name": "Bob",
      "sessions": 38,
      "total_edits": 654,
      "avg_trust_score": 84.7,
      "silent_failures_caught": 23,
      "favorite_tool": "MultiEdit",
      "best_category": "backend",
      "trend": "-1.3"
    }
  ]
}
```

## Leaderboard Views

### View 1: Trust Champion (Highest Avg Score)

```
🏆 TRUST CHAMPIONS — Highest Average Trust Score
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🥇 Alice     ████████████████████ 91.3  (892 edits, 45 sessions)
🥈 Charlie   ███████████████████░ 89.8  (567 edits, 32 sessions)
🥉 Bob       ██████████████████░░ 84.7  (654 edits, 38 sessions)
4  Diana     █████████████████░░░ 81.2  (423 edits, 28 sessions)
5  Eve       ████████████████░░░░ 78.5  (334 edits, 21 sessions)
```

### View 2: Silent Failure Hunter (Most Failures Caught)

```
🔍 SILENT FAILURE HUNTERS — Most Failures Detected
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🥇 Bob       ████████████████████ 23 caught  (3.5% of edits)
🥈 Alice     ██████████████░░░░░░ 12 caught  (1.3% of edits)
🥉 Diana     ████████████░░░░░░░░ 9 caught   (2.1% of edits)
```

### View 3: Most Improved (30-Day Trend)

```
📈 MOST IMPROVED — 30-Day Trust Score Trend
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🥇 Eve       +5.2  (73.3 → 78.5)
🥈 Charlie   +3.1  (86.7 → 89.8)
🥉 Alice     +2.1  (89.2 → 91.3)
```

### View 4: Tool-Specific Rankings

```
🔧 BEST WITH EDIT TOOL          🔧 BEST WITH WRITE TOOL
━━━━━━━━━━━━━━━━━━━━━━━━━━     ━━━━━━━━━━━━━━━━━━━━━━━
Alice      94.2 avg              Charlie    97.1 avg
Charlie    91.5 avg              Alice     96.8 avg
Bob        86.3 avg              Diana     95.2 avg
```

## Team Insights

Trust Guard can generate team-wide insights:

```
📊 TEAM INSIGHTS — June 2026
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Team Average:         87.2/100
Best Month:           May (89.1)
Most Improved:        Eve (+5.2)
Silent Failure Rate:  2.1% of all edits

Common Patterns:
  • MultiEdit partials are the #1 failure mode (58% of failures)
  • DeepSeek sessions avg 79.8 vs Opus 93.2 (-13.4)
  • Afternoon edits (2-4pm) have highest trust scores
  • Friday 4pm+ edits have 22% lower trust scores

Recommendations:
  • Bob: try /think before MultiEdit — highest partial application rate
  • Eve: switch to Opus for backend edits (DeepSeek avg 72 on backend)
  • Team: consider "no production edits after 5pm Friday" policy
```

## Privacy Note

Team leaderboard data is **local only**. Nothing is sent to any server. The `.trust-guard/team.json` file stays in your project repository. Share it with your team via git, or keep it in `.gitignore` for privacy.

## Gamification Ideas

| Achievement | Criteria |
|-------------|----------|
| 🛡️ **Trust Guardian** | 100+ edits with avg score >90 |
| 🔍 **Failure Hunter** | Caught 20+ silent failures |
| 🎯 **Perfect Session** | Session with avg score 100 across 10+ edits |
| 📈 **Rising Star** | 30-day trend >+5.0 |
| 🏆 **Trust Champion** | Highest team avg score in a month |
| ⚡ **Speed + Trust** | 50+ edits in a session, avg score >85 |
