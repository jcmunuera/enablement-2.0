#!/bin/bash
# dockerfile-check.sh
# Validates Dockerfile syntax and best practices

SERVICE_DIR=${1:-.}
DOCKERFILE="$SERVICE_DIR/Dockerfile"

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

# Check if Dockerfile exists
if [ ! -f "$DOCKERFILE" ]; then
    skip "No Dockerfile found"
    exit 0
fi

pass "Dockerfile exists"

# Check FROM instruction exists (required)
if grep -q "^FROM " "$DOCKERFILE"; then
    pass "FROM instruction present"
else
    fail "FROM instruction missing"
    ERRORS=$((ERRORS + 1))
fi

# Check for specific base images
if grep -q "^FROM .*openjdk" "$DOCKERFILE" || grep -q "^FROM .*eclipse-temurin" "$DOCKERFILE"; then
    pass "Using Java base image"
elif grep -q "^FROM .*node" "$DOCKERFILE"; then
    pass "Using Node.js base image"
fi

# Check for multi-stage build (best practice for Java)
STAGE_COUNT=$(grep -c "^FROM " "$DOCKERFILE")
if [ "$STAGE_COUNT" -gt 1 ]; then
    pass "Multi-stage build detected ($STAGE_COUNT stages)"
else
    warn "Single-stage build (multi-stage recommended for smaller images)"
fi

# Check WORKDIR is used
if grep -q "^WORKDIR " "$DOCKERFILE"; then
    pass "WORKDIR instruction present"
else
    warn "WORKDIR not used (recommended for clarity)"
fi

# Check EXPOSE instruction for ports
if grep -q "^EXPOSE " "$DOCKERFILE"; then
    PORTS=$(grep "^EXPOSE " "$DOCKERFILE" | sed 's/EXPOSE //')
    pass "EXPOSE instruction present: $PORTS"
else
    warn "EXPOSE instruction not present (documents which ports are used)"
fi

# Check for COPY or ADD
if grep -q "^COPY " "$DOCKERFILE" || grep -q "^ADD " "$DOCKERFILE"; then
    pass "COPY/ADD instructions present"
else
    warn "No COPY/ADD instructions (may be intentional)"
fi

# Check for CMD or ENTRYPOINT
if grep -q "^CMD " "$DOCKERFILE" || grep -q "^ENTRYPOINT " "$DOCKERFILE"; then
    pass "CMD or ENTRYPOINT instruction present"
else
    fail "No CMD or ENTRYPOINT (container won't start)"
    ERRORS=$((ERRORS + 1))
fi

# Check for USER instruction (security best practice)
if grep -q "^USER " "$DOCKERFILE"; then
    pass "USER instruction present (runs as non-root)"
else
    warn "No USER instruction (running as root, consider security implications)"
fi

# Basic syntax check with Docker (if available)
if command -v docker &> /dev/null; then
    # Use docker build --check if available (Docker 23.0+)
    if docker build --help 2>&1 | grep -q "\-\-check"; then
        if docker build --check -f "$DOCKERFILE" "$SERVICE_DIR" > /dev/null 2>&1; then
            pass "Dockerfile syntax valid (docker build --check)"
        else
            fail "Dockerfile has syntax errors"
            ERRORS=$((ERRORS + 1))
        fi
    else
        # Fallback: just check if docker can parse it
        if docker build -f "$DOCKERFILE" -t test-validation "$SERVICE_DIR" --dry-run > /dev/null 2>&1; then
            pass "Dockerfile syntax appears valid"
        else
            warn "Cannot validate Dockerfile syntax (Docker available but validation failed)"
        fi
    fi
else
    warn "Docker not available (cannot validate syntax)"
fi

if [ $ERRORS -eq 0 ]; then
    exit 0
else
    exit 1
fi
