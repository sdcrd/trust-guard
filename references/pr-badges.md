# Trust Guard — PR Trust Badge

Auto-generate a trust score badge for every pull request.

## What It Does

When you create a PR, Trust Guard scans all changed files, calculates an aggregate trust score, and generates a badge that goes in the PR description.

## Badge Output

```
🛡️ Trust Score: 94/100 — TRUSTED
12 files changed | 0 silent failures | 1 re-applied edit
```

Or as a markdown badge:
```markdown
![Trust Score](https://img.shields.io/badge/Trust%20Score-94%2F100-brightgreen)
```

## Trust Score Color Coding

| Score Range | Badge Color | Meaning |
|-------------|-------------|---------|
| 90-100 | 🟢 Bright Green | TRUSTED — All edits verified |
| 75-89 | 🟡 Yellow | SUSPECT — Minor concerns, reviewed |
| 50-74 | 🟠 Orange | UNTRUSTED — Partial applications detected, fixed |
| 0-49 | 🔴 Red | BROKEN — Silent failures detected, needs re-review |

## PR Description Template

When creating a PR, the agent can auto-append:

```markdown
## 🛡️ Trust Guard Report

**Trust Score: 94/100 — TRUSTED**

| Metric | Value |
|--------|-------|
| Files changed | 12 |
| Total edits | 47 |
| Silent failures detected | 0 |
| Partial applications detected | 1 |
| Edits re-applied | 1 |
| Average trust score | 94.2 |
| Lowest trust score | 78 (src/components/Header.tsx) |
| Model used | deepseek-v4-pro |

### Per-File Breakdown

| File | Score | Status |
|------|-------|--------|
| src/auth/login.ts | 95/100 | 🟢 TRUSTED |
| src/api/routes.ts | 100/100 | 🟢 TRUSTED |
| src/components/Header.tsx | 78/100 | 🟡 SUSPECT |
| ... | ... | ... |

### Reviewer Notes
- ✅ No silent failures detected
- ⚠️ src/components/Header.tsx had partial Edit — re-applied, now verified
- 🤖 DeepSeek V4 Pro used — trust baseline 79.8 (+14.4 above model average)
```

## GitHub Action Integration

Create `.github/workflows/trust-guard.yml`:

```yaml
name: Trust Guard PR Check

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  trust-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Trust Guard Scan
        run: |
          echo "## 🛡️ Trust Guard Report" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY

          # Get changed files
          FILES=$(git diff --name-only origin/${{ github.base_ref }}...HEAD)

          # Calculate trust score (simplified — in production, use trust-check.sh)
          SCORE=0
          COUNT=0
          FAILURES=0

          for file in $FILES; do
            if [ -f "$file" ]; then
              COUNT=$((COUNT + 1))
              # Check for merge conflicts
              if grep -qE "^[<>]{7}" "$file" 2>/dev/null; then
                FAILURES=$((FAILURES + 1))
                echo "🔴 $file — MERGE CONFLICT" >> $GITHUB_STEP_SUMMARY
              elif [ -s "$file" ]; then
                echo "🟢 $file — OK" >> $GITHUB_STEP_SUMMARY
              else
                FAILURES=$((FAILURES + 1))
                echo "🔴 $file — EMPTY FILE (possible ghost write)" >> $GITHUB_STEP_SUMMARY
              fi
            fi
          done

          echo "" >> $GITHUB_STEP_SUMMARY
          echo "**Files:** $COUNT | **Issues:** $FAILURES" >> $GITHUB_STEP_SUMMARY

          if [ "$FAILURES" -gt 0 ]; then
            echo "" >> $GITHUB_STEP_SUMMARY
            echo "⚠️ **Trust issues detected. Please review before merging.**" >> $GITHUB_STEP_SUMMARY
            exit 1
          fi

      - name: Post PR Comment
        if: always()
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const summary = fs.readFileSync(process.env.GITHUB_STEP_SUMMARY, 'utf8');
            await github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: summary
            });
```

## Badge in README

Add a live trust score badge to your project README:

```markdown
[![Trust Score](https://trust-guard-badges.vercel.app/api/trust-score/emkaru/kayouni)](https://skills.sh/emkaru/trust-guard)
```

Shows the project's current trust score based on the most recent session data committed to `.trust-guard/history.json`.
