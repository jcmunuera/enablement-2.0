#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# context-map-check.sh — Validates bounded-context-map.yaml
# Module: mod-design-001-strategic-ddd
# Version: 1.0
# ═══════════════════════════════════════════════════════════════
#
# Usage: ./context-map-check.sh <yaml-file> [full-strategic|lightweight]
#
# Exit codes:
#   0 — All checks passed
#   1 — ERROR-level validation failure
#   2 — WARNING-level issues only (still exits 0 if no errors)

set -euo pipefail

FILE="${1:?Usage: context-map-check.sh <yaml-file> [full-strategic|lightweight]}"
OPTION="${2:-full-strategic}"

ERRORS=0
WARNINGS=0

error() { echo "  ERROR: $1"; ERRORS=$((ERRORS + 1)); }
warn()  { echo "  WARNING: $1"; WARNINGS=$((WARNINGS + 1)); }
info()  { echo "  OK: $1"; }

echo "═══════════════════════════════════════════════════════════"
echo "  Bounded Context Map Validation"
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

# Load YAML into Python for remaining checks
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

# ─── Check 2: Required top-level fields ───
required_top = ['version', 'domain', 'description', 'analysis_date', 'source_requirements']
for field in required_top:
    if field not in data:
        errors.append(f"Missing required top-level field: {field}")

# ─── ID format helper ───
kebab_re = re.compile(r'^[a-z][a-z0-9-]*$')

def check_kebab(field_name, value):
    if not kebab_re.match(value):
        errors.append(f"{field_name} '{value}' is not valid kebab-case")

# ─── Check domain ID ───
if 'domain' in data:
    check_kebab('domain', data['domain'])

# ─── Collect all context IDs and capabilities ───
all_context_ids = []
all_capabilities = []
subdomain_ids = []

if 'subdomains' in data and data['subdomains']:
    for sd in data['subdomains']:
        sd_id = sd.get('id', '')
        subdomain_ids.append(sd_id)
        check_kebab('subdomain.id', sd_id)

        # Check subdomain type
        sd_type = sd.get('type', '')
        if sd_type not in ('core', 'supporting', 'generic'):
            errors.append(f"Subdomain '{sd_id}' has invalid type: '{sd_type}'")

        # Check investment_strategy
        if 'investment_strategy' not in sd:
            errors.append(f"Subdomain '{sd_id}' missing investment_strategy")

        # Process bounded contexts
        contexts = sd.get('bounded_contexts', [])
        if not contexts:
            errors.append(f"Subdomain '{sd_id}' has no bounded contexts")

        for ctx in contexts:
            ctx_id = ctx.get('id', '')
            all_context_ids.append(ctx_id)
            check_kebab('bounded_context.id', ctx_id)

            # Check capabilities
            caps = ctx.get('capabilities', [])
            if not caps:
                errors.append(f"Context '{ctx_id}' has no capabilities")
            if len(caps) > 5:
                warnings.append(f"Context '{ctx_id}' has {len(caps)} capabilities (potential god context)")
            all_capabilities.extend([(cap, ctx_id) for cap in caps])

            # Check ubiquitous language (full-strategic only)
            ul = ctx.get('ubiquitous_language', [])
            if option == 'full-strategic' and len(ul) < 3:
                errors.append(f"Context '{ctx_id}' has {len(ul)} UL terms (minimum 3 for full-strategic)")

            # Check required fields
            for req in ['name', 'description', 'owner']:
                if req not in ctx:
                    errors.append(f"Context '{ctx_id}' missing required field: {req}")
else:
    if option == 'full-strategic':
        errors.append("No subdomains defined")

# ─── Check duplicate context IDs ───
seen_ids = set()
for cid in all_context_ids:
    if cid in seen_ids:
        errors.append(f"Duplicate context ID: '{cid}'")
    seen_ids.add(cid)

# ─── Check duplicate subdomain IDs ───
seen_sd = set()
for sid in subdomain_ids:
    if sid in seen_sd:
        errors.append(f"Duplicate subdomain ID: '{sid}'")
    seen_sd.add(sid)

# ─── Check duplicate capabilities across contexts ───
cap_owners = {}
for cap, ctx_id in all_capabilities:
    if cap in cap_owners:
        warnings.append(f"Capability '{cap}' appears in both '{cap_owners[cap]}' and '{ctx_id}'")
    cap_owners[cap] = ctx_id

# ─── Check relationships ───
relationships = data.get('context_relationships', [])
valid_rel_types = {'customer-supplier', 'conformist', 'acl', 'partnership', 'shared-kernel', 'open-host', 'published-language'}
valid_rel_types = {'customer-supplier', 'conformist', 'acl', 'partnership', 'shared-kernel', 'open-host', 'published-language'}

rel_ids = set()
for rel in relationships:
    rel_id = rel.get('id', '')
    if rel_id in rel_ids:
        errors.append(f"Duplicate relationship ID: '{rel_id}'")
    rel_ids.add(rel_id)
    check_kebab('relationship.id', rel_id)

    # Check upstream/downstream refs
    upstream = rel.get('upstream', '')
    downstream = rel.get('downstream', '')
    if upstream not in seen_ids:
        errors.append(f"Relationship '{rel_id}': upstream '{upstream}' is not a valid context ID")
    if downstream not in seen_ids:
        errors.append(f"Relationship '{rel_id}': downstream '{downstream}' is not a valid context ID")

    # Check relationship type
    rel_type = rel.get('type', '')
    if rel_type not in valid_rel_types:
        errors.append(f"Relationship '{rel_id}': invalid type '{rel_type}'")

# ─── Output results ───
for e in errors:
    print(f"ERROR:{e}")
for w in warnings:
    print(f"WARNING:{w}")
print(f"SUMMARY:{len(errors)}:{len(warnings)}")
PYEOF
2>&1)

# Parse Python output
while IFS= read -r line; do
    case "$line" in
        ERROR:*)   error "${line#ERROR:}" ;;
        WARNING:*) warn "${line#WARNING:}" ;;
        SUMMARY:*) ;; # handled below
    esac
done <<< "$VALIDATION"

# Extract summary
SUMMARY_LINE=$(echo "$VALIDATION" | grep "^SUMMARY:" | tail -1)
PY_ERRORS=$(echo "$SUMMARY_LINE" | cut -d: -f2)
PY_WARNINGS=$(echo "$SUMMARY_LINE" | cut -d: -f3)

echo ""
echo "═══════════════════════════════════════════════════════════"
if [ "$ERRORS" -gt 0 ]; then
    echo "  RESULT: FAIL ($ERRORS errors, $WARNINGS warnings)"
    exit 1
else
    echo "  RESULT: PASS ($WARNINGS warnings)"
    exit 0
fi
