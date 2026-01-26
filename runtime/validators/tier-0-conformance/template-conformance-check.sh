#!/bin/bash
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
#   ./template-conformance-check.sh <service_dir> [generation-context.json]
#
# EXIT CODES:
#   0 - All conformance checks passed
#   1 - One or more conformance checks failed
#
# REQUIRES:
#   - generation-context.json in trace/ directory
#   - Fingerprint definitions in this script
#
# ═══════════════════════════════════════════════════════════════════════════════

SERVICE_DIR="${1:-.}"
CONTEXT_FILE="${2:-$SERVICE_DIR/../trace/generation-context.json}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

pass() { echo -e "${GREEN}✅ PASS:${NC} $1"; PASSED=$((PASSED + 1)); }
fail() { echo -e "${RED}❌ FAIL:${NC} $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo -e "${YELLOW}⚠️  WARN:${NC} $1"; }
info() { echo -e "${CYAN}ℹ️  INFO:${NC} $1"; }

ERRORS=0
PASSED=0

echo "════════════════════════════════════════════════════════════"
echo "  TEMPLATE CONFORMANCE CHECK (DEC-024/DEC-025)"
echo "════════════════════════════════════════════════════════════"
echo "  Service: $SERVICE_DIR"
echo "  Context: $CONTEXT_FILE"
echo "════════════════════════════════════════════════════════════"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# FINGERPRINT DEFINITIONS
# ═══════════════════════════════════════════════════════════════════════════════
# Each module has mandatory patterns that MUST appear in generated code
# if the template was followed correctly.
#
# Format: MODULE_FINGERPRINTS["module-id:file-pattern"]="pattern1|pattern2|..."
# ═══════════════════════════════════════════════════════════════════════════════

declare -A MODULE_FINGERPRINTS

# mod-code-015: Hexagonal Base
MODULE_FINGERPRINTS["mod-code-015:CorrelationIdFilter.java"]="public static final String CORRELATION_ID_HEADER|public static final String CORRELATION_ID_MDC_KEY|public static String getCurrentCorrelationId|extractOrGenerate"
MODULE_FINGERPRINTS["mod-code-015:GlobalExceptionHandler.java"]="@RestControllerAdvice|ProblemDetail"

# mod-code-019: API Public Exposure (HATEOAS)
MODULE_FINGERPRINTS["mod-code-019:*ModelAssembler.java"]="extends RepresentationModelAssemblerSupport|super(.*Controller.class.*Response.class)|withSelfRel"
MODULE_FINGERPRINTS["mod-code-019:*Response.java"]="extends RepresentationModel"

# mod-code-017: Persistence SystemAPI
MODULE_FINGERPRINTS["mod-code-017:*SystemApiAdapter.java"]="implements.*Repository|@Component"
MODULE_FINGERPRINTS["mod-code-017:*SystemApiMapper.java"]="@Component|toDomain|toRequest"

# mod-code-018: API Integration REST
MODULE_FINGERPRINTS["mod-code-018:*Client.java"]="RestClient|@Component"
MODULE_FINGERPRINTS["mod-code-018:RestClientConfig.java"]="@Configuration|RestClient.Builder|SimpleClientHttpRequestFactory"

# mod-code-001: Circuit Breaker (only applies to SystemApiAdapter)
MODULE_FINGERPRINTS["mod-code-001:*SystemApiAdapter.java"]="@CircuitBreaker"

# mod-code-002: Retry (only applies to SystemApiAdapter)
MODULE_FINGERPRINTS["mod-code-002:*SystemApiAdapter.java"]="@Retry"

# ═══════════════════════════════════════════════════════════════════════════════
# CHECK FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

check_fingerprints() {
    local file="$1"
    local patterns="$2"
    local filename=$(basename "$file")
    local all_found=true
    
    IFS='|' read -ra PATTERNS <<< "$patterns"
    for pattern in "${PATTERNS[@]}"; do
        if grep -qE "$pattern" "$file" 2>/dev/null; then
            : # Pattern found
        else
            fail "$filename: Missing required pattern: $pattern"
            all_found=false
        fi
    done
    
    if $all_found; then
        pass "$filename: All fingerprints present"
    fi
}

match_file_pattern() {
    local file="$1"
    local pattern="$2"
    local filename=$(basename "$file")
    
    # Convert glob pattern to regex
    local regex=$(echo "$pattern" | sed 's/\*/.*/g')
    
    if [[ "$filename" =~ $regex ]]; then
        return 0
    fi
    return 1
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN VALIDATION
# ═══════════════════════════════════════════════════════════════════════════════

echo "── Checking Module Fingerprints ────────────────────────────"
echo ""

# Find all Java files
JAVA_FILES=$(find "$SERVICE_DIR" -name "*.java" -type f 2>/dev/null)

for key in "${!MODULE_FINGERPRINTS[@]}"; do
    module_id="${key%%:*}"
    file_pattern="${key##*:}"
    patterns="${MODULE_FINGERPRINTS[$key]}"
    
    # Find files matching the pattern
    for java_file in $JAVA_FILES; do
        if match_file_pattern "$java_file" "$file_pattern"; then
            info "Checking $module_id conformance: $(basename $java_file)"
            check_fingerprints "$java_file" "$patterns"
        fi
    done
done

# ═══════════════════════════════════════════════════════════════════════════════
# SPECIFIC CHECKS FOR COMMON IMPROVISATIONS
# ═══════════════════════════════════════════════════════════════════════════════

echo ""
echo "── Anti-Improvisation Checks ───────────────────────────────"
echo ""

# Check: No implements RepresentationModelAssembler (should be extends ...Support)
WRONG_ASSEMBLERS=$(grep -rl "implements RepresentationModelAssembler" "$SERVICE_DIR" 2>/dev/null | grep -v ".class")
if [ -n "$WRONG_ASSEMBLERS" ]; then
    for file in $WRONG_ASSEMBLERS; do
        fail "$(basename $file): Uses 'implements RepresentationModelAssembler' instead of 'extends RepresentationModelAssemblerSupport'"
    done
else
    pass "No incorrect RepresentationModelAssembler implementations"
fi

# Check: CorrelationIdFilter has getCurrentCorrelationId() method
CORRELATION_FILTER=$(find "$SERVICE_DIR" -name "CorrelationIdFilter.java" -type f 2>/dev/null | head -1)
if [ -n "$CORRELATION_FILTER" ]; then
    if grep -q "getCurrentCorrelationId" "$CORRELATION_FILTER" 2>/dev/null; then
        pass "CorrelationIdFilter has getCurrentCorrelationId() method"
    else
        fail "CorrelationIdFilter missing getCurrentCorrelationId() method (required for correlation propagation)"
    fi
fi

# Check: Assembler naming convention (*ModelAssembler, not *ResponseAssembler)
WRONG_ASSEMBLER_NAMES=$(find "$SERVICE_DIR" -name "*ResponseAssembler.java" -type f 2>/dev/null)
if [ -n "$WRONG_ASSEMBLER_NAMES" ]; then
    for file in $WRONG_ASSEMBLER_NAMES; do
        fail "$(basename $file): Should be named '*ModelAssembler.java' per template"
    done
else
    pass "Assembler naming convention correct (*ModelAssembler)"
fi

# Check: Constants are public static final (not private)
CORRELATION_FILTER=$(find "$SERVICE_DIR" -name "CorrelationIdFilter.java" -type f 2>/dev/null | head -1)
if [ -n "$CORRELATION_FILTER" ]; then
    if grep -q "private static final String CORRELATION_ID" "$CORRELATION_FILTER" 2>/dev/null; then
        fail "CorrelationIdFilter: Constants should be 'public static final' not 'private static final'"
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
    echo -e "  ${RED}RESULT: FAILED${NC}"
    echo ""
    echo "  Generated code does not conform to templates."
    echo "  This indicates DEC-024/DEC-025 violation (improvisation)."
    echo ""
    exit 1
else
    echo -e "  ${GREEN}RESULT: PASSED${NC}"
    echo ""
    echo "  Generated code conforms to expected templates."
    echo ""
    exit 0
fi
