#!/bin/bash
# Test: Partial application detection
# Simulates: Edit updates only 1 of 3 call sites
# Expected: Trust score 40-64 (UNTRUSTED)

set -euo pipefail

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "=== Test: Partial Application Detection ==="

# Setup: file with 3 identical call sites
cat > "$TMPDIR/test.txt" << 'EOF'
Line 1: Hello World — This is call site one.
Line 2: Some other content here.
Line 3: Hello World — This is call site two.
Line 4: More unrelated text.
Line 5: Hello World — This is call site three.
EOF

echo "  Setup: File with 3 'Hello World' call sites"

# Pre-flight: count occurrences
OLD_COUNT_PRE=$(grep -c "Hello World" "$TMPDIR/test.txt" || echo "0")
echo "  Pre-flight: $OLD_COUNT_PRE occurrences of 'Hello World'"

# Simulate: Edit that only updates 1 of 3 (partial application)
# Change only the first occurrence
sed -i '0,/Hello World/{s/Hello World/Hello Customer/}' "$TMPDIR/test.txt" 2>/dev/null || \
sed -i '' '1,/Hello World/s/Hello World/Hello Customer/' "$TMPDIR/test.txt" 2>/dev/null

# Post-flight verification
NEW_COUNT=$(grep -c "Hello Customer" "$TMPDIR/test.txt" || echo "0")
OLD_COUNT_POST=$(grep -c "Hello World" "$TMPDIR/test.txt" || echo "0")

echo "  Post-flight: $NEW_COUNT 'Hello Customer' (expected: 3)"
echo "  Post-flight: $OLD_COUNT_POST 'Hello World' remaining (expected: 0)"

# Trust scoring
SCORE=100
if [ "$NEW_COUNT" -lt "$OLD_COUNT_PRE" ]; then
  echo "  PARTIAL APPLICATION: Only $NEW_COUNT of $OLD_COUNT_PRE sites updated"
  SCORE=45
fi

if [ "$OLD_COUNT_POST" -gt 0 ]; then
  echo "  OLD CONTENT REMAINS: $OLD_COUNT_POST sites still have old value"
fi

echo "  Trust Score: $SCORE/100"

if [ "$SCORE" -ge 40 ] && [ "$SCORE" -le 64 ]; then
  echo "  PASS: Partial application correctly flagged as UNTRUSTED"
else
  echo "  FAIL: Expected score 40-64, got $SCORE"
  exit 1
fi
