#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# coverage-check.sh — Validates BDD scenario coverage
# Module: mod-design-004-bdd-scenarios
# Version: 1.0
# ═══════════════════════════════════════════════════════════════
#
# Usage: ./coverage-check.sh <aggregate-definitions.yaml> <scenario-tracing.yaml>
#
# Checks that every command, query, and invariant from the aggregate
# has at least the required scenario coverage.

set -euo pipefail

AGG_FILE="${1:?Usage: coverage-check.sh <aggregate-definitions.yaml> <scenario-tracing.yaml>}"
TRACE_FILE="${2:?Usage: coverage-check.sh <aggregate-definitions.yaml> <scenario-tracing.yaml>}"

echo "═══════════════════════════════════════════════════════════"
echo "  BDD Coverage Validation"
echo "  Aggregates: $AGG_FILE"
echo "  Tracing:    $TRACE_FILE"
echo "═══════════════════════════════════════════════════════════"

RESULT=$(AGG_PATH="$AGG_FILE" TRACE_PATH="$TRACE_FILE" python3 << 'PYEOF'
import yaml
import os

agg_path = os.environ['AGG_PATH']
trace_path = os.environ['TRACE_PATH']

with open(agg_path) as f:
    agg_data = yaml.safe_load(f)
with open(trace_path) as f:
    trace_data = yaml.safe_load(f)

errors = []
warnings = []

# Collect DDD elements
commands = []
queries = []
invariants = []

for agg in agg_data.get('aggregates', []):
    for cmd in agg.get('commands', []):
        commands.append(cmd['id'])
    for qry in agg.get('queries', []):
        queries.append({
            'id': qry['id'],
            'filters': qry.get('filters', [])
        })
    for inv in agg.get('invariants', []):
        # DEC-070: Only require violation scenarios for command-level invariants
        if inv.get('enforced_by', '') != 'query-validation':
            invariants.append(inv['id'])

# Collect scenario coverage
scenarios = trace_data.get('scenarios', [])
exercises_map = {}  # element_id -> set of categories
invariant_covered = set()

for sc in scenarios:
    ex = sc.get('exercises', '')
    cat = sc.get('category', '')
    if ex not in exercises_map:
        exercises_map[ex] = set()
    exercises_map[ex].add(cat)

    inv = sc.get('tests_invariant', '')
    if inv:
        invariant_covered.add(inv)

# Check commands: need happy-path + validation/invariant/not-found
for cmd_id in commands:
    cats = exercises_map.get(cmd_id, set())
    if 'happy-path' not in cats:
        errors.append(f"Command '{cmd_id}' has no happy-path scenario")
    error_cats = cats & {'validation', 'invariant', 'not-found'}
    if not error_cats:
        errors.append(f"Command '{cmd_id}' has no error scenario (validation/invariant/not-found)")

# Check queries: need happy-path; ID-targeting queries also need not-found (DEC-071)
for qry in queries:
    qry_id = qry['id']
    cats = exercises_map.get(qry_id, set())
    if 'happy-path' not in cats and 'pagination' not in cats:
        errors.append(f"Query '{qry_id}' has no happy-path scenario")

    # DEC-071: Get-by-ID queries must have not-found scenario
    # Only applies to single-entity queries (Get/Search) where the ID filter
    # targets the aggregate's own entity (not a foreign key like customerId)
    is_single_entity = qry_id.startswith('get-') or qry_id.startswith('search-')
    # Heuristic: filter name matches aggregate/entity name pattern
    # e.g., get-card with filter cardId -> yes; get-global-position with customerId -> no
    agg_id = ''
    for a in agg_data.get('aggregates', []):
        for q in a.get('queries', []):
            if q['id'] == qry_id:
                agg_id = a['id']
                break
    has_own_id_filter = any(
        f.get('required', False) and (
            f.get('name', '').endswith('Id') or
            f.get('type', '') == 'UUID'
        ) and (
            agg_id.replace('-', '') in f.get('name', '').lower() or
            f.get('name', '').lower().replace('id', '') in agg_id.replace('-', '')
        )
        for f in qry.get('filters', [])
    )
    if is_single_entity and has_own_id_filter and 'not-found' not in cats:
        warnings.append(f"Query '{qry_id}' targets entity by ID but has no not-found scenario")

# Check invariants: need violation scenario
for inv_id in invariants:
    if inv_id not in invariant_covered:
        errors.append(f"Invariant '{inv_id}' has no violation scenario")

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
