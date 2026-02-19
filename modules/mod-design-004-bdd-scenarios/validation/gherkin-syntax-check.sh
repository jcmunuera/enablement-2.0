#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# gherkin-syntax-check.sh — Validates .feature file structure
# Module: mod-design-004-bdd-scenarios
# Version: 1.0
# ═══════════════════════════════════════════════════════════════
#
# Usage: ./gherkin-syntax-check.sh <feature-file>

set -euo pipefail

FILE="${1:?Usage: gherkin-syntax-check.sh <feature-file>}"

ERRORS=0
WARNINGS=0

error() { echo "  ERROR: $1"; ERRORS=$((ERRORS + 1)); }
warn()  { echo "  WARNING: $1"; WARNINGS=$((WARNINGS + 1)); }
info()  { echo "  OK: $1"; }

echo "═══════════════════════════════════════════════════════════"
echo "  Gherkin Syntax Validation"
echo "  File: $FILE"
echo "═══════════════════════════════════════════════════════════"

# Check file exists
if [ ! -f "$FILE" ]; then
    error "File not found: $FILE"
    exit 1
fi

# Check 1: Feature keyword
echo ""
echo "── Check 1: Feature keyword"
if grep -q "^Feature:" "$FILE"; then
    info "Feature keyword present"
else
    error "No Feature: keyword found"
fi

# Check 2: At least one Scenario
echo "── Check 2: Scenarios present"
SCENARIO_COUNT=$(grep -c "^  Scenario:" "$FILE" || true)
if [ "$SCENARIO_COUNT" -gt 0 ]; then
    info "$SCENARIO_COUNT scenarios found"
else
    error "No scenarios found"
fi

# Check 3: No HTTP codes in scenarios
echo "── Check 3: No HTTP codes"
HTTP_CODES=$(grep -n "\bHTTP\b\|status code [0-9]\{3\}\|responds with [0-9]\{3\}\|returns [0-9]\{3\}\|HTTP [0-9]\{3\}" "$FILE" | grep -v "^#" || true)
if [ -z "$HTTP_CODES" ]; then
    info "No HTTP codes found"
else
    while IFS= read -r line; do
        error "Technology detail found: $line"
    done <<< "$HTTP_CODES"
fi

# Check 4: No JSON references
echo "── Check 4: No JSON references"
JSON_REFS=$(grep -ni "\"json\"\|\.json\|application/json\|JSON body\|JSON response" "$FILE" | grep -v "^#" || true)
if [ -z "$JSON_REFS" ]; then
    info "No JSON references found"
else
    while IFS= read -r line; do
        error "Technology detail found: $line"
    done <<< "$JSON_REFS"
fi

# Check 5: Single When per scenario (Python check for multi-line parsing)
echo "── Check 5: Single When per scenario"
MULTI_WHEN=$(FILE_PATH="$FILE" python3 << 'PYEOF'
import os

file_path = os.environ['FILE_PATH']
with open(file_path) as f:
    lines = f.readlines()

in_scenario = False
scenario_name = ""
when_count = 0
issues = []

for line in lines:
    stripped = line.strip()
    if stripped.startswith("Scenario:"):
        if in_scenario and when_count > 1:
            issues.append(f"Scenario '{scenario_name}' has {when_count} When steps (must be 1)")
        scenario_name = stripped.replace("Scenario:", "").strip()
        in_scenario = True
        when_count = 0
    elif stripped.startswith("When ") and in_scenario:
        when_count += 1

# Check last scenario
if in_scenario and when_count > 1:
    issues.append(f"Scenario '{scenario_name}' has {when_count} When steps (must be 1)")

for issue in issues:
    print(f"ERROR:{issue}")
if not issues:
    print("OK")
PYEOF
2>&1)

while IFS= read -r line; do
    case "$line" in
        ERROR:*) error "${line#ERROR:}" ;;
        OK) info "Single When per scenario" ;;
    esac
done <<< "$MULTI_WHEN"

echo ""
echo "═══════════════════════════════════════════════════════════"
if [ "$ERRORS" -gt 0 ]; then
    echo "  RESULT: FAIL ($ERRORS errors, $WARNINGS warnings)"
    exit 1
else
    echo "  RESULT: PASS ($WARNINGS warnings)"
    exit 0
fi
