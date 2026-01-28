#!/bin/sh
# traceability-check.sh
# Universal validator - applies to ALL outputs from ALL domains
#
# Validates .enablement/manifest.json exists and contains required fields
# Updated for Model v3.0 (skill removed, discovery-based)
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

# Check 4: Required fields - check for common manifest fields
# Model v3.0 uses: version, generator, service, capabilities

if json_has_field "$MANIFEST" "version"; then
    pass "Field 'version' present"
else
    warn "Field 'version' missing"
fi

if json_has_field "$MANIFEST" "generator"; then
    pass "Field 'generator' present"
else
    warn "Field 'generator' missing"
fi

if json_has_field "$MANIFEST" "service"; then
    pass "Field 'service' present"
else
    fail "Field 'service' missing (required)"
fi

if json_has_field "$MANIFEST" "capabilities"; then
    pass "Field 'capabilities' present"
else
    warn "Field 'capabilities' missing"
fi

# Check 5: Service name is present
SERVICE_NAME=$(json_get_value "$MANIFEST" "name")
if [ -n "$SERVICE_NAME" ]; then
    pass "service.name: $SERVICE_NAME"
else
    warn "service.name is empty or not found"
fi

# Check 6: Stack is present
STACK=$(json_get_value "$MANIFEST" "stack")
if [ -n "$STACK" ]; then
    pass "service.stack: $STACK"
else
    warn "service.stack is empty or not found"
fi

# Check 7: generated_at timestamp present
TIMESTAMP=$(json_get_value "$MANIFEST" "generated_at")
if [ -n "$TIMESTAMP" ]; then
    pass "generated_at: $TIMESTAMP"
else
    warn "generated_at timestamp missing"
fi

# Check 8: Files array present (indicates traceability)
if json_has_field "$MANIFEST" "files"; then
    # Count file entries (rough estimate)
    FILE_COUNT=$(grep -c '"path"' "$MANIFEST" 2>/dev/null || echo "0")
    pass "files array present (~$FILE_COUNT entries)"
else
    warn "files array missing (recommended for traceability)"
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
