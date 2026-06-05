#!/bin/bash
# trust-guard/scripts/diff-guard.sh
# Compares the actual diff against intended changes.
# Usage: diff-guard.sh <file> "<intended_change_description>"

FILE="${1:?Usage: diff-guard.sh <file> <intent_description>}"
INTENT="${2:-}"

echo "═══ Diff vs Intent Analysis ═══"
echo "File: $FILE"
echo ""

# Show what actually changed
echo "--- Actual Diff ---"
git diff "$FILE" 2>/dev/null | head -80 || echo "(no git diff available — file may be untracked)"

echo ""
echo "--- Intent ---"
echo "$INTENT"

echo ""
echo "--- Quick Checks ---"

# Check 1: Diff is non-empty (something actually changed)
DIFF_LINES=$(git diff "$FILE" 2>/dev/null | wc -l || echo "0")
if [ "$DIFF_LINES" -eq 0 ]; then
  echo "WARN: Diff is empty — no changes detected despite edit"
  echo "      This is the classic silent failure pattern."
  echo "      Action: re-read the file, re-apply the edit with verified old_string."
  exit 2
else
  echo "PASS: Diff contains $DIFF_LINES lines of changes"
fi

# Check 2: Diff contains additions (not just deletions)
ADDITIONS=$(git diff "$FILE" 2>/dev/null | grep -c "^+" || echo "0")
if [ "$ADDITIONS" -eq 0 ]; then
  echo "WARN: Diff has no additions — only deletions. Intent mismatch?"
fi

# Check 3: No conflict markers in diff
if git diff "$FILE" 2>/dev/null | grep -qE "^[<>]{7}"; then
  echo "FAIL: Conflict markers in diff — resolution incomplete"
  exit 3
fi

echo ""
echo "Done. Review the actual diff above against the stated intent."
echo "Ask: Does the change match what was requested?"
