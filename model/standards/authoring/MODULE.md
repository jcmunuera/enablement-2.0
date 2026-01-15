# Authoring Guide: MODULE

**Version:** 2.0  
**Last Updated:** 2025-01-15  
**Asset Type:** Module  
**Model Version:** 2.0

---

## What's New in v2.0

| Change | Description |
|--------|-------------|
| **Capability.Feature Reference** | Modules must declare which capability.feature they implement |
| **No Direct Skill Reference** | Modules are discovered via capabilities, not referenced by skills |
| **1:1 Feature Mapping** | Each module implements exactly ONE feature |

---

## Overview

Modules are **implementation units** that contain the knowledge for generating or transforming code. They are the "how" that implements capability features.

### Module in the Model v2.0

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           MODEL v2.0 RELATIONSHIPS                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Skill ──────► Capability ──────► Feature ──────► Module                    │
│                                      │              │                        │
│                                      │              │                        │
│                                      └──────────────┘                        │
│                                           1:1                                │
│                                                                              │
│  The module declares which capability.feature it implements                 │
│  The capability-index.yaml maps feature → module                            │
│  Skills never reference modules directly                                    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Module Structure

```
mod-code-{NNN}-{name}/
├── MODULE.md               # Specification (required)
├── templates/              # Code templates (required for CODE domain)
│   └── *.tpl
└── validation/             # Tier-3 validators (required)
    ├── README.md
    └── *-check.sh
```

---

## MODULE.md Template (v2.0)

```yaml
---
id: mod-code-001-circuit-breaker-java-resilience4j
name: "Circuit Breaker - Resilience4j"
version: "2.0.0"
date: 2025-01-15
status: Active
domain: code

# ═══════════════════════════════════════════════════════════════════════════
# CAPABILITY.FEATURE REFERENCE (Required in v2.0)
# ═══════════════════════════════════════════════════════════════════════════
# This module implements exactly ONE feature of ONE capability.
# This creates the link: capability → feature → module

implements:
  capability: resilience
  feature: circuit-breaker

# ═══════════════════════════════════════════════════════════════════════════
# TECHNOLOGY STACK
# ═══════════════════════════════════════════════════════════════════════════
stack: java-spring
library: resilience4j

# ═══════════════════════════════════════════════════════════════════════════
# KNOWLEDGE REFERENCES
# ═══════════════════════════════════════════════════════════════════════════
eri_source: eri-code-008-circuit-breaker-java-resilience4j
adr_compliance:
  - adr-004-resilience-patterns

# ═══════════════════════════════════════════════════════════════════════════
# TEMPLATE CATALOG
# ═══════════════════════════════════════════════════════════════════════════
templates:
  - source: "config/CircuitBreakerConfig.java.tpl"
    target: "src/main/java/{{packagePath}}/infrastructure/config/CircuitBreakerConfig.java"
  - source: "config/application-resilience.yml.tpl"
    target: "src/main/resources/application-resilience.yml"
    merge: true

# ═══════════════════════════════════════════════════════════════════════════
# VALIDATION (Tier-3)
# ═══════════════════════════════════════════════════════════════════════════
validation:
  scripts:
    - circuit-breaker-check.sh
  rules:
    - "CircuitBreaker annotation must be present on adapter methods"
    - "CircuitBreakerConfig must define fallback methods"
---
```

---

## The `implements` Section

### Purpose

Links the module to its capability and feature in capability-index.yaml.

```yaml
# In MODULE.md
implements:
  capability: resilience
  feature: circuit-breaker

# Must match capability-index.yaml
capabilities:
  resilience:
    features:
      circuit-breaker:
        module: mod-code-001-circuit-breaker-java-resilience4j  # This module
```

### Rules

1. **Required:** Every module MUST have an `implements` section
2. **1:1 Mapping:** One module implements exactly one feature
3. **Consistency:** Must match the mapping in capability-index.yaml

### Validation

```bash
# Check that module's implements matches capability-index.yaml
capability=$(yq '.implements.capability' MODULE.md)
feature=$(yq '.implements.feature' MODULE.md)
expected_module=$(yq ".capabilities.$capability.features.$feature.module" capability-index.yaml)

if [ "$expected_module" != "$module_id" ]; then
  echo "ERROR: Module mismatch"
  exit 1
fi
```

---

## Module Role by Skill Type

| Skill Type | Module Role | How Used |
|------------|-------------|----------|
| **Generation** | Knowledge source | Agent consults templates as guidance |
| **Transformation** | Applied directly | Templates applied to existing code |

### For Generation Skills

1. Discovery resolves capabilities → features → modules
2. Agent reads MODULE.md and templates
3. Agent generates ALL code in ONE pass
4. Templates are GUIDANCE, not executed sequentially
5. Tier-3 validation runs AFTER generation

### For Transformation Skills

1. Discovery identifies target capability → features → modules
2. Templates applied more directly to existing code
3. More deterministic transformation
4. Tier-3 validation verifies changes

---

## Template Catalog

### Structure

```yaml
templates:
  - source: "relative/path/Template.java.tpl"
    target: "output/path/{{variable}}/File.java"
    merge: false     # Optional: true for config files
    condition: null  # Optional: when to include
```

### Fields

| Field | Required | Description |
|-------|----------|-------------|
| `source` | Yes | Path relative to module's templates/ |
| `target` | Yes | Output path with {{variables}} |
| `merge` | No | If true, merge with existing (for YAML/XML) |
| `condition` | No | Condition for inclusion |

### Variables in Target Path

```yaml
# Available variables
{{serviceName}}    # Service name (PascalCase)
{{packagePath}}    # Package as path (com/example/service)
{{packageName}}    # Package as dots (com.example.service)
```

---

## Tier-3 Validation

Each module contains its own validators that verify the feature was implemented correctly.

### Location

```
mod-code-001-circuit-breaker-java-resilience4j/
└── validation/
    ├── README.md
    └── circuit-breaker-check.sh
```

### Validator Script

```bash
#!/bin/bash
# circuit-breaker-check.sh

PROJECT_DIR="${1:-.}"
ERRORS=0

pass() { echo -e "✅ PASS: $1"; }
fail() { echo -e "❌ FAIL: $1"; ERRORS=$((ERRORS + 1)); }

# Check CircuitBreaker annotation exists
if grep -r "@CircuitBreaker" "$PROJECT_DIR/src" > /dev/null; then
    pass "CircuitBreaker annotation found"
else
    fail "CircuitBreaker annotation not found"
fi

# Check fallback method exists
if grep -r "fallbackMethod" "$PROJECT_DIR/src" > /dev/null; then
    pass "Fallback method configured"
else
    fail "Fallback method not configured"
fi

exit $ERRORS
```

---

## Creating a New Module

### Step 1: Identify the Capability.Feature

Before creating a module, ensure:
1. The capability exists in capability-index.yaml
2. The feature is defined (or needs to be added)
3. No existing module implements this feature

### Step 2: Create Module Directory

```bash
mkdir -p modules/mod-code-{NNN}-{name}/
mkdir -p modules/mod-code-{NNN}-{name}/templates
mkdir -p modules/mod-code-{NNN}-{name}/validation
```

### Step 3: Write MODULE.md

Include the `implements` section:

```yaml
implements:
  capability: {capability-name}
  feature: {feature-name}
```

### Step 4: Create Templates

Templates with `.tpl` extension containing:
- Handlebars-style variables: `{{variableName}}`
- Conditional blocks: `{{#if condition}}...{{/if}}`

### Step 5: Create Validators

Bash scripts that verify the feature was implemented correctly.

### Step 6: Register in capability-index.yaml

```yaml
# Add the module mapping
capabilities:
  {capability}:
    features:
      {feature}:
        module: mod-code-{NNN}-{name}
```

---

## Example: Complete Module

### mod-code-001-circuit-breaker-java-resilience4j/MODULE.md

```markdown
---
id: mod-code-001-circuit-breaker-java-resilience4j
name: "Circuit Breaker - Resilience4j"
version: "2.0.0"
status: Active
domain: code

implements:
  capability: resilience
  feature: circuit-breaker

stack: java-spring
library: resilience4j

eri_source: eri-code-008-circuit-breaker-java-resilience4j
adr_compliance:
  - adr-004-resilience-patterns

templates:
  - source: "config/CircuitBreakerConfig.java.tpl"
    target: "src/main/java/{{packagePath}}/infrastructure/config/CircuitBreakerConfig.java"
  - source: "pom-dependencies.xml.tpl"
    target: "pom.xml"
    merge: true

validation:
  scripts:
    - circuit-breaker-check.sh
---

# Module: Circuit Breaker

## Overview

Implements the Circuit Breaker pattern using Resilience4j to prevent 
cascade failures in distributed systems.

## Pattern Implementation

The Circuit Breaker wraps calls to external services and monitors failures.
When failures exceed a threshold, the circuit "opens" and fails fast.

### States

| State | Description |
|-------|-------------|
| CLOSED | Normal operation, requests pass through |
| OPEN | Circuit tripped, requests fail immediately |
| HALF_OPEN | Testing if service recovered |

## Configuration

```yaml
resilience4j.circuitbreaker:
  instances:
    {{adapterName}}:
      failureRateThreshold: 50
      slowCallRateThreshold: 100
      waitDurationInOpenState: 60000
      permittedNumberOfCallsInHalfOpenState: 10
      slidingWindowSize: 100
```

## Usage

Apply to infrastructure adapter methods:

```java
@CircuitBreaker(name = "{{adapterName}}", fallbackMethod = "fallback")
public Response callExternalService() {
    // ...
}
```

## Validation

Tier-3 validators check:
- CircuitBreaker annotation present
- Fallback method configured
- Configuration in application.yml
```

---

## Validation Checklist

### Required in MODULE.md

- [ ] Has `implements.capability` and `implements.feature`
- [ ] `implements` matches capability-index.yaml
- [ ] Has `stack` declaration
- [ ] Has `eri_source` reference
- [ ] Has `templates` catalog (for CODE domain)
- [ ] Has `validation.scripts` list

### Required Files

- [ ] MODULE.md exists
- [ ] validation/README.md exists
- [ ] At least one validation script exists
- [ ] Templates exist (if CODE domain)

### Registration

- [ ] Module is mapped in capability-index.yaml
- [ ] Feature→Module mapping is correct

---

## Migration from v1.x Modules

### Add implements Section

```yaml
# ADD to existing MODULE.md frontmatter
implements:
  capability: resilience
  feature: circuit-breaker
```

### Verify capability-index.yaml Mapping

Ensure the module is correctly mapped:

```yaml
# In capability-index.yaml
resilience:
  features:
    circuit-breaker:
      module: mod-code-001-circuit-breaker-java-resilience4j
```

---

## Related

- `runtime/discovery/capability-index.yaml` - Feature→Module mapping
- `authoring/CAPABILITY.md` - How capabilities define features
- `authoring/SKILL.md` - How skills use capabilities
- `ENABLEMENT-MODEL-v2.0.md` - Core model documentation

---

**Last Updated:** 2025-01-15
