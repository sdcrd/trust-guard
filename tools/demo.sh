#!/bin/bash
# Trust Guard Demo — Simulates a silent edit failure and shows trust-guard catching it.
# Run: bash tools/demo.sh
# This generates the scenario shown in the README Before/After comparison.

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

DEMO_DIR="/tmp/trust-guard-demo-$$"
mkdir -p "$DEMO_DIR"
cd "$DEMO_DIR"

echo -e "${CYAN}═══════════════════════════════════════════${NC}"
echo -e "${CYAN}     🛡️  TRUST GUARD — LIVE DEMO           ${NC}"
echo -e "${CYAN}═══════════════════════════════════════════${NC}"
echo ""

# Setup: create a file with two call sites (like the real i18n bug)
cat > greeting.ts << 'EOF'
export function getGreeting(user: string): string {
  return "Hello World";  // Call site 1
}

export function getFarewell(user: string): string {
  return "Hello World";  // Call site 2
}
EOF

echo -e "${CYAN}📄 Initial file created: greeting.ts${NC}"
echo "   File has 2 call sites of 'Hello World'"
echo ""

# Simulate: agent edits only ONE call site (the bug)
echo -e "${YELLOW}🤖 Agent: Editing greeting.ts — change 'Hello World' to 'Hello Customer'${NC}"
echo -e "${YELLOW}   Tool response: ✅ Edit applied successfully${NC}"
echo ""

# Simulate the partial edit (only first occurrence changed)
cat > greeting.ts << 'EOF'
export function getGreeting(user: string): string {
  return "Hello Customer";  // Call site 1 — UPDATED
}

export function getFarewell(user: string): string {
  return "Hello World";  // Call site 2 — STILL OLD
}
EOF

echo -e "${RED}❌ WITHOUT TRUST GUARD:${NC}"
echo "   Agent: 'Done! The change has been made.'"
echo "   Agent proceeds to next task..."
echo ""

# Now Trust Guard verification
echo -e "${CYAN}═══════════════════════════════════════════${NC}"
echo -e "${CYAN}     🛡️  TRUST GUARD — POST-FLIGHT CHECK   ${NC}"
echo -e "${CYAN}═══════════════════════════════════════════${NC}"
echo ""

echo -e "${CYAN}🔍 Check A: Grep for new content 'Hello Customer'${NC}"
NEW_COUNT=$(grep -c "Hello Customer" greeting.ts || echo "0")
echo "   Found: $NEW_COUNT occurrence(s)"
echo "   Expected: 2"
if [ "$NEW_COUNT" -lt 2 ]; then
  echo -e "   ${RED}⚠️  PARTIAL APPLICATION — only $NEW_COUNT of 2 call sites updated${NC}"
fi
echo ""

echo -e "${CYAN}🔍 Check B: Grep for old content 'Hello World'${NC}"
OLD_COUNT=$(grep -c "Hello World" greeting.ts || echo "0")
echo "   Found: $OLD_COUNT occurrence(s)"
echo "   Expected: 0 (all replaced)"
if [ "$OLD_COUNT" -gt 0 ]; then
  echo -e "   ${RED}⚠️  OLD CONTENT REMAINS — $OLD_COUNT call site(s) not updated${NC}"
fi
echo ""

# Trust score
echo -e "${CYAN}═══════════════════════════════════════════${NC}"
echo -e "${YELLOW}📊 TRUST SCORE: 45/100 — UNTRUSTED${NC}"
echo -e "${YELLOW}   Partial application detected. Re-applying edit...${NC}"
echo -e "${CYAN}═══════════════════════════════════════════${NC}"
echo ""

# Fix: re-apply to second call site
echo -e "${GREEN}🔧 Re-applying edit to call site 2...${NC}"
cat > greeting.ts << 'EOF'
export function getGreeting(user: string): string {
  return "Hello Customer";  // Call site 1 — UPDATED
}

export function getFarewell(user: string): string {
  return "Hello Customer";  // Call site 2 — NOW UPDATED
}
EOF

echo -e "${CYAN}🔍 Re-verifying...${NC}"
NEW_COUNT=$(grep -c "Hello Customer" greeting.ts || echo "0")
OLD_COUNT=$(grep -c "Hello World" greeting.ts || echo "0")
echo "   'Hello Customer': $NEW_COUNT (expected 2)"
echo "   'Hello World': $OLD_COUNT (expected 0)"
echo ""

echo -e "${CYAN}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}📊 TRUST SCORE: 95/100 — TRUSTED ✅${NC}"
echo -e "${GREEN}   All call sites verified. Production safe.${NC}"
echo -e "${CYAN}═══════════════════════════════════════════${NC}"
echo ""

echo -e "${GREEN}✅ DEMO COMPLETE${NC}"
echo ""
echo "Trust Guard caught a silent partial edit failure and prevented it from reaching production."
echo "Time saved: 30-90 minutes of debugging."
echo ""
echo "Install: npx skills add emkaru/trust-guard"
echo ""

# Cleanup
rm -rf "$DEMO_DIR"
