#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# requirements-check.sh — Validates normalized-requirements.yaml
# Module: mod-design-000-requirements-normalization
# Version: 1.0
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

FILE="${1:?Usage: requirements-check.sh <normalized-requirements.yaml>}"

echo "═══════════════════════════════════════════════════════════"
echo "  Normalized Requirements Validation"
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
warnings = []
kebab_re = re.compile(r'^[a-z][a-z0-9-]*$')

def check_kebab(ctx, val):
    if not kebab_re.match(str(val)):
        errors.append(f"{ctx}: '{val}' is not valid kebab-case")

# ─── Top-level fields ───
for field in ['version', 'domain', 'title', 'description', 'source', 'analysis_date']:
    if field not in data:
        errors.append(f"Missing required top-level field: {field}")

check_kebab('domain', data.get('domain', ''))

# ─── Actors ───
actors = data.get('actors', [])
if not actors:
    errors.append("No actors defined")
actor_ids = set()
for a in actors:
    aid = a.get('id', '???')
    check_kebab('actor.id', aid)
    actor_ids.add(aid)

# ─── Feature groups ───
groups = data.get('feature_groups', [])
if not groups:
    errors.append("No feature_groups defined")

all_feature_ids = set()
valid_types = {'query', 'command', 'composite'}
valid_criticality = {'essential', 'important', 'optional'}
valid_entity_class = {'master', 'reference', 'derived'}
orders = []

for g in groups:
    gid = g.get('id', '???')
    check_kebab('feature_group.id', gid)

    # Actor ref
    actor_ref = g.get('actor', '')
    if actor_ref not in actor_ids:
        errors.append(f"Feature group '{gid}': actor '{actor_ref}' not found")

    # Order
    order = g.get('order')
    if order is not None:
        orders.append(order)

    # Features
    features = g.get('features', [])
    if not features:
        errors.append(f"Feature group '{gid}': no features defined")

    for f in features:
        fid = f.get('id', '???')
        check_kebab('feature.id', fid)
        if fid in all_feature_ids:
            errors.append(f"Duplicate feature ID: '{fid}'")
        all_feature_ids.add(fid)

        # Type
        ftype = f.get('type', '')
        if ftype not in valid_types:
            errors.append(f"Feature '{fid}': invalid type '{ftype}'")

        # Criticality
        crit = f.get('criticality', '')
        if crit not in valid_criticality:
            errors.append(f"Feature '{fid}': invalid criticality '{crit}'")

        # Data entities
        entities = f.get('data_entities', [])
        if not entities:
            errors.append(f"Feature '{fid}': no data_entities")
        for de in entities:
            ec = de.get('classification', '')
            if ec not in valid_entity_class:
                errors.append(f"Feature '{fid}': entity '{de.get('entity', '???')}' invalid classification '{ec}'")

        # Command-specific checks
        if ftype == 'command':
            rules = f.get('business_rules', [])
            if not rules:
                errors.append(f"Feature '{fid}' (command): no business_rules defined")
            errs = f.get('error_scenarios', [])
            if not errs:
                errors.append(f"Feature '{fid}' (command): no error_scenarios defined")
            for r in rules:
                rid = r.get('id', '???')
                check_kebab('rule.id', rid)

        # Pagination check for list features
        desc_lower = f.get('description', '').lower()
        has_list = any(kw in desc_lower for kw in ['list', 'display list', 'history', 'recent'])
        has_pagination = f.get('pagination') is not None
        if has_list and not has_pagination:
            warnings.append(f"Feature '{fid}' appears to list items but has no pagination block")

# ─── Order sequential check ───
if orders:
    sorted_orders = sorted(orders)
    expected = list(range(1, len(sorted_orders) + 1))
    if sorted_orders != expected:
        warnings.append(f"Feature group order is not sequential: {sorted_orders}")

# ─── Integrations ───
valid_int_types = {'system-of-record', 'external-provider', 'internal-platform'}
for i in data.get('integrations', []):
    iid = i.get('id', '???')
    check_kebab('integration.id', iid)
    itype = i.get('type', '')
    if itype not in valid_int_types:
        errors.append(f"Integration '{iid}': invalid type '{itype}'")

# ─── Assumptions ───
assumptions = data.get('assumptions', [])
if not assumptions:
    warnings.append("No assumptions defined (usually there are implicit requirements)")
valid_confidence = {'high', 'medium', 'low'}
for a in assumptions:
    aid = a.get('id', '???')
    check_kebab('assumption.id', aid)
    conf = a.get('confidence', '')
    if conf not in valid_confidence:
        errors.append(f"Assumption '{aid}': invalid confidence '{conf}'")

# ═══════════════════════════════════════════════════════════════
# GAP DETECTION RULES (G1-G6)
# Validate that downstream phases have sufficient information
# ═══════════════════════════════════════════════════════════════

# Build entity → integration lookup
integration_entities = set()
for i in data.get('integrations', []):
    for ent in i.get('data_entities', []):
        integration_entities.add(ent.lower().strip())

# G1: Data source for every reference/derived entity
all_entities = []
for g in groups:
    for f in g.get('features', []):
        for de in f.get('data_entities', []):
            all_entities.append(de)

for de in all_entities:
    ename = de.get('entity', '???')
    eclass = de.get('classification', '')
    if eclass in ('reference', 'derived'):
        # Reference entities should have an integration source
        if eclass == 'reference' and ename.lower().strip() not in integration_entities:
            warnings.append(f"G1: Reference entity '{ename}' has no integration that masters it")

# G2: State machine for stateful entities
# Detect command features with state-change signals
state_signals = ['block', 'unblock', 'activate', 'deactivate', 'pause', 'resume',
                 'cancel', 'approve', 'reject', 'suspend', 'close', 'reactivate',
                 'status', 'state']
stateful_entities = set()
for g in groups:
    for f in g.get('features', []):
        if f.get('type') == 'command':
            fname = f.get('name', '').lower()
            fdesc = f.get('description', '').lower()
            text = fname + ' ' + fdesc
            if any(sig in text for sig in state_signals):
                for de in f.get('data_entities', []):
                    if de.get('classification') == 'master':
                        stateful_entities.add(de.get('entity', '???'))

# Check assumptions for state definitions
assumption_text = ' '.join(a.get('description', '').lower() for a in assumptions)
for entity in stateful_entities:
    # Look for state definition in assumptions or in business rules
    entity_lower = entity.lower()
    has_state_info = (entity_lower in assumption_text and
                      any(kw in assumption_text for kw in ['state', 'status', 'active', 'blocked', 'cancelled', 'paused']))
    # Also check business_rules for state-related rules
    has_state_rules = False
    for g in groups:
        for f in g.get('features', []):
            for de in f.get('data_entities', []):
                if de.get('entity', '').lower() == entity_lower:
                    for br in f.get('business_rules', []):
                        br_desc = br.get('description', '').lower()
                        if any(kw in br_desc for kw in ['only active', 'only blocked', 'only paused',
                                                         'requires active', 'requires blocked', 'requires paused',
                                                         'not cancelled', 'not already', 'cancelled']):
                            has_state_rules = True
    if not has_state_info and not has_state_rules:
        errors.append(f"G2: Entity '{entity}' appears stateful (involved in state-change commands) but has no state machine defined in assumptions or business rules")

# G3: Business criticality / differentiation
# Check if user provided differentiation input (look for assumption about criticality)
criticality_keywords = ['differentiating', 'non-differentiating', 'not differentiating',
                         'competitive differentiator', 'competitive advantage',
                         'table stakes', 'not especially differentiating',
                         'basic and common', 'standard capability', 'commodity']
has_criticality = any(
    any(kw in a.get('description', '').lower() for kw in criticality_keywords)
    for a in assumptions
)
if not has_criticality:
    warnings.append("G3: No assumption about business criticality/differentiation found. Downstream Phase 1 may misclassify subdomains.")

# G4: Integration existence and access
for i in data.get('integrations', []):
    iid = i.get('id', '???')
    idesc = i.get('description', '').lower()
    has_access_info = any(kw in idesc for kw in ['api', 'exposes', 'existing', 'system api',
                                                   'internal', 'proprietary', 'third-party'])
    if not has_access_info:
        warnings.append(f"G4: Integration '{iid}' has no info about access method (APIs, existing system, etc.)")

# G5: Interaction synchronicity — REMOVED from Phase 0 validation
# Sync/async is a technical design decision resolved during Solution Target binding.
# If the user provides this info (e.g., "user sees result immediately"), capture it
# in the feature description or assumptions. But it's not required at this stage.

# G6: Terminal state reversibility
# Check assumptions for terminal state info
for entity in stateful_entities:
    entity_lower = entity.lower()
    has_terminal_info = False
    for a in assumptions:
        adesc = a.get('description', '').lower()
        if entity_lower in adesc and any(kw in adesc for kw in ['terminal', 'irreversible', 'permanent',
                                                                   'cannot be reactivated', 'cannot be resumed']):
            has_terminal_info = True
    # Also check business rules
    for g in groups:
        for f in g.get('features', []):
            for br in f.get('business_rules', []):
                brdesc = br.get('description', '').lower()
                if entity_lower in brdesc and any(kw in brdesc for kw in ['cannot cancel', 'not already cancelled',
                                                                            'irreversible', 'permanently']):
                    has_terminal_info = True
            for de in f.get('data_entities', []):
                if de.get('entity', '').lower() == entity_lower:
                    role = de.get('role', '').lower()
                    if 'permanent' in role or 'terminal' in role:
                        has_terminal_info = True
    if not has_terminal_info:
        warnings.append(f"G6: Stateful entity '{entity}' has no explicit terminal state / reversibility info")

# G7: Implicit lifecycle for view-only entities
# Entities that appear ONLY in query features but are classified as 'master'
# or have lifecycle signals should be confirmed as view-only or managed
master_entities_in_queries = set()
master_entities_in_commands = set()
for g in groups:
    for f in g.get('features', []):
        ftype = f.get('type', '')
        for de in f.get('data_entities', []):
            ename = de.get('entity', '')
            classification = de.get('classification', '')
            role = de.get('role', '').lower()
            if classification == 'master':
                if ftype == 'command':
                    master_entities_in_commands.add(ename)
                elif ftype == 'query':
                    master_entities_in_queries.add(ename)

# Master entities that appear in queries but never in commands
query_only_masters = master_entities_in_queries - master_entities_in_commands
for entity in query_only_masters:
    # Check if there's an assumption confirming view-only or managed-elsewhere
    has_lifecycle_clarity = False
    entity_lower = entity.lower()
    for a in assumptions:
        adesc = a.get('description', '').lower()
        if entity_lower in adesc and any(kw in adesc for kw in ['view only', 'view-only', 'managed elsewhere',
                                                                   'managed by', 'read only', 'read-only',
                                                                   'visualization only', 'not managed']):
            has_lifecycle_clarity = True
    if not has_lifecycle_clarity:
        warnings.append(f"G7: Entity '{entity}' is classified as master but appears only in query features — confirm if users manage it or only view it")

# G8: Incomplete state operations
# For each stateful entity, check that every transition has a corresponding command
for entity in stateful_entities:
    entity_lower = entity.lower()
    # Collect known states from assumptions
    entity_states = []
    for a in assumptions:
        adesc = a.get('description', '').lower()
        if entity_lower in adesc and 'state' in adesc:
            # Found state machine assumption — check if all transitions have commands
            # Look for transition keywords in features
            transition_keywords = {
                'cancel': False, 'block': False, 'reactivate': False,
                'pause': False, 'resume': False, 'activate': False,
                'deactivate': False, 'approve': False, 'reject': False,
                'suspend': False, 'close': False, 'archive': False
            }
            # Check which transitions appear in command features
            for g in groups:
                for f in g.get('features', []):
                    if f.get('type', '') == 'command':
                        fname = f.get('id', '').lower() + ' ' + f.get('description', '').lower()
                        for kw in transition_keywords:
                            if kw in fname:
                                transition_keywords[kw] = True
            # Check which transitions are implied by the state machine
            for kw in list(transition_keywords.keys()):
                if kw in adesc and not transition_keywords[kw]:
                    # State machine mentions this transition but no command covers it
                    warnings.append(f"G8: Entity '{entity}' state machine mentions '{kw}' but no command feature covers this transition")

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
