# Authoring Guide: SKILL

**Version:** 3.0  
**Last Updated:** 2025-01-15  
**Asset Type:** Skill  
**Priority:** CRITICAL  
**Model Version:** 2.0

---

## What's New in v3.0 (Model v2.0)

| Change | Description |
|--------|-------------|
| **Skill Types** | Skills are now either `generation` or `transformation` |
| **Capability-based** | Skills declare capabilities, NOT modules directly |
| **No Inheritance** | `extends:` is removed; skills are self-contained |
| **Required Capabilities** | Generation skills declare `required_capabilities` |
| **Target Capability** | Transformation skills declare `target_capability` |

### Removed in v3.0

| Removed | Replacement |
|---------|-------------|
| `extends:` | Skills declare all capabilities explicitly |
| `modules:` section | Modules resolved via capability-index.yaml |
| `modules_added:` | Not needed (no inheritance) |
| Conditional modules | Capabilities inferred from prompt |

---

## Overview

Skills are **automated executable capabilities** that leverage the Knowledge Base to perform tasks. They are the primary interface between AI orchestration and the accumulated knowledge.

### Skill Types

| Type | Purpose | Key Attribute | Example |
|------|---------|---------------|---------|
| **Generation** | Create artifacts from scratch | `required_capabilities` | skill-021-api-rest |
| **Transformation** | Modify existing code | `target_capability` | skill-040-add-resilience |

---

## Skill Architecture (v2.0)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              SKILL                                           │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  SKILL.md - Complete specification                                     │  │
│  │  - Type: generation | transformation                                   │  │
│  │  - Required/Target capabilities (NOT modules)                         │  │
│  │  - References execution flow                                          │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                              │                                               │
│                              ▼                                               │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  Discovery Resolution                                                  │  │
│  │  - capability-index.yaml resolves capabilities → features → modules   │  │
│  │  - Compatibility validated automatically                               │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                              │                                               │
│                              ▼                                               │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  prompts/ - AI orchestration instructions                              │  │
│  │  - system.md: Role, context, constraints                               │  │
│  │  - user.md: Request template                                           │  │
│  │  - examples/: Few-shot examples                                        │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                              │                                               │
│                              ▼                                               │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  validation/ - Quality assurance                                       │  │
│  │  - validate.sh: Orchestrates validators                                │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Directory Structure

```
skills/
├── code/
│   ├── soi/                           # System of Integration
│   │   ├── skill-020-microservice-java-spring/    # Generation
│   │   ├── skill-021-api-rest-java-spring/        # Generation
│   │   ├── skill-040-add-resilience-java-spring/  # Transformation
│   │   └── skill-041-add-api-exposure-java-spring/ # Transformation
│   ├── soe/                           # System of Engagement
│   └── sor/                           # System of Record
├── design/
├── qa/
└── governance/
```

### Skill Internal Structure

```
skill-{NNN}-{name}/
├── SKILL.md            # Complete specification (required)
├── OVERVIEW.md         # Quick reference for discovery (required)
├── README.md           # External-facing documentation (required)
├── prompts/            # AI prompts (required)
│   ├── system.md
│   ├── user.md
│   └── examples/
└── validation/         # Validation orchestration (required)
    ├── README.md
    └── validate.sh
```

---

## SKILL.md Template: Generation Skill

```yaml
---
id: skill-021-api-rest-java-spring
title: "Skill: Fusion REST API Generator"
version: 2.0.0
date: 2025-01-15
status: Active
domain: code
layer: soi

# ═══════════════════════════════════════════════════════════════════
# SKILL TYPE (Required in v2.0)
# ═══════════════════════════════════════════════════════════════════
type: generation

# ═══════════════════════════════════════════════════════════════════
# REQUIRED CAPABILITIES (Replaces modules section)
# ═══════════════════════════════════════════════════════════════════
# These capabilities are ALWAYS included when this skill executes.
# Additional capabilities are inferred from the user prompt.
# Capabilities resolve to modules via capability-index.yaml.

required_capabilities:
  - architecture.hexagonal-base    # Structural - defines code foundation
  - api-exposure.rest-hateoas      # Compositional - required for this skill type

# ═══════════════════════════════════════════════════════════════════
# STACK (Required)
# ═══════════════════════════════════════════════════════════════════
stack: java-spring

# ═══════════════════════════════════════════════════════════════════
# OUTPUT SPECIFICATION
# ═══════════════════════════════════════════════════════════════════
output:
  type: code-project
  technology: java-spring

# ═══════════════════════════════════════════════════════════════════
# GOVERNANCE REFERENCES
# ═══════════════════════════════════════════════════════════════════
adr_compliance:
  - adr-001-api-design-standards
  - adr-009-service-architecture-patterns
eri_reference:
  - eri-code-001-hexagonal-light-java-spring
  - eri-code-014-api-public-exposure-java-spring
traceability_profile: code-project

# ═══════════════════════════════════════════════════════════════════
# DISCOVERY TAGS
# ═══════════════════════════════════════════════════════════════════
tags:
  artifact-type: api
  runtime-model: request-response
  stack: java-spring
  protocol: rest
  api-model: fusion

keywords:
  - REST API
  - Domain API
  - Fusion API
  - HATEOAS
  - OpenAPI
  - microservice
  - Spring Boot
---
```

### Generation Skill Body

```markdown
# Skill: Fusion REST API Generator

**Skill ID:** skill-021-api-rest-java-spring  
**Type:** Generation  
**Version:** 2.0.0  
**Status:** Active

---

## Overview

Generates a complete Fusion REST API microservice with:
- Hexagonal architecture (ports and adapters)
- HATEOAS-compliant REST endpoints
- OpenAPI specification
- Domain-driven design patterns

---

## Required Capabilities

| Capability | Type | Purpose |
|------------|------|---------|
| `architecture.hexagonal-base` | Structural | Code foundation and layer separation |
| `api-exposure.rest-hateoas` | Compositional | REST endpoints with HATEOAS |

> **Note:** Additional capabilities (resilience, persistence, etc.) are inferred 
> from the user prompt and validated for compatibility automatically.

---

## Capability Resolution

This skill does NOT declare modules directly. Module resolution happens via:

1. `required_capabilities` → capability-index.yaml → modules
2. Prompt analysis → additional capabilities → capability-index.yaml → modules
3. Compatibility validation → final module list

**Example Resolution:**

```
User prompt: "Generate Customer API with resilience and System API backend"

Required (from skill):
  architecture.hexagonal-base → mod-015
  api-exposure.rest-hateoas → mod-019

From prompt:
  "resilience" → resilience.* → mod-001, mod-002, mod-003, mod-004
  "System API backend" → persistence.systemapi → mod-017
                       → (requires) api-integration.restclient → mod-018

Final modules: [mod-015, mod-019, mod-001, mod-002, mod-003, mod-004, mod-017, mod-018]
```

---

## Input Specification

### Required Parameters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `serviceName` | string | Service name (PascalCase) | `CustomerService` |
| `packageName` | string | Java package | `com.company.customer` |
| `apiName` | string | API name | `Customer API` |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `persistence` | string | none | Persistence type (jpa, systemapi) |
| `resilience` | boolean | false | Enable resilience patterns |

---

## Output Specification

```
{serviceName}/
├── src/main/java/{package}/
│   ├── domain/
│   ├── application/
│   └── infrastructure/
│       └── rest/
├── src/main/resources/
│   └── openapi/
├── pom.xml
└── .enablement/
    └── manifest.json
```

---

## Execution Flow

This skill follows the **GENERATE** execution flow.

**See:** `runtime/flows/code/GENERATE.md`

---

## Semantic Relationships

| Related Skill | Relationship |
|---------------|--------------|
| skill-020-microservice | Same architecture, no API exposure |
| skill-040-add-resilience | Adds resilience to existing code |
| skill-041-add-api-exposure | Promotes microservice to API |

> **Note:** These are semantic relationships for documentation.
> There is no technical inheritance between skills.

---

## Changelog

| Date | Version | Change |
|------|---------|--------|
| 2025-01-15 | 2.0.0 | Migrated to capability-based model (v2.0) |
| 2024-12-01 | 1.5.0 | Previous version with module references |
```

---

## SKILL.md Template: Transformation Skill

```yaml
---
id: skill-040-add-resilience-java-spring
title: "Skill: Add Resilience Patterns"
version: 1.0.0
date: 2025-01-15
status: Active
domain: code
layer: soi

# ═══════════════════════════════════════════════════════════════════
# SKILL TYPE
# ═══════════════════════════════════════════════════════════════════
type: transformation

# ═══════════════════════════════════════════════════════════════════
# TARGET CAPABILITY (Replaces modules for transformation skills)
# ═══════════════════════════════════════════════════════════════════
# This is the capability that this skill ADDS to existing code.
# Features within the capability are determined from the user prompt.

target_capability: resilience

# ═══════════════════════════════════════════════════════════════════
# COMPATIBLE WITH (Required for transformation skills)
# ═══════════════════════════════════════════════════════════════════
# What existing architecture this skill can work with.
# Validated against the target code before transformation.

compatible_with:
  - architecture.hexagonal-base

# ═══════════════════════════════════════════════════════════════════
# STACK
# ═══════════════════════════════════════════════════════════════════
stack: java-spring

# ═══════════════════════════════════════════════════════════════════
# OUTPUT SPECIFICATION
# ═══════════════════════════════════════════════════════════════════
output:
  type: code-transformation
  technology: java-spring

# ═══════════════════════════════════════════════════════════════════
# GOVERNANCE
# ═══════════════════════════════════════════════════════════════════
adr_compliance:
  - adr-004-resilience-patterns
eri_reference:
  - eri-code-008-circuit-breaker-java-resilience4j
  - eri-code-009-retry-java-resilience4j
  - eri-code-010-timeout-java-resilience4j
traceability_profile: code-transformation

# ═══════════════════════════════════════════════════════════════════
# DISCOVERY
# ═══════════════════════════════════════════════════════════════════
keywords:
  - add resilience
  - circuit breaker
  - retry
  - timeout
  - fault tolerance
  - añadir resiliencia
---
```

### Transformation Skill Body

```markdown
# Skill: Add Resilience Patterns

**Skill ID:** skill-040-add-resilience-java-spring  
**Type:** Transformation  
**Version:** 1.0.0  
**Status:** Active

---

## Overview

Adds resilience patterns (circuit breaker, retry, timeout, rate limiter) 
to existing hexagonal Java Spring code.

---

## Target Capability

| Capability | Features |
|------------|----------|
| `resilience` | circuit-breaker, retry, timeout, rate-limiter |

> **Feature Resolution:** The specific features to apply are determined from 
> the user prompt. If unspecified, all features are applied.

---

## Compatible With

This transformation skill works only with code that has:

| Required Architecture | Reason |
|----------------------|--------|
| `architecture.hexagonal-base` | Resilience is applied at adapter/port boundaries |

---

## Feature Resolution Examples

| User Prompt | Features Applied |
|-------------|------------------|
| "Add circuit breaker" | resilience.circuit-breaker |
| "Add resilience" | All: circuit-breaker, retry, timeout, rate-limiter |
| "Add retry and timeout" | resilience.retry, resilience.timeout |
| "Add fault tolerance" | All (synonym for resilience) |

---

## Input Specification

### Required

| Parameter | Type | Description |
|-----------|------|-------------|
| `targetProject` | path | Path to existing project |

### Optional

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `features` | array | all | Specific features to add |
| `targetServices` | array | all | Services to apply resilience to |

---

## Execution Flow

This skill follows the **ADD** execution flow.

**See:** `runtime/flows/code/ADD.md`

---

## Pre-Transformation Validation

Before applying transformation:

1. Verify target project exists
2. Verify architecture is `hexagonal-base`
3. Check for existing resilience patterns (avoid duplicates)

---

## Post-Transformation Output

```
{targetProject}/
├── src/main/java/{package}/
│   └── infrastructure/
│       └── config/
│           └── ResilienceConfig.java    # ADDED
├── pom.xml                              # MODIFIED (dependencies)
└── .enablement/
    └── transformation-log.json          # GENERATED
```

---

## Changelog

| Date | Version | Change |
|------|---------|--------|
| 2025-01-15 | 1.0.0 | Initial version (replaces skill-001-circuit-breaker) |
```

---

## OVERVIEW.md Template (v2.0)

```yaml
---
id: skill-021-api-rest-java-spring
version: 2.0.0
type: generation
tags:
  artifact-type: api
  runtime-model: request-response
  stack: java-spring
  protocol: rest
  api-model: fusion
---

# skill-021-api-rest-java-spring

## Overview

**Skill ID:** skill-021-api-rest-java-spring  
**Type:** GENERATION  
**Stack:** Java 17+ / Spring Boot 3.2.x  
**Architecture:** Hexagonal + REST API

---

## Purpose

Generates a complete Fusion REST API microservice with hexagonal architecture,
HATEOAS-compliant endpoints, and OpenAPI specification.

---

## When to Use

✅ **Use this skill when:**
- Creating a new Domain/Fusion API from scratch
- Need REST endpoints with HATEOAS
- Building customer-facing APIs

❌ **Do NOT use when:**
- Modifying existing code (use transformation skills)
- Creating internal service without API (use skill-020)
- Need gRPC or GraphQL (different skills)

---

## Required Capabilities

| Capability | Type |
|------------|------|
| architecture.hexagonal-base | Structural |
| api-exposure.rest-hateoas | Compositional |

---

## Additional Capabilities (from prompt)

These are inferred from the user request:
- resilience.* (circuit-breaker, retry, timeout)
- persistence.* (jpa, systemapi)
- api-integration.* (restclient)

---

## Version

**Current:** 2.0.0  
**Model:** v2.0  
**Status:** Active
```

---

## Key Differences: Generation vs Transformation

| Aspect | Generation Skill | Transformation Skill |
|--------|------------------|---------------------|
| Purpose | Create from scratch | Modify existing code |
| Key attribute | `required_capabilities` | `target_capability` |
| Additional capabilities | Inferred from prompt | Features inferred from prompt |
| Compatibility | Implicit (capabilities define it) | Explicit (`compatible_with`) |
| Output | New project | Modified project |
| Traceability profile | `code-project` | `code-transformation` |

---

## Validation Checklist (v2.0)

### Structure
- [ ] Skill in correct location: `skills/{domain}/{layer}/skill-{NNN}-{name}/`
- [ ] SKILL.md has `type: generation` or `type: transformation`
- [ ] OVERVIEW.md has frontmatter with type and tags

### For Generation Skills
- [ ] Has `required_capabilities` (NOT modules)
- [ ] Required capabilities include at least one structural
- [ ] Does NOT have `modules:` section

### For Transformation Skills
- [ ] Has `target_capability`
- [ ] Has `compatible_with` list
- [ ] Target capability is compositional (not structural)

### Common
- [ ] Stack is declared
- [ ] Keywords support discovery
- [ ] Execution flow is referenced
- [ ] Registered in skill-index.yaml

---

## Migration from v2.x Skills

### Remove

```yaml
# REMOVE these from old SKILL.md
extends: skill-020-...           # No inheritance
modules:
  mandatory: [...]               # No direct module references
  conditional: [...]             # No conditional modules
modules_added: [...]             # No delta additions
```

### Add

```yaml
# ADD these to new SKILL.md
type: generation                 # or transformation
required_capabilities:           # for generation
  - architecture.hexagonal-base
  - api-exposure.rest-hateoas
# OR
target_capability: resilience    # for transformation
compatible_with:
  - architecture.hexagonal-base
```

---

## Related

- `capability-index.yaml` - Capability to module mapping
- `ENABLEMENT-MODEL-v2.0.md` - Core model documentation
- `authoring/CAPABILITY.md` - How to create capabilities
- `authoring/MODULE.md` - How to create modules
- `runtime/flows/code/GENERATE.md` - Generation flow
- `runtime/flows/code/ADD.md` - Transformation flow

---

**Last Updated:** 2025-01-15
