---
skill_id: skill-021-api-rest-java-spring
skill_name: Fusion REST API Generator
version: 3.0.0
date: 2025-01-15
author: Fusion C4E Team
status: active

# ═══════════════════════════════════════════════════════════════════
# MODEL v2.0 - Skill Type and Capabilities
# ═══════════════════════════════════════════════════════════════════
type: generation
domain: code
layer: soi
stack: java-spring

# Required capabilities (resolved to modules via capability-index.yaml)
required_capabilities:
  - architecture.hexagonal-base
  - api-exposure.rest-hateoas

# Additional capabilities (resilience, persistence, compensation) are
# inferred from prompt and resolved via capability-index.yaml

tags:
  - generation
  - spring-boot
  - java
  - hexagonal
  - rest-api
  - fusion
  - hateoas
---

# Skill: Fusion REST API Generator (4-Layer Model)

**Skill ID:** skill-021-api-rest-java-spring  
**Domain:** code  
**Layer:** soi  
**Type:** Generation  
**Version:** 3.0.0  
**Status:** Active  
**Model:** v2.0  
**Last Updated:** 2025-01-15

---

## Overview

Generates a complete **Fusion REST API** microservice following the 4-layer API model (Experience, Composable, Domain, System) defined in ADR-001.

This skill produces a production-ready Spring Boot service with:
- Hexagonal Light architecture (ports and adapters)
- REST endpoints with pagination and filtering
- HATEOAS support (for Experience and Domain layers)
- OpenAPI specification
- Fusion API standards compliance
- Optional: SAGA compensation (for Domain APIs)

> **IMPORTANT:** This skill applies ONLY when the request explicitly references a **Fusion API**.
> See ADR-001 "Fusion API Identification" section for inference rules.
> If the request does not mention "Fusion" with an API layer name, either ask for clarification
> or use skill-020 for internal microservices.

### Capability Model (v2.0)

```
┌─────────────────────────────────────────────────────────────────────┐
│  skill-021-api-rest-java-spring                                      │
│                                                                      │
│  Required Capabilities:                                              │
│  ├── architecture.hexagonal-base → mod-015 (structural)             │
│  └── api-exposure.rest-hateoas → mod-019 (compositional)            │
│                                                                      │
│  Additional (from prompt):                                           │
│  ├── resilience.* → mod-001, mod-002, mod-003, mod-004              │
│  ├── persistence.jpa → mod-016                                       │
│  ├── persistence.systemapi → mod-017, mod-018                        │
│  └── distributed-transactions.compensation → mod-020                 │
└─────────────────────────────────────────────────────────────────────┘
```

> **Note:** In Model v2.0, this skill does NOT extend skill-020. Both are 
> independent generation skills. skill-021 includes more required 
> capabilities (api-exposure in addition to architecture).

---

## Model Version

**Knowledge Base Model:** v2.0  
**Skill Type:** Generation  
**Required Capabilities:** architecture.hexagonal-base, api-exposure.rest-hateoas

> This skill follows the capability-based discovery model. It declares 
> required capabilities, and additional capabilities are inferred from 
> the user prompt. See `ENABLEMENT-MODEL-v2.0.md` for details.

---

## Pre-conditions (Activation Rules)

This skill should ONLY be activated when the request explicitly references a **Fusion API**. 
Follow the inference rules defined in `runtime/discovery/skill-index.yaml`.

### When to Use This Skill

| Prompt Contains | Action | Skill |
|-----------------|--------|-------|
| "Fusion" + API layer (Domain/System/BFF/Experience/Composable) | ✅ Apply directly | skill-021 |
| API layer WITHOUT "Fusion" (e.g., "Domain API") | ⚠️ ASK for clarification | - |
| "microservicio", "servicio interno", "API interna" | ❌ Use skill-020 | skill-020 |

### Examples

**Use skill-021:**
- "Genera una Fusion Domain API para Customer"
- "Implementar la API de Sistema Fusion para Parties"
- "Create a Fusion BFF for mobile channel"

**ASK for clarification:**
- "Genera una Domain API para Customer" → Ask: "¿Te refieres a una API del modelo Fusion?"
- "Create a System API for Parties" → Ask: "Is this a Fusion System API?"

**Use skill-020 (NOT this skill):**
- "Genera un microservicio para Customer"
- "Implementar un servicio interno de notificaciones"
- "Create an internal API for event processing"

---

## Required Capabilities

This skill declares the following required capabilities (Model v2.0):

| Capability | Type | Module | Purpose |
|------------|------|--------|---------|
| `architecture.hexagonal-base` | Structural | mod-015 | Code foundation, layers |
| `api-exposure.rest-hateoas` | Compositional | mod-019 | REST, pagination, HATEOAS |

### Additional Capabilities (from prompt)

These capabilities are inferred from the user prompt:

| Prompt Keywords | Capability | Features |
|-----------------|------------|----------|
| "resilience", "circuit breaker" | `resilience` | All resilience patterns |
| "JPA", "database", "local persistence" | `persistence.jpa` | JPA/Hibernate |
| "System API", "backend", "mainframe" | `persistence.systemapi` | Backend integration |
| "compensation", "SAGA" | `distributed-transactions.compensation` | SAGA participation |

Resolution happens via `capability-index.yaml`.

---

## Knowledge Dependencies

### ADR Compliance
- **ADR-001:** API Design Standards (Fusion model, REST, pagination, HATEOAS)
- **ADR-009:** Service Architecture Patterns (Hexagonal Light)
- **ADR-004:** Resilience Patterns (when resilience enabled)
- **ADR-011:** Persistence Patterns (when persistence enabled)
- **ADR-013:** Distributed Transactions (when compensation enabled)

### Reference Implementations
- **ERI-001:** Hexagonal Light Java Spring
- **ERI-014:** API Public Exposure Java Spring
- **ERI-008-011:** Resilience patterns (when enabled)
- **ERI-012:** Persistence patterns (when enabled)
- **ERI-015:** Distributed Transactions (when compensation enabled)

---

## Capability Resolution

### Required (always included)

| Capability | Feature | Module |
|------------|---------|--------|
| architecture | hexagonal-base | mod-code-015 |
| api-exposure | rest-hateoas | mod-code-019 |

### Conditional (from prompt/config)

| Condition | Capability.Feature | Module |
|-----------|-------------------|--------|
| resilience.circuit_breaker.enabled | resilience.circuit-breaker | mod-001 |
| resilience.retry.enabled | resilience.retry | mod-002 |
| resilience.timeout.enabled | resilience.timeout | mod-003 |
| resilience.rate_limiter.enabled | resilience.rate-limiter | mod-004 |
| persistence.type = "jpa" | persistence.jpa | mod-016 |
| persistence.type = "system_api" | persistence.systemapi | mod-017 |
| System API client needed | api-integration.restclient | mod-018 |
| apiLayer = "domain" AND features.compensation.enabled | distributed-transactions.compensation | mod-020 |

### Layer-Based Feature Matrix

| Feature | Experience | Composable | Domain | System |
|---------|------------|------------|--------|--------|
| Pagination | ✅ | ✅ | ✅ | ✅ |
| HATEOAS | ✅ | ❌ | ✅ | ❌ |
| Compensation | ❌ | ❌ | ✅ (opt-in) | ❌ |

### Resolution Algorithm

```python
# 1. Start with required capabilities
modules = []
for cap in skill.required_capabilities:
    modules.extend(resolve_capability(cap))

# 2. Extract additional capabilities from config
if config.features.resilience.circuit_breaker.enabled:
    modules.extend(resolve_capability("resilience.circuit-breaker"))
# ... similar for other resilience features

if config.features.persistence.type == "jpa":
    modules.extend(resolve_capability("persistence.jpa"))
elif config.features.persistence.type == "system_api":
    modules.extend(resolve_capability("persistence.systemapi"))
    modules.extend(resolve_capability("api-integration.restclient"))

if config.apiLayer == "domain" and config.features.compensation.enabled:
    modules.extend(resolve_capability("distributed-transactions.compensation"))

# 3. Configure HATEOAS based on layer
if config.apiLayer in ["experience", "domain"]:
    configure_module("mod-019", hateoas=True)
else:
    configure_module("mod-019", hateoas=False)

return deduplicate(modules)
```

---

## Input Specification

### Required Parameters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `serviceName` | string | Service name in kebab-case | `customer-api` |
| `basePackage` | string | Java base package | `com.company.customer` |
| `apiLayer` | enum | API layer type | `domain` |
| `entities` | array | Domain entities | See below |

### API Layer Values

| Value | Description | HATEOAS | Compensation |
|-------|-------------|---------|--------------|
| `experience` | BFF for UI channels | ✅ | ❌ |
| `composable` | Multi-domain orchestration | ❌ | ❌ |
| `domain` | Business capabilities | ✅ | ✅ (opt-in) |
| `system` | SoR integration | ❌ | ❌ |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `groupId` | string | (from basePackage) | Maven group ID |
| `javaVersion` | string | "17" | Java version |
| `pagination.defaultSize` | int | 20 | Default page size |
| `pagination.maxSize` | int | 100 | Maximum page size |
| `features.resilience.*` | object | - | Resilience configuration |
| `features.persistence.*` | object | - | Persistence configuration |
| `features.compensation.enabled` | boolean | false | Enable SAGA compensation |

### Input Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Fusion REST API Generation Config",
  "type": "object",
  "required": ["serviceName", "basePackage", "apiLayer", "entities"],
  "properties": {
    "serviceName": {
      "type": "string",
      "pattern": "^[a-z][a-z0-9-]*$"
    },
    "basePackage": {
      "type": "string",
      "pattern": "^[a-z][a-z0-9]*(\\.[a-z][a-z0-9]*)*$"
    },
    "apiLayer": {
      "type": "string",
      "enum": ["experience", "composable", "domain", "system"]
    },
    "entities": {
      "type": "array",
      "minItems": 1
    },
    "pagination": {
      "type": "object",
      "properties": {
        "defaultSize": { "type": "integer", "default": 20 },
        "maxSize": { "type": "integer", "default": 100 }
      }
    },
    "features": {
      "type": "object",
      "properties": {
        "resilience": { "$ref": "#/definitions/ResilienceFeatures" },
        "persistence": { "$ref": "#/definitions/PersistenceFeatures" },
        "compensation": {
          "type": "object",
          "properties": {
            "enabled": { "type": "boolean", "default": false }
          }
        }
      }
    }
  }
}
```

### Example Input

```json
{
  "serviceName": "customer-management-api",
  "basePackage": "com.bank.customer",
  "apiLayer": "domain",
  "entities": [
    {
      "name": "Customer",
      "fields": [
        { "name": "firstName", "type": "String", "required": true },
        { "name": "lastName", "type": "String", "required": true },
        { "name": "email", "type": "String", "required": true, "format": "email" }
      ]
    }
  ],
  "features": {
    "resilience": {
      "circuit_breaker": { "enabled": true },
      "retry": { "enabled": true }
    },
    "persistence": { "type": "system_api" },
    "compensation": { "enabled": true }
  }
}
```

---

## Output Specification

### Complete Generated Structure

```
{serviceName}/
├── pom.xml
├── README.md
├── Dockerfile
│
├── src/main/java/{basePackagePath}/
│   ├── {ServiceName}Application.java
│   │
│   ├── domain/                           # DOMAIN LAYER (Pure POJOs)
│   │   ├── model/
│   │   │   └── {Entity}.java
│   │   ├── service/
│   │   │   └── {Entity}DomainService.java
│   │   ├── repository/
│   │   │   └── {Entity}Repository.java
│   │   ├── exception/
│   │   │   └── {Entity}NotFoundException.java
│   │   └── transaction/                  # If compensation enabled
│   │       ├── Compensable.java
│   │       ├── CompensationRequest.java
│   │       ├── CompensationResult.java
│   │       ├── CompensationStatus.java
│   │       └── TransactionLog.java
│   │
│   ├── application/                      # APPLICATION LAYER
│   │   └── service/
│   │       └── {Entity}ApplicationService.java
│   │
│   ├── adapter/                          # ADAPTER LAYER
│   │   ├── in/rest/
│   │   │   ├── controller/
│   │   │   │   └── {Entity}Controller.java
│   │   │   ├── dto/
│   │   │   │   ├── {Entity}DTO.java
│   │   │   │   ├── Create{Entity}Request.java
│   │   │   │   ├── Update{Entity}Request.java
│   │   │   │   ├── PageResponse.java     # From api-exposure
│   │   │   │   └── {Entity}Filter.java   # From api-exposure
│   │   │   └── assembler/                # HATEOAS (if enabled)
│   │   │       └── {Entity}ModelAssembler.java
│   │   │
│   │   └── out/persistence/              # If persistence enabled
│   │       └── [JPA or SystemAPI adapters]
│   │
│   └── infrastructure/
│       ├── config/
│       │   └── ApplicationConfig.java
│       ├── exception/
│       │   └── GlobalExceptionHandler.java
│       └── web/
│           └── PageableConfig.java       # From api-exposure
│
├── src/main/resources/
│   ├── application.yml
│   └── openapi/
│       └── api.yaml
│
└── src/test/java/
    └── [test classes]
```

---

## Execution Flow

This skill follows the **GENERATE** execution flow.

**See:** `runtime/flows/code/GENERATE.md`

### Skill-Specific Steps

1. **Parse Input**
   - Validate JSON config
   - Extract apiLayer parameter
   - Identify additional capabilities from config

2. **Resolve Capabilities**
   - Load required: architecture.hexagonal-base, api-exposure.rest-hateoas
   - Resolve conditional capabilities from config
   - Validate compatibility via capability-index.yaml
   - Build final module list

3. **Generate Base Structure**
   - Create directory structure
   - Generate pom.xml with dependencies
   - Generate Application.java
   - Generate application.yml configs

4. **Generate Domain Layer**
   - Generate entities, services, repositories
   - Generate compensation interfaces (if Domain + enabled)

5. **Generate Application Layer**
   - Generate application services

6. **Generate Adapter Layer**
   - Generate REST controllers with pagination
   - Generate DTOs including PageResponse, Filter
   - Generate HATEOAS assemblers (if Experience/Domain)
   - Generate persistence adapters (if configured)

7. **Generate Infrastructure**
   - Generate config classes
   - Generate PageableConfig
   - Generate exception handlers

8. **Generate Tests**
   - Generate unit tests
   - Generate integration tests

9. **Validate Output**
   - Run all applicable validators
   - Generate traceability manifest

---

## Validation

### Tier 1: Universal
- Traceability check
- Project structure check
- Naming conventions check

### Tier 2: Technology
- Java Spring validation
- Maven build
- Docker validation (if enabled)

### Tier 3: Module-specific

| Validator | Module | Condition |
|-----------|--------|-----------|
| hexagonal-structure-check.sh | mod-015 | Always |
| pagination-check.sh | mod-019 | Always |
| config-check.sh | mod-019 | Always |
| hateoas-check.sh | mod-019 | apiLayer IN [experience, domain] |
| circuit-breaker-check.sh | mod-001 | If circuit breaker enabled |
| retry-check.sh | mod-002 | If retry enabled |
| persistence-check.sh | mod-016/017 | If persistence enabled |
| compensation-interface-check.sh | mod-020 | If compensation enabled |
| compensation-endpoint-check.sh | mod-020 | If compensation enabled |

---

## Related Skills

| Skill | Type | Relationship |
|-------|------|--------------|
| skill-020-microservice-java-spring | Generation | Internal service (no API exposure) |
| skill-040-add-resilience-java-spring | Transformation | Add resilience to existing code |
| skill-041-add-api-exposure-java-spring | Transformation | Promote microservice to API |
| skill-042-add-persistence-java-spring | Transformation | Add persistence to existing code |

> **Model v2.0 Note:** skill-021 and skill-020 are independent skills. 
> They share the same architectural base (hexagonal) but have different 
> required capabilities. There is no inheritance relationship.

---

## Changelog

### Version 3.0.0 (2025-01-15)
- **BREAKING:** Migrated to Model v2.0 (capability-based discovery)
- Removed `extends: skill-020` - skill is now self-contained
- Added `type: generation` to frontmatter
- Added explicit `required_capabilities`
- Consolidated all content (no more "Delta Only" sections)
- Updated execution flow for capability resolution
- Updated Related Skills section

### Version 2.2.0 (2025-12-22)
- Documentation improvements
- Updated pre-conditions section

### Version 2.0.0 (2025-12-19)
- Redesigned as extension of skill-020

### Version 1.0.0 (2025-12-19)
- Initial version (standalone)
