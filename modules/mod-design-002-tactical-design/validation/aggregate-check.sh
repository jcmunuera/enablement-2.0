#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# aggregate-check.sh — Validates aggregate-definitions.yaml
# Module: mod-design-002-tactical-design
# Version: 1.0
# ═══════════════════════════════════════════════════════════════
#
# Usage: ./aggregate-check.sh <yaml-file> [full-tactical|entity-focused]
#
# Exit codes:
#   0 — All checks passed (may have warnings)
#   1 — ERROR-level validation failure

set -euo pipefail

FILE="${1:?Usage: aggregate-check.sh <yaml-file> [full-tactical|entity-focused]}"
OPTION="${2:-full-tactical}"

ERRORS=0
WARNINGS=0

error() { echo "  ERROR: $1"; ERRORS=$((ERRORS + 1)); }
warn()  { echo "  WARNING: $1"; WARNINGS=$((WARNINGS + 1)); }
info()  { echo "  OK: $1"; }

echo "═══════════════════════════════════════════════════════════"
echo "  Aggregate Definitions Validation"
echo "  File: $FILE"
echo "  Option: $OPTION"
echo "═══════════════════════════════════════════════════════════"

# ─── Check 1: Valid YAML ───
echo ""
echo "── Check 1: Valid YAML"
if ! python3 -c "import yaml; yaml.safe_load(open('$FILE'))" 2>/dev/null; then
    error "File is not valid YAML"
    echo ""
    echo "RESULT: FAIL ($ERRORS errors, $WARNINGS warnings)"
    exit 1
fi
info "Valid YAML"

# ─── All remaining checks via Python ───
VALIDATION=$(FILE_PATH="$FILE" CHECK_OPTION="$OPTION" python3 << 'PYEOF'
import yaml
import os
import re

file_path = os.environ['FILE_PATH']
option = os.environ['CHECK_OPTION']

with open(file_path, 'r') as f:
    data = yaml.safe_load(f)

errors = []
warnings = []

kebab_re = re.compile(r'^[a-z][a-z0-9-]*$')
command_name_re = re.compile(r'^(Create|Update|Delete|Change|Process|Approve|Reject|Cancel|Submit|Block|Reactivate|Pause|Resume|Activate|Deactivate|Suspend|Execute)[A-Z]')
event_name_re = re.compile(r'^[A-Z][a-zA-Z]+(Created|Updated|Deleted|Changed|Processed|Approved|Rejected|Cancelled|Submitted|Executed|Blocked|Reactivated|Paused|Resumed|Activated|Deactivated|Suspended)$')

def check_kebab(field_name, value):
    if not kebab_re.match(str(value)):
        errors.append(f"{field_name} '{value}' is not valid kebab-case")

# ─── Required top-level fields ───
for field in ['version', 'bounded_context', 'context_name', 'analysis_date']:
    if field not in data:
        errors.append(f"Missing required top-level field: {field}")

if 'bounded_context' in data:
    check_kebab('bounded_context', data['bounded_context'])

# ─── Process aggregates ───
all_entity_ids = []  # track globally within context for uniqueness
all_command_ids = {}
all_event_ids = {}
all_invariant_ids = {}
invariant_referenced = set()

aggregates = data.get('aggregates', [])
if not aggregates:
    errors.append("No aggregates defined")

for agg in aggregates:
    agg_id = agg.get('id', '???')
    check_kebab('aggregate.id', agg_id)

    # ─── Root entity check ───
    entities = agg.get('entities', [])
    root_count = sum(1 for e in entities if e.get('is_root'))
    if root_count != 1:
        errors.append(f"Aggregate '{agg_id}': has {root_count} root entities (must be exactly 1)")

    # ─── Entity uniqueness ───
    agg_entity_ids = []
    for ent in entities:
        eid = ent.get('id', '???')
        check_kebab('entity.id', eid)
        if eid in all_entity_ids:
            errors.append(f"Entity '{eid}' appears in multiple aggregates")
        all_entity_ids.append(eid)
        agg_entity_ids.append(eid)

    # ─── Value objects ───
    for vo in agg.get('value_objects', []):
        vo_id = vo.get('id', '???')
        check_kebab('value_object.id', vo_id)
        if 'identity' in vo:
            errors.append(f"Value object '{vo_id}' has identity field (VOs must not have identity)")
        used_by = vo.get('used_by', [])
        for ref in used_by:
            if ref not in agg_entity_ids:
                errors.append(f"Value object '{vo_id}' used_by references '{ref}' which is not in aggregate '{agg_id}'")

    # ─── Invariants ───
    for inv in agg.get('invariants', []):
        inv_id = inv.get('id', '???')
        check_kebab('invariant.id', inv_id)
        all_invariant_ids[inv_id] = agg_id
        # Invariants enforced at query level don't need command error_case linkage
        if inv.get('enforced_by') == 'query-validation':
            invariant_referenced.add(inv_id)

    # ─── Commands ───
    for cmd in agg.get('commands', []):
        cmd_id = cmd.get('id', '???')
        cmd_name = cmd.get('name', '')
        check_kebab('command.id', cmd_id)
        all_command_ids[cmd_id] = agg_id

        # Name validation
        if not command_name_re.match(cmd_name):
            errors.append(f"Command name '{cmd_name}' does not follow convention (PascalCase imperative verb)")

        # Error cases
        error_cases = cmd.get('error_cases', [])
        if option == 'full-tactical' and not error_cases:
            errors.append(f"Command '{cmd_id}' has no error cases (required for full-tactical)")

        # Track invariant references
        for ec in error_cases:
            inv_ref = ec.get('invariant')
            if inv_ref:
                invariant_referenced.add(inv_ref)

        # Produces event ref
        event_ref = cmd.get('produces_event', '')
        if event_ref:
            # Will validate below after collecting all events
            pass

    # ─── Events ───
    for evt in agg.get('domain_events', []):
        evt_id = evt.get('id', '???')
        evt_name = evt.get('name', '')
        check_kebab('event.id', evt_id)
        all_event_ids[evt_id] = agg_id

        if not event_name_re.match(evt_name):
            errors.append(f"Event name '{evt_name}' does not follow convention (PascalCase past tense)")

        triggered_by = evt.get('triggered_by', '')
        if triggered_by and triggered_by not in all_command_ids:
            # Might be defined later in same aggregate, defer check
            pass

        visibility = evt.get('visibility', '')
        if visibility not in ('internal', 'cross-context'):
            errors.append(f"Event '{evt_id}' has invalid visibility: '{visibility}'")

    # ─── Queries ───
    for qry in agg.get('queries', []):
        qry_id = qry.get('id', '???')
        check_kebab('query.id', qry_id)

# ─── Cross-reference validation (after all aggregates processed) ───

# Check produces_event refs
for agg in aggregates:
    for cmd in agg.get('commands', []):
        event_ref = cmd.get('produces_event', '')
        if event_ref and event_ref not in all_event_ids:
            errors.append(f"Command '{cmd.get('id')}' references event '{event_ref}' which does not exist")

# Check triggered_by refs
for agg in aggregates:
    for evt in agg.get('domain_events', []):
        triggered_by = evt.get('triggered_by', '')
        if triggered_by and triggered_by not in all_command_ids:
            errors.append(f"Event '{evt.get('id')}' triggered_by '{triggered_by}' which does not exist")

# Check invariant linkage
if option == 'full-tactical':
    for inv_id in all_invariant_ids:
        if inv_id not in invariant_referenced:
            warnings.append(f"Invariant '{inv_id}' is not referenced by any command error case")

# ─── Output ───
for e in errors:
    print(f"ERROR:{e}")
for w in warnings:
    print(f"WARNING:{w}")
print(f"SUMMARY:{len(errors)}:{len(warnings)}")
PYEOF
2>&1)

# Parse output
while IFS= read -r line; do
    case "$line" in
        ERROR:*)   error "${line#ERROR:}" ;;
        WARNING:*) warn "${line#WARNING:}" ;;
        SUMMARY:*) ;;
    esac
done <<< "$VALIDATION"

echo ""
echo "═══════════════════════════════════════════════════════════"
if [ "$ERRORS" -gt 0 ]; then
    echo "  RESULT: FAIL ($ERRORS errors, $WARNINGS warnings)"
    exit 1
else
    echo "  RESULT: PASS ($WARNINGS warnings)"
    exit 0
fi
