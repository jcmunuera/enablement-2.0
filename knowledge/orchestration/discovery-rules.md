# Discovery Rules: Prompt → Capabilities → Skills

**Version:** 1.0  
**Last Updated:** 2025-12-05

---

## Overview

This document defines the **deterministic rules** for transforming a user's natural 
language prompt into structured capability identification and skill selection.

---

## Discovery Flow

```
┌─────────────────────────────────────────────────────────────────┐
│ USER PROMPT (natural language)                                  │
│                                                                 │
│ "Necesito un microservicio Customer que consulte el System      │
│  API de Parties con circuit breaker y retry"                    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ PHASE 1: ENTITY EXTRACTION                                      │
│                                                                 │
│ Extract key entities from prompt:                               │
│ - Service name: "Customer"                                      │
│ - Entity names: ["Customer"]                                    │
│ - External systems: ["Parties System API"]                      │
│ - Patterns mentioned: ["circuit breaker", "retry"]              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ PHASE 2: CAPABILITY DETECTION                                   │
│                                                                 │
│ Match extracted entities against Capability Detection Rules     │
│ Output: capabilities_identified[]                               │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ PHASE 3: SKILL SELECTION                                        │
│                                                                 │
│ Match capabilities against Skill Selection Rules                │
│ Output: skill_selected, skill_type                              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ PHASE 4: INPUT GENERATION                                       │
│                                                                 │
│ Generate skill-specific input JSON from extracted entities      │
│ Output: generation-request.json (or transformation-request.json)│
└─────────────────────────────────────────────────────────────────┘
```

---

## Phase 1: Entity Extraction Rules

### Service/Project Identification

| Pattern | Extracts | Example |
|---------|----------|---------|
| "microservicio {Name}" | service_name | "microservicio Customer" → Customer |
| "servicio {Name}" | service_name | "servicio de Pagos" → Pagos |
| "API de {Name}" | service_name | "API de Clientes" → Clientes |
| "{Name} service" | service_name | "Payment service" → Payment |

### Entity Identification

| Pattern | Extracts | Example |
|---------|----------|---------|
| "gestionar {Entity}" | entity_name | "gestionar Customers" → Customer |
| "CRUD de {Entity}" | entity_name | "CRUD de Productos" → Producto |
| "entidad {Entity}" | entity_name | "entidad Cliente" → Cliente |
| "{Entity} entity" | entity_name | "Order entity" → Order |

### External System Identification

| Pattern | Extracts | Example |
|---------|----------|---------|
| "System API de {Name}" | system_api | "System API de Parties" → Parties |
| "backend {Name}" | system_api | "backend de Cuentas" → Cuentas |
| "consultar {API}" | system_api | "consultar API de Pagos" → Pagos |
| "datos de {System}" | system_api | "datos del sistema legacy" → legacy |

### Pattern/Feature Identification

| Pattern | Extracts | Example |
|---------|----------|---------|
| "circuit breaker", "CB" | resilience.circuit_breaker | ✓ |
| "retry", "reintentos" | resilience.retry | ✓ |
| "timeout", "tiempo límite" | resilience.timeout | ✓ |
| "rate limit", "throttling" | resilience.rate_limiter | ✓ |
| "base de datos", "PostgreSQL", "JPA" | persistence.jpa | ✓ |
| "System API", "API externa" | persistence.system_api | ✓ |

---

## Phase 2: Capability Detection Rules

For each extracted entity, map to capability:

### API Architecture Capabilities

| Condition | Capability | Feature |
|-----------|------------|---------|
| Building new service + expose REST API | api_architecture | domain_api |
| Aggregating multiple backends | api_architecture | composable_api |
| Backend data service | api_architecture | system_api |
| Frontend-facing API | api_architecture | experience_api |

**Detection logic:**
```
IF prompt mentions "Domain API" OR "microservicio" OR "REST API"
   AND NOT mentions "agregar" OR "BFF" OR "frontend"
THEN capability = api_architecture.domain_api
```

### Persistence Capabilities

| Condition | Capability | Feature |
|-----------|------------|---------|
| Mentions "System API", "API externa", "backend" | persistence | system_api |
| Mentions "base de datos", "JPA", "PostgreSQL" | persistence | jpa |
| Mentions "MongoDB", "NoSQL" | persistence | mongodb |
| No persistence mentioned | persistence | none (in-memory) |

**Detection logic:**
```
IF prompt mentions "System API" OR "consultar API" OR "backend"
THEN capability = persistence.system_api

ELSE IF prompt mentions "base de datos" OR "JPA" OR "PostgreSQL"
THEN capability = persistence.jpa
```

### Resilience Capabilities

| Condition | Capability | Feature |
|-----------|------------|---------|
| Mentions "circuit breaker", "CB", "fallback" | resilience | circuit_breaker |
| Mentions "retry", "reintento", "reintentar" | resilience | retry |
| Mentions "timeout", "tiempo límite" | resilience | timeout |
| Mentions "rate limit", "throttling", "límite" | resilience | rate_limiter |
| Mentions "resiliencia" (generic) | resilience | circuit_breaker, retry, timeout |

**Detection logic:**
```
FOR EACH resilience_keyword IN prompt:
    ADD corresponding capability
    
IF mentions "resiliencia" without specifics:
    ADD default set: [circuit_breaker, retry, timeout]
```

---

## Phase 3: Skill Selection Rules

### Primary Skill Selection

| Capabilities Detected | Skill Selected | Type |
|-----------------------|----------------|------|
| api_architecture.domain_api | skill-code-020-generate-microservice-java-spring | GENERATE |
| api_architecture.composable_api | skill-code-021-generate-composable-api (future) | GENERATE |
| Only resilience.circuit_breaker | skill-code-001-add-circuit-breaker-java-resilience4j | ADD |
| Only resilience.retry | skill-code-002-add-retry-java-resilience4j | ADD |
| Only resilience.timeout | skill-code-003-add-timeout-java-resilience4j | ADD |

**Selection logic:**
```
IF capabilities CONTAINS api_architecture.*
THEN select GENERATE skill for that api type
     (resilience capabilities passed as features to the GENERATE skill)

ELSE IF capabilities CONTAINS ONLY resilience.*
THEN select ADD skill for each resilience pattern
     (applied to existing codebase)
```

### Skill Type Determination

| Prompt Pattern | Skill Type |
|----------------|------------|
| "crear", "generar", "nuevo microservicio" | GENERATE |
| "añadir", "agregar", "implementar" + existing project | ADD |
| "eliminar", "quitar", "remover" | REMOVE |
| "refactorizar", "mejorar", "optimizar" | REFACTOR |
| "analizar", "revisar", "auditar" | ANALYZE |

---

## Phase 4: Input Generation Rules

### For GENERATE Skills (e.g., skill-020)

Generate `generation-request.json`:

```json
{
  "service": {
    "name": "{extracted service_name, kebab-case}",
    "description": "{from prompt or default}",
    "group_id": "com.{organization}.{domain}",
    "artifact_id": "{service_name}",
    "base_package": "com.{organization}.{service_name}"
  },
  "entities": [
    {
      "name": "{extracted entity_name, PascalCase}",
      "fields": []  // To be filled from OpenAPI or user
    }
  ],
  "api_type": "{detected api_architecture feature}",
  "persistence": {
    "type": "{detected persistence feature}",
    "system_api": {
      "name": "{extracted system_api name}",
      "spec_file": "{to be provided by user}"
    }
  },
  "features": {
    "resilience": {
      "circuit_breaker": { "enabled": {detected} },
      "retry": { "enabled": {detected} },
      "timeout": { "enabled": {detected}, "strategy": "client_level" }
    }
  }
}
```

### For ADD Skills (e.g., skill-001)

Generate `transformation-request.json`:

```json
{
  "targetClass": "{to be specified by user}",
  "targetMethod": "{to be specified by user}",
  "pattern": {
    "type": "basic_fallback"
  },
  "config": {
    // defaults from capability definition
  }
}
```

---

## Prompt Template for Users

To minimize omitted information, suggest users follow this template:

```markdown
## Microservice Generation Request

### Service Information
- **Service name:** [e.g., customer-service]
- **Main entity:** [e.g., Customer]
- **Description:** [brief description]

### Data Source (choose one)
- [ ] Own database (JPA/PostgreSQL)
- [ ] External System API
  - System API name: [e.g., Parties]
  - OpenAPI spec: [attached]

### API Type
- [ ] Domain API (business capability)
- [ ] Composable API (orchestrates multiple backends)
- [ ] Experience API (BFF for frontend)

### Resilience Patterns (select all that apply)
- [ ] Circuit Breaker
- [ ] Retry
- [ ] Timeout
- [ ] Rate Limiter

### Additional Files (attach if applicable)
- [ ] Domain API OpenAPI spec
- [ ] System API OpenAPI spec
- [ ] Field mapping (domain ↔ system api)
```

---

## Example: Full Discovery

**User Prompt:**
> "Necesito un microservicio Customer que exponga una Domain API para consultar 
> clientes. Los datos vienen del System API de Parties. Necesito circuit breaker, 
> retry y timeout."

**Phase 1 - Entity Extraction:**
```json
{
  "service_name": "Customer",
  "entities": ["Customer"],
  "system_api": "Parties",
  "patterns": ["circuit breaker", "retry", "timeout"],
  "api_type_hint": "Domain API"
}
```

**Phase 2 - Capability Detection:**
```json
{
  "capabilities": [
    "api_architecture.domain_api",
    "persistence.system_api",
    "resilience.circuit_breaker",
    "resilience.retry",
    "resilience.timeout"
  ]
}
```

**Phase 3 - Skill Selection:**
```json
{
  "skill": "skill-code-020-generate-microservice-java-spring",
  "type": "GENERATE",
  "reason": "api_architecture.domain_api detected, resilience passed as features"
}
```

**Phase 4 - Input Generation:**
```json
{
  "service": {
    "name": "customer-service",
    "group_id": "com.bank.customer",
    "base_package": "com.bank.customer"
  },
  "entities": [{ "name": "Customer" }],
  "api_type": "domain_api",
  "persistence": {
    "type": "system_api",
    "system_api": { "name": "Parties" }
  },
  "features": {
    "resilience": {
      "circuit_breaker": { "enabled": true },
      "retry": { "enabled": true },
      "timeout": { "enabled": true, "strategy": "client_level" }
    }
  }
}
```

---

## Missing Information Handling

When extracted information is incomplete:

| Missing | Action |
|---------|--------|
| Service name | Ask user or derive from entity name |
| Entity fields | Ask user or derive from OpenAPI spec |
| System API spec | Ask user to provide |
| Mapping (domain ↔ system api) | Ask user or generate draft from specs |
| Organization/group_id | Ask user or use default |

**Prompt for missing info:**
```
Para completar la generación, necesito:
- [ ] OpenAPI spec del System API de Parties
- [ ] Mapeo de campos entre Customer (dominio) y Party (System API)
```
