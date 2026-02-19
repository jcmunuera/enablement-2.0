#!/bin/sh
# traceability-check.sh
# Universal validator - applies to ALL outputs from ALL domains
#
# Validates .enablement/manifest.json exists and contains required fields
# Updated for Model v3.0.11 - matches actual manifest structure from CodeGen
#
# POSIX compatible - does NOT require jq (uses grep/sed)

OUTPUT_DIR="${1:-.}"
ERRORS=0
WARNINGS=0

# Output functions
pass() { echo "✅ PASS: $1"; }
fail() { echo "❌ FAIL: $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo "⚠️  WARN: $1"; WARNINGS=$((WARNINGS + 1)); }
skip() { echo "⏭️  SKIP: $1"; }

# JSON helper: check if a field exists (basic grep-based)
json_has_field() {
    local file="$1"
    local field="$2"
    grep -q "\"$field\"" "$file" 2>/dev/null
}

# JSON helper: extract simple string value
json_get_value() {
    local file="$1"
    local field="$2"
    grep "\"$field\"" "$file" 2>/dev/null | sed 's/.*"'"$field"'"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' | head -1
}

echo "════════════════════════════════════════════════════════════"
echo "  TIER 1 - TRACEABILITY VALIDATION (Universal)"
echo "════════════════════════════════════════════════════════════"
echo "  Target: $OUTPUT_DIR"
echo "════════════════════════════════════════════════════════════"

# Check 1: .enablement directory exists
if [ -d "$OUTPUT_DIR/.enablement" ]; then
    pass ".enablement/ directory exists"
else
    fail ".enablement/ directory not found"
    echo "    Every generated output MUST include .enablement/ directory"
    exit 1
fi

# Check 2: manifest.json exists
MANIFEST="$OUTPUT_DIR/.enablement/manifest.json"
if [ -f "$MANIFEST" ]; then
    pass "manifest.json exists"
else
    fail "manifest.json not found in .enablement/"
    exit 1
fi

# Check 3: Valid JSON (basic check - looks for opening/closing braces)
if head -1 "$MANIFEST" | grep -q "^{" && tail -1 "$MANIFEST" | grep -q "}$"; then
    pass "manifest.json appears to be valid JSON"
else
    fail "manifest.json does not appear to be valid JSON"
    exit 1
fi

# Check 4: Required fields - adapted for actual manifest structure
# Actual structure has: generation, enablement, modules, status, metrics

if json_has_field "$MANIFEST" "generation"; then
    pass "Field 'generation' present"
else
    fail "Field 'generation' missing (required)"
fi

if json_has_field "$MANIFEST" "enablement"; then
    pass "Field 'enablement' present"
else
    fail "Field 'enablement' missing (required)"
fi

if json_has_field "$MANIFEST" "modules"; then
    pass "Field 'modules' present"
else
    warn "Field 'modules' missing"
fi

if json_has_field "$MANIFEST" "status"; then
    pass "Field 'status' present"
else
    warn "Field 'status' missing"
fi

# Check 5: Service name is present (in generation section)
SERVICE_NAME=$(json_get_value "$MANIFEST" "service_name")
if [ -n "$SERVICE_NAME" ]; then
    pass "generation.service_name: $SERVICE_NAME"
else
    warn "generation.service_name is empty or not found"
fi

# Check 6: Enablement version present
VERSION=$(json_get_value "$MANIFEST" "version")
if [ -n "$VERSION" ]; then
    pass "enablement.version: $VERSION"
else
    warn "enablement.version is empty or not found"
fi

# Check 7: Timestamp present
TIMESTAMP=$(json_get_value "$MANIFEST" "timestamp")
if [ -n "$TIMESTAMP" ]; then
    pass "generation.timestamp: $TIMESTAMP"
else
    warn "generation.timestamp missing"
fi

# Check 8: Modules array has entries
if json_has_field "$MANIFEST" "modules"; then
    MODULE_COUNT=$(grep -c '"id"' "$MANIFEST" 2>/dev/null || echo "0")
    if [ "$MODULE_COUNT" -gt 0 ]; then
        pass "modules array has ~$MODULE_COUNT entries"
    else
        warn "modules array appears empty"
    fi
fi

# Check 9: Generation status
GEN_STATUS=$(json_get_value "$MANIFEST" "generation")
# Look for SUCCESS in the status section
if grep -q '"generation"[[:space:]]*:[[:space:]]*"SUCCESS"' "$MANIFEST" 2>/dev/null; then
    pass "status.generation: SUCCESS"
else
    warn "status.generation not found or not SUCCESS"
fi

# Summary
echo ""
echo "════════════════════════════════════════════════════════════"
if [ $ERRORS -eq 0 ]; then
    echo "  ✅ TRACEABILITY: PASSED ($WARNINGS warnings)"
else
    echo "  ❌ TRACEABILITY: FAILED ($ERRORS errors, $WARNINGS warnings)"
fi
echo "════════════════════════════════════════════════════════════"

exit $ERRORS
