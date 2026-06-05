#!/bin/bash
# Test: Ghost write detection
# Simulates: Subagent claims successful write but file is empty
# Expected: Trust score 0-10 (CRITICAL)

set -euo pipefail

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "=== Test: Ghost Write Detection ==="

# Simulate: Subagent claims to write a file
CLAIMED_FILE="$TMPDIR/output.ts"
echo "  Subagent claims: Created $CLAIMED_FILE with 50 lines"

# The "ghost write" — file doesn't actually exist yet
# (subagent claimed success but nothing was written)

# Trust Guard verification
if [ ! -f "$CLAIMED_FILE" ]; then
  echo "  GHOST WRITE DETECTED: File does not exist despite subagent claim"
  SCORE=0
elif [ ! -s "$CLAIMED_FILE" ]; then
  echo "  GHOST WRITE DETECTED: File exists but is empty"
  SCORE=10
else
  LINES=$(wc -l < "$CLAIMED_FILE")
  if [ "$LINES" -lt 1 ]; then
    SCORE=10
  else
    SCORE=100
  fi
fi

echo "  Trust Score: $SCORE/100"

if [ "$SCORE" -le 10 ]; then
  echo "  PASS: Ghost write correctly detected"
else
  echo "  FAIL: Should have detected ghost write (score $SCORE > 10)"
  exit 1
fi
