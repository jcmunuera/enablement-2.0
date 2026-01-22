# Authoring Guide: VALIDATOR

**Version:** 1.1  
**Last Updated:** 2026-01-22  
**Asset Type:** Validator  
**Model Version:** 3.0.1

---

## What's New in v1.1

| Change | Description |
|--------|-------------|
| **Skills Eliminated** | References updated from skills to modules/flows |
| **Flow Integration** | Validators now executed by flows (flow-generate/flow-transform) |

---

## Overview

Validators are **reusable components** that verify the correctness of generated artifacts. They are organized by artifact type (not domain) to enable cross-domain reuse.

## When to Create a Validator

Create a Validator when:

- A new technology stack needs validation support
- A new artifact type is being generated
- Validation logic should be reusable across modules
- ERI constraints need automated verification

Do NOT create a Validator for:

- One-off validation logic (embed in module instead)
- Module-specific validation (use Tier 3 in module)
- Runtime/CI-CD validation (Tier 4, future)

---

## Validator Tiers

| Tier | Location | Purpose | When to Create |
|------|----------|---------|----------------|
| **1** | `validators/tier-1-universal/` | Universal structural checks | Rarely - only for new universal standards |
| **2** | `validators/tier-2-technology/` | Artifact-specific checks | When supporting new technology/artifact |
| **3** | `modules/{mod}/validation/` | Feature-specific checks | With each new module (embedded) |

---

## Directory Structure

### Tier 1 & 2 Validators

```
runtime/validators/
├── tier-1-universal/
│   └── {validator-name}/
│       ├── VALIDATOR.md        # Documentation
│       └── {name}-check.sh     # Validation script(s)
│
└── tier-2-technology/
    ├── code-projects/
    │   └── {stack}/
    │       ├── VALIDATOR.md
    │       └── *-check.sh
    ├── deployments/
    │   └── {platform}/
    │       ├── VALIDATOR.md
    │       └── *-check.sh
    ├── documents/
    │   └── {type}/
    │       ├── VALIDATOR.md
    │       └── *-check.sh
    └── reports/
        └── {type}/
            ├── VALIDATOR.md
            └── *-check.sh
```

### Tier 3 Validators (Embedded in Modules)

```
modules/{module}/
└── validation/
    ├── README.md
    └── {feature}-check.sh
```

---

## Naming Convention

### Validator ID

```
val-{tier}-{category}-{name}
```

- `{tier}`: `tier1`, `tier2`, `tier3`
- `{category}`: `generic`, `code-projects`, `deployments`, `documents`, `reports`
- `{name}`: Specific validator name

**Examples:**
- `val-tier1-generic-project-structure`
- `val-tier2-code-projects-java-spring`
- `val-tier2-deployments-docker`

### Script Names

```
{check-name}-check.sh
```

**Examples:**
- `project-structure-check.sh`
- `compile-check.sh`
- `dockerfile-check.sh`

---

## Required VALIDATOR.md Structure

```yaml
---
validator_id: val-{tier}-{category}-{name}
tier: 1|2|3
category: generic|code-projects|deployments|documents|reports
target: {what it validates}
version: X.Y.Z
cross_domain_usage:
  - code: "{usage description}"
  - qa: "{usage description}"
---
```

### Template

```markdown
# Validator: {Name}

## Purpose

[What this validator checks and why]

## Checks

| Script | Type | Description |
|--------|------|-------------|
| `{script}.sh` | Required/Warning | [What it validates] |

## Usage

```bash
./{name}-check.sh <target-directory>
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All checks passed |
| 1 | One or more checks failed |

## Check Details

### {script-name}.sh

[Detailed description of what this script checks]

**Checks:**
- [ ] {Check 1}
- [ ] {Check 2}

**Skip Conditions:**
- {When this check is skipped}

## Output Example

```
✅ PASS: {what passed}
❌ FAIL: {what failed}
⚠️  WARN: {warning message}
⏸️  SKIP: {skip reason}
```

## Dependencies

- {Required tool 1}
- {Required tool 2}

## When This Runs

- **Tier:** {1|2|3}
- **Frequency:** {ALWAYS|CONDITIONAL}
- **Condition:** {When it runs}

## Related

- **ADR:** {related ADR}
- **ERI:** {related ERI}
- **Other Validators:** {validators that run before/after}
```

---

## Validation Script Template

```bash
#!/bin/bash
# {name}-check.sh
# {Brief description}
# Tier: {1|2|3}
# Category: {category}

SERVICE_DIR="${1:-.}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Output functions
pass() { echo -e "${GREEN}✅ PASS:${NC} $1"; }
fail() { echo -e "${RED}❌ FAIL:${NC} $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo -e "${YELLOW}⚠️  WARN:${NC} $1"; }
skip() { echo -e "${BLUE}⏸️  SKIP:${NC} $1"; }

ERRORS=0

# ══════════════════════════════════════════════════════════════════
# CHECK 1: {Description}
# ══════════════════════════════════════════════════════════════════

if [ condition ]; then
    pass "{what passed}"
else
    fail "{what failed}"
fi

# ══════════════════════════════════════════════════════════════════
# CHECK 2: {Description}
# ══════════════════════════════════════════════════════════════════

# Skip condition
if [ skip_condition ]; then
    skip "{reason for skip}"
else
    if [ check_condition ]; then
        pass "{what passed}"
    else
        fail "{what failed}"
    fi
fi

# ══════════════════════════════════════════════════════════════════
# RESULT
# ══════════════════════════════════════════════════════════════════

if [ $ERRORS -eq 0 ]; then
    exit 0
else
    exit 1
fi
```

---

## Cross-Domain Usage

Validators are organized by **artifact type**, not domain:

```
val-tier2-code-projects-java-spring
  │
  ├── Used by: mod-code-020-microservice-java-spring
  │            (CODE domain - flow-generate)
  │
  └── Used by: mod-qa-010-analyze-java-code
               (QA domain - validation)
```

Document cross-domain usage in VALIDATOR.md:

```yaml
cross_domain_usage:
  - code: "Validates generated Java code compiles"
  - qa: "Verifies code under analysis compiles before quality checks"
```

---

## Validation Checklist

Before deploying a validator:

- [ ] VALIDATOR.md documents all checks
- [ ] Script(s) follow naming convention
- [ ] Scripts use standard output functions (pass/fail/warn/skip)
- [ ] Exit codes are correct (0=pass, non-zero=fail)
- [ ] Skip conditions are documented
- [ ] Dependencies are listed
- [ ] Cross-domain usage is documented
- [ ] At least one module references this validator

---

## Best Practices

### Script Quality

1. **Idempotent:** Running multiple times produces same result
2. **Fast:** Avoid long-running operations when possible
3. **Clear output:** Use pass/fail/warn/skip consistently
4. **Helpful errors:** Explain what's wrong and how to fix
5. **Skip gracefully:** Don't fail if preconditions not met

### Check Design

1. **One concern per check:** Keep checks focused
2. **Required vs Warning:** Use ERROR for must-fix, WARNING for should-fix
3. **Evidence:** Include specific details in failure messages
4. **Actionable:** Tell users how to fix issues

### Integration

1. **Document order:** Specify which validators run before/after
2. **Dependencies:** List required tools clearly
3. **Conditions:** Document when validator runs/skips

---

## Tier-Specific Guidelines

### Tier 1: Generic

- Apply to ALL generated projects
- Technology-agnostic
- Focus on structure and naming
- Rarely added (only for new universal standards)

### Tier 2: Artifacts

- Apply based on artifact type
- Technology-specific
- Focus on compilation, configuration, format
- Added when supporting new technology/artifact

### Tier 3: Module (Embedded)

- Apply based on enabled features
- Feature-specific
- Focus on pattern implementation
- Added with each new module

---

## Examples

### Good Validator

```bash
# project-structure-check.sh
# Clear, focused, helpful output

if [ -d "$SERVICE_DIR/src/main/java" ]; then
    pass "src/main/java exists"
else
    fail "src/main/java missing - create standard Maven source directory"
fi
```

### Poor Validator

```bash
# Bad example - don't do this

if [ -d "src" ]; then
    echo "OK"  # No standard output format
else
    echo "Error"  # Not helpful
    # No exit code!
fi
```

---

## Adding a New Technology Stack

When adding support for a new technology (e.g., Python):

1. **Create Tier 2 validator directory:**
   ```
   validators/tier-2-technology/code-projects/python/
   ```

2. **Create VALIDATOR.md** with all checks documented

3. **Create check scripts:**
   - `syntax-check.sh` - Python syntax validation
   - `requirements-check.sh` - Dependencies present
   - `test-check.sh` - Tests pass

4. **Update modules** that generate Python code to use validators

5. **Document cross-domain usage** for QA modules

---

## Related

- `model/standards/validation/README.md` - Validation system overview
- `model/standards/ASSET-STANDARDS-v1.4.md` - Validator structure
- `runtime/validators/` - Existing validators
- `authoring/MODULE.md` - Tier 3 validators in modules
- `authoring/FLOW.md` - How flows execute validators

---

**Last Updated:** 2026-01-22
