#!/bin/bash
# compile-check.sh
# Validates Maven compilation

SERVICE_DIR=${1:-.}

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

pass() { echo -e "${GREEN}✅ PASS:${NC} $1"; }
fail() { echo -e "${RED}❌ FAIL:${NC} $1"; }
skip() { echo -e "${BLUE}⏸️  SKIP:${NC} $1"; }

# Check if this is a Maven project
if [ ! -f "$SERVICE_DIR/pom.xml" ]; then
    skip "Not a Maven project (no pom.xml found)"
    exit 0
fi

# Check if mvn is available
if ! command -v mvn &> /dev/null; then
    skip "Maven not installed in environment"
    exit 0
fi

# Compile project
cd "$SERVICE_DIR"
if mvn clean compile -q 2>/dev/null; then
    pass "Maven compilation successful"
    exit 0
else
    fail "Maven compilation failed"
    echo ""
    echo "To see details, run:"
    echo "  cd $SERVICE_DIR && mvn clean compile"
    exit 1
fi
