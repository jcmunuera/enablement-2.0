# Migration Instructions: MODULE.md Files

## Overview

All MODULE.md files need an `implements` section in their YAML frontmatter to link them to their capability.feature in capability-index.yaml.

---

## Module → Capability.Feature Mapping

| Module | Capability | Feature |
|--------|------------|---------|
| mod-code-001-circuit-breaker-java-resilience4j | resilience | circuit-breaker |
| mod-code-002-retry-java-resilience4j | resilience | retry |
| mod-code-003-timeout-java-resilience4j | resilience | timeout |
| mod-code-004-rate-limiter-java-resilience4j | resilience | rate-limiter |
| mod-code-015-hexagonal-base-java-spring | architecture | hexagonal-base |
| mod-code-016-persistence-jpa-spring | persistence | jpa |
| mod-code-017-persistence-systemapi | persistence | systemapi |
| mod-code-018-api-integration-rest-java-spring | api-integration | restclient |
| mod-code-019-api-public-exposure-java-spring | api-exposure | rest-hateoas |
| mod-code-020-compensation-java-spring | distributed-transactions | compensation |

---

## How to Update Each Module

### Step 1: Open MODULE.md

Navigate to:
```
modules/mod-code-{NNN}-{name}/MODULE.md
```

### Step 2: Add `implements` Section

In the YAML frontmatter (between `---` markers), add:

```yaml
# After existing fields like id, name, version, etc.

# ═══════════════════════════════════════════════════════════════════
# MODEL v2.0 - Capability.Feature Implementation
# ═══════════════════════════════════════════════════════════════════
implements:
  capability: {capability-name}
  feature: {feature-name}
```

---

## Example Updates

### mod-code-001-circuit-breaker-java-resilience4j

**ADD** to frontmatter:

```yaml
implements:
  capability: resilience
  feature: circuit-breaker
```

### mod-code-015-hexagonal-base-java-spring

**ADD** to frontmatter:

```yaml
implements:
  capability: architecture
  feature: hexagonal-base
```

### mod-code-016-persistence-jpa-spring

**ADD** to frontmatter:

```yaml
implements:
  capability: persistence
  feature: jpa
```

### mod-code-017-persistence-systemapi

**ADD** to frontmatter:

```yaml
implements:
  capability: persistence
  feature: systemapi
```

### mod-code-018-api-integration-rest-java-spring

**ADD** to frontmatter:

```yaml
implements:
  capability: api-integration
  feature: restclient
```

### mod-code-019-api-public-exposure-java-spring

**ADD** to frontmatter:

```yaml
implements:
  capability: api-exposure
  feature: rest-hateoas
```

### mod-code-020-compensation-java-spring

**ADD** to frontmatter:

```yaml
implements:
  capability: distributed-transactions
  feature: compensation
```

---

## Validation Script

After updating all modules, run this validation:

```bash
#!/bin/bash
# validate-module-implements.sh

KB_ROOT="${1:-.}"
CAPABILITY_INDEX="$KB_ROOT/runtime/discovery/capability-index.yaml"
MODULES_DIR="$KB_ROOT/modules"
ERRORS=0

echo "Validating module implements sections..."

for module_dir in "$MODULES_DIR"/mod-code-*/; do
    module_md="$module_dir/MODULE.md"
    
    if [[ ! -f "$module_md" ]]; then
        echo "❌ MISSING: $module_md"
        ERRORS=$((ERRORS + 1))
        continue
    fi
    
    # Extract implements section
    capability=$(grep -A2 "^implements:" "$module_md" | grep "capability:" | awk '{print $2}')
    feature=$(grep -A2 "^implements:" "$module_md" | grep "feature:" | awk '{print $2}')
    
    if [[ -z "$capability" || -z "$feature" ]]; then
        echo "❌ NO IMPLEMENTS: $module_md"
        ERRORS=$((ERRORS + 1))
        continue
    fi
    
    module_id=$(basename "$module_dir")
    
    # Verify mapping in capability-index.yaml
    expected_module=$(yq ".capabilities.$capability.features.$feature.module" "$CAPABILITY_INDEX")
    
    if [[ "$expected_module" == "$module_id" ]]; then
        echo "✅ VALID: $module_id → $capability.$feature"
    else
        echo "❌ MISMATCH: $module_id declares $capability.$feature but index maps to $expected_module"
        ERRORS=$((ERRORS + 1))
    fi
done

echo ""
echo "Validation complete. Errors: $ERRORS"
exit $ERRORS
```

---

## Git Commit

After updating all modules:

```bash
git add modules/*/MODULE.md
git commit -m "feat(modules): add implements section for Model v2.0

All MODULE.md files now declare which capability.feature they implement.
This creates the link: capability → feature → module

Changes:
- mod-001: implements resilience.circuit-breaker
- mod-002: implements resilience.retry
- mod-003: implements resilience.timeout
- mod-004: implements resilience.rate-limiter
- mod-015: implements architecture.hexagonal-base
- mod-016: implements persistence.jpa
- mod-017: implements persistence.systemapi
- mod-018: implements api-integration.restclient
- mod-019: implements api-exposure.rest-hateoas
- mod-020: implements distributed-transactions.compensation

Part of Model v2.0 migration (Phase 4)."
```
