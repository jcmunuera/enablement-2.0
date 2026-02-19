#!/bin/bash
# actuator-check.sh
# Validates Spring Boot Actuator configuration

SERVICE_DIR=${1:-.}
APP_YML="$SERVICE_DIR/src/main/resources/application.yml"
APP_PROPERTIES="$SERVICE_DIR/src/main/resources/application.properties"

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

# Check if Spring Boot project
if [ ! -f "$APP_YML" ] && [ ! -f "$APP_PROPERTIES" ]; then
    skip "Not a Spring Boot project (no application.yml/properties)"
    exit 0
fi

CONFIG_FILE=""
if [ -f "$APP_YML" ]; then
    CONFIG_FILE="$APP_YML"
elif [ -f "$APP_PROPERTIES" ]; then
    CONFIG_FILE="$APP_PROPERTIES"
fi

# Check if management configuration exists
if grep -q "management:" "$CONFIG_FILE" 2>/dev/null; then
    pass "Spring Boot Actuator configured"
    
    # Check if endpoints are exposed
    if grep -q "exposure:" "$CONFIG_FILE" 2>/dev/null; then
        pass "Actuator endpoints explicitly exposed"
        
        # Check specific endpoints
        if grep -q "include:" "$CONFIG_FILE" 2>/dev/null; then
            ENDPOINTS=$(grep "include:" "$CONFIG_FILE" | head -1)
            pass "Endpoints configured: ${ENDPOINTS##*include:}"
        fi
    else
        warn "Actuator endpoints not explicitly exposed (using defaults)"
    fi
    
    # Check health endpoint
    if grep -q "health:" "$CONFIG_FILE" 2>/dev/null; then
        pass "Health endpoint configured"
    else
        warn "Health endpoint not explicitly configured (using defaults)"
    fi
else
    warn "Spring Boot Actuator not configured in $CONFIG_FILE"
fi

# Check pom.xml for actuator dependency
if [ -f "$SERVICE_DIR/pom.xml" ]; then
    if grep -q "spring-boot-starter-actuator" "$SERVICE_DIR/pom.xml"; then
        pass "spring-boot-starter-actuator dependency present"
    else
        warn "spring-boot-starter-actuator dependency not found in pom.xml"
    fi
fi

exit 0
