# Capability: Integration

**Capability ID:** integration  
**Version:** 1.2  
**Date:** 2026-01-21  
**Status:** Active  

---

## Overview

The Integration capability enables services to communicate with other services via different protocols and patterns. It provides standardized approaches for API-based integration (request/response) and event-driven integration (pub/sub).

---

## Type

- **Type:** Layered
- **Phase Group:** implementation
- **Cardinality:** multiple
- **Transformable:** Yes
- **Requires:** architecture (foundational)

---

## Discovery (v2.2)

### Capability-Level Keywords

```yaml
keywords:
  - integration
  - integración
  - external API
  - API externa
```

### No Default Feature (User Must Specify)

The integration capability currently only has `api-rest`, but future features (gRPC, Kafka) will be added. When multiple options exist, user must specify.

**Example:**
- "integración REST" → `integration.api-rest`
- "consumir API" → `integration.api-rest`

---

## Sub-Capabilities

### integration.api

API-based integration using request/response patterns.

#### integration.api.rest

REST synchronous integration via HTTP.

| Aspect | Details |
|--------|---------|
| **Status** | ✅ Supported |
| **ADR** | ADR-012 (API Integration Patterns) |
| **ERI** | ERI-013 (api-integration-rest-java-spring) |
| **MODULE** | mod-code-018-api-integration-rest-java-spring |
| **Variants** | RestClient (default), Feign, RestTemplate |

**Configuration:**

```json
{
  "features": {
    "integration": {
      "enabled": true,
      "apis": [
        {
          "name": "parties-api",
          "type": "rest",
          "client": "restclient",
          "baseUrlEnv": "PARTIES_API_URL"
        }
      ]
    }
  }
}
```

#### integration.api.grpc

gRPC synchronous integration.

| Aspect | Details |
|--------|---------|
| **Status** | 🔮 Planned |
| **ADR** | ADR-012 |
| **ERI** | TBD |
| **MODULE** | TBD |

#### integration.api.async

Async request/reply integration.

| Aspect | Details |
|--------|---------|
| **Status** | 🔮 Planned |
| **ADR** | ADR-012 |
| **ERI** | TBD |
| **MODULE** | TBD |

---

### integration.event

Event-driven integration using pub/sub patterns.

#### integration.event.choreography

Event-based choreography (reactive, no orchestrator).

| Aspect | Details |
|--------|---------|
| **Status** | 🔮 Planned |
| **ADR** | TBD |
| **ERI** | TBD |
| **MODULE** | TBD |

#### integration.event.orchestration

Command-based orchestration (SAGA pattern).

| Aspect | Details |
|--------|---------|
| **Status** | 🔮 Planned |
| **ADR** | TBD |
| **ERI** | TBD |
| **MODULE** | TBD |

---

## Relationships

### Depends On

- **resilience** - All outbound integrations should apply resilience patterns

### Used By

- **persistence** (when type = system_api) - Uses integration.api.rest for System API calls
- **api_architecture** (composable, experience) - Orchestrates calls to other APIs

---

## Feature Flags

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `integration.enabled` | boolean | false | Enable integration capability |
| `integration.apis[].type` | enum | rest | API type: rest, grpc, async |
| `integration.apis[].client` | enum | restclient | Client: restclient, feign, resttemplate |
| `integration.apis[].baseUrlEnv` | string | - | Environment variable for base URL |

---

## Generated Artifacts

When `integration.api.rest` is enabled:

```
adapter/
└── integration/
    ├── client/
    │   └── {ApiName}Client.java
    ├── dto/
    │   └── {Entity}Dto.java
    ├── mapper/
    │   └── {Entity}Mapper.java
    └── exception/
        └── IntegrationException.java
```

---

## Validation

Integration clients are validated for:

- Correlation header propagation (X-Correlation-ID)
- Base URL externalization
- Source system header (X-Source-System)
- Error handling

See mod-code-018 validation for details.

---

## Related

- **ADR-012:** API Integration Patterns
- **ERI-013:** REST Integration Java Spring
- **mod-code-018:** api-integration-rest-java-spring
- **CAP resilience:** Applied to integration calls

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-01 | Initial version - REST support |
