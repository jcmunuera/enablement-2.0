#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# manifest-check.sh — Validates capability manifest
# Module: mod-bridge-001-blueprint-binding
# Usage: manifest-check.sh <manifest.yaml> <capability-index.yaml>
# ═══════════════════════════════════════════════════════════
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: manifest-check.sh <manifest.yaml> <capability-index.yaml>"
  exit 1
fi

MANIFEST="$1"
CAP_INDEX="$2"

if [ ! -f "$MANIFEST" ]; then echo "ERROR: $MANIFEST not found"; exit 1; fi
if [ ! -f "$CAP_INDEX" ]; then echo "ERROR: $CAP_INDEX not found"; exit 1; fi

echo "═══════════════════════════════════════════════════════════"
echo "  Manifest Check: $(basename "$MANIFEST")"
echo "═══════════════════════════════════════════════════════════"

python3 - "$MANIFEST" "$CAP_INDEX" << 'PYEOF'
import yaml, sys

manifest_file = sys.argv[1]
index_file = sys.argv[2]

errors = []
warnings = []

with open(manifest_file) as f:
    manifest = yaml.safe_load(f)

with open(index_file) as f:
    index = yaml.safe_load(f)

# Required fields
for field in ['context_id', 'building_block', 'tech_stack', 'blueprint', 'capabilities']:
    if not manifest.get(field):
        errors.append(f"Missing required field: {field}")

# Build capability lookup from index
available = set()
caps = index.get('capabilities', {})
for cap_id, cap in caps.items():
    for feat_id in cap.get('features', {}).keys():
        available.add(f"{cap_id}.{feat_id}")

print(f"  OK: CODE index has {len(available)} available capability.features")

# Check each capability is resolvable
capabilities = manifest.get('capabilities', [])
seen = set()
for cap in capabilities:
    cap_id = cap.get('id', '')
    if not cap_id:
        errors.append("Capability entry missing 'id'")
        continue
    if not cap.get('source'):
        warnings.append(f"Capability '{cap_id}' missing 'source' annotation")
    if cap_id in seen:
        warnings.append(f"Duplicate capability: '{cap_id}'")
    seen.add(cap_id)
    
    if cap_id not in available:
        errors.append(f"Capability '{cap_id}' not found in CODE capability-index")

print(f"  OK: {len(capabilities)} capabilities in manifest, {len(seen)} unique")

# Output
for e in errors:
    print(f"ERROR:{e}")
for w in warnings:
    print(f"WARNING:{w}")

e_count = len(errors)
w_count = len(warnings)
print(f"SUMMARY:{e_count}:{w_count}")
PYEOF

# Parse result
LAST=$(python3 - "$MANIFEST" "$CAP_INDEX" << 'PYEOF2' 2>/dev/null | tail -1)
import yaml, sys
with open(sys.argv[1]) as f: m = yaml.safe_load(f)
with open(sys.argv[2]) as f: idx = yaml.safe_load(f)
avail = set()
for cid, c in idx.get('capabilities',{}).items():
    for fid in c.get('features',{}).keys(): avail.add(f"{cid}.{fid}")
errs = sum(1 for c in m.get('capabilities',[]) if c.get('id','') not in avail)
print(f"SUMMARY:{errs}:0")
PYEOF2

ERRORS=$(echo "$LAST" | cut -d: -f2)
WARNINGS=$(echo "$LAST" | cut -d: -f3)

echo "═══════════════════════════════════════════════════════════"
if [ "${ERRORS:-0}" -gt 0 ]; then
  echo "  RESULT: FAIL ($ERRORS errors, $WARNINGS warnings)"
else
  echo "  RESULT: PASS ($WARNINGS warnings)"
fi
echo "═══════════════════════════════════════════════════════════"
