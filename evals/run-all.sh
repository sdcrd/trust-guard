#!/bin/bash
# Trust Guard — Run all evaluation tests
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PASSED=0
FAILED=0
TOTAL=0

echo "========================================="
echo "  Trust Guard — Evaluation Test Suite"
echo "========================================="
echo ""

for test in "$SCRIPT_DIR"/test-*.sh; do
  TOTAL=$((TOTAL + 1))
  if bash "$test" 2>&1; then
    PASSED=$((PASSED + 1))
    echo "  >>> $test: PASSED"
  else
    FAILED=$((FAILED + 1))
    echo "  >>> $test: FAILED"
  fi
  echo ""
done

echo "========================================="
echo "  Results: $PASSED/$TOTAL passed, $FAILED failed"
echo "========================================="

if [ "$FAILED" -gt 0 ]; then
  exit 1
fi
