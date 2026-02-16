# Capability: API Architecture

**Capability ID:** api_architecture  
**Version:** 2.0  
**Based on:** ADR-001, ADR-009

---

## Overview

Defines the architectural patterns for API design and service structure. This capability encompasses the Fusion 4-layer API model (Domain, System, Experience, Composable) plus a standard API option for general use.

---

## Type

- **Type:** Layered
- **Phase Group:** structural
- **Cardinality:** multiple
- **Transformable:** Yes
- **Requires:** architecture (foundational)

---

## Discovery (v2.2)

### Capability-Level Keywords

The api-architecture capability can be matched by generic terms:

```yaml
keywords:
  - API
  - REST
  - REST API
  - Fusion
  - endpoint
  - exponer
  - expose
```

### Default Feature: standard

When user says just "API" without specifying a Fusion type, `standard` is selected:

```yaml
default_feature: standard
```

**Standard vs Domain API:**

| Aspect | standard | domain-api |
|--------|----------|------------|
| **Use case** | Generic REST API | Business capability as product |
| **HATEOAS** | No | Yes |
| **Transactional** | No | Yes |
| **Idempotent** | No requirement | Required |
| **Compensation** | No | Available |
| **Constraints** | None | Cannot call other Domain APIs |

**Examples:**
- "Genera una API" → `api-architecture.standard` (via default)
- "Genera una API REST" → `api-architecture.standard` (via default)
- "Domain API" → `api-architecture.domain-api` (explicit)
- "Fusion Domain API" → `api-architecture.domain-api` (explicit)
- "System API" → `api-architecture.system-api` (explicit)
- "BFF" → `api-architecture.experience-api` (explicit)

---

## Features

### standard (default)

Standard REST API without Fusion model semantics. Use when:
- Building internal services
- No need for HATEOAS
- No transactional requirements
- Not exposing as a product API

**Config:**
```yaml
hateoas: false
compensation_available: false
```

### domain-api

Domain API following Fusion model. Exposes business capabilities as a product. Use when:
- Building a product API
- Need HATEOAS for discoverability
- Transactional operations
- May participate in SAGAs

**Config:**
```yaml
hateoas: true
compensation_available: true
transactional: true
idempotent: true
```

### system-api

System API - wrapper over legacy systems (mainframe, CICS).

### experience-api

Experience API (BFF) - Backend for Frontend for UI channels.

### composable-api

Composable API - multi-domain orchestration layer.

---

## Sub-Features

### api_layers

Configuration for the 4-layer API model.

```json
{
  "api_architecture": {
    "api_layers": {
      "type": "domain_api"
    }
  }
}
```

**Options:**

| Type | Description | Constraints |
|------|-------------|-------------|
| `domain_api` | Business domain service | Owns data, no cross-domain calls |
| `composable_api` | Orchestration layer | Calls Domain APIs, stateless, SAGA |
| `system_api` | SoR integration | Abstracts backend systems |
| `experience_api` | BFF pattern | Channel-specific, calls downstream |

**Affects:**
- HTTP client generation
- Persistence layer inclusion
- SAGA support
- Validation rules

---

### service_architecture

Defines the internal service architecture style.

```json
{
  "api_architecture": {
    "service_architecture": {
      "style": "hexagonal_light"
    }
  }
}
```

**Options:**

| Style | Description | Use When |
|-------|-------------|----------|
| `hexagonal_light` | Default - domain POJOs, adapters | 3-10 business rules |
| `full_hexagonal` | Explicit ports/adapters | 10+ business rules |
| `traditional` | Controller/Service/Repository | <3 business rules, simple CRUD |

**Affects:**
- Project structure
- Layer organization
- Test strategy
- Framework coupling

---

### compensation_endpoints

For Domain APIs and SAGA support.

```json
{
  "api_architecture": {
    "compensation_endpoints": {
      "enabled": true,
      "convention": "POST /api/v1/{entity}/compensate"
    }
  }
}
```

**Generates:**
- Compensation controller endpoints
- Idempotent compensation logic
- Compensation domain service methods

---

## Dependencies

| ADR | Relationship |
|-----|--------------|
| ADR-001 | Defines 4-layer API model |
| ADR-009 | Defines Hexagonal Light structure |

---

## Modules Used

| api_layers.type | Module(s) |
|-----------------|-----------|
| `domain_api` | mod-code-015-hexagonal-base-java-spring |
| `composable_api` | mod-015 + mod-code-016-saga-orchestrator (future) |
| `system_api` | mod-015 + mod-code-017-sor-adapter (future) |
| `experience_api` | mod-015 + mod-code-018-bff-cache (future) |

---

## Skills Using This Feature

- **skill-020:** generate-microservice-java-spring
- **skill-021:** generate-domain-api-java-spring (future)
- **skill-022:** generate-composable-api-java-spring (future)

---

## Example Configuration

```json
{
  "serviceName": "customer-service",
  "basePackage": "com.company.customer",
  
  "apiType": "domain_api",
  
  "features": {
    "api_architecture": {
      "api_layers": {
        "type": "domain_api"
      },
      "service_architecture": {
        "style": "hexagonal_light"
      },
      "compensation_endpoints": {
        "enabled": true
      }
    }
  }
}
```

---

## Validation Rules

### domain_api
```yaml
- no HTTP clients to other domain APIs
- persistence.enabled allowed
- compensation_endpoints recommended
```

### composable_api
```yaml
- HTTP clients required for Domain APIs
- persistence.enabled should be false (warn)
- circuit_breaker required for external calls
- saga_orchestration recommended
```

### system_api
```yaml
- no business logic (only transformation)
- persistence.enabled for caching only
```

### experience_api
```yaml
- HTTP clients required for downstream
- caching recommended
- no direct database (only through APIs)
```

---

## Changelog

### v1.0 (2025-11-24)
- Initial feature definition
- Based on ADR-001 and ADR-009
