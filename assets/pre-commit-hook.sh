#!/bin/bash
# trust-guard/assets/pre-commit-hook.sh
# Drop into .git/hooks/pre-commit to enforce trust gate before every commit.
# Install: cp assets/pre-commit-hook.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit

echo "🛡️  Trust Guard — Pre-Commit Gate"

# Find trust-guard scripts relative to project root
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
TRUST_CHECK="$PROJECT_ROOT/.agents/skills/trust-guard/scripts/trust-check.sh"

# Fallback: search for trust-check.sh
if [ ! -f "$TRUST_CHECK" ]; then
  TRUST_CHECK=$(find "$PROJECT_ROOT" -name "trust-check.sh" -path "*/trust-guard/*" 2>/dev/null | head -1)
fi

if [ ! -f "$TRUST_CHECK" ]; then
  echo "⚠️  Trust Guard scripts not found. Skipping trust gate."
  echo "   Install: npx skills add emkaru/trust-guard"
  exit 0
fi

# Run trust check on staged files
STAGED_FILES=$(git diff --cached --name-only | tr '\n' ' ')

if [ -z "$STAGED_FILES" ]; then
  echo "✅ No staged files to check."
  exit 0
fi

FAILED=0
for file in $STAGED_FILES; do
  if [ -f "$file" ]; then
    bash "$TRUST_CHECK" --file "$file" --min-score 70 || FAILED=$((FAILED + 1))
  fi
done

if [ "$FAILED" -gt 0 ]; then
  echo ""
  echo "🛑 Trust Gate FAILED — $FAILED file(s) below trust threshold."
  echo "   Review the files above. Re-verify edits, fix issues, and try again."
  echo "   To bypass (NOT RECOMMENDED): git commit --no-verify"
  exit 1
fi

echo "✅ Trust Gate PASSED — all files verified."
exit 0
