#!/bin/bash
# Validation script for mod-018-api-integration-rest-java-spring
# Tier-3 validation: Module-specific checks
# Version: 1.1
# Updated: 2026-01-23
# Changes: Also searches in */systemapi/* path for client files

# Note: Not using set -e to handle errors manually

TARGET_DIR="${1:-.}"
ERRORS=0
WARNINGS=0

echo "=== Integration REST Validation ==="
echo "Target: $TARGET_DIR"
echo ""

# Find client files in both /integration/ and /systemapi/ paths
CLIENT_FILES=$(find "$TARGET_DIR" -name "*Client.java" \( -path "*/integration/*" -o -path "*/systemapi/*" \) 2>/dev/null || true)

if [ -z "$CLIENT_FILES" ]; then
    echo "ℹ️  INFO: No integration/systemapi client files found"
    echo "   (This check applies when using mod-018 for generic REST integration)"
    exit 0
fi

for file in $CLIENT_FILES; do
    echo "Checking: $file"
    
    # Skip Feign declarative interfaces — they handle headers via FeignConfig, not inline
    if grep -q "@FeignClient\|public interface.*Client" "$file"; then
        echo "  ℹ️  SKIP: Feign declarative interface (headers handled by FeignConfig)"
        echo ""
        continue
    fi
    
    # ERROR: Correlation headers must be propagated
    # VB-001 FIX: Also detect constant reference CORRELATION_ID_HEADER
    if ! grep -qE "X-Correlation-ID|x-correlation-id|correlationId|CORRELATION_ID_HEADER" "$file"; then
        echo "  ❌ ERROR: Missing X-Correlation-ID header propagation"
        ERRORS=$((ERRORS + 1))
    else
        echo "  ✅ X-Correlation-ID header present"
    fi
    
    # ERROR: Base URL must be externalized
    if grep -q 'baseUrl = "http' "$file"; then
        echo "  ❌ ERROR: Base URL is hardcoded, must use environment variable"
        ERRORS=$((ERRORS + 1))
    else
        echo "  ✅ Base URL externalized"
    fi
    
    # WARNING: Source system header (optional)
    if ! grep -q "X-Source-System" "$file"; then
        echo "  ℹ️  INFO: X-Source-System header not set (optional)"
    else
        echo "  ✅ X-Source-System header present"
    fi
    
    # WARNING: Logging (optional)
    if ! grep -q "log.debug\|log.info\|LOG\.\|logger\." "$file"; then
        echo "  ℹ️  INFO: No logging found in client (optional)"
    else
        echo "  ✅ Logging present"
    fi
    
    echo ""
done

# Summary
echo "=== Summary ==="
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"

if [ $ERRORS -gt 0 ]; then
    echo "❌ Validation FAILED"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo "⚠️  Validation passed with warnings"
    exit 0
else
    echo "✅ Validation PASSED"
    exit 0
fi
