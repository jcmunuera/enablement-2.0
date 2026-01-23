#!/bin/bash
# pagination-check.sh
# Tier 3 validation for mod-code-019-api-public-exposure
# Validates ERI constraint: page-response-structure, page-metadata-fields
# =============================================================================
# Version: 1.1
# Updated: 2026-01-23
# Changes: Make pagination check conditional - only required if API has list operations
# =============================================================================

SERVICE_DIR="${1:-.}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

pass() { echo -e "${GREEN}✅ PASS:${NC} $1"; }
fail() { echo -e "${RED}❌ FAIL:${NC} $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo -e "${YELLOW}⚠️  WARN:${NC} $1"; }
info() { echo -e "${BLUE}ℹ️  INFO:${NC} $1"; }

ERRORS=0

echo "=== Pagination Structure Check ==="
echo "Service directory: $SERVICE_DIR"
echo ""

# First, detect if API has list operations that would need pagination
echo "--- Detecting List Operations ---"

# Look for methods returning List, Page, PageResponse, or collection endpoints
HAS_LIST_OPERATION=false

# Check controllers for list operations
CONTROLLERS=$(find "$SERVICE_DIR" -name "*Controller.java" -type f 2>/dev/null)
if [ -n "$CONTROLLERS" ]; then
    for ctrl in $CONTROLLERS; do
        # Check for GetMapping returning List/Page/PageResponse or with no path param (collection)
        if grep -E "@GetMapping\s*(\(\s*\))?\s*$|@GetMapping\s*\([^)]*\)\s*$" "$ctrl" 2>/dev/null | grep -v "{" | grep -q .; then
            # GetMapping without path variable might be a list operation
            if grep -B5 "@GetMapping" "$ctrl" 2>/dev/null | grep -qE "List<|Page<|PageResponse<"; then
                HAS_LIST_OPERATION=true
                info "List operation detected in: $(basename $ctrl)"
                break
            fi
        fi
        # Check for explicit Page/List return types
        if grep -qE "ResponseEntity<(Page|List|PageResponse)<" "$ctrl" 2>/dev/null; then
            HAS_LIST_OPERATION=true
            info "Paginated return type detected in: $(basename $ctrl)"
            break
        fi
    done
fi

echo ""

if [ "$HAS_LIST_OPERATION" = false ]; then
    info "No list/pagination operations detected in controllers"
    info "PageResponse validation skipped (not required for single-resource APIs)"
    echo ""
    echo "=== Pagination Check Complete ==="
    echo "Result: SKIPPED (no list operations)"
    exit 0
fi

# If we have list operations, validate PageResponse structure
echo "--- PageResponse Validation ---"

# Check 1: PageResponse.java exists
PAGE_RESPONSE=$(find "$SERVICE_DIR" -name "PageResponse.java" -type f 2>/dev/null | head -1)
if [ -n "$PAGE_RESPONSE" ]; then
    pass "PageResponse.java exists"
    
    # Check 1a: PageResponse has content field
    if grep -q "List<T> content" "$PAGE_RESPONSE" 2>/dev/null; then
        pass "PageResponse has 'content' field"
    else
        fail "PageResponse missing 'content' field (List<T>)"
    fi
    
    # Check 1b: PageResponse has page metadata
    if grep -q "PageMetadata page" "$PAGE_RESPONSE" 2>/dev/null; then
        pass "PageResponse has 'page' metadata field"
    else
        fail "PageResponse missing 'page' metadata field"
    fi
    
    # Check 1c: PageResponse has _links
    if grep -q "_links" "$PAGE_RESPONSE" 2>/dev/null || grep -q "Links links" "$PAGE_RESPONSE" 2>/dev/null; then
        pass "PageResponse has '_links' field"
    else
        fail "PageResponse missing '_links' field for HATEOAS"
    fi
else
    fail "PageResponse.java not found (required for list operations)"
fi

# Check 2: PageMetadata structure
if [ -n "$PAGE_RESPONSE" ]; then
    echo ""
    echo "--- PageMetadata Validation ---"
    
    # Check for required fields in PageMetadata
    if grep -q "int number" "$PAGE_RESPONSE" 2>/dev/null; then
        pass "PageMetadata has 'number' field"
    else
        fail "PageMetadata missing 'number' field"
    fi
    
    if grep -q "int size" "$PAGE_RESPONSE" 2>/dev/null; then
        pass "PageMetadata has 'size' field"
    else
        fail "PageMetadata missing 'size' field"
    fi
    
    if grep -q "long totalElements" "$PAGE_RESPONSE" 2>/dev/null; then
        pass "PageMetadata has 'totalElements' field"
    else
        fail "PageMetadata missing 'totalElements' field"
    fi
    
    if grep -q "int totalPages" "$PAGE_RESPONSE" 2>/dev/null; then
        pass "PageMetadata has 'totalPages' field"
    else
        fail "PageMetadata missing 'totalPages' field"
    fi
fi

echo ""
echo "=== Pagination Check Complete ==="
echo "Errors: $ERRORS"

exit $ERRORS
