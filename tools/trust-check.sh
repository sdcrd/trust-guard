#!/bin/bash
# trust-guard/scripts/trust-check.sh
# Full session trust scanner — verifies all edits made in current session.
# Usage: trust-check.sh [--session] [--pre-commit] [--min-score 70] [--file <path>]

set -euo pipefail

MODE="${1:---session}"
MIN_SCORE="${3:-70}"
TARGET_FILE="${5:-}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

TRUST_DIR=".trust-guard"
mkdir -p "$TRUST_DIR"

SESSION_ID="${CLAUDE_SESSION_ID:-$(date +%Y%m%d-%H%M%S)}"
REPORT_FILE="$TRUST_DIR/session-$SESSION_ID.json"
FAILURES=0
CHECKS=0
TOTAL_SCORE=0

echo -e "${CYAN}═══ Trust Guard — Session Scanner ═══${NC}"
echo ""

# Get list of files changed in this session from git
get_changed_files() {
  if [ -n "${TARGET_FILE:-}" ]; then
    echo "$TARGET_FILE"
  else
    git diff --name-only HEAD 2>/dev/null || echo ""
    git diff --cached --name-only 2>/dev/null || echo ""
    # Also check untracked files
    git ls-files --others --exclude-standard 2>/dev/null || echo ""
  fi
}

scan_file() {
  local file="$1"
  CHECKS=$((CHECKS + 1))

  # Skip deleted files, non-files, binary
  if [ ! -f "$file" ]; then return; fi
  if file "$file" 2>/dev/null | grep -q "binary"; then return; fi

  local file_score=100
  local file_issues=""

  # Check 1: File is readable and has content
  if [ ! -r "$file" ]; then
    echo -e "  ${RED}✗ $file — NOT READABLE${NC}"
    FAILURES=$((FAILURES + 1))
    return
  fi

  # Check 2: File was recently modified (evidence of edit attempt)
  local mtime=""
  if command -v stat &> /dev/null; then
    mtime=$(stat -c %Y "$file" 2>/dev/null || stat -f %m "$file" 2>/dev/null || echo "0")
  fi

  # Check 3: Syntax check where applicable
  case "$file" in
    *.ts|*.tsx)
      if command -v npx &> /dev/null; then
        if npx tsc --noEmit "$file" 2>/dev/null; then
          : # passes
        else
          file_score=$((file_score - 10))
          file_issues="$file_issues TYPECHECK_WARN"
        fi
      fi
      ;;
    *.js|*.jsx)
      if command -v npx &> /dev/null; then
        if npx eslint "$file" --quiet 2>/dev/null; then
          : # passes
        else
          file_score=$((file_score - 5))
          file_issues="$file_issues LINT_WARN"
        fi
      fi
      ;;
    *.py)
      if command -v python3 &> /dev/null; then
        python3 -m py_compile "$file" 2>/dev/null || {
          file_score=$((file_score - 15))
          file_issues="$file_issues PY_SYNTAX_ERR"
        }
      fi
      ;;
  esac

  # Check 4: File has no obvious error markers
  if grep -qE "<<<<<<< |======= |>>>>>>> " "$file" 2>/dev/null; then
    file_score=$((file_score - 30))
    file_issues="$file_issues MERGE_CONFLICT"
    echo -e "  ${RED}✗ $file — MERGE CONFLICT MARKERS FOUND${NC}"
    FAILURES=$((FAILURES + 1))
    return
  fi

  # Check 5: For TypeScript — no "any" flood (pattern of declining quality)
  local any_count=$(grep -c ": any" "$file" 2>/dev/null || echo "0")
  local total_lines=$(wc -l < "$file" 2>/dev/null || echo "1")
  local any_ratio=$((any_count * 100 / total_lines))
  if [ "$any_ratio" -gt 20 ]; then
    file_score=$((file_score - 10))
    file_issues="$file_issues ANY_FLOOD"
  fi

  TOTAL_SCORE=$((TOTAL_SCORE + file_score))

  if [ "$file_score" -ge 90 ]; then
    echo -e "  ${GREEN}✓ $file — ${file_score}/100 TRUSTED${NC}"
  elif [ "$file_score" -ge 70 ]; then
    echo -e "  ${YELLOW}⚠ $file — ${file_score}/100 SUSPECT $file_issues${NC}"
  elif [ "$file_score" -ge 40 ]; then
    echo -e "  ${YELLOW}● $file — ${file_score}/100 UNTRUSTED $file_issues${NC}"
    FAILURES=$((FAILURES + 1))
  else
    echo -e "  ${RED}✗ $file — ${file_score}/100 BROKEN $file_issues${NC}"
    FAILURES=$((FAILURES + 1))
  fi
}

# Main scan loop
FILES=$(get_changed_files | sort -u | head -50)

if [ -z "$FILES" ]; then
  echo "No changed files detected in this session."
  echo '{"status":"clean","checks":0,"failures":0,"avg_score":100}' > "$REPORT_FILE"
  exit 0
fi

echo "Scanning changed files..."
echo ""

while IFS= read -r file; do
  [ -z "$file" ] && continue
  scan_file "$file"
done <<< "$FILES"

# Summary
echo ""
echo -e "${CYAN}═══ Session Trust Summary ═══${NC}"
echo "Files checked: $CHECKS"
echo "Failures:      $FAILURES"

if [ "$CHECKS" -gt 0 ]; then
  AVG_SCORE=$((TOTAL_SCORE / CHECKS))
  echo "Avg Score:     $AVG_SCORE/100"
else
  AVG_SCORE=100
fi

# JSON report
cat > "$REPORT_FILE" << JSONEOF
{
  "session_id": "$SESSION_ID",
  "timestamp": "$(date -Iseconds)",
  "mode": "$MODE",
  "checks": $CHECKS,
  "failures": $FAILURES,
  "avg_score": $AVG_SCORE,
  "min_required": $MIN_SCORE,
  "passed": $([ "$AVG_SCORE" -ge "$MIN_SCORE" ] && echo "true" || echo "false")
}
JSONEOF

# Exit code
if [ "$AVG_SCORE" -lt "$MIN_SCORE" ]; then
  echo -e "${RED}Trust gate FAILED (avg $AVG_SCORE < required $MIN_SCORE)${NC}"
  echo "Report: $REPORT_FILE"
  exit 1
else
  echo -e "${GREEN}Trust gate PASSED${NC}"
  echo "Report: $REPORT_FILE"
  exit 0
fi
