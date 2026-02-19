#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# hateoas-check.sh
# Tier 3 validation for mod-code-019-api-public-exposure
# ═══════════════════════════════════════════════════════════════════════════════
# Validates ERI constraints:
#   - hateoas-self-link
#   - model-assembler-exists
#   - CRITICAL: correct import path for RepresentationModelAssemblerSupport
#
# Updated: 2026-01-26 - Added import validation (DEC-025 compliance)
# ═══════════════════════════════════════════════════════════════════════════════

SERVICE_DIR="${1:-.}"
PACKAGE_PATH="${2:-}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}✅ PASS:${NC} $1"; }
fail() { echo -e "${RED}❌ FAIL:${NC} $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo -e "${YELLOW}⚠️  WARN:${NC} $1"; }

ERRORS=0

echo "═══════════════════════════════════════════════════════════════════════════════"
echo "TIER-3: HATEOAS Structure Check (mod-019)"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo "Service directory: $SERVICE_DIR"
echo ""

# ─────────────────────────────────────────────────────────────────────────────────
# Check 1: Find Assembler classes
# ─────────────────────────────────────────────────────────────────────────────────
echo ">>> Assembler Classes"

ASSEMBLERS=$(find "$SERVICE_DIR" -name "*Assembler.java" -type f 2>/dev/null | grep -v "Test")
ASSEMBLER_COUNT=$(echo "$ASSEMBLERS" | grep -c "Assembler" 2>/dev/null || echo "0")

if [ -n "$ASSEMBLERS" ] && [ "$ASSEMBLER_COUNT" -gt 0 ]; then
    pass "Found $ASSEMBLER_COUNT Assembler class(es)"
    
    for ASSEMBLER in $ASSEMBLERS; do
        ASSEMBLER_NAME=$(basename "$ASSEMBLER")
        echo ""
        echo "--- Checking: $ASSEMBLER_NAME ---"
        
        # ─────────────────────────────────────────────────────────────────────────
        # CRITICAL CHECK: Correct import path for RepresentationModelAssemblerSupport
        # ─────────────────────────────────────────────────────────────────────────
        # CORRECT:   org.springframework.hateoas.server.mvc.RepresentationModelAssemblerSupport
        # INCORRECT: org.springframework.hateoas.server.RepresentationModelAssemblerSupport
        # ─────────────────────────────────────────────────────────────────────────
        
        if grep -q "import org.springframework.hateoas.server.mvc.RepresentationModelAssemblerSupport" "$ASSEMBLER" 2>/dev/null; then
            pass "$ASSEMBLER_NAME has CORRECT import (server.mvc.RMAS)"
        elif grep -q "import org.springframework.hateoas.server.RepresentationModelAssemblerSupport" "$ASSEMBLER" 2>/dev/null; then
            fail "$ASSEMBLER_NAME has INCORRECT import (server.RMAS) - should be server.mvc.RMAS"
        elif grep -q "RepresentationModelAssemblerSupport" "$ASSEMBLER" 2>/dev/null; then
            warn "$ASSEMBLER_NAME uses RMAS but import not found - verify manually"
        fi
        
        # Check: Extends RepresentationModelAssemblerSupport
        if grep -q "extends RepresentationModelAssemblerSupport" "$ASSEMBLER" 2>/dev/null; then
            pass "$ASSEMBLER_NAME extends RepresentationModelAssemblerSupport"
        elif grep -q "implements.*RepresentationModelAssembler" "$ASSEMBLER" 2>/dev/null; then
            pass "$ASSEMBLER_NAME implements RepresentationModelAssembler"
        else
            fail "$ASSEMBLER_NAME does not use HATEOAS assembler pattern"
        fi
        
        # Check: @Component annotation
        if grep -q "@Component" "$ASSEMBLER" 2>/dev/null; then
            pass "$ASSEMBLER_NAME has @Component annotation"
        else
            fail "$ASSEMBLER_NAME missing @Component annotation"
        fi
        
        # Check: Self link
        if grep -q "withSelfRel" "$ASSEMBLER" 2>/dev/null; then
            pass "$ASSEMBLER_NAME adds self link (withSelfRel)"
        else
            fail "$ASSEMBLER_NAME missing self link (withSelfRel)"
        fi
        
        # Check: WebMvcLinkBuilder
        if grep -q "WebMvcLinkBuilder\|linkTo\|methodOn" "$ASSEMBLER" 2>/dev/null; then
            pass "$ASSEMBLER_NAME uses WebMvcLinkBuilder"
        else
            warn "$ASSEMBLER_NAME may not use WebMvcLinkBuilder"
        fi
    done
else
    fail "No Assembler classes found"
fi

# ─────────────────────────────────────────────────────────────────────────────────
# Check 2: Response DTOs
# ─────────────────────────────────────────────────────────────────────────────────
echo ""
echo ">>> Response DTO Check"

RESPONSE_DTOS=$(find "$SERVICE_DIR" -name "*Response.java" \( -path "*/dto/*" -o -path "*/application/*" \) -type f 2>/dev/null)

for DTO in $RESPONSE_DTOS; do
    DTO_NAME=$(basename "$DTO")
    
    # Skip PageResponse and external DTOs
    if [[ "$DTO_NAME" == "PageResponse.java" ]] || echo "$DTO" | grep -q "systemapi"; then
        continue
    fi
    
    if grep -q "RepresentationModel" "$DTO" 2>/dev/null; then
        pass "$DTO_NAME extends RepresentationModel"
    else
        warn "$DTO_NAME does not extend RepresentationModel"
    fi
done

echo ""
echo "═══════════════════════════════════════════════════════════════════════════════"
echo "RESULT: $ERRORS error(s)"
echo "═══════════════════════════════════════════════════════════════════════════════"

exit $ERRORS
