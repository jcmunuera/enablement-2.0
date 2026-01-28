#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════════════
# Template Conformance Check (DEC-024/DEC-025 Enforcement)
# ═══════════════════════════════════════════════════════════════════════════════
#
# PURPOSE:
#   Validates that generated code conforms to expected templates by checking
#   mandatory "fingerprints" - unique patterns that MUST appear if the template
#   was followed correctly.
#
# USAGE:
#   ./template-conformance-check.sh <package_dir>
#
# EXIT CODES:
#   0 - All conformance checks passed
#   1 - One or more conformance checks failed
#
# POSIX COMPATIBLE - works with sh/bash 3.2+ (macOS default)
#
# ═══════════════════════════════════════════════════════════════════════════════

PACKAGE_DIR="${1:-.}"
SERVICE_DIR="$PACKAGE_DIR/output"

# Find the actual service directory (first subdirectory of output/)
if [ -d "$SERVICE_DIR" ]; then
    ACTUAL_SERVICE=$(ls "$SERVICE_DIR" 2>/dev/null | head -1)
    if [ -n "$ACTUAL_SERVICE" ]; then
        SERVICE_DIR="$SERVICE_DIR/$ACTUAL_SERVICE"
    fi
fi

ERRORS=0
PASSED=0

pass() { echo "✅ PASS: $1"; PASSED=$((PASSED + 1)); }
fail() { echo "❌ FAIL: $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo "⚠️  WARN: $1"; }
info() { echo "ℹ️  INFO: $1"; }

echo "════════════════════════════════════════════════════════════"
echo "  TEMPLATE CONFORMANCE CHECK (DEC-024/DEC-025)"
echo "════════════════════════════════════════════════════════════"
echo "  Package: $PACKAGE_DIR"
echo "  Service: $SERVICE_DIR"
echo "════════════════════════════════════════════════════════════"
echo ""

# Check service directory exists
if [ ! -d "$SERVICE_DIR" ]; then
    fail "Service directory not found: $SERVICE_DIR"
    exit 1
fi

# ═══════════════════════════════════════════════════════════════════════════════
# FINGERPRINT CHECK FUNCTION
# ═══════════════════════════════════════════════════════════════════════════════
# Checks if a file contains all required patterns (pipe-separated)
# Usage: check_fingerprints "file" "pattern1|pattern2|pattern3"

check_fingerprints() {
    file="$1"
    patterns="$2"
    filename=$(basename "$file")
    all_found=true
    
    # Split patterns by | and check each
    echo "$patterns" | tr '|' '\n' | while read pattern; do
        if [ -n "$pattern" ]; then
            if grep -qE "$pattern" "$file" 2>/dev/null; then
                : # Pattern found
            else
                echo "❌ FAIL: $filename: Missing required pattern: $pattern"
                # Note: can't increment ERRORS here due to subshell
            fi
        fi
    done
}

# ═══════════════════════════════════════════════════════════════════════════════
# FINGERPRINT CHECKS BY MODULE
# ═══════════════════════════════════════════════════════════════════════════════

echo "── Checking Module Fingerprints ────────────────────────────"
echo ""

# mod-code-015: Hexagonal Base - CorrelationIdFilter
CORR_FILTER=$(find "$SERVICE_DIR" -name "CorrelationIdFilter.java" -type f 2>/dev/null | head -1)
if [ -n "$CORR_FILTER" ]; then
    info "Checking mod-code-015: CorrelationIdFilter.java"
    MISSING=0
    if grep -q "public static final String CORRELATION_ID_HEADER" "$CORR_FILTER" 2>/dev/null; then
        : # OK
    else
        fail "CorrelationIdFilter: Missing CORRELATION_ID_HEADER constant"
        MISSING=1
    fi
    if grep -q "getCurrentCorrelationId" "$CORR_FILTER" 2>/dev/null; then
        : # OK
    else
        fail "CorrelationIdFilter: Missing getCurrentCorrelationId() method"
        MISSING=1
    fi
    if [ $MISSING -eq 0 ]; then
        pass "CorrelationIdFilter: All fingerprints present"
    fi
fi

# mod-code-015: GlobalExceptionHandler
EXCEPTION_HANDLER=$(find "$SERVICE_DIR" -name "GlobalExceptionHandler.java" -type f 2>/dev/null | head -1)
if [ -n "$EXCEPTION_HANDLER" ]; then
    info "Checking mod-code-015: GlobalExceptionHandler.java"
    MISSING=0
    if grep -q "@RestControllerAdvice" "$EXCEPTION_HANDLER" 2>/dev/null; then
        : # OK
    else
        fail "GlobalExceptionHandler: Missing @RestControllerAdvice"
        MISSING=1
    fi
    if grep -q "@ExceptionHandler" "$EXCEPTION_HANDLER" 2>/dev/null; then
        : # OK
    else
        fail "GlobalExceptionHandler: Missing @ExceptionHandler"
        MISSING=1
    fi
    if [ $MISSING -eq 0 ]; then
        pass "GlobalExceptionHandler: All fingerprints present"
    fi
fi

# mod-code-019: ModelAssembler (HATEOAS)
ASSEMBLERS=$(find "$SERVICE_DIR" -name "*ModelAssembler.java" -type f 2>/dev/null)
for assembler in $ASSEMBLERS; do
    if [ -n "$assembler" ]; then
        info "Checking mod-code-019: $(basename $assembler)"
        MISSING=0
        if grep -q "extends RepresentationModelAssemblerSupport" "$assembler" 2>/dev/null; then
            : # OK
        else
            fail "$(basename $assembler): Should extend RepresentationModelAssemblerSupport"
            MISSING=1
        fi
        if grep -q "withSelfRel" "$assembler" 2>/dev/null; then
            : # OK
        else
            warn "$(basename $assembler): Missing withSelfRel() call"
        fi
        if [ $MISSING -eq 0 ]; then
            pass "$(basename $assembler): All fingerprints present"
        fi
    fi
done

# mod-code-017: SystemApiAdapter
ADAPTERS=$(find "$SERVICE_DIR" -name "*SystemApiAdapter.java" -o -name "*Adapter.java" 2>/dev/null | grep -i "systemapi\|adapter")
for adapter in $ADAPTERS; do
    if [ -n "$adapter" ] && [ -f "$adapter" ]; then
        info "Checking mod-code-017: $(basename $adapter)"
        MISSING=0
        if grep -q "implements.*Repository" "$adapter" 2>/dev/null; then
            : # OK
        else
            warn "$(basename $adapter): Should implement a Repository interface"
        fi
        if grep -q "@Component\|@Service\|@Repository" "$adapter" 2>/dev/null; then
            : # OK
        else
            fail "$(basename $adapter): Missing Spring component annotation"
            MISSING=1
        fi
        if [ $MISSING -eq 0 ]; then
            pass "$(basename $adapter): All fingerprints present"
        fi
    fi
done

# mod-code-018: RestClient configuration
REST_CONFIG=$(find "$SERVICE_DIR" -name "RestClientConfig.java" -type f 2>/dev/null | head -1)
if [ -n "$REST_CONFIG" ]; then
    info "Checking mod-code-018: RestClientConfig.java"
    MISSING=0
    if grep -q "@Configuration" "$REST_CONFIG" 2>/dev/null; then
        : # OK
    else
        fail "RestClientConfig: Missing @Configuration"
        MISSING=1
    fi
    if grep -q "RestClient" "$REST_CONFIG" 2>/dev/null; then
        : # OK
    else
        fail "RestClientConfig: Missing RestClient reference"
        MISSING=1
    fi
    if [ $MISSING -eq 0 ]; then
        pass "RestClientConfig: All fingerprints present"
    fi
fi

# mod-code-001/002: Resilience annotations on adapters
for adapter in $ADAPTERS; do
    if [ -n "$adapter" ] && [ -f "$adapter" ]; then
        if grep -q "@CircuitBreaker" "$adapter" 2>/dev/null; then
            pass "$(basename $adapter): @CircuitBreaker annotation present"
        fi
        if grep -q "@Retry" "$adapter" 2>/dev/null; then
            pass "$(basename $adapter): @Retry annotation present"
        fi
        if grep -q "@TimeLimiter" "$adapter" 2>/dev/null; then
            pass "$(basename $adapter): @TimeLimiter annotation present"
        fi
    fi
done

# ═══════════════════════════════════════════════════════════════════════════════
# ANTI-IMPROVISATION CHECKS
# ═══════════════════════════════════════════════════════════════════════════════

echo ""
echo "── Anti-Improvisation Checks ───────────────────────────────"
echo ""

# Check: No implements RepresentationModelAssembler (should extend Support)
WRONG_ASSEMBLERS=$(grep -rl "implements RepresentationModelAssembler" "$SERVICE_DIR" 2>/dev/null | grep "\.java$")
if [ -n "$WRONG_ASSEMBLERS" ]; then
    for file in $WRONG_ASSEMBLERS; do
        fail "$(basename $file): Uses 'implements' instead of 'extends RepresentationModelAssemblerSupport'"
    done
else
    pass "No incorrect RepresentationModelAssembler implementations"
fi

# Check: Assembler naming convention
WRONG_NAMES=$(find "$SERVICE_DIR" -name "*ResponseAssembler.java" -type f 2>/dev/null)
if [ -n "$WRONG_NAMES" ]; then
    for file in $WRONG_NAMES; do
        fail "$(basename $file): Should be named '*ModelAssembler.java'"
    done
else
    pass "Assembler naming convention correct"
fi

# Check: Constants visibility in CorrelationIdFilter
if [ -n "$CORR_FILTER" ]; then
    if grep -q "private static final String CORRELATION_ID" "$CORR_FILTER" 2>/dev/null; then
        fail "CorrelationIdFilter: Constants should be 'public static final' not 'private'"
    else
        pass "CorrelationIdFilter: Constants visibility correct"
    fi
fi

# ═══════════════════════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════════════════════

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  TEMPLATE CONFORMANCE SUMMARY"
echo "════════════════════════════════════════════════════════════"
echo "  Passed: $PASSED"
echo "  Failed: $ERRORS"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo "  RESULT: FAILED"
    echo ""
    echo "  Generated code does not fully conform to templates."
    echo "  Review failures above for DEC-024/DEC-025 violations."
    echo ""
    exit 1
else
    echo "  RESULT: PASSED"
    echo ""
    echo "  Generated code conforms to expected templates."
    echo ""
    exit 0
fi
