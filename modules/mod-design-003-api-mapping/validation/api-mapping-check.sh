#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# api-mapping-check.sh — Validates api-mapping.yaml
# Module: mod-design-003-api-mapping
# Version: 1.0
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

FILE="${1:?Usage: api-mapping-check.sh <api-mapping.yaml>}"

echo "═══════════════════════════════════════════════════════════"
echo "  API Mapping Validation"
echo "  File: $FILE"
echo "═══════════════════════════════════════════════════════════"

if ! python3 -c "import yaml; yaml.safe_load(open('$FILE'))" 2>/dev/null; then
    echo "  ERROR: File is not valid YAML"
    exit 1
fi
echo "  OK: Valid YAML"

RESULT=$(FILE_PATH="$FILE" python3 << 'PYEOF'
import yaml, os, re

with open(os.environ['FILE_PATH']) as f:
    data = yaml.safe_load(f)

errors = []
valid_tiers = {'domain', 'system', 'composable', 'experience'}
valid_types = {'rest', 'grpc', 'async', 'graphql'}
valid_methods = {'GET', 'POST', 'PUT', 'PATCH', 'DELETE'}

for field in ['version', 'source_context', 'source_aggregate', 'api_tier', 'api_name', 'api_type']:
    if field not in data:
        errors.append(f"Missing required field: {field}")

if data.get('api_tier', '') not in valid_tiers:
    errors.append(f"Invalid api_tier: '{data.get('api_tier')}'")
if data.get('api_type', '') not in valid_types:
    errors.append(f"Invalid api_type: '{data.get('api_type')}'")

resources = data.get('resources', [])
if not resources:
    errors.append("No resources defined")

for res in resources:
    if not res.get('aggregate'):
        errors.append(f"Resource '{res.get('name', '???')}' has no aggregate ref")
    ops = res.get('operations', [])
    if not ops:
        errors.append(f"Resource '{res.get('name', '???')}' has no operations")
    for op in ops:
        method = op.get('method', '')
        if method not in valid_methods:
            errors.append(f"Invalid HTTP method: '{method}'")
        if not op.get('command_or_query'):
            errors.append(f"Operation {method} {op.get('path', '???')} has no command_or_query ref")

for dep in data.get('system_api_dependencies', []):
    if not dep.get('field_mapping_ref'):
        errors.append(f"System API dep '{dep.get('system_api', '???')}' missing field_mapping_ref")

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
