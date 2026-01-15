# Authoring Guide: CAPABILITY

**Version:** 2.0  
**Last Updated:** 2025-01-15  
**Asset Type:** Capability  
**Model Version:** 2.0

---

## What's New in v2.0

| Change | Description |
|--------|-------------|
| **Capability Types** | Capabilities are now `structural` or `compositional` |
| **Transformable Flag** | Indicates if capability can be target of transformation skills |
| **Features with Modules** | Each feature maps 1:1 to a module |
| **Compatibility Declarations** | Capabilities declare their own compatibility |
| **capability-index.yaml** | Central source of truth for capability→feature→module |

---

## Overview

Capabilities are **technical characteristics** that can be part of generated code. They are the bridge between Skills (what to generate) and Modules (how to implement).

### Capability Types

| Type | Description | Transformable | Example |
|------|-------------|---------------|---------|
| **Structural** | Defines fundamental code structure | NO | `architecture.hexagonal-base` |
| **Compositional** | Adds functionality on top of structure | YES | `resilience`, `persistence` |

---

## Capability Model

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           CAPABILITY                                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  STRUCTURAL                         COMPOSITIONAL                           │
│  ───────────                        ─────────────                           │
│  • Defines code foundation          • Adds features to foundation          │
│  • transformable: false             • transformable: true                   │
│  • Cannot be transformation target  • CAN be transformation target         │
│  • Always REQUIRED in generation    • REQUIRED or OPTIONAL in generation   │
│                                                                              │
│  Example: architecture              Examples: resilience, persistence,      │
│                                              api-exposure, caching          │
│                                                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  CAPABILITY                                                                 │
│      │                                                                      │
│      ├── type: structural | compositional                                   │
│      ├── transformable: true | false                                        │
│      ├── compatible_with: [other capabilities]                              │
│      ├── incompatible_with: [exclusive capabilities]                        │
│      │                                                                      │
│      └── FEATURES                                                           │
│              │                                                              │
│              ├── feature-1 ──────────────► module-1 (1:1)                  │
│              ├── feature-2 ──────────────► module-2 (1:1)                  │
│              └── feature-3 ──────────────► module-3 (1:1)                  │
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
- Capability type and transformable flag
- Features and their module mappings
- Compatibility rules
- Keywords for discovery

### 2. Capability Documentation (Explanatory - Human Readable)

```
model/domains/code/capabilities/{capability}.md
```

This provides:
- Detailed explanation of the capability
- Usage guidelines
- Examples
- Related ADRs and ERIs

---

## capability-index.yaml Structure

```yaml
capabilities:

  # ─────────────────────────────────────────────────────────────────
  # STRUCTURAL CAPABILITY
  # ─────────────────────────────────────────────────────────────────
  architecture:
    description: "Foundational architectural patterns"
    type: structural
    transformable: false
    documentation: "model/domains/code/capabilities/architecture.md"
    
    features:
      hexagonal-base:
        description: "Hexagonal Light architecture"
        module: mod-code-015-hexagonal-base-java-spring
        stack: [java-spring]
        keywords:
          - hexagonal
          - clean architecture
          - ports and adapters

  # ─────────────────────────────────────────────────────────────────
  # COMPOSITIONAL CAPABILITY
  # ─────────────────────────────────────────────────────────────────
  resilience:
    description: "Fault tolerance and resilience patterns"
    type: compositional
    transformable: true
    documentation: "model/domains/code/capabilities/resilience.md"
    
    # Capability-level compatibility
    compatible_with:
      - architecture.hexagonal-base
    stack: [java-spring]
    keywords:
      - resilience
      - fault tolerance
    
    features:
      circuit-breaker:
        description: "Circuit Breaker pattern"
        module: mod-code-001-circuit-breaker-java-resilience4j
        keywords:
          - circuit breaker
          - CB
      
      retry:
        description: "Retry with backoff"
        module: mod-code-002-retry-java-resilience4j
        keywords:
          - retry
          - reintento
      
      timeout:
        description: "Timeout pattern"
        module: mod-code-003-timeout-java-resilience4j
        keywords:
          - timeout

  # ─────────────────────────────────────────────────────────────────
  # COMPOSITIONAL WITH INCOMPATIBILITIES
  # ─────────────────────────────────────────────────────────────────
  persistence:
    description: "Data persistence strategies"
    type: compositional
    transformable: true
    documentation: "model/domains/code/capabilities/persistence.md"
    compatible_with:
      - architecture.hexagonal-base
    stack: [java-spring]
    
    features:
      jpa:
        description: "JPA/Hibernate persistence"
        module: mod-code-016-persistence-jpa-spring
        keywords:
          - JPA
          - database
        incompatible_with:
          - persistence.systemapi        # Mutually exclusive
      
      systemapi:
        description: "Persistence via System API"
        module: mod-code-017-persistence-systemapi
        keywords:
          - System API
          - backend
        requires:
          - api-integration.restclient   # Dependency
        incompatible_with:
          - persistence.jpa              # Mutually exclusive
```

---

## Creating a New Capability

### Step 1: Determine Type

| Question | If YES → |
|----------|----------|
| Does it define fundamental code structure? | Structural |
| Can existing code have this added? | Compositional |
| Would changing it require regenerating the code? | Structural |
| Is it a cross-cutting concern? | Compositional |

### Step 2: Add to capability-index.yaml

```yaml
# In runtime/discovery/capability-index.yaml

caching:                                    # New capability
  description: "Caching strategies"
  type: compositional                       # Can be added to existing code
  transformable: true                       # Can be target of transformation
  documentation: "model/domains/code/capabilities/caching.md"
  
  compatible_with:
    - architecture.hexagonal-base           # Requires hexagonal
  
  incompatible_with:
    - deployment.serverless                 # Doesn't make sense for serverless
  
  stack: [java-spring]
  
  keywords:
    - cache
    - caching
  
  features:
    redis:
      description: "Distributed cache with Redis"
      module: mod-code-025-cache-redis      # Must exist
      keywords:
        - Redis
        - distributed cache
    
    local:
      description: "Local cache with Caffeine"
      module: mod-code-026-cache-local-caffeine
      keywords:
        - local cache
        - Caffeine
```

### Step 3: Create Documentation

```markdown
# model/domains/code/capabilities/caching.md

# Capability: Caching

**Capability ID:** caching  
**Type:** Compositional  
**Transformable:** Yes

---

## Overview

Caching strategies for improving performance by storing frequently 
accessed data in memory.

---

## Features

| Feature | Module | Use Case |
|---------|--------|----------|
| `redis` | mod-code-025 | Distributed applications |
| `local` | mod-code-026 | Single-instance applications |

---

## Compatibility

**Requires:**
- architecture.hexagonal-base

**Incompatible with:**
- deployment.serverless (stateless environment)

---

## Usage

### In Generation Skills

```yaml
# Inferred from prompt
Prompt: "Generate Customer API with Redis caching"
→ Adds caching.redis capability
→ Resolves to mod-code-025
```

### In Transformation Skills

```yaml
skill-043-add-caching-java-spring:
  type: transformation
  target_capability: caching
```

---

## Related

- **ADR:** adr-015-caching-patterns
- **ERI:** eri-code-020-cache-redis
```

### Step 4: Create Associated Module(s)

Each feature must have a corresponding module. See `authoring/MODULE.md`.

### Step 5: (Optional) Create Transformation Skill

If `transformable: true`, consider creating a transformation skill:

```yaml
skill-043-add-caching-java-spring:
  type: transformation
  target_capability: caching
  compatible_with:
    - architecture.hexagonal-base
```

---

## Compatibility Rules

### compatible_with

Declares what this capability REQUIRES to function:

```yaml
resilience:
  compatible_with:
    - architecture.hexagonal-base    # Must have hexagonal
```

**Validation:** If the resolved context doesn't include required capabilities, 
the capability is rejected.

### incompatible_with

Declares what CANNOT coexist with this capability:

```yaml
persistence:
  features:
    jpa:
      incompatible_with:
        - persistence.systemapi      # Can't have both
```

**Validation:** If both are requested, reject with clear error message.

### requires

Declares dependencies that are AUTO-ADDED if missing:

```yaml
persistence:
  features:
    systemapi:
      requires:
        - api-integration.restclient # Auto-add if not present
```

**Resolution:** If requirement is missing, add it automatically.

---

## Feature to Module Mapping

### Rule: 1 Feature = 1 Module

Every feature maps to exactly one module. This is enforced.

```yaml
# CORRECT
features:
  circuit-breaker:
    module: mod-code-001-circuit-breaker    # Single module

# INCORRECT (not allowed)
features:
  circuit-breaker:
    modules:                                 # Multiple modules
      - mod-001
      - mod-002
```

### Why 1:1?

- **Simplicity:** Clear traceability from capability→feature→module
- **Modularity:** Each module is self-contained
- **Discovery:** Unambiguous resolution

### What if a feature needs multiple modules?

Create a "composite" module that orchestrates others:

```yaml
# Instead of:
features:
  full-resilience:
    modules: [mod-001, mod-002, mod-003]   # NOT ALLOWED

# Do this:
features:
  circuit-breaker:
    module: mod-001
  retry:
    module: mod-002
  timeout:
    module: mod-003

# Or create a composite module:
features:
  full-resilience:
    module: mod-005-resilience-bundle      # Single module that includes all
```

---

## Keywords for Discovery

Keywords help the discovery agent match user prompts to capabilities/features.

### Guidelines

1. **Include synonyms:** "retry", "reintento", "reintentos"
2. **Include common misspellings:** (if applicable)
3. **Include related terms:** "circuit breaker", "CB", "breaker"
4. **Be language-inclusive:** Include Spanish equivalents
5. **Avoid generic terms:** "code", "service" are too broad

### Hierarchy

Keywords at feature level have priority over capability level:

```yaml
resilience:
  keywords:
    - resilience              # Matches all features
    - fault tolerance
  features:
    circuit-breaker:
      keywords:
        - circuit breaker     # Specific to this feature
        - CB
```

---

## Validation Checklist

### In capability-index.yaml

- [ ] Has `type: structural` or `type: compositional`
- [ ] Has `transformable: true` or `false`
- [ ] Structural capabilities have `transformable: false`
- [ ] Has `compatible_with` list (compositional)
- [ ] Has `stack` declaration
- [ ] Each feature has exactly one `module`
- [ ] All referenced modules exist
- [ ] Keywords are descriptive and non-generic

### In documentation

- [ ] File exists at path specified in `documentation`
- [ ] Overview explains purpose clearly
- [ ] All features are documented
- [ ] Compatibility is explained
- [ ] Related ADRs/ERIs are referenced

---

## Common Patterns

### Mutually Exclusive Features

```yaml
persistence:
  features:
    jpa:
      incompatible_with: [persistence.systemapi]
    systemapi:
      incompatible_with: [persistence.jpa]
```

### Feature with Dependencies

```yaml
persistence:
  features:
    systemapi:
      requires: [api-integration.restclient]
```

### Stack-Specific Features

```yaml
api-exposure:
  features:
    rest-hateoas:
      stack: [java-spring]          # Only for Spring
    rest-express:
      stack: [node-express]         # Only for Express
```

---

## Related

- `runtime/discovery/capability-index.yaml` - Central capability index
- `ENABLEMENT-MODEL-v2.0.md` - Core model documentation
- `authoring/SKILL.md` - How skills reference capabilities
- `authoring/MODULE.md` - How modules implement features
- `runtime/discovery/discovery-guidance.md` - Discovery algorithm

---

**Last Updated:** 2025-01-15
