# Authoring Guide: CAPABILITY

**Version:** 3.2  
**Last Updated:** 2026-01-22  
**Asset Type:** Capability  
**Model Version:** 3.0.2  
**capability-index Version:** 2.3

---

## What's New in v3.2

| Change | Description |
|--------|-------------|
| **requires_config** | New attribute for config prerequisite validation (Rule 7) |
| **Hybrid persistence** | `jpa` and `systemapi` no longer incompatible |

## What's New in v3.1

| Change | Description |
|--------|-------------|
| **New Taxonomy** | Types changed from structural/compositional to **foundational/layered/cross-cutting** |
| **phase_group** | New required attribute for automatic phase assignment |
| **cardinality** | New required attribute (exactly-one or multiple) |
| **default_feature** | Capability-level default when no specific feature matched |
| **is_default** | Feature-level flag marking the default feature |
| **requires** | Now points to **capability** (not feature), uses default_feature |

---

## Overview

Capabilities are **conceptual groupings of related features**. They represent technical concerns (architecture, persistence, resilience, etc.) and are the primary entry point for discovery.

---

## Capability Types (v2.2 Taxonomy)

| Type | Description | Cardinality | Required for Generate | Transformable |
|------|-------------|-------------|----------------------|---------------|
| **foundational** | Base architecture, defines project structure | exactly-one | YES | NO |
| **layered** | Adds layers on top of foundational | multiple | NO | YES |
| **cross-cutting** | Decorators on existing code | multiple | NO | YES |

### Type Behaviors

**FOUNDATIONAL:**
- Exactly ONE required for `flow-generate`
- Cannot be added via transformation (must be set at project creation)
- All `layered` capabilities implicitly require foundational
- Example: `architecture`

**LAYERED:**
- Requires foundational to exist (auto-added if missing in flow-generate)
- Phase determined by `phase_group` attribute
- Can be added via `flow-transform`
- Examples: `api-architecture`, `persistence`, `integration`

**CROSS-CUTTING:**
- Does NOT require foundational (can apply to existing external projects)
- Decorates existing code (annotations, config)
- Can be added via `flow-transform` without any other capabilities
- Examples: `resilience`, `distributed-transactions`

---

## Phase Groups

| Phase Group | Phase | Description | Capabilities |
|-------------|-------|-------------|--------------|
| `structural` | 1 | Project structure, adapters IN | architecture, api-architecture |
| `implementation` | 2 | External connections, adapters OUT | integration, persistence |
| `cross-cutting` | 3+ | Decorators, annotations | resilience, distributed-transactions |

**Important:** `type` describes WHAT the capability is; `phase_group` describes WHEN it executes.

Example: `api-architecture` is type `layered` but phase_group `structural` (executes in Phase 1).

---

## Entity Hierarchy

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       CAPABILITY HIERARCHY (v2.3)                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  CAPABILITY                                                                 │
│      │                                                                      │
│      ├── type: foundational | layered | cross-cutting                       │
│      ├── phase_group: structural | implementation | cross-cutting           │
│      ├── cardinality: exactly-one | multiple                                │
│      ├── transformable: true | false                                        │
│      ├── keywords: [...]                                                    │
│      ├── default_feature: feature_name (optional)                           │
│      │                                                                      │
│      └── FEATURES                                                           │
│              │                                                              │
│              ├── is_default: true | false                                   │
│              ├── keywords: [...]                                            │
│              ├── requires: [capability | capability.feature]                │
│              ├── requires_config: [{capability, config_key, value}]  NEW    │
│              ├── incompatible_with: [other.features]                        │
│              ├── config: { key: value }                                     │
│              ├── input_spec: { field: schema }                              │
│              │                                                              │
│              └── IMPLEMENTATIONS                                            │
│                      │                                                      │
│                      ├── id: unique-identifier                              │
│                      ├── stack: java-spring | nodejs | ...                  │
│                      ├── pattern: annotation | client-config | ...          │
│                      └── module: mod-code-xxx                               │
│                                                                              │
│              └── default: implementation-id                                 │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Where Capabilities Are Defined

Capabilities exist in TWO places (and must be synchronized):

### 1. capability-index.yaml (Definitive - Machine Readable)

```
runtime/discovery/capability-index.yaml
```

This is the **single source of truth** for:
- Capability type, phase_group, cardinality
- Features with all enriched attributes
- Implementations per stack/pattern
- Compatibility rules and defaults
- Keywords for discovery

### 2. Capability Documentation (Explanatory - Human Readable)

```
model/domains/code/capabilities/{capability}.md
```

This provides:
- Detailed explanation of the capability
- Usage guidelines and examples
- Related ADRs and ERIs

---

## capability-index.yaml Structure (v2.2)

```yaml
version: "2.2"
domain: code

# ─────────────────────────────────────────────────────────────────
# HEADER DOCUMENTATION (inline in actual file)
# ─────────────────────────────────────────────────────────────────
# Capability Types:
#   - foundational: Base architecture (exactly-one, not transformable)
#   - layered: Adds on foundational (multiple, transformable)
#   - cross-cutting: Decorators (multiple, transformable, no foundational required)
#
# Phase Groups:
#   - structural → Phase 1 (project structure)
#   - implementation → Phase 2 (external connections)
#   - cross-cutting → Phase 3+ (decorators)

# ─────────────────────────────────────────────────────────────────
# DEFAULTS
# ─────────────────────────────────────────────────────────────────
defaults:
  stack: java-spring

# ─────────────────────────────────────────────────────────────────
# STACKS
# ─────────────────────────────────────────────────────────────────
stacks:
  java-spring:
    description: "Java 17+ with Spring Boot 3.x"
    detection:
      - file: pom.xml
        contains: "spring-boot-starter"
    keywords: [java, spring, spring boot]

# ─────────────────────────────────────────────────────────────────
# CAPABILITIES
# ─────────────────────────────────────────────────────────────────
capabilities:

  # ═══════════════════════════════════════════════════════════════
  # FOUNDATIONAL CAPABILITY
  # ═══════════════════════════════════════════════════════════════
  architecture:
    description: "Foundational architectural patterns"
    type: foundational
    phase_group: structural
    cardinality: exactly-one
    transformable: false
    documentation: "model/domains/code/capabilities/architecture.md"
    
    keywords:
      - microservicio
      - microservice
      - servicio
      - service
      - aplicación
      - application
    
    default_feature: hexagonal-light
    
    features:
      hexagonal-light:
        description: "Hexagonal Light architecture"
        is_default: true
        keywords:
          - hexagonal
          - clean architecture
          - ports and adapters
          - DDD
        
        implementations:
          - id: java-spring
            module: mod-code-015-hexagonal-base-java-spring
            stack: java-spring
        
        default: java-spring

  # ═══════════════════════════════════════════════════════════════
  # LAYERED CAPABILITY (structural phase)
  # ═══════════════════════════════════════════════════════════════
  api-architecture:
    description: "API types according to Fusion model"
    type: layered
    phase_group: structural
    cardinality: multiple
    transformable: true
    documentation: "model/domains/code/capabilities/api_architecture.md"
    
    keywords:
      - API
      - REST
      - REST API
      - endpoint
    
    default_feature: standard    # NOT domain-api
    
    features:
      standard:
        description: "Standard REST API - default for generic API requests"
        is_default: true
        keywords:
          - REST
          - REST API
          - API REST
        
        requires:
          - architecture           # Points to CAPABILITY, not feature
        
        config:
          hateoas: false
          compensation_available: false
        
        implementations:
          - id: java-spring
            module: mod-code-019-api-public-exposure-java-spring
            stack: java-spring
        
        default: java-spring
      
      domain-api:
        description: "Domain API - business capabilities as product"
        is_default: false
        keywords:
          - Domain API
          - API de dominio
          - Fusion Domain
        
        requires:
          - architecture           # Points to CAPABILITY
        
        config:
          hateoas: true
          compensation_available: true
          transactional: true
          idempotent: true
        
        implementations:
          - id: java-spring
            module: mod-code-019-api-public-exposure-java-spring
            stack: java-spring
        
        default: java-spring

  # ═══════════════════════════════════════════════════════════════
  # LAYERED CAPABILITY (implementation phase)
  # ═══════════════════════════════════════════════════════════════
  persistence:
    description: "Data persistence strategies"
    type: layered
    phase_group: implementation
    cardinality: multiple
    transformable: true
    # NO default_feature - user must choose between jpa/systemapi
    
    features:
      jpa:
        description: "JPA/Hibernate persistence"
        keywords: [JPA, database, SQL, Hibernate]
        
        requires:
          - architecture
        
        incompatible_with:
          - persistence.systemapi
        
        implementations:
          - id: java-spring
            module: mod-code-016-persistence-jpa-spring
            stack: java-spring
        
        default: java-spring
      
      systemapi:
        description: "Persistence via System API"
        keywords: [System API, backend, legacy]
        
        requires:
          - architecture
          - integration.api-rest    # Specific feature required
        
        incompatible_with:
          - persistence.jpa
        
        implementations:
          - id: java-spring
            module: mod-code-017-persistence-systemapi
            stack: java-spring
        
        default: java-spring

  # ═══════════════════════════════════════════════════════════════
  # CROSS-CUTTING CAPABILITY
  # ═══════════════════════════════════════════════════════════════
  resilience:
    description: "Resilience patterns for fault tolerance"
    type: cross-cutting
    phase_group: cross-cutting
    cardinality: multiple
    transformable: true
    # NO default_feature - user must specify patterns
    # NO requires - can apply to existing code without foundational
    
    keywords:
      - resilience
      - resiliencia
      - fault tolerance
    
    features:
      circuit-breaker:
        description: "Circuit breaker pattern"
        keywords:
          - circuit breaker
          - circuit-breaker
          - cortocircuito
        
        # NO requires - cross-cutting can apply to any code
        
        config:
          failure_rate_threshold: 50
          wait_duration_in_open_state: 60000
        
        implementations:
          - id: java-spring
            module: mod-code-001-circuit-breaker-java-resilience4j
            stack: java-spring
        
        default: java-spring
```

---

## Creating a New Capability

### Step 1: Determine Type

| Question | If YES → |
|----------|----------|
| Does it define the fundamental project structure? | **foundational** |
| Does it add a layer that requires project structure? | **layered** |
| Can it be applied to any existing code without structure? | **cross-cutting** |
| Would changing it require regenerating the entire project? | **foundational** |
| Is it a decorator (annotations, config)? | **cross-cutting** |

### Step 2: Determine Phase Group

| If capability is... | Phase Group |
|---------------------|-------------|
| About project structure or entry points (controllers) | `structural` |
| About external connections (DB, APIs, messaging) | `implementation` |
| About decorating existing code | `cross-cutting` |

### Step 3: Determine Cardinality

| Question | Cardinality |
|----------|-------------|
| Can there be only ONE of this in a project? | `exactly-one` |
| Can multiple features coexist? | `multiple` |

### Step 4: Determine Default Feature

| Situation | default_feature |
|-----------|-----------------|
| One obvious default | Set to that feature |
| Features are mutually exclusive | Don't set (user must choose) |
| No clear default | Don't set (ask user) |

### Step 5: Define Features

For each feature, determine:
- **is_default:** Is this the default when capability matched but no feature specified?
- **keywords:** How users will request this feature
- **requires:** Dependencies (point to CAPABILITY, not feature, unless specific feature needed)
- **incompatible_with:** Mutually exclusive features
- **config:** Feature-specific configuration values
- **input_spec:** What user input is needed
- **implementations:** Which modules implement this (per stack)

### Step 6: Add to capability-index.yaml

```yaml
# Example: Adding a new layered capability

caching:
  description: "Caching strategies for performance"
  type: layered
  phase_group: implementation
  cardinality: multiple
  transformable: true
  documentation: "model/domains/code/capabilities/caching.md"
  
  keywords:
    - cache
    - caching
    - caché
  
  default_feature: local    # Local cache is safe default
  
  features:
    local:
      description: "Local in-memory cache with Caffeine"
      is_default: true
      keywords:
        - local cache
        - Caffeine
        - in-memory
      
      requires:
        - architecture       # Points to capability
      
      config:
        max_size: 1000
        ttl_seconds: 3600
      
      implementations:
        - id: java-spring
          module: mod-code-026-cache-local-caffeine
          stack: java-spring
      
      default: java-spring
    
    redis:
      description: "Distributed cache with Redis"
      is_default: false
      keywords:
        - Redis
        - distributed cache
      
      requires:
        - architecture
      
      config:
        ttl_seconds: 3600
        serializer: json
      
      input_spec:
        redisHost:
          type: string
          required: true
        redisPort:
          type: integer
          required: false
          default: 6379
      
      implementations:
        - id: java-spring
          module: mod-code-025-cache-redis-java-spring
          stack: java-spring
      
      default: java-spring
```

### Step 7: Create Documentation

```markdown
# model/domains/code/capabilities/caching.md

# Capability: Caching

## Type

- **Type:** Layered
- **Phase Group:** implementation
- **Cardinality:** multiple
- **Transformable:** Yes
- **Requires Foundational:** Yes (auto-added)

## Overview

Caching strategies for improving application performance.

## Features

### local (Default)
- Local in-memory cache using Caffeine
- Best for: Single-instance applications, session data
- Module: mod-code-026

### redis
- Distributed cache using Redis
- Best for: Multi-instance applications, shared state
- Module: mod-code-025

## Related

- ADR: adr-015-caching-patterns
- ERI: eri-code-020-cache-redis
```

### Step 8: Create Associated Module(s)

Each implementation must have a corresponding module. See `authoring/MODULE.md`.

---

## Capability Attributes Reference

### type (Required)

```yaml
type: foundational | layered | cross-cutting
```

### phase_group (Required)

```yaml
phase_group: structural | implementation | cross-cutting
```

### cardinality (Required)

```yaml
cardinality: exactly-one | multiple
```

### transformable (Required)

```yaml
transformable: true | false
```

Note: `foundational` capabilities must have `transformable: false`.

### keywords (Recommended)

Capability-level keywords for matching when no specific feature is mentioned:

```yaml
keywords:
  - API
  - REST
  - endpoint
```

### default_feature (Optional)

Feature to use when capability matched but no specific feature:

```yaml
default_feature: standard
```

If not set and capability is matched without specific feature, discovery should ask user.

---

## Feature Attributes Reference

### is_default (Recommended)

Marks this feature as the default for the capability:

```yaml
is_default: true
```

Should match `default_feature` at capability level.

### keywords (Required)

Terms for discovery matching:

```yaml
keywords:
  - circuit breaker    # English
  - cortocircuito      # Spanish
  - CB                 # Abbreviation
```

**Guidelines:**
- Include synonyms and abbreviations
- Include Spanish equivalents
- Avoid generic terms ("code", "service")

### requires (Optional)

Dependencies auto-added during discovery:

```yaml
# Point to CAPABILITY (uses its default_feature)
requires:
  - architecture
  - integration

# Point to specific FEATURE (when specific feature needed)
requires:
  - integration.api-rest
```

**Important:** Prefer pointing to capability unless a specific feature is required.

### incompatible_with (Optional)

Mutually exclusive features:

```yaml
incompatible_with:
  - persistence.jpa    # Error if both selected
```

**Note (v2.3):** Use sparingly. Prefer allowing combinations when technically feasible. Example: `persistence.jpa` and `persistence.systemapi` are NOT incompatible (hybrid scenarios valid).

### requires_config (Optional, NEW in v2.3)

Config prerequisite validation. Ensures a required config value exists in another selected feature:

```yaml
requires_config:
  - capability: api-architecture
    config_key: compensation_available
    value: true
    error_message: "Compensation requires an API type that supports it (e.g., domain-api)"
```

**Fields:**

| Field | Required | Description |
|-------|----------|-------------|
| `capability` | Yes | Target capability to check |
| `config_key` | Yes | Config key to validate |
| `value` | Yes | Expected value |
| `error_message` | Yes | Error message if validation fails |

**Use case:** Features that only work with certain API types or configurations.

**Example:** `saga-compensation` requires `compensation_available=true`, which only `domain-api` has.

### config (Optional)

Feature-specific configuration passed to module:

```yaml
config:
  hateoas: true
  compensation_available: true
  max_retries: 3
```

### input_spec (Optional)

Schema for user input:

```yaml
input_spec:
  serviceName:
    type: string
    required: true
    pattern: "^[a-z][a-z0-9-]*$"
    description: "Service name in kebab-case"
    example: "customer-api"
```

### implementations (Required)

List of implementations per stack/pattern:

```yaml
implementations:
  - id: java-spring
    module: mod-code-003-timeout
    stack: java-spring
```

### default (Required if multiple implementations)

Default implementation when not specified:

```yaml
default: java-spring
```

---

## Validation Checklist

### Capability-Level (in capability-index.yaml)

- [ ] Has `type: foundational | layered | cross-cutting`
- [ ] Has `phase_group: structural | implementation | cross-cutting`
- [ ] Has `cardinality: exactly-one | multiple`
- [ ] Has `transformable: true | false`
- [ ] If `type: foundational` then `transformable: false`
- [ ] If `type: foundational` then `cardinality: exactly-one`
- [ ] Has `keywords` array (recommended)
- [ ] Has `default_feature` if there's an obvious default
- [ ] `default_feature` matches a feature with `is_default: true`

### Feature-Level (in capability-index.yaml)

- [ ] Has `keywords` array
- [ ] Has `implementations` array with at least one entry
- [ ] Each implementation has `id`, `module`, `stack`
- [ ] Has `default` if multiple implementations
- [ ] All referenced modules exist
- [ ] `requires` references valid capabilities or features
- [ ] `incompatible_with` references valid features
- [ ] If capability has `default_feature`, one feature has `is_default: true`

### Documentation (in capabilities/*.md)

- [ ] File exists at path specified in `documentation`
- [ ] Has **Type** section with type, phase_group, cardinality, transformable
- [ ] Overview explains purpose clearly
- [ ] All features are documented
- [ ] Compatibility/requirements explained
- [ ] Related ADRs/ERIs are referenced

---

## Discovery Rules (How Capabilities Are Found)

For reference, these are the discovery rules that use capability attributes:

1. **Keyword Matching Priority:** feature.keywords > capability.keywords > stack.keywords
2. **Default Feature Resolution:** If capability matched but no feature → use `default_feature`
3. **Dependency Resolution:** `requires: [capability]` → auto-add `capability.default_feature`
4. **Foundational Guarantee:** flow-generate requires exactly ONE foundational
5. **Incompatibility Check:** Validate `incompatible_with` before finalizing
6. **Phase Assignment:** Group features by `phase_group` attribute

---

## Common Patterns

### Foundational Capability (exactly-one)

```yaml
architecture:
  type: foundational
  phase_group: structural
  cardinality: exactly-one
  transformable: false
  default_feature: hexagonal-light
  
  features:
    hexagonal-light:
      is_default: true
      # NO requires (it IS the foundation)
```

### Layered Capability with Default

```yaml
api-architecture:
  type: layered
  phase_group: structural
  cardinality: multiple
  transformable: true
  default_feature: standard
  
  features:
    standard:
      is_default: true
      requires:
        - architecture    # Points to capability
```

### Layered Capability without Default (User Must Choose)

```yaml
persistence:
  type: layered
  phase_group: implementation
  cardinality: multiple
  transformable: true
  # NO default_feature
  
  features:
    jpa:
      incompatible_with: [persistence.systemapi]
    
    systemapi:
      incompatible_with: [persistence.jpa]
```

### Cross-Cutting Capability (No Foundational Required)

```yaml
resilience:
  type: cross-cutting
  phase_group: cross-cutting
  cardinality: multiple
  transformable: true
  # NO default_feature (user specifies patterns)
  # NO requires at capability level
  
  features:
    circuit-breaker:
      # NO requires - can apply to any existing code
```

---

## Related

- `runtime/discovery/capability-index.yaml` - Central capability index (v2.2)
- `runtime/discovery/discovery-guidance.md` - Discovery algorithm with 6 rules
- `model/ENABLEMENT-MODEL-v3.0.md` - Core model documentation
- `authoring/MODULE.md` - How modules implement features
- `DECISION-LOG.md` - Decisions DEC-006 to DEC-009

---

**Last Updated:** 2026-01-21
