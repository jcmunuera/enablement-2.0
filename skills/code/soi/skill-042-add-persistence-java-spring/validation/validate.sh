#!/bin/bash
# validate.sh - Validation script for skill-042-add-persistence-java-spring
# Usage: ./validate.sh <project-dir> <persistence-type>

set -e

PROJECT_DIR="${1:-.}"
PERSISTENCE_TYPE="${2:-jpa}"
ERRORS=0

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Validating Persistence Transformation                       ║"
echo "║  Skill: skill-042-add-persistence-java-spring                ║"
echo "║  Type: $PERSISTENCE_TYPE                                     ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# ─────────────────────────────────────────────────────────────────────
# 1. Check adapter classes exist
# ─────────────────────────────────────────────────────────────────────
echo "▶ Checking persistence adapters..."

if [[ "$PERSISTENCE_TYPE" == "jpa" ]]; then
    ADAPTER_FILES=$(find "$PROJECT_DIR/src/main/java" -path "*/persistence/*" -name "*Adapter.java" 2>/dev/null || true)
else
    ADAPTER_FILES=$(find "$PROJECT_DIR/src/main/java" -path "*/systemapi/*" -name "*Adapter.java" 2>/dev/null || true)
fi

if [[ -z "$ADAPTER_FILES" ]]; then
    echo "  ❌ FAIL: No persistence adapters found"
    ERRORS=$((ERRORS + 1))
else
    echo "  ✅ Persistence adapters found"
fi

# ─────────────────────────────────────────────────────────────────────
# 2. Check JPA-specific (if jpa)
# ─────────────────────────────────────────────────────────────────────
if [[ "$PERSISTENCE_TYPE" == "jpa" ]]; then
    echo ""
    echo "▶ Checking JPA entities..."
    
    JPA_ENTITIES=$(find "$PROJECT_DIR/src/main/java" -path "*/persistence/entity/*" -name "*Entity.java" 2>/dev/null || true)
    
    if [[ -z "$JPA_ENTITIES" ]]; then
        echo "  ❌ FAIL: No JPA entities found"
        ERRORS=$((ERRORS + 1))
    else
        for file in $JPA_ENTITIES; do
            if grep -q "@Entity" "$file" 2>/dev/null; then
                echo "  ✅ @Entity found in $(basename $file)"
            else
                echo "  ❌ FAIL: Missing @Entity in $(basename $file)"
                ERRORS=$((ERRORS + 1))
            fi
        done
    fi
    
    if grep -q "spring-boot-starter-data-jpa" "$PROJECT_DIR/pom.xml" 2>/dev/null; then
        echo "  ✅ JPA dependency found"
    else
        echo "  ❌ FAIL: JPA dependency not found"
        ERRORS=$((ERRORS + 1))
    fi
fi

# ─────────────────────────────────────────────────────────────────────
# 3. Check System API-specific (if systemapi)
# ─────────────────────────────────────────────────────────────────────
if [[ "$PERSISTENCE_TYPE" == "systemapi" ]]; then
    echo ""
    echo "▶ Checking System API client..."
    
    CLIENT_FILES=$(find "$PROJECT_DIR/src/main/java" -path "*/systemapi/client/*" -name "*Client.java" 2>/dev/null || true)
    
    if [[ -z "$CLIENT_FILES" ]]; then
        echo "  ❌ FAIL: No System API clients found"
        ERRORS=$((ERRORS + 1))
    else
        echo "  ✅ System API client found"
    fi
    
    echo ""
    echo "▶ Checking resilience on adapters..."
    
    for file in $ADAPTER_FILES; do
        if grep -q "@CircuitBreaker" "$file" 2>/dev/null; then
            echo "  ✅ @CircuitBreaker found in $(basename $file)"
        else
            echo "  ❌ FAIL: Missing @CircuitBreaker in $(basename $file)"
            ERRORS=$((ERRORS + 1))
        fi
    done
fi

# ─────────────────────────────────────────────────────────────────────
# 4. Compilation check
# ─────────────────────────────────────────────────────────────────────
echo ""
echo "▶ Checking compilation..."

if command -v mvn &> /dev/null; then
    if (cd "$PROJECT_DIR" && mvn compile -q 2>/dev/null); then
        echo "  ✅ Project compiles successfully"
    else
        echo "  ❌ FAIL: Compilation failed"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo "  ⚠️  SKIP: Maven not available"
fi

# ─────────────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════════════"
if [[ $ERRORS -eq 0 ]]; then
    echo "✅ VALIDATION PASSED"
else
    echo "❌ VALIDATION FAILED ($ERRORS errors)"
fi
echo "═══════════════════════════════════════════════════════════════"

exit $ERRORS
