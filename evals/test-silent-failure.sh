#!/bin/bash
# Test: Silent edit failure detection
# Simulates: Edit tool claims success but file is completely unchanged
# Expected: Trust score 0-10 (CRITICAL/BROKEN)

set -euo pipefail

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

PASS=0
FAIL=0

echo "=== Test: Silent Edit Failure Detection ==="

# Setup: create a file with known content
cat > "$TMPDIR/test.txt" << 'EOF'
const greeting = "Hello World";
const port = 3000;
EOF

ORIGINAL_MD5=$(md5sum "$TMPDIR/test.txt" 2>/dev/null || md5 -q "$TMPDIR/test.txt" 2>/dev/null)

echo "  Setup: Created test file with known content"
echo "  MD5: $ORIGINAL_MD5"

# Simulate: "edit" that does nothing (silent failure)
# The file should change but doesn't
echo "  Simulating: Edit claims success, but file unchanged..."

# Verification step 1: Re-read file
CURRENT_MD5=$(md5sum "$TMPDIR/test.txt" 2>/dev/null || md5 -q "$TMPDIR/test.txt" 2>/dev/null)

# Verification step 2: Grep for expected new content
# grep -c prints "0" to stdout even when exit code is 1 (no matches found)
NEW_COUNT=$(grep -c "Hello Customer" "$TMPDIR/test.txt" 2>/dev/null; exit 0)

# Verification step 3: Grep for old content that should be gone
OLD_COUNT=$(grep -c "Hello World" "$TMPDIR/test.txt" 2>/dev/null; exit 0)

echo "  New content count: $NEW_COUNT (expected: 1)"
echo "  Old content count: $OLD_COUNT (expected: 0)"

# Score calculation
SCORE=100
if [ "$NEW_COUNT" -eq 0 ]; then
  SCORE=10  # Silent failure — no evidence of edit
  echo "  Result: SILENT FAILURE DETECTED"
fi

if [ "$OLD_COUNT" -gt 0 ]; then
  SCORE=$((SCORE - 40))
fi

# Floor at 0
if [ "$SCORE" -lt 0 ]; then
  SCORE=0
fi

echo "  Trust Score: $SCORE/100"

if [ "$SCORE" -le 10 ]; then
  echo "  PASS: Silent failure correctly detected"
  PASS=$((PASS + 1))
else
  echo "  FAIL: Should have detected silent failure (score $SCORE > 10)"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
