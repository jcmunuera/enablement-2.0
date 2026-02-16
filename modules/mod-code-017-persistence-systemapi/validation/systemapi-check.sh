#!/bin/bash
# =============================================================================
# MOD-017: System API Persistence Validation Script
# Tier 3 validation for System API persistence implementation
# =============================================================================
# Version: 1.1
# Updated: 2026-01-23
# Changes: Support multiple valid path variants for repository and adapter
# =============================================================================

# Note: Not using 'set -e' because we handle errors manually with ERRORS counter

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

TARGET_DIR="${1:-.}"

echo "=============================================="
echo "MOD-017: System API Persistence Validation"
echo "Target: $TARGET_DIR"
echo "=============================================="

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    ERRORS=$((ERRORS + 1))
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    WARNINGS=$((WARNINGS + 1))
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

info() {
    echo -e "[INFO] $1"
}

echo ""
echo "--- Structural Constraints ---"

# Check 1: Repository interface in domain (supports multiple valid locations)
# Valid paths: domain/repository/, domain/port/, domain/port/out/
info "Checking repository interface in domain layer..."
REPO_FOUND=false
for pattern in "*/domain/repository/*Repository.java" "*/domain/port/*Repository.java" "*/domain/port/out/*Repository.java"; do
    if find "$TARGET_DIR/src/main/java" -path "$pattern" 2>/dev/null | grep -q .; then
        REPO_PATH=$(find "$TARGET_DIR/src/main/java" -path "$pattern" 2>/dev/null | head -1)
        success "Repository interface found: ${REPO_PATH#$TARGET_DIR/}"
        REPO_FOUND=true
        break
    fi
done
if [ "$REPO_FOUND" = false ]; then
    error "Repository interface not found in domain layer (checked: domain/repository/, domain/port/, domain/port/out/)"
fi

# Check 2: System API adapter in correct location (supports multiple valid locations)
# Valid paths: adapter/systemapi/, adapter/out/systemapi/, infrastructure/adapter/out/systemapi/
info "Checking System API adapter..."
ADAPTER_FOUND=false
for pattern in "*/adapter/systemapi/*Adapter.java" "*/adapter/out/systemapi/*Adapter.java" "*/infrastructure/adapter/out/systemapi/*Adapter.java"; do
    if find "$TARGET_DIR/src/main/java" -path "$pattern" 2>/dev/null | grep -q .; then
        ADAPTER_PATH=$(find "$TARGET_DIR/src/main/java" -path "$pattern" 2>/dev/null | head -1)
        success "System API adapter found: ${ADAPTER_PATH#$TARGET_DIR/}"
        ADAPTER_FOUND=true
        break
    fi
done
if [ "$ADAPTER_FOUND" = false ]; then
    error "System API adapter not found (checked: adapter/systemapi/, adapter/out/systemapi/, infrastructure/adapter/out/systemapi/)"
fi

# Check 3: Client in adapter (supports multiple valid locations)
info "Checking System API client..."
CLIENT_FOUND=false
for pattern in "*/systemapi/client/*Client.java" "*/systemapi/*Client.java"; do
    if find "$TARGET_DIR/src/main/java" -path "$pattern" 2>/dev/null | grep -q .; then
        CLIENT_PATH=$(find "$TARGET_DIR/src/main/java" -path "$pattern" 2>/dev/null | head -1)
        success "System API client found: ${CLIENT_PATH#$TARGET_DIR/}"
        CLIENT_FOUND=true
        break
    fi
done
if [ "$CLIENT_FOUND" = false ]; then
    warning "System API client not found in expected location"
fi

echo ""
echo "--- Resilience Constraints (Phase 3 cross-cutting) ---"
echo "[INFO] Note: Resilience annotations are added by Phase 3 transform (mod-001, mod-002, mod-003)"
echo "[INFO]       These checks will warn (not fail) if Phase 3 has not yet run."

# Check 4: CircuitBreaker annotation present (Phase 3 responsibility)
info "Checking @CircuitBreaker on adapter..."
if grep -r "@CircuitBreaker" "$TARGET_DIR/src/main/java" 2>/dev/null | grep -q "systemapi"; then
    success "@CircuitBreaker found on System API adapter"
else
    warning "@CircuitBreaker not yet present on System API adapter (requires Phase 3 transform)"
fi

# Check 5: Retry annotation present (Phase 3 responsibility)
info "Checking @Retry on adapter..."
if grep -r "@Retry" "$TARGET_DIR/src/main/java" 2>/dev/null | grep -q "systemapi"; then
    success "@Retry found on System API adapter"
else
    warning "@Retry not yet present on System API adapter (requires Phase 3 transform)"
fi

# Check 6: Resilience4j configuration (Phase 3 responsibility)
info "Checking Resilience4j configuration..."
if [ -f "$TARGET_DIR/src/main/resources/application.yml" ]; then
    if grep -q "resilience4j:" "$TARGET_DIR/src/main/resources/application.yml"; then
        success "Resilience4j configuration found"
    else
        warning "Resilience4j configuration not yet in application.yml (requires Phase 3 transform)"
    fi
fi

echo ""
echo "--- Configuration Constraints ---"

# Check 7: Base URL externalized
info "Checking base URL externalization..."
if grep -rE "(base-url|baseUrl|url).*\\\$\{" "$TARGET_DIR/src/main/resources" 2>/dev/null | grep -q .; then
    success "Base URL uses environment variable"
else
    warning "Base URL should be externalized via environment variable"
fi

# Check 8: Timeouts configured
info "Checking timeout configuration..."
if grep -r "timeout" "$TARGET_DIR/src/main/resources/application.yml" 2>/dev/null | grep -q .; then
    success "Timeout configuration found"
else
    warning "Connection/read timeouts should be configured"
fi

echo ""
echo "--- Headers Constraints ---"

# Check 9: Correlation headers
info "Checking correlation headers..."
if grep -ri "X-Correlation-Id\|X-Source-System\|correlationId" "$TARGET_DIR/src/main/java" 2>/dev/null | grep -q .; then
    success "Correlation headers found"
else
    warning "X-Correlation-Id and X-Source-System headers should be set"
fi

echo ""
echo "--- Dependency Constraints ---"

# Check 10: Resilience4j dependency
info "Checking Resilience4j dependency..."
if [ -f "$TARGET_DIR/pom.xml" ]; then
    if grep -q "resilience4j" "$TARGET_DIR/pom.xml"; then
        success "Resilience4j dependency found"
    else
        error "Resilience4j dependency not found in pom.xml"
    fi
fi

echo ""
echo "--- Testing Constraints ---"

# Check 11: Adapter tests exist
info "Checking System API adapter tests..."
if find "$TARGET_DIR/src/test/java" -name "*SystemApiAdapter*Test.java" 2>/dev/null | grep -q .; then
    success "System API adapter tests found"
else
    warning "No System API adapter tests found"
fi

echo ""
echo "=============================================="
echo "Validation Summary"
echo "=============================================="
echo -e "Errors:   ${RED}$ERRORS${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}VALIDATION FAILED${NC}"
    exit 1
else
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}VALIDATION PASSED WITH WARNINGS${NC}"
    else
        echo -e "${GREEN}VALIDATION PASSED${NC}"
    fi
    exit 0
fi
