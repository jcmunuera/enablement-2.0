#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# Enablement 2.0 - Validation Suite Runner
# Template: runtime/validators/run-all.sh.tpl
# ═══════════════════════════════════════════════════════════════════
#
# USAGE: ./run-all.sh
#
# This script runs all validation scripts in tier1, tier2, tier3 directories
# and generates a JSON report.
#
# EXIT CODES:
#   0 - All validations passed
#   1 - One or more validations failed
#   Individual scripts can return:
#     0 - PASS
#     1 - FAIL
#     2 - SKIPPED (e.g., feature not applicable)
# ═══════════════════════════════════════════════════════════════════

# IMPORTANT: Do NOT use 'set -e' - we want to continue even if validations fail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/../output/{{SERVICE_NAME}}"
REPORTS_DIR="$SCRIPT_DIR/reports"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_PASSED=0
TOTAL_FAILED=0
TOTAL_SKIPPED=0

# Results for JSON report
declare -a TIER0_RESULTS
declare -a TIER1_RESULTS
declare -a TIER2_RESULTS
declare -a TIER3_RESULTS

run_validation() {
    local tier=$1
    local script=$2
    local name=$(basename "$script" .sh)
    
    # Aligned output
    printf "  %-40s " "$name"
    
    # Ensure script is executable
    if [[ ! -x "$script" ]]; then
        chmod +x "$script"
    fi
    
    # Run script and capture output and exit code
    local output
    local exit_code
    output=$("$script" "$PROJECT_DIR" 2>&1)
    exit_code=$?
    
    # Process result based on exit code
    case $exit_code in
        0)
            echo -e "${GREEN}PASS${NC}"
            eval "TIER${tier}_RESULTS+=(\"{\\\"name\\\": \\\"$name\\\", \\\"result\\\": \\\"PASS\\\"}\")"
            ((TOTAL_PASSED++))
            ;;
        2)
            echo -e "${YELLOW}SKIPPED${NC}"
            eval "TIER${tier}_RESULTS+=(\"{\\\"name\\\": \\\"$name\\\", \\\"result\\\": \\\"SKIPPED\\\"}\")"
            ((TOTAL_SKIPPED++))
            ;;
        *)
            echo -e "${RED}FAIL${NC}"
            # Show first 10 lines of error output
            echo "$output" | head -10 | sed 's/^/    /'
            eval "TIER${tier}_RESULTS+=(\"{\\\"name\\\": \\\"$name\\\", \\\"result\\\": \\\"FAIL\\\"}\")"
            ((TOTAL_FAILED++))
            ;;
    esac
}

# Header
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  ENABLEMENT 2.0 - VALIDATION SUITE${NC}"
echo -e "${BLUE}  Project: {{SERVICE_NAME}}${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
echo ""

# Check project directory exists
if [[ ! -d "$PROJECT_DIR" ]]; then
    echo -e "${RED}ERROR: Project directory not found: $PROJECT_DIR${NC}"
    exit 1
fi

# ─────────────────────────────────────────────────────────────────────
# TIER 0: Conformance Validations (Generation Process)
# ─────────────────────────────────────────────────────────────────────
echo -e "${BLUE}▶ TIER 0: Conformance Validations (DEC-024/DEC-025)${NC}"
if [[ -d "$SCRIPT_DIR/scripts/tier0" ]]; then
    for script in "$SCRIPT_DIR/scripts/tier0/"*.sh; do
        [[ -f "$script" ]] && run_validation "0" "$script"
    done
else
    echo "  (no tier0 scripts found)"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────
# TIER 1: Universal Validations
# ─────────────────────────────────────────────────────────────────────
echo -e "${BLUE}▶ TIER 1: Universal Validations${NC}"
if [[ -d "$SCRIPT_DIR/scripts/tier1" ]]; then
    for script in "$SCRIPT_DIR/scripts/tier1/"*.sh; do
        [[ -f "$script" ]] && run_validation "1" "$script"
    done
else
    echo "  (no tier1 scripts found)"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────
# TIER 2: Technology-specific Validations
# ─────────────────────────────────────────────────────────────────────
echo -e "${BLUE}▶ TIER 2: Technology Validations ({{STACK}})${NC}"
if [[ -d "$SCRIPT_DIR/scripts/tier2" ]]; then
    for script in "$SCRIPT_DIR/scripts/tier2/"*.sh; do
        [[ -f "$script" ]] && run_validation "2" "$script"
    done
else
    echo "  (no tier2 scripts found)"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────
# TIER 3: Module-specific Validations
# ─────────────────────────────────────────────────────────────────────
echo -e "${BLUE}▶ TIER 3: Module-specific Validations${NC}"
if [[ -d "$SCRIPT_DIR/scripts/tier3" ]]; then
    for script in "$SCRIPT_DIR/scripts/tier3/"*.sh; do
        [[ -f "$script" ]] && run_validation "3" "$script"
    done
else
    echo "  (no tier3 scripts found)"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────────────
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  SUMMARY${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "  Passed:  ${GREEN}$TOTAL_PASSED${NC}"
echo -e "  Failed:  ${RED}$TOTAL_FAILED${NC}"
echo -e "  Skipped: ${YELLOW}$TOTAL_SKIPPED${NC}"
echo ""

# Determine overall result
if [[ $TOTAL_FAILED -eq 0 ]]; then
    if [[ $TOTAL_SKIPPED -gt 0 ]]; then
        OVERALL="PASS_WITH_WARNINGS"
        echo -e "  Overall: ${YELLOW}$OVERALL${NC}"
    else
        OVERALL="PASS"
        echo -e "  Overall: ${GREEN}$OVERALL${NC}"
    fi
    EXIT_CODE=0
else
    OVERALL="FAIL"
    echo -e "  Overall: ${RED}$OVERALL${NC}"
    EXIT_CODE=1
fi
echo ""

# ─────────────────────────────────────────────────────────────────────
# Generate JSON Report
# ─────────────────────────────────────────────────────────────────────
mkdir -p "$REPORTS_DIR"

# Helper to join array elements
join_array() {
    local arr=("$@")
    local result=""
    for item in "${arr[@]}"; do
        if [[ -n "$result" ]]; then
            result="$result, $item"
        else
            result="$item"
        fi
    done
    echo "$result"
}

cat > "$REPORTS_DIR/validation-results.json" << EOF
{
  "version": "1.0",
  "run_id": "$(date +%Y%m%d_%H%M%S)",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "project": "{{SERVICE_NAME}}",
  "project_path": "$PROJECT_DIR",
  "summary": {
    "overall_result": "$OVERALL",
    "total_validations": $((TOTAL_PASSED + TOTAL_FAILED + TOTAL_SKIPPED)),
    "passed": $TOTAL_PASSED,
    "failed": $TOTAL_FAILED,
    "skipped": $TOTAL_SKIPPED
  },
  "tiers": {
    "tier1": {
      "name": "Universal",
      "validations": [$(join_array "${TIER1_RESULTS[@]}")]
    },
    "tier2": {
      "name": "Technology ({{STACK}})",
      "validations": [$(join_array "${TIER2_RESULTS[@]}")]
    },
    "tier3": {
      "name": "Module-specific",
      "validations": [$(join_array "${TIER3_RESULTS[@]}")]
    }
  }
}
EOF

echo "Report saved to: $REPORTS_DIR/validation-results.json"
echo ""

exit $EXIT_CODE
