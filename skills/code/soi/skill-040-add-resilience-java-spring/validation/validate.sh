#!/bin/bash
# validate.sh - Validation script for skill-040-add-resilience-java-spring
# Usage: ./validate.sh <project-dir>

set -e

PROJECT_DIR="${1:-.}"
ERRORS=0

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Validating Resilience Transformation                        ║"
echo "║  Skill: skill-040-add-resilience-java-spring                 ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# ─────────────────────────────────────────────────────────────────────
# 1. Check project structure
# ─────────────────────────────────────────────────────────────────────
echo "▶ Checking project structure..."

if [[ ! -f "$PROJECT_DIR/pom.xml" ]]; then
    echo "  ❌ FAIL: pom.xml not found"
    ERRORS=$((ERRORS + 1))
else
    echo "  ✅ pom.xml found"
fi

if [[ ! -d "$PROJECT_DIR/src/main/java" ]]; then
    echo "  ❌ FAIL: src/main/java not found"
    ERRORS=$((ERRORS + 1))
else
    echo "  ✅ Java sources found"
fi

# ─────────────────────────────────────────────────────────────────────
# 2. Check resilience4j dependency
# ─────────────────────────────────────────────────────────────────────
echo ""
echo "▶ Checking dependencies..."

if grep -q "resilience4j-spring-boot" "$PROJECT_DIR/pom.xml" 2>/dev/null; then
    echo "  ✅ resilience4j dependency found"
else
    echo "  ❌ FAIL: resilience4j dependency not found in pom.xml"
    ERRORS=$((ERRORS + 1))
fi

if grep -q "spring-boot-starter-aop" "$PROJECT_DIR/pom.xml" 2>/dev/null; then
    echo "  ✅ spring-boot-starter-aop dependency found"
else
    echo "  ⚠️  WARN: spring-boot-starter-aop not found (required for annotations)"
fi

# ─────────────────────────────────────────────────────────────────────
# 3. Check resilience4j configuration
# ─────────────────────────────────────────────────────────────────────
echo ""
echo "▶ Checking configuration..."

APP_YML="$PROJECT_DIR/src/main/resources/application.yml"
if [[ -f "$APP_YML" ]]; then
    if grep -q "resilience4j:" "$APP_YML" 2>/dev/null; then
        echo "  ✅ resilience4j configuration found"
        
        if grep -q "circuitbreaker:" "$APP_YML" 2>/dev/null; then
            echo "    ✅ circuitbreaker config present"
        fi
        if grep -q "retry:" "$APP_YML" 2>/dev/null; then
            echo "    ✅ retry config present"
        fi
        if grep -q "timelimiter:" "$APP_YML" 2>/dev/null; then
            echo "    ✅ timelimiter config present"
        fi
        if grep -q "ratelimiter:" "$APP_YML" 2>/dev/null; then
            echo "    ✅ ratelimiter config present"
        fi
    else
        echo "  ❌ FAIL: resilience4j configuration not found in application.yml"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo "  ⚠️  WARN: application.yml not found"
fi

# ─────────────────────────────────────────────────────────────────────
# 4. Check annotations in adapter classes
# ─────────────────────────────────────────────────────────────────────
echo ""
echo "▶ Checking resilience annotations..."

ADAPTER_FILES=$(find "$PROJECT_DIR/src/main/java" -path "*/adapter/*" -name "*Adapter.java" 2>/dev/null || true)

if [[ -z "$ADAPTER_FILES" ]]; then
    echo "  ⚠️  WARN: No adapter classes found"
else
    for file in $ADAPTER_FILES; do
        filename=$(basename "$file")
        echo "  Checking $filename..."
        
        if grep -q "@CircuitBreaker" "$file" 2>/dev/null; then
            echo "    ✅ @CircuitBreaker found"
            
            # Check for fallback method
            if grep -q "fallbackMethod" "$file" 2>/dev/null; then
                echo "    ✅ fallbackMethod defined"
            else
                echo "    ❌ FAIL: @CircuitBreaker without fallbackMethod"
                ERRORS=$((ERRORS + 1))
            fi
        fi
        
        if grep -q "@Retry" "$file" 2>/dev/null; then
            echo "    ✅ @Retry found"
        fi
    done
fi

# ─────────────────────────────────────────────────────────────────────
# 5. Verify annotation order (ADR-004)
# ─────────────────────────────────────────────────────────────────────
echo ""
echo "▶ Checking annotation order (ADR-004)..."

# This is a simplified check - in production would need AST parsing
for file in $ADAPTER_FILES; do
    if grep -q "@Retry" "$file" && grep -q "@CircuitBreaker" "$file"; then
        # Check if @Retry appears AFTER @CircuitBreaker (correct order)
        retry_line=$(grep -n "@Retry" "$file" | head -1 | cut -d: -f1)
        cb_line=$(grep -n "@CircuitBreaker" "$file" | head -1 | cut -d: -f1)
        
        if [[ -n "$retry_line" && -n "$cb_line" ]]; then
            if [[ $retry_line -gt $cb_line ]]; then
                echo "  ✅ Annotation order correct in $(basename $file)"
            else
                echo "  ❌ FAIL: Wrong annotation order in $(basename $file)"
                echo "         Expected: @CircuitBreaker before @Retry"
                ERRORS=$((ERRORS + 1))
            fi
        fi
    fi
done

# ─────────────────────────────────────────────────────────────────────
# 6. Compilation check
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
