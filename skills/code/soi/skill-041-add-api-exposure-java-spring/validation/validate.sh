#!/bin/bash
# validate.sh - Validation script for skill-041-add-api-exposure-java-spring
# Usage: ./validate.sh <project-dir> [api-layer]

set -e

PROJECT_DIR="${1:-.}"
API_LAYER="${2:-domain}"
ERRORS=0

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Validating API Exposure Transformation                      ║"
echo "║  Skill: skill-041-add-api-exposure-java-spring               ║"
echo "║  API Layer: $API_LAYER                                       ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# ─────────────────────────────────────────────────────────────────────
# 1. Check REST controllers exist
# ─────────────────────────────────────────────────────────────────────
echo "▶ Checking REST controllers..."

CONTROLLER_FILES=$(find "$PROJECT_DIR/src/main/java" -path "*/adapter/*rest*" -name "*Controller.java" 2>/dev/null || true)

if [[ -z "$CONTROLLER_FILES" ]]; then
    echo "  ❌ FAIL: No REST controllers found"
    ERRORS=$((ERRORS + 1))
else
    for file in $CONTROLLER_FILES; do
        filename=$(basename "$file")
        echo "  Checking $filename..."
        
        if grep -q "@RestController" "$file" 2>/dev/null; then
            echo "    ✅ @RestController found"
        else
            echo "    ❌ FAIL: Missing @RestController"
            ERRORS=$((ERRORS + 1))
        fi
        
        if grep -q "@RequestMapping" "$file" 2>/dev/null; then
            echo "    ✅ @RequestMapping found"
        else
            echo "    ⚠️  WARN: Missing @RequestMapping"
        fi
        
        if grep -q "@Tag" "$file" 2>/dev/null; then
            echo "    ✅ OpenAPI @Tag found"
        else
            echo "    ⚠️  WARN: Missing OpenAPI @Tag"
        fi
    done
fi

# ─────────────────────────────────────────────────────────────────────
# 2. Check pagination support
# ─────────────────────────────────────────────────────────────────────
echo ""
echo "▶ Checking pagination support..."

if find "$PROJECT_DIR/src/main/java" -name "PageResponse.java" 2>/dev/null | grep -q .; then
    echo "  ✅ PageResponse DTO found"
else
    echo "  ❌ FAIL: PageResponse DTO not found"
    ERRORS=$((ERRORS + 1))
fi

for file in $CONTROLLER_FILES; do
    if grep -q "Pageable" "$file" 2>/dev/null; then
        echo "  ✅ Pageable parameter found in $(basename $file)"
    fi
done

# ─────────────────────────────────────────────────────────────────────
# 3. Check HATEOAS (if applicable)
# ─────────────────────────────────────────────────────────────────────
echo ""
echo "▶ Checking HATEOAS support..."

if [[ "$API_LAYER" == "experience" || "$API_LAYER" == "domain" ]]; then
    ASSEMBLER_FILES=$(find "$PROJECT_DIR/src/main/java" -name "*Assembler.java" 2>/dev/null || true)
    
    if [[ -n "$ASSEMBLER_FILES" ]]; then
        echo "  ✅ HATEOAS assemblers found"
    else
        echo "  ⚠️  WARN: HATEOAS assemblers not found (expected for $API_LAYER layer)"
    fi
    
    if grep -q "spring-boot-starter-hateoas" "$PROJECT_DIR/pom.xml" 2>/dev/null; then
        echo "  ✅ HATEOAS dependency found"
    else
        echo "  ⚠️  WARN: HATEOAS dependency not in pom.xml"
    fi
else
    echo "  ⏭️  SKIP: HATEOAS not required for $API_LAYER layer"
fi

# ─────────────────────────────────────────────────────────────────────
# 4. Check OpenAPI dependency
# ─────────────────────────────────────────────────────────────────────
echo ""
echo "▶ Checking OpenAPI support..."

if grep -q "springdoc-openapi" "$PROJECT_DIR/pom.xml" 2>/dev/null; then
    echo "  ✅ springdoc-openapi dependency found"
else
    echo "  ❌ FAIL: springdoc-openapi dependency not found"
    ERRORS=$((ERRORS + 1))
fi

# ─────────────────────────────────────────────────────────────────────
# 5. Compilation check
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
