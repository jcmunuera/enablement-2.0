# Discovery

**Version:** 3.1  
**Last Updated:** 2026-02-03

---

## Purpose

This folder contains the **discovery system** that maps user prompts to capabilities, features, and modules.

> **v3.0:** All discovery goes through a **single path** via `capability-index.yaml`. Skills have been eliminated.
> 
> **v3.1:** Added **Config Flags Pub/Sub** pattern for cross-module influence (DEC-035).

---

## Contents

| Document | Purpose |
|----------|---------|
| `capability-index.yaml` | **Single source of truth** for capabilities, features, implementations |
| `discovery-guidance.md` | Step-by-step discovery algorithm |
| `execution-framework.md` | Generic execution framework |
| `prompt-template.md` | Template for user prompts |

---

## Discovery Flow (v3.1)

```
User Prompt + Context
     │
     ▼
┌─────────────────────────────────────────┐
│ STEP 1: STACK RESOLUTION                │
│                                         │
│ Priority:                               │
│   1. Explicit in prompt                 │
│   2. Detected from existing code        │
│   3. Organizational default             │
│                                         │
│ Source: capability-index.yaml#defaults  │
└─────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│ STEP 2: FEATURE MATCHING                │
│                                         │
│ Match prompt keywords against           │
│ feature keywords in capability-index    │
│                                         │
│ Source: capability-index.yaml#features  │
└─────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│ STEP 3: RESOLVE DEPENDENCIES            │
│                                         │
│ For each feature, check `requires`      │
│ and auto-add missing dependencies       │
└─────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│ STEP 4: VALIDATE COMPATIBILITY          │
│                                         │
│ Check `incompatible_with` rules         │
│ Error if conflicts detected             │
└─────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│ STEP 5: RESOLVE IMPLEMENTATIONS         │
│                                         │
│ For each feature, find implementation   │
│ matching resolved stack → module        │
└─────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│ STEP 6: COLLECT CONFIG FLAGS (v3.1)     │
│                                         │
│ For each active feature, collect        │
│ `publishes_flags` → config_flags        │
│                                         │
│ These flags propagate to templates      │
│ via generation-context.json             │
└─────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│ STEP 7: SELECT FLOW                     │
│                                         │
│ No existing code → flow-generate        │
│ Existing code    → flow-transform       │
└─────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│ OUTPUT: Discovery Result                │
│                                         │
│ - flow: flow-generate | flow-transform  │
│ - stack: java-spring                    │
│ - features: [...]                       │
│ - modules: [...]                        │
│ - config: {...}                         │
│ - config_flags: {...} ← NEW in v3.1     │
│ - input_spec: {...}                     │
└─────────────────────────────────────────┘
```

---

## Config Flags Pub/Sub (v3.1, DEC-035)

Feature modules can **publish** config flags that affect code generation in other modules.

### Flow

```
┌─────────────────┐        ┌──────────────────┐        ┌─────────────────┐
│   CAPABILITY    │        │  GENERATION      │        │    TEMPLATE     │
│   INDEX         │───────►│  CONTEXT         │───────►│                 │
│                 │        │                  │        │                 │
│ domain-api:     │        │ config_flags:    │        │ {{#config.hateoas}}
│  publishes_flags│        │   hateoas: true  │        │ public class...
│    hateoas: true│        │                  │        │ {{/config.hateoas}}
└─────────────────┘        └──────────────────┘        └─────────────────┘
     Publisher                  Runtime                   Subscriber
```

### Publisher Declaration (capability-index.yaml)

```yaml
api-architecture:
  features:
    domain-api:
      module: mod-code-019-api-public-exposure-java-spring
      publishes_flags:
        hateoas: true
        pagination: true
```

### Subscriber Usage (Template)

```java
{{#config.hateoas}}
public class {{Entity}}Response extends RepresentationModel<{{Entity}}Response> {
{{/config.hateoas}}
{{^config.hateoas}}
public record {{Entity}}Response(
{{/config.hateoas}}
```

### Standard Flags

| Flag | Publisher | Subscribers | Description |
|------|-----------|-------------|-------------|
| `hateoas` | mod-019 | mod-015 (Response.tpl) | HATEOAS support |
| `pagination` | mod-019 | mod-015 (Controller.tpl) | Pagination support |
| `jpa` | mod-016 | mod-015 (Entity.tpl) | JPA annotations |
| `systemapi` | mod-017 | mod-015 (Repository.tpl) | System API persistence |

See [DEC-035](../../DECISION-LOG.md#dec-035) for full details.

---

## Key Concepts (v3.0)

### Single Discovery Path

All discovery goes through `capability-index.yaml`:

| v2.x | v3.0 |
|------|------|
| skill-index.yaml + capability-index.yaml | capability-index.yaml only |
| Skills as runtime entities | Skills eliminated |
| Dual discovery paths | Single discovery path |

### Enriched Features

Features now include:
- `keywords` - For matching user prompts
- `requires` - Dependencies auto-added
- `incompatible_with` - Mutually exclusive features
- `config` - Feature-specific configuration
- `input_spec` - Required user input schema
- `implementations` - Per-stack module mappings

### Multi-Implementation Support

Features can have multiple implementations:

```yaml
timeout:
  implementations:
    - id: java-spring-annotation
      module: mod-003-timeout
      stack: java-spring
      pattern: annotation
    
    - id: java-spring-client
      module: mod-003b-timeout-restclient
      stack: java-spring
      pattern: client-config
  
  default: java-spring-annotation
```

---

## capability-index.yaml Structure

```yaml
version: "2.1"
domain: code

defaults:
  stack: java-spring
  patterns:
    timeout: annotation

stacks:
  java-spring:
    detection:
      - file: pom.xml
        contains: "spring-boot-starter"

capabilities:
  resilience:
    type: compositional
    transformable: true
    
    features:
      circuit-breaker:
        keywords: [circuit breaker, cortocircuito]
        implementations:
          - id: java-spring-resilience4j
            module: mod-code-001
            stack: java-spring
            pattern: annotation
        default: java-spring-resilience4j
```

---

## Relationship to Other Components

```
runtime/discovery/      ← You are here
    │
    │ capability-index.yaml
    ▼
┌─────────────────┐
│ features        │ → keywords, requires, config, input_spec
│ implementations │ → stack, pattern, module
└─────────────────┘
    │
    │ resolves to
    ▼
modules/                ← Reusable templates
    │
    ├── MODULE.md       ← Templates & rules
    └── templates/      ← Code patterns
    │
    │ executes via
    ▼
runtime/flows/          ← Execution flows
    │
    ├── flow-generate.md
    └── flow-transform.md
```

---

## Key Documents

| Document | Read When |
|----------|-----------|
| `capability-index.yaml` | Understanding available capabilities |
| `discovery-guidance.md` | Understanding discovery algorithm |
| `model/CONSUMER-PROMPT.md` | Consumer agent system prompt |
| `runtime/flows/code/flow-generate.md` | Understanding generation flow |

---

## Related

- [ENABLEMENT-MODEL-v3.0.md](../../model/ENABLEMENT-MODEL-v3.0.md) - Complete model
- [CONSUMER-PROMPT.md](../../model/CONSUMER-PROMPT.md) - Consumer agent system prompt
- [runtime/flows/](../flows/) - Execution flows
