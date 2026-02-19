#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# field-mapping-check.sh — Validates field-mapping.json
# Module: mod-design-003-api-mapping
# Version: 1.0
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

FILE="${1:?Usage: field-mapping-check.sh <field-mapping.json>}"

echo "═══════════════════════════════════════════════════════════"
echo "  Field Mapping Validation"
echo "  File: $FILE"
echo "═══════════════════════════════════════════════════════════"

if ! python3 -c "import json; json.load(open('$FILE'))" 2>/dev/null; then
    echo "  ERROR: File is not valid JSON"
    exit 1
fi
echo "  OK: Valid JSON"

RESULT=$(FILE_PATH="$FILE" python3 << 'PYEOF'
import json, os

with open(os.environ['FILE_PATH']) as f:
    data = json.load(f)

errors = []
valid_transforms = {'direct', 'uuid-to-string', 'enum-to-code', 'date-format', 'composite', 'lookup', 'constant'}
valid_directions = {'bidirectional', 'domain-to-system', 'system-to-domain'}

for field in ['version', 'domain_api', 'system_api']:
    if field not in data:
        errors.append(f"Missing required field: {field}")

mappings = data.get('entity_mappings', [])
if not mappings:
    errors.append("No entity_mappings defined")

for em in mappings:
    entity = em.get('domain_entity', '???')
    fields = em.get('field_mappings', [])
    if not fields:
        errors.append(f"Entity '{entity}' has no field_mappings")
    for fm in fields:
        t = fm.get('transformation', '')
        if t not in valid_transforms:
            errors.append(f"Entity '{entity}', field '{fm.get('domain_field', '???')}': invalid transformation '{t}'")
        d = fm.get('direction', '')
        if d not in valid_directions:
            errors.append(f"Entity '{entity}', field '{fm.get('domain_field', '???')}': invalid direction '{d}'")

for e in errors:
    print(f"ERROR:{e}")
print(f"SUMMARY:{len(errors)}:0")
PYEOF
2>&1)

ERRORS=0
while IFS= read -r line; do
    case "$line" in
        ERROR:*) echo "  ERROR: ${line#ERROR:}"; ERRORS=$((ERRORS + 1)) ;;
        SUMMARY:*) ;;
    esac
done <<< "$RESULT"

echo ""
if [ "$ERRORS" -gt 0 ]; then
    echo "  RESULT: FAIL ($ERRORS errors)"
    exit 1
else
    echo "  RESULT: PASS"
    exit 0
fi
