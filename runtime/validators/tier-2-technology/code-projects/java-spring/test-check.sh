#!/bin/bash
# test-check.sh
# Validates Maven tests execution

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

# Check if tests exist
if [ ! -d "$SERVICE_DIR/src/test/java" ]; then
    skip "No tests directory found"
    exit 0
fi

TEST_COUNT=$(find "$SERVICE_DIR/src/test/java" -name "*Test.java" -o -name "*Tests.java" | wc -l)
if [ "$TEST_COUNT" -eq 0 ]; then
    skip "No test files found (*Test.java, *Tests.java)"
    exit 0
fi

# Run tests
cd "$SERVICE_DIR"
if mvn test -q 2>/dev/null; then
    pass "All tests passed ($TEST_COUNT test file(s))"
    exit 0
else
    fail "Some tests failed"
    echo ""
    echo "To see details, run:"
    echo "  cd $SERVICE_DIR && mvn test"
    exit 1
fi
