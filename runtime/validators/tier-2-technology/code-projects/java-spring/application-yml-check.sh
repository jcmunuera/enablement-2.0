#!/bin/bash
# application-yml-check.sh
# Validates application.yml syntax and basic structure

SERVICE_DIR=${1:-.}
APP_YML="$SERVICE_DIR/src/main/resources/application.yml"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

pass() { echo -e "${GREEN}✅ PASS:${NC} $1"; }
fail() { echo -e "${RED}❌ FAIL:${NC} $1"; }
warn() { echo -e "${YELLOW}⚠️  WARN:${NC} $1"; }
skip() { echo -e "${BLUE}⏸️  SKIP:${NC} $1"; }

ERRORS=0

# Check if application.yml exists
if [ ! -f "$APP_YML" ]; then
    skip "No application.yml found"
    exit 0
fi

pass "application.yml exists"

# Basic YAML syntax check (if yq or python available)
if command -v yq &> /dev/null; then
    if yq eval '.' "$APP_YML" > /dev/null 2>&1; then
        pass "application.yml has valid YAML syntax"
    else
        fail "application.yml has invalid YAML syntax"
        ERRORS=$((ERRORS + 1))
    fi
elif command -v python3 &> /dev/null; then
    if python3 -c "import yaml; yaml.safe_load(open('$APP_YML'))" 2>/dev/null; then
        pass "application.yml has valid YAML syntax"
    else
        fail "application.yml has invalid YAML syntax"
        ERRORS=$((ERRORS + 1))
    fi
else
    warn "Cannot validate YAML syntax (yq or python3 not available)"
fi

# Check for common Spring Boot properties
if grep -q "spring:" "$APP_YML"; then
    pass "Spring configuration present"
else
    warn "No spring: configuration found"
fi

# Check for application name
if grep -q "application:" "$APP_YML" && grep -q "name:" "$APP_YML"; then
    APP_NAME=$(grep -A 2 "application:" "$APP_YML" | grep "name:" | head -1 | sed 's/.*name: *//')
    pass "Application name configured: $APP_NAME"
else
    warn "Application name not configured"
fi

# Check for server port configuration
if grep -q "server:" "$APP_YML" && grep -q "port:" "$APP_YML"; then
    PORT=$(grep -A 2 "server:" "$APP_YML" | grep "port:" | head -1 | sed 's/.*port: *//')
    pass "Server port configured: $PORT"
else
    warn "Server port not explicitly configured (will use default 8080)"
fi

if [ $ERRORS -eq 0 ]; then
    exit 0
else
    exit 1
fi
