# Enablement 2.0 - Knowledge Base Model v2.0

## Overview

Enablement 2.0 is an AI-powered platform for automated software development. The Knowledge Base (KB) contains the structured knowledge that guides AI agents in generating, transforming, and maintaining code according to enterprise standards.

This document defines the **data model** - the entities, relationships, and rules that govern the KB.

---

## Core Philosophy

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         DESIGN PRINCIPLES                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. SEPARATION OF CONCERNS                                                  │
│     - Skills define WHAT to generate (type of artifact)                     │
│     - Capabilities define WHAT features are available                       │
│     - Modules define HOW to implement each feature                          │
│                                                                              │
│  2. COMPOSITION OVER INHERITANCE                                            │
│     - Skills compose capabilities, not inherit from other skills            │
│     - Capabilities compose features                                         │
│     - New capabilities don't require changes to existing skills             │
│                                                                              │
│  3. COMPATIBILITY-DRIVEN DISCOVERY                                          │
│     - Capabilities declare their own compatibility                          │
│     - System validates combinations at discovery time                       │
│     - Invalid combinations are rejected early                               │
│                                                                              │
│  4. SINGLE SOURCE OF TRUTH                                                  │
│     - capability-index.yaml is the definitive mapping                       │
│     - Skills reference capabilities, not modules                            │
│     - Modules reference the capability.feature they implement               │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Entity Model

### Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         ENTITY RELATIONSHIPS                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│                              ┌───────────┐                                  │
│                              │   SKILL   │                                  │
│                              └─────┬─────┘                                  │
│                                    │                                        │
│                    ┌───────────────┼───────────────┐                       │
│                    │               │               │                        │
│                    ▼               ▼               ▼                        │
│            ┌──────────────┐ ┌──────────────┐ ┌──────────────┐              │
│            │  Generation  │ │Transformation│ │    (more)    │              │
│            │    Skill     │ │    Skill     │ │    types     │              │
│            └──────┬───────┘ └──────┬───────┘ └──────────────┘              │
│                   │                │                                        │
│     required_capabilities    target_capability                              │
│                   │                │                                        │
│                   ▼                ▼                                        │
│            ┌─────────────────────────────┐                                  │
│            │        CAPABILITY           │                                  │
│            │  ┌───────────┬───────────┐  │                                  │
│            │  │ Structural│Compositional│ │                                  │
│            │  │  (core)   │ (additive) │  │                                  │
│            │  └───────────┴───────────┘  │                                  │
│            └─────────────┬───────────────┘                                  │
│                          │                                                  │
│                       features                                              │
│                          │                                                  │
│                          ▼                                                  │
│                   ┌─────────────┐                                           │
│                   │   FEATURE   │                                           │
│                   └──────┬──────┘                                           │
│                          │                                                  │
│                       module (1:1)                                          │
│                          │                                                  │
│                          ▼                                                  │
│                   ┌─────────────┐                                           │
│                   │   MODULE    │                                           │
│                   └─────────────┘                                           │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Entity Definitions

### 1. SKILL

A Skill defines **what type of artifact** the AI should generate or transform.

#### Skill Types

| Type | Purpose | Key Attribute |
|------|---------|---------------|
| **Generation** | Create artifacts from scratch | `required_capabilities` |
| **Transformation** | Modify existing code | `target_capability` |

#### Generation Skill

```yaml
skill-021-api-rest-java-spring:
  type: generation
  domain: code
  layer: soi
  description: "Fusion REST API with HATEOAS"
  stack: java-spring
  
  # Capabilities this skill REQUIRES
  # These are resolved to modules automatically
  required_capabilities:
    - architecture.hexagonal-base      # Structural - always required
    - api-exposure.rest-hateoas        # Compositional - required for this skill type
  
  # Additional compositional capabilities (resilience, persistence, etc.)
  # are inferred from the user prompt, NOT declared here
  
  keywords:
    - REST API
    - Domain API
    - Fusion API
```

#### Transformation Skill

```yaml
skill-040-add-resilience-java-spring:
  type: transformation
  domain: code
  layer: soi
  description: "Add resilience patterns to existing code"
  stack: java-spring
  
  # The capability this skill ADDS to existing code
  target_capability: resilience
  
  # What existing architecture this skill can work with
  compatible_with:
    - architecture.hexagonal-base
  
  # Specific features (circuit-breaker, retry, etc.)
  # are determined from the user prompt context
  
  keywords:
    - add resilience
    - circuit breaker
    - retry
```

#### Key Rules for Skills

1. Skills do **NOT** declare modules directly
2. Skills do **NOT** inherit from other skills
3. Generation skills declare `required_capabilities`
4. Transformation skills declare `target_capability`
5. Compositional capabilities beyond required are inferred from prompt

---

### 2. CAPABILITY

A Capability defines a **technical characteristic** that can be part of generated code.

#### Capability Types

| Type | Description | Transformable | Example |
|------|-------------|---------------|---------|
| **Structural** | Defines fundamental code structure | NO | `architecture.hexagonal-base` |
| **Compositional** | Adds functionality on top of structure | YES | `resilience`, `persistence` |

#### Capability Definition

```yaml
resilience:
  description: "Fault tolerance and resilience patterns"
  type: compositional
  transformable: true
  
  # What this capability requires to function
  compatible_with:
    - architecture.hexagonal-base
  
  stack: [java-spring]
  
  # Features are variants/options within this capability
  features:
    circuit-breaker:
      description: "Circuit Breaker pattern"
      module: mod-code-001-circuit-breaker-java-resilience4j
      keywords: [circuit breaker, CB]
    
    retry:
      description: "Retry pattern with backoff"
      module: mod-code-002-retry-java-resilience4j
      keywords: [retry, reintento]
```

#### Key Rules for Capabilities

1. Each capability has a `type`: structural or compositional
2. `transformable: false` means it cannot be target of transformation skills
3. `compatible_with` declares prerequisite capabilities
4. `incompatible_with` declares mutual exclusions
5. `requires` declares mandatory dependencies
6. Features map 1:1 to modules

---

### 3. FEATURE

A Feature is a **variant or option** within a capability.

Features are defined inline within capabilities in `capability-index.yaml`.

#### Feature Definition

```yaml
# Within a capability
features:
  circuit-breaker:
    description: "Circuit Breaker pattern"
    module: mod-code-001-circuit-breaker-java-resilience4j
    keywords: [circuit breaker, CB, cortocircuito]
    
    # Feature-level overrides (optional)
    incompatible_with: []
    requires: []
```

#### Key Rules for Features

1. Every feature maps to exactly ONE module (1:1)
2. Keywords help discovery match user intent to features
3. Features can have their own incompatibilities/dependencies
4. Feature-level rules override capability-level rules

---

### 4. MODULE

A Module contains the **implementation knowledge** for generating code.

#### Module Structure

```
mod-code-001-circuit-breaker-java-resilience4j/
├── MODULE.md           # Implementation instructions
├── validation/
│   └── README.md       # Validation rules
└── templates/          # Code templates (optional)
```

#### Module Metadata

```yaml
# In MODULE.md frontmatter
id: mod-code-001-circuit-breaker-java-resilience4j
name: Circuit Breaker - Resilience4j
version: "1.0.0"
domain: code

# NEW in v2.0: Link to capability.feature
implements:
  capability: resilience
  feature: circuit-breaker
```

#### Key Rules for Modules

1. Module implements exactly ONE feature
2. Module declares what capability.feature it implements
3. Module contains all knowledge needed to generate that feature
4. Module is independent and composable

---

## Discovery Flow

### Generation Skill Discovery

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    GENERATION DISCOVERY FLOW                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  PROMPT: "Generate Customer API with resilience and System API backend"     │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ STEP 1: Skill Discovery                                             │   │
│  │ ─────────────────────────                                           │   │
│  │ Match prompt keywords against skill-index.yaml                      │   │
│  │ "API" + "Customer" → skill-021-api-rest-java-spring                │   │
│  │ Type: generation                                                    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                              │                                              │
│                              ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ STEP 2: Resolve Required Capabilities                               │   │
│  │ ────────────────────────────────────                                │   │
│  │ skill-021.required_capabilities:                                    │   │
│  │   - architecture.hexagonal-base → mod-015                          │   │
│  │   - api-exposure.rest-hateoas → mod-019                            │   │
│  │                                                                      │   │
│  │ Context established:                                                 │   │
│  │   stack: java-spring                                                │   │
│  │   architecture: hexagonal-base                                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                              │                                              │
│                              ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ STEP 3: Extract Additional Capabilities from Prompt                 │   │
│  │ ───────────────────────────────────────────────────                 │   │
│  │ "resilience" → capability: resilience (all features)               │   │
│  │ "System API backend" → capability: persistence.systemapi           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                              │                                              │
│                              ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ STEP 4: Validate Compatibility                                      │   │
│  │ ──────────────────────────────                                      │   │
│  │ resilience:                                                         │   │
│  │   compatible_with: [architecture.hexagonal-base] ✅                 │   │
│  │   stack: [java-spring] ✅                                           │   │
│  │                                                                      │   │
│  │ persistence.systemapi:                                              │   │
│  │   compatible_with: [architecture.hexagonal-base] ✅                 │   │
│  │   requires: [api-integration.restclient] → Auto-add                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                              │                                              │
│                              ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ STEP 5: Resolve to Modules                                          │   │
│  │ ──────────────────────────                                          │   │
│  │ Required:                                                           │   │
│  │   - mod-015 (architecture.hexagonal-base)                          │   │
│  │   - mod-019 (api-exposure.rest-hateoas)                            │   │
│  │                                                                      │   │
│  │ Additional:                                                         │   │
│  │   - mod-001 (resilience.circuit-breaker)                           │   │
│  │   - mod-002 (resilience.retry)                                     │   │
│  │   - mod-003 (resilience.timeout)                                   │   │
│  │   - mod-004 (resilience.rate-limiter)                              │   │
│  │   - mod-017 (persistence.systemapi)                                │   │
│  │   - mod-018 (api-integration.restclient) [dependency]              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  FINAL MODULE LIST:                                                         │
│  [mod-015, mod-019, mod-001, mod-002, mod-003, mod-004, mod-017, mod-018]  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Transformation Skill Discovery

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    TRANSFORMATION DISCOVERY FLOW                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  PROMPT: "Add circuit breaker to Customer service"                          │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ STEP 1: Intent Detection                                            │   │
│  │ ────────────────────────                                            │   │
│  │ "Add" + existing code context → TRANSFORMATION intent              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                              │                                              │
│                              ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ STEP 2: Skill Discovery                                             │   │
│  │ ─────────────────────────                                           │   │
│  │ "circuit breaker" → resilience capability                          │   │
│  │ Match transformation skill with target_capability: resilience      │   │
│  │ → skill-040-add-resilience-java-spring                             │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                              │                                              │
│                              ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ STEP 3: Validate Compatibility with Existing Code                   │   │
│  │ ─────────────────────────────────────────────────                   │   │
│  │ skill-040.compatible_with: [architecture.hexagonal-base]           │   │
│  │ Existing code architecture: hexagonal-base ✅                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                              │                                              │
│                              ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ STEP 4: Extract Features from Prompt                                │   │
│  │ ────────────────────────────────────                                │   │
│  │ "circuit breaker" → resilience.circuit-breaker                     │   │
│  │ (NOT full resilience, just the specific feature requested)         │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                              │                                              │
│                              ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ STEP 5: Resolve to Modules                                          │   │
│  │ ──────────────────────────                                          │   │
│  │ resilience.circuit-breaker → mod-001                               │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  FINAL MODULE LIST: [mod-001]                                               │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Compatibility Rules

### Structural vs Compositional

| Aspect | Structural | Compositional |
|--------|------------|---------------|
| Purpose | Define code foundation | Add features |
| Transformable | NO | YES |
| In Generation Skills | Always REQUIRED | REQUIRED or OPTIONAL |
| In Transformation Skills | N/A (not targetable) | Is the TARGET |
| Example | `architecture.*` | `resilience`, `persistence` |

### Compatibility Declarations

```yaml
# Capability-level compatibility
resilience:
  compatible_with:
    - architecture.hexagonal-base    # Requires this architecture
  incompatible_with: []              # No global incompatibilities
  
# Feature-level compatibility (overrides capability-level)
persistence:
  features:
    jpa:
      incompatible_with:
        - persistence.systemapi      # Can't have both
    systemapi:
      requires:
        - api-integration.restclient # Needs REST client
      incompatible_with:
        - persistence.jpa            # Can't have both
```

### Validation Rules

1. **Architecture Required**: All compositional capabilities require a structural capability
2. **Mutual Exclusion**: Features in `incompatible_with` cannot coexist
3. **Dependencies**: Features in `requires` are auto-added if missing
4. **Stack Match**: Capability stack must match skill stack

---

## Supporting Entities

### ADR (Architectural Decision Record)

Captures the **rationale** behind architectural choices. Referenced by capabilities and modules.

### ERI (Enterprise Reference Implementation)

Provides **concrete examples** of implemented patterns. Referenced by modules.

### FLOW

Defines **execution workflows** (GENERATE, ADD, REFACTOR, etc.). Uses skills and capabilities.

### VALIDATOR

Defines **validation rules** for generated code. Applied per module.

---

## File Structure

```
enablement-2.0/
├── model/
│   ├── ENABLEMENT-MODEL-v2.0.md          # This document
│   ├── standards/
│   │   ├── ASSET-STANDARDS-v2.0.md       # Asset format standards
│   │   └── authoring/
│   │       ├── SKILL.md                   # How to create skills
│   │       ├── CAPABILITY.md              # How to create capabilities
│   │       └── MODULE.md                  # How to create modules
│   └── domains/code/
│       └── capabilities/                  # Capability documentation
├── runtime/
│   ├── discovery/
│   │   ├── skill-index.yaml              # Skill definitions
│   │   ├── capability-index.yaml         # Capability→Feature→Module mapping
│   │   └── discovery-guidance.md         # Discovery algorithm
│   └── flows/code/
│       ├── GENERATE.md                    # Generation flow
│       └── ADD.md                         # Transformation flow
├── skills/
│   └── code/soi/
│       ├── skill-020-microservice.../     # Generation skill
│       ├── skill-021-api-rest.../         # Generation skill
│       └── skill-040-add-resilience.../   # Transformation skill
└── modules/
    ├── mod-code-001-circuit-breaker.../
    ├── mod-code-015-hexagonal-base.../
    └── ...
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2024-01 | Initial model |
| 1.5 | 2024-06 | Added skill inheritance |
| 1.7 | 2024-12 | Added conditional modules |
| **2.0** | **2025-01** | **Capability-based model. Removed inheritance. Added skill types. Added capability types.** |

---

## Migration from v1.7

See `MODEL-v2-MIGRATION-PLAN.md` for detailed migration steps.

Key changes:
- Skills no longer have `extends`
- Skills no longer declare `modules` directly
- Capabilities now have `type` (structural/compositional)
- Capabilities now have `features` that map to modules
- New `capability-index.yaml` is single source of truth
- Transformation skills use `target_capability` instead of module list
