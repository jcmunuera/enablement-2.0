#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# openapi-lint.sh — Basic OpenAPI spec validation
# Module: mod-design-003-api-mapping
# Version: 1.0
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

FILE="${1:?Usage: openapi-lint.sh <openapi-spec.yaml>}"

echo "═══════════════════════════════════════════════════════════"
echo "  OpenAPI Lint"
echo "  File: $FILE"
echo "═══════════════════════════════════════════════════════════"

if ! python3 -c "import yaml; yaml.safe_load(open('$FILE'))" 2>/dev/null; then
    echo "  ERROR: File is not valid YAML"
    exit 1
fi
echo "  OK: Valid YAML"

RESULT=$(FILE_PATH="$FILE" python3 << 'PYEOF'
import yaml, os

with open(os.environ['FILE_PATH']) as f:
    data = yaml.safe_load(f)

errors = []

if 'openapi' not in data:
    errors.append("Missing 'openapi' version field")
elif not str(data['openapi']).startswith('3.'):
    errors.append(f"OpenAPI version should be 3.x, got: {data['openapi']}")

info = data.get('info', {})
if not info.get('title'):
    errors.append("Missing info.title")
if not info.get('version'):
    errors.append("Missing info.version")

paths = data.get('paths', {})
if not paths:
    errors.append("No paths defined")

schemas = data.get('components', {}).get('schemas', {})
if not schemas:
    errors.append("No component schemas defined")

# Check that paths have at least one operation
for path, methods in paths.items():
    if not isinstance(methods, dict):
        continue
    valid_ops = [m for m in methods if m in ('get', 'post', 'put', 'patch', 'delete')]
    if not valid_ops:
        errors.append(f"Path '{path}' has no valid HTTP operations")

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
