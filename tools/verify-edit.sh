#!/bin/bash
# trust-guard/scripts/verify-edit.sh
# Post-edit verification: confirms edit actually applied to file.
# Usage: verify-edit.sh <file> "<expected_new>" "<expected_old_gone>" [--multi]

set -euo pipefail

FILE="${1:?Usage: verify-edit.sh <file> <expected_new> <expected_old_gone> [--multi]}"
EXPECTED_NEW="${2:-}"
EXPECTED_OLD_GONE="${3:-}"
MULTI_MODE="${4:-}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCORE=100
ISSUES=""

# Check 1: File exists and is non-empty
if [ ! -f "$FILE" ]; then
  echo -e "${RED}FAIL: File '$FILE' does not exist${NC}"
  exit 1
fi

if [ ! -s "$FILE" ]; then
  SCORE=10
  ISSUES="$ISSUES FILE_EMPTY"
  echo -e "${RED}CRITICAL: File '$FILE' is empty — silent write failure likely${NC}"
fi

# Check 2: Expected new content exists
if [ -n "$EXPECTED_NEW" ]; then
  NEW_COUNT=$(grep -cF "$EXPECTED_NEW" "$FILE" 2>/dev/null || echo "0")
  if [ "$NEW_COUNT" -eq 0 ]; then
    SCORE=10
    ISSUES="$ISSUES NEW_NOT_FOUND"
    echo -e "${RED}CRITICAL: Expected new content NOT found in $FILE${NC}"
    echo "  Expected: $EXPECTED_NEW"
  else
    echo -e "${GREEN}PASS: New content found ($NEW_COUNT occurrence(s))${NC}"
  fi
fi

# Check 3: Expected old content is gone
if [ -n "$EXPECTED_OLD_GONE" ]; then
  OLD_COUNT=$(grep -cF "$EXPECTED_OLD_GONE" "$FILE" 2>/dev/null || echo "0")
  if [ "$OLD_COUNT" -gt 0 ]; then
    SCORE=$((SCORE - 40))
    ISSUES="$ISSUES OLD_STILL_PRESENT"
    echo -e "${YELLOW}WARN: Old content still found in $FILE ($OLD_COUNT occurrence(s))${NC}"
    echo "  Old fragment: $EXPECTED_OLD_GONE"
    if [ "$MULTI_MODE" == "--multi" ]; then
      echo "  Multi-edit: partial application likely — some call sites missed"
    fi
  else
    echo -e "${GREEN}PASS: Old content successfully removed${NC}"
  fi
fi

# Check 4: File modification time is recent (within last 60 seconds)
if command -v stat &> /dev/null; then
  MTIME=$(stat -c %Y "$FILE" 2>/dev/null || stat -f %m "$FILE" 2>/dev/null || echo "0")
  NOW=$(date +%s)
  AGE=$((NOW - MTIME))
  if [ "$AGE" -gt 120 ]; then
    SCORE=$((SCORE - 20))
    ISSUES="$ISSUES FILE_NOT_RECENT"
    echo -e "${YELLOW}WARN: File not modified recently (${AGE}s ago) — may not reflect latest edit${NC}"
  fi
fi

# Check 5: Line count sanity (file wasn't truncated)
LINE_COUNT=$(wc -l < "$FILE" 2>/dev/null || echo "0")
if [ "$LINE_COUNT" -eq 0 ] && [ -s "$FILE" ]; then
  SCORE=$((SCORE - 10))
  ISSUES="$ISSUES ZERO_LINES"
  echo -e "${YELLOW}WARN: File has content but wc -l reports 0 lines${NC}"
fi

# Summary
echo ""
echo "Trust Score: $SCORE/100"
if [ -n "$ISSUES" ]; then
  echo "Issues: $ISSUES"
fi

if [ "$SCORE" -ge 90 ]; then
  echo -e "${GREEN}Status: TRUSTED${NC}"
  exit 0
elif [ "$SCORE" -ge 70 ]; then
  echo -e "${YELLOW}Status: SUSPECT — re-verify recommended${NC}"
  exit 0
elif [ "$SCORE" -ge 40 ]; then
  echo -e "${YELLOW}Status: UNTRUSTED — re-apply edit${NC}"
  exit 1
else
  echo -e "${RED}Status: BROKEN — silent failure detected${NC}"
  exit 2
fi
