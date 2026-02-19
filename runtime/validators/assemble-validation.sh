#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# assemble-validation.sh
# Assembles validation scripts from KB into a package's validation directory
# ═══════════════════════════════════════════════════════════════════════════════
#
# USAGE:
#   ./assemble-validation.sh <validation-dir> <service-name> <stack> <module-1> [module-2] ...
#
# EXAMPLE:
#   ./assemble-validation.sh ./gen_customer-api/validation customer-api java-spring \
#       mod-code-015 mod-code-017 mod-code-018 mod-code-019 \
#       mod-code-001 mod-code-002 mod-code-003
#
# This script is MANDATORY for Phase 6 (DEC-034).
# DO NOT manually create or copy validation scripts.
# ═══════════════════════════════════════════════════════════════════════════════

set -e

# ─────────────────────────────────────────────────────────────────────────────
# Arguments
# ─────────────────────────────────────────────────────────────────────────────
VALIDATION_DIR="$1"
SERVICE_NAME="$2"
STACK="$3"
shift 3
MODULES=("$@")

if [ -z "$VALIDATION_DIR" ] || [ -z "$SERVICE_NAME" ] || [ -z "$STACK" ]; then
    echo "ERROR: Missing required arguments"
    echo "Usage: $0 <validation-dir> <service-name> <stack> <module-1> [module-2] ..."
    exit 1
fi

# ─────────────────────────────────────────────────────────────────────────────
# Resolve KB root (relative to this script's location)
# ─────────────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KB_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "═══════════════════════════════════════════════════════════════════════════════"
echo "VALIDATION ASSEMBLY (DEC-034)"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo "  Target:    $VALIDATION_DIR"
echo "  Service:   $SERVICE_NAME"
echo "  Stack:     $STACK"
echo "  Modules:   ${MODULES[*]}"
echo "  KB Root:   $KB_ROOT"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Create directory structure
# ─────────────────────────────────────────────────────────────────────────────
echo "▶ Creating directory structure..."
mkdir -p "$VALIDATION_DIR/scripts/tier0"
mkdir -p "$VALIDATION_DIR/scripts/tier1"
mkdir -p "$VALIDATION_DIR/scripts/tier2"
mkdir -p "$VALIDATION_DIR/scripts/tier3"
mkdir -p "$VALIDATION_DIR/reports"

COPIED=0
SKIPPED=0

# ─────────────────────────────────────────────────────────────────────────────
# Tier 0: Conformance (from runtime/validators/tier-0-conformance/)
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "▶ TIER 0: Conformance scripts..."
TIER0_SRC="$KB_ROOT/runtime/validators/tier-0-conformance"
if [ -d "$TIER0_SRC" ]; then
    for script in "$TIER0_SRC"/*.sh; do
        if [ -f "$script" ] && [[ ! "$(basename "$script")" == ._* ]]; then
            cp "$script" "$VALIDATION_DIR/scripts/tier0/"
            echo "   ✓ $(basename "$script")"
            COPIED=$((COPIED + 1))
        fi
    done
else
    echo "   ⚠ Source not found: $TIER0_SRC"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Tier 1: Universal (from runtime/validators/tier-1-universal/)
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "▶ TIER 1: Universal scripts..."
TIER1_SRC="$KB_ROOT/runtime/validators/tier-1-universal"
if [ -d "$TIER1_SRC" ]; then
    # Find all .sh files recursively
    find "$TIER1_SRC" -name "*.sh" -type f | while read script; do
        if [[ ! "$(basename "$script")" == ._* ]]; then
            cp "$script" "$VALIDATION_DIR/scripts/tier1/"
            echo "   ✓ $(basename "$script")"
        fi
    done
    COPIED=$((COPIED + $(find "$TIER1_SRC" -name "*.sh" -type f | grep -v "/\._" | wc -l)))
else
    echo "   ⚠ Source not found: $TIER1_SRC"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Tier 2: Technology-specific (based on stack)
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "▶ TIER 2: Technology scripts ($STACK)..."
TIER2_SRC="$KB_ROOT/runtime/validators/tier-2-technology/code-projects/$STACK"
if [ -d "$TIER2_SRC" ]; then
    for script in "$TIER2_SRC"/*.sh; do
        if [ -f "$script" ] && [[ ! "$(basename "$script")" == ._* ]]; then
            cp "$script" "$VALIDATION_DIR/scripts/tier2/"
            echo "   ✓ $(basename "$script")"
            COPIED=$((COPIED + 1))
        fi
    done
else
    echo "   ⚠ Source not found: $TIER2_SRC"
    echo "   Available stacks:"
    ls "$KB_ROOT/runtime/validators/tier-2-technology/code-projects/" 2>/dev/null || echo "     (none)"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Tier 3: Module-specific (from modules/{module-id}/validation/)
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "▶ TIER 3: Module-specific scripts..."
for module in "${MODULES[@]}"; do
    # Find module directory (handles variations like mod-code-001-circuit-breaker-java-resilience4j)
    MODULE_DIR=$(find "$KB_ROOT/modules" -maxdepth 1 -type d -name "${module}*" 2>/dev/null | head -1)
    
    if [ -n "$MODULE_DIR" ] && [ -d "$MODULE_DIR/validation" ]; then
        echo "   [$module]"
        for script in "$MODULE_DIR/validation"/*.sh; do
            if [ -f "$script" ] && [[ ! "$(basename "$script")" == ._* ]]; then
                cp "$script" "$VALIDATION_DIR/scripts/tier3/"
                echo "      ✓ $(basename "$script")"
                COPIED=$((COPIED + 1))
            fi
        done
    else
        echo "   [$module] ⚠ No validation scripts found"
        SKIPPED=$((SKIPPED + 1))
    fi
done

# ─────────────────────────────────────────────────────────────────────────────
# Copy and configure run-all.sh
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "▶ Configuring run-all.sh..."
TEMPLATE="$KB_ROOT/runtime/validators/run-all.sh.tpl"
if [ -f "$TEMPLATE" ]; then
    sed -e "s/{{SERVICE_NAME}}/$SERVICE_NAME/g" \
        -e "s/{{STACK}}/$STACK/g" \
        "$TEMPLATE" > "$VALIDATION_DIR/run-all.sh"
    
    # Verify the marker exists (proves it came from template)
    if grep -q "TEMPLATE_MARKER: ENABLEMENT_2_0_RUN_ALL_V2" "$VALIDATION_DIR/run-all.sh"; then
        echo "   ✓ run-all.sh (from template, verified)"
    else
        echo "   ⚠ run-all.sh created but marker not found - may be corrupted"
    fi
else
    echo "   ✗ Template not found: $TEMPLATE"
    echo "   ⚠ DO NOT generate run-all.sh manually!"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Make all scripts executable
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "▶ Setting permissions..."
find "$VALIDATION_DIR" -name "*.sh" -type f -exec chmod +x {} \;
echo "   ✓ All scripts marked executable"

# ─────────────────────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════════════════════════════"
echo "ASSEMBLY COMPLETE"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""
echo "Scripts copied:"
find "$VALIDATION_DIR/scripts" -name "*.sh" -type f | sort | while read f; do
    tier=$(basename "$(dirname "$f")")
    echo "  [$tier] $(basename "$f")"
done
echo ""
TOTAL=$(find "$VALIDATION_DIR/scripts" -name "*.sh" -type f | wc -l)
echo "Total: $TOTAL scripts"
echo ""
echo "To run validations:"
echo "  cd $VALIDATION_DIR && ./run-all.sh"
echo ""
