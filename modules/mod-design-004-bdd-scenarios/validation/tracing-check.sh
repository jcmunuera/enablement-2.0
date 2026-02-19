#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# tracing-check.sh — Validates scenario-tracing.yaml completeness
# Module: mod-design-004-bdd-scenarios
# Version: 1.0
# ═══════════════════════════════════════════════════════════════
#
# Usage: ./tracing-check.sh <scenario-tracing.yaml> <feature-file>

set -euo pipefail

TRACE="${1:?Usage: tracing-check.sh <scenario-tracing.yaml> <feature-file>}"
FEATURE="${2:?Usage: tracing-check.sh <scenario-tracing.yaml> <feature-file>}"

echo "═══════════════════════════════════════════════════════════"
echo "  Scenario Tracing Validation"
echo "  Feature: $FEATURE"
echo "  Tracing: $TRACE"
echo "═══════════════════════════════════════════════════════════"

RESULT=$(FEATURE_PATH="$FEATURE" TRACE_PATH="$TRACE" python3 << 'PYEOF'
import yaml
import os
import re

feature_path = os.environ['FEATURE_PATH']
trace_path = os.environ['TRACE_PATH']

errors = []
warnings = []
kebab_re = re.compile(r'^[a-z][a-z0-9-]*$')
valid_categories = {'happy-path', 'validation', 'invariant', 'not-found', 'integration', 'pagination'}
error_categories = {'validation', 'invariant', 'not-found'}

# Extract scenario names from .feature
with open(feature_path) as f:
    feature_scenarios = []
    for line in f:
        stripped = line.strip()
        if stripped.startswith("Scenario:"):
            name = stripped.replace("Scenario:", "").strip()
            feature_scenarios.append(name)

# Parse tracing YAML
with open(trace_path) as f:
    trace_data = yaml.safe_load(f)

if not trace_data:
    errors.append("Tracing file is empty")
else:
    scenarios = trace_data.get('scenarios', [])
    traced_names = set()
    traced_ids = set()

    for sc in scenarios:
        sc_id = sc.get('id', '???')
        sc_name = sc.get('scenario', '')
        sc_cat = sc.get('category', '')

        # ID format
        if not kebab_re.match(sc_id):
            errors.append(f"Scenario ID '{sc_id}' is not valid kebab-case")

        # Duplicate IDs
        if sc_id in traced_ids:
            errors.append(f"Duplicate scenario ID: '{sc_id}'")
        traced_ids.add(sc_id)

        # Category valid
        if sc_cat not in valid_categories:
            errors.append(f"Scenario '{sc_id}' has invalid category: '{sc_cat}'")

        # Invariant category requires tests_invariant
        if sc_cat == 'invariant' and not sc.get('tests_invariant'):
            errors.append(f"Scenario '{sc_id}' is category=invariant but missing tests_invariant")

        # Error categories require expected_error
        if sc_cat in error_categories and not sc.get('expected_error'):
            errors.append(f"Scenario '{sc_id}' is category={sc_cat} but missing expected_error")

        traced_names.add(sc_name)

    # Check 1:1 mapping
    feature_set = set(feature_scenarios)

    untraced = feature_set - traced_names
    for name in untraced:
        errors.append(f"Feature scenario '{name}' has no tracing entry")

    orphan = traced_names - feature_set
    for name in orphan:
        errors.append(f"Tracing entry '{name}' does not match any scenario in .feature")

for e in errors:
    print(f"ERROR:{e}")
for w in warnings:
    print(f"WARNING:{w}")
print(f"SUMMARY:{len(errors)}:{len(warnings)}")
PYEOF
2>&1)

ERRORS=0
WARNINGS=0

while IFS= read -r line; do
    case "$line" in
        ERROR:*)   echo "  ERROR: ${line#ERROR:}"; ERRORS=$((ERRORS + 1)) ;;
        WARNING:*) echo "  WARNING: ${line#WARNING:}"; WARNINGS=$((WARNINGS + 1)) ;;
        SUMMARY:*) ;;
    esac
done <<< "$RESULT"

echo ""
echo "═══════════════════════════════════════════════════════════"
if [ "$ERRORS" -gt 0 ]; then
    echo "  RESULT: FAIL ($ERRORS errors, $WARNINGS warnings)"
    exit 1
else
    echo "  RESULT: PASS ($WARNINGS warnings)"
    exit 0
fi
