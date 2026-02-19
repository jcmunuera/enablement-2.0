# Authoring Guide: MODULE

**Version:** 3.2  
**Last Updated:** 2026-02-04  
**Asset Type:** Module  
**Model Version:** 3.0.16

---

## What's New in v3.2

| Change | Description |
|--------|-------------|
| **variants** | New section for defining implementation variants within a module (DEC-041) |
| **Template headers** | `// Output:` and `// Variant:` headers now mandatory (DEC-036, DEC-040) |
| **TEMPLATE.md** | New authoring guide for .tpl files |
| **Style files** | Stack-specific style rules in runtime/codegen/styles/ (DEC-042) |

## What's New in v3.1

| Change | Description |
|--------|-------------|
| **subscribes_to_flags** | New section for declaring config flag subscriptions (DEC-035) |
| **Template conditionals** | `{{#config.flag}}` syntax for flag-based code generation |
| **Config Flags Pub/Sub** | Pattern for reacting to flags published by feature modules |

## What's New in v3.0

| Change | Description |
|--------|-------------|
| **Skills Eliminated** | Modules are discovered via capabilities only |
| **Stack Declaration** | `stack` in frontmatter required for filtering |
| **1:1 Feature Mapping** | Each module implements exactly ONE feature |
| **Phase-Based Execution** | Modules loaded per phase, not all at once |

---

## Overview

Modules are **implementation units** that contain the knowledge for generating or transforming code. They are the "how" that implements capability features.

### Module in the Model v3.0

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           MODEL v3.0 RELATIONSHIPS                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Capability ──────► Feature ──────► Implementation ──────► Module           │
│                        │                   │                   │             │
│                        │                   │                   │             │
│                        └───────────────────┴───────────────────┘             │
│                                      1:1:1                                   │
│                                                                              │
│  The module declares which capability.feature it implements                 │
│  The capability-index.yaml maps feature → implementation → module           │
│  Discovery resolves capability → feature → module (via stack)               │
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

## MODULE.md Template (v3.0)

```yaml
---
id: mod-code-001-circuit-breaker-java-resilience4j
name: "Circuit Breaker - Resilience4j"
version: "2.0.0"
date: 2025-01-15
status: Active
domain: code

# ═══════════════════════════════════════════════════════════════════════════
# CAPABILITY.FEATURE REFERENCE (Required)
# ═══════════════════════════════════════════════════════════════════════════
# This module implements exactly ONE feature of ONE capability.
# This creates the link: capability → feature → module

implements:
  capability: resilience
  feature: circuit-breaker
  stack: java-spring   # Required for stack filtering

# ═══════════════════════════════════════════════════════════════════════════
# TECHNOLOGY STACK
# ═══════════════════════════════════════════════════════════════════════════
stack: java-spring
library: resilience4j

# ═══════════════════════════════════════════════════════════════════════════
# MODULE VARIANTS (DEC-041) - Optional
# ═══════════════════════════════════════════════════════════════════════════
# Define when the module offers multiple implementation alternatives.
# User can select via prompt keywords, or default is used.
# See: "Module Variants" section below for detailed documentation.

variants:
  http_client:
    description: "HTTP client implementation"
    default: restclient
    options:
      restclient:
        description: "Spring 6.1+ RestClient (recommended)"
        templates:
          - client/restclient.java.tpl
        keywords:
          - restclient
          - rest client
      feign:
        description: "OpenFeign declarative client"
        templates:
          - client/feign.java.tpl
          - config/feign-config.java.tpl
        dependencies:
          - groupId: org.springframework.cloud
            artifactId: spring-cloud-starter-openfeign
        keywords:
          - feign
          - openfeign

# ═══════════════════════════════════════════════════════════════════════════
# CONFIG FLAG SUBSCRIPTIONS (DEC-035) - Optional
# ═══════════════════════════════════════════════════════════════════════════
# Declare flags this module reacts to (published by other capabilities).
# See: "Config Flags Subscription" section below for detailed documentation.

subscribes_to_flags:
  - flag: hateoas
    publisher: api-architecture.domain-api
    affects:
      - templates/application/Response.java.tpl
    behavior: |
      When hateoas=true: Skip this template, mod-019 generates HATEOAS version.
      When hateoas=false: Generate standard Response.java record.

# ═══════════════════════════════════════════════════════════════════════════
# INTER-MODULE DEPENDENCIES (ODEC-016)
# ═══════════════════════════════════════════════════════════════════════════
# Declare relationships with other modules for subphase grouping and
# execution ordering. Used by Plan Agent when >4 modules per phase.
dependencies:
  requires:                  # Must be generated BEFORE this module
    - mod-code-015-hexagonal-base-java-spring
  co_locate:                 # Should be in same subphase if possible
    - mod-code-018-api-integration-rest-java-spring
  incompatible: []           # Cannot coexist in same generation
  layer: adapter/out/persistence  # Architectural layer (informational)

# ═══════════════════════════════════════════════════════════════════════════
# KNOWLEDGE REFERENCES
# ═══════════════════════════════════════════════════════════════════════════
eri_source: eri-code-008-circuit-breaker-java-resilience4j
adr_compliance:
  - adr-004-resilience-patterns

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

## Module Role by Flow

| Flow | Module Role | How Used |
|------|-------------|----------|
| **flow-generate** | Knowledge source | Agent consults templates as guidance |
| **flow-transform** | Applied directly | Templates applied to existing code |

### For flow-generate

1. Discovery resolves capabilities → features → modules
2. Modules grouped by `phase_group` (structural → implementation → cross-cutting)
3. Agent reads MODULE.md and templates for current phase
4. Agent generates code in ONE pass per phase
5. Templates are GUIDANCE, not executed sequentially
6. Tier-3 validation runs AFTER generation

### For flow-transform

1. Discovery identifies target capability → features → modules
2. Templates applied more directly to existing code
3. Cross-cutting capabilities can apply without foundational
4. More deterministic transformation
5. Tier-3 validation verifies changes

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

## Inter-Module Dependencies (ODEC-016)

The `dependencies` section declares relationships between modules. These are used by the Plan Agent for subphase grouping when a phase contains more than 4 modules.

### Fields

| Field | Type | Purpose |
|-------|------|---------|
| `requires` | list of module IDs | Modules that must be generated BEFORE this one. Establishes execution order across subphases. |
| `co_locate` | list of module IDs | Modules that should be in the same subphase when possible. Hint for grouping (not hard constraint). |
| `incompatible` | list of module IDs | Modules that cannot coexist in the same generation. Validated at Discovery time. |
| `layer` | string | Architectural layer where this module generates code. Informational, not used for grouping. |

### Layer Values

| Value | Meaning | Example Modules |
|-------|---------|-----------------|
| `domain + application + adapter/in` | Multi-layer foundational | mod-015 |
| `adapter/in/rest` | REST controller enrichment | mod-019 |
| `adapter/out/persistence` | Database or backend access | mod-016, mod-017 |
| `adapter/out/integration` | External service integration | mod-018 |
| `cross-cutting/resilience` | Resilience decorators | mod-001, mod-002, mod-003, mod-004 |
| `domain + application` | Domain logic additions | mod-020 |

### Rules

1. **Foundation module (mod-015) requires nothing** — it is the base for all other modules.
2. **Phase 2 modules require mod-015** — they extend the domain model and adapters.
3. **Phase 3 modules require their transform targets** — e.g., mod-001 requires mod-017 because it transforms the SystemApiAdapter.
4. **`co_locate` is a soft hint** — the Plan Agent uses it for optimization but can split if context window limits require it.
5. **`incompatible` is a hard constraint** — Discovery Agent must reject combinations where incompatible modules are both selected.

### Example

```yaml
# mod-code-017 (persistence-systemapi)
dependencies:
  requires:
    - mod-code-015-hexagonal-base-java-spring
    - mod-code-018-api-integration-rest-java-spring
  co_locate:
    - mod-code-018-api-integration-rest-java-spring
  incompatible: []
  layer: adapter/out/persistence
```

This declares that mod-017 needs mod-015 (domain model) and mod-018 (RestClient) to exist before it generates, and should be grouped with mod-018 in the same subphase for import coherence.

---

## Module Variants (DEC-041)

Variants allow a module to offer multiple implementation alternatives that users can select via prompt keywords.

### Config Flags vs Variants

| Concept | Config Flags | Variants |
|---------|--------------|----------|
| **Defined in** | capability-index.yaml | MODULE.md |
| **Semantics** | "Is this capability active?" | "Which implementation to use?" |
| **Scope** | Cross-module influence | Intra-module selection |
| **Example** | `hateoas: true` | `http_client: feign` |

### When to Use Variants

Use variants when:
- Your module has multiple valid implementations of the same feature
- User might prefer one over another based on their environment
- Each variant has different templates, dependencies, or configuration

**Examples:**
- HTTP clients: RestClient vs Feign vs RestTemplate
- Caching: Redis vs Caffeine vs Hazelcast
- Messaging: Kafka vs RabbitMQ vs ActiveMQ

### Defining Variants in MODULE.md

```yaml
variants:
  variant_name:                    # Identifier (used in config_flags)
    description: "Human readable"  # Shown in documentation
    default: option_id             # Used when no keyword detected
    options:
      option_id:
        description: "Option description"
        templates:                 # Templates specific to this option
          - path/to/template.tpl
        dependencies:              # Additional Maven deps (optional)
          - groupId: org.example
            artifactId: example-lib
        keywords:                  # Prompt keywords that select this option
          - keyword1
          - "multi word keyword"
```

### Template Variant Header

Templates for specific variants MUST include a `// Variant:` header:

```java
// Output: src/main/java/{{basePackagePath}}/client/{{Entity}}Client.java
// Variant: feign

package {{basePackage}}.client;

@FeignClient(name = "{{entity}}-api")
public interface {{Entity}}Client {
    // Feign-specific implementation
}
```

**Rules:**
1. `// Variant:` must be immediately after `// Output:`
2. Value must match an option ID in MODULE.md variants section
3. Only ONE variant per template file
4. Templates without `// Variant:` are always included

### Variant Selection Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         VARIANT SELECTION FLOW                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. User prompt: "Create API using Feign client"                           │
│           │                                                                 │
│           ▼                                                                 │
│  2. Discovery: Scans prompt for variant keywords                           │
│     → Finds "feign" → matches mod-017.http_client.feign                    │
│     → Output: variant_selections: {"mod-017.http_client": "feign"}         │
│           │                                                                 │
│           ▼                                                                 │
│  3. Context: Resolves variant to config_flags                              │
│     → config_flags: {http_client: "feign"}                                 │
│           │                                                                 │
│           ▼                                                                 │
│  4. CodeGen: Filters templates by // Variant: header                       │
│     → Only includes templates with "// Variant: feign"                     │
│     → Skips "// Variant: restclient" templates                             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete Example

**MODULE.md:**
```yaml
variants:
  http_client:
    description: "HTTP client implementation for System API calls"
    default: restclient
    options:
      restclient:
        description: "Spring 6.1+ RestClient (recommended)"
        templates:
          - client/restclient.java.tpl
        keywords:
          - restclient
          - rest client
          - webclient
      feign:
        description: "OpenFeign declarative client"
        templates:
          - client/feign.java.tpl
          - config/feign-config.java.tpl
        dependencies:
          - groupId: org.springframework.cloud
            artifactId: spring-cloud-starter-openfeign
        keywords:
          - feign
          - openfeign
          - declarative client
```

**templates/client/restclient.java.tpl:**
```java
// Output: src/main/java/{{basePackagePath}}/client/{{Entity}}Client.java
// Variant: restclient

@Component
public class {{Entity}}Client {
    private final RestClient restClient;
    // RestClient implementation...
}
```

**templates/client/feign.java.tpl:**
```java
// Output: src/main/java/{{basePackagePath}}/client/{{Entity}}Client.java
// Variant: feign

@FeignClient(name = "{{entity}}-api")
public interface {{Entity}}Client {
    // Feign declarative interface...
}
```

---

## Config Flag Subscriptions (DEC-035)

Modules can **subscribe** to config flags published by other modules. This enables cross-module influence without tight coupling.

### Purpose

Feature modules (e.g., mod-019 HATEOAS) publish flags that affect code generation in core modules (e.g., mod-015's Response.java). The subscriber module declares which flags affect its templates and how.

### Declaring Subscriptions (MODULE.md)

Add a `subscribes_to_flags` section to your MODULE.md:

```yaml
# In MODULE.md frontmatter or dedicated section
subscribes_to_flags:
  - flag: hateoas
    publisher: mod-code-019-api-public-exposure-java-spring
    affects:
      - template: templates/application/dto/Response.java.tpl
        skip_when: true       # Skip this template when flag is true
    behavior: |
      When true:  DO NOT generate Response.java from this module.
                  mod-019 generates HATEOAS version instead.
      When false: Generate Response.java as immutable record.
```

### The `skip_when` Field

The `skip_when` field enables **deterministic template filtering** in run-codegen.sh. When a config flag matches the `skip_when` value, the template is excluded from the CodeGen prompt automatically — the LLM never sees it.

| `skip_when` value | Flag value | Result |
|-------------------|-----------|--------|
| `true` | `true` | Template SKIPPED |
| `true` | `false` or absent | Template INCLUDED |
| `false` | `false` | Template SKIPPED |
| `false` | `true` or absent | Template INCLUDED |

**Rules:**
1. `skip_when` is parsed by run-codegen.sh — it is deterministic, not probabilistic
2. `behavior` remains as human-readable documentation
3. Each `affects` entry uses `template:` key with path relative to the module root
4. The template path must match what run-codegen.sh sees when traversing the module's templates/

### Two Mechanisms for Flag Reactions

| Mechanism | When to use | Determinism |
|-----------|-------------|-------------|
| **`skip_when`** | Skip entire template (another module provides alternative) | 100% — script-level filtering |
| **Template conditionals** (`{{#config.flag}}`) | Same template, different code paths | LLM-dependent |

**Prefer `skip_when`** when the flag means "another module handles this entirely". Use template conditionals only when the same template needs minor variations based on a flag.

### Governance

- Document all subscriptions in MODULE.md
- Each subscription should specify `flag`, `affects` (templates), and `behavior`
- Check ENABLEMENT-MODEL-v3.0.md for the Standard Flags Registry
- Orphan flags (published but not subscribed) should be investigated

### See Also

- DEC-035: Config Flags Pub/Sub Pattern
- CAPABILITY.md: `publishes_flags` attribute
- ENABLEMENT-MODEL-v3.0.md: Standard Flags Registry

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

## Determinism and Module-Specific Rules

### Rule Architecture

Rules for code generation follow a **cohesion principle**: module-specific rules live with their modules.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         RULE ARCHITECTURE                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  DETERMINISM-RULES.md (Global)         MODULE.md (Specific)             │
│  ├── Java patterns (records, DTOs)     ├── ## ⚠️ CRITICAL section       │
│  ├── Required annotations              │   └── Rules that ONLY apply    │
│  ├── Forbidden patterns (Lombok)       │       to THIS module           │
│  ├── Code style conventions            ├── Templates                     │
│  └── Dependency versions               └── Module-specific patterns      │
│                                                                          │
│  Priority: MODULE.md CRITICAL > MODULE.md templates > DETERMINISM-RULES │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### The `## ⚠️ CRITICAL` Section

Modules SHOULD include a CRITICAL section at the top of the markdown body for rules that:
- **Only apply to this module** (not globally)
- **Override general patterns** when there's a conflict
- **Prevent known hallucinations** specific to this module's technology

```markdown
# Module: My Module

## ⚠️ CRITICAL: [Rule Name]

**[Clear statement of the rule]**

\`\`\`java
// ❌ WRONG - [Explanation]
bad code example

// ✅ CORRECT - [Explanation]  
good code example
\`\`\`

**Why?**
- Bullet points explaining rationale
- Reference to specific constraints

**This rule OVERRIDES [other rule/module] when [condition].**

---
```

### Examples of Module-Specific Rules

| Module | CRITICAL Rule | Why Module-Specific |
|--------|---------------|---------------------|
| mod-017 (System API) | NO @Transactional | Only applies when persistence is via HTTP |
| mod-018 (REST Client) | RestClient is DEFAULT | Only applies to API integration |
| mod-019 (API Exposure) | NO Spring Data Pageable | Only applies when not using JPA |

### Rule Lifecycle

When a module is **deprecated**, its specific rules go with it:

```
mod-017 DEPRECATED
  ├── MODULE.md archived
  ├── Templates archived  
  └── "NO @Transactional" rule automatically obsolete
      (No need to update DETERMINISM-RULES.md)
```

### What Goes Where

| Rule Type | Location | Example |
|-----------|----------|---------|
| **Global Java/Spring patterns** | DETERMINISM-RULES.md | "Use records for DTOs" |
| **Module-specific constraints** | MODULE.md CRITICAL | "NO @Transactional with System API" |
| **Known hallucinations (global)** | DETERMINISM-RULES.md | "String.replace has no 3-arg version" |
| **Known hallucinations (module)** | MODULE.md CRITICAL | "Pageable requires spring-data" |

---

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
- `model/ENABLEMENT-MODEL-v3.0.md` - Core model documentation
- `runtime/flows/code/flow-generate.md` - Generation flow
- `runtime/flows/code/flow-transform.md` - Transformation flow

---

**Last Updated:** 2026-01-21
