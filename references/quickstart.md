# Trust Guard — 30-Second Quickstart

## Install

```bash
npx skills add emkaru/trust-guard
```

## Verify It Works

1. The agent edits any file
2. Trust Guard automatically verifies the edit
3. Trust score appears in the agent's response
4. That's it. You're protected.

## Your First Trust Score

```
Agent: Edit src/config.ts — change PORT from 3000 to 8080
Agent: Post-flight: Grep for "8080" → found. Grep for "3000" → gone.
Agent: Trust score: 95/100 TRUSTED ✓
```

## Modes

Tell the agent:
- "Trust Guard strict mode" — blocks on any score below 80
- "Trust Guard normal mode" — warns below 70 (default)
- "Trust Guard light mode" — multi-file verification only
- "Trust Guard off" — skip (not recommended)

## What to Expect

- ~5 seconds added per edit (verification time)
- Silent failures caught before they reach production
- 2-4 hours saved per week from prevented debugging
- Works automatically — no manual commands needed

## Next Steps

- Read [verification-guide.md](verification-guide.md) for per-tool protocols
- Read [failure-patterns.md](failure-patterns.md) to learn what gets caught
- Read [integrations.md](integrations.md) for hook configs
- Read [dashboard.md](dashboard.md) for trust score tracking
