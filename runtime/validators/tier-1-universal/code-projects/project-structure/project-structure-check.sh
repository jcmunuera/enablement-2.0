#!/bin/bash
# project-structure-check.sh
# Validates basic project structure

SERVICE_DIR=${1:-.}

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}✅ PASS:${NC} $1"; }
fail() { echo -e "${RED}❌ FAIL:${NC} $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo -e "${YELLOW}⚠️  WARN:${NC} $1"; }

ERRORS=0

# Check src/main/java exists
if [ -d "$SERVICE_DIR/src/main/java" ]; then
    pass "src/main/java exists"
else
    fail "src/main/java missing"
fi

# Check src/test/java exists
if [ -d "$SERVICE_DIR/src/test/java" ]; then
    pass "src/test/java exists"
else
    fail "src/test/java missing"
fi

# Check src/main/resources exists (warning only)
if [ -d "$SERVICE_DIR/src/main/resources" ]; then
    pass "src/main/resources exists"
else
    warn "src/main/resources missing (optional)"
fi

# Check src/test/resources exists (warning only)
if [ -d "$SERVICE_DIR/src/test/resources" ]; then
    pass "src/test/resources exists"
else
    warn "src/test/resources missing (optional)"
fi

if [ $ERRORS -eq 0 ]; then
    exit 0
else
    exit 1
fi
