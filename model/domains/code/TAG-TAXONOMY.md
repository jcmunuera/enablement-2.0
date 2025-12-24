# CODE Domain: Tag Taxonomy

**Version:** 1.1  
**Date:** 2025-12-24  
**Domain:** CODE

---

## Purpose

This document defines the tag taxonomy for CODE domain skills. It specifies:

1. **Tag dimensions** and valid values
2. **Extraction rules** for detecting tags from user prompts
3. **Default values** when tags are not specified
4. **Dimension weights** for discovery scoring
5. **Coherence rules** for skill extension

For the generic tag format and discovery process, see `model/standards/authoring/TAGS.md`.

---

## Language Support

Keywords are defined in **English and Spanish** to support bilingual prompts. The discovery process matches against any variant.

> **Note:** This bilingual keyword approach is a pragmatic solution. Future evolution may include semantic matching or external ontologies for more flexible language support.

---

## Tag Dimensions

### artifact-type (REQUIRED)

What the skill produces.

| Value | Description | 
|-------|-------------|
| `api` | Product exposed to third parties with public contract (OpenAPI) |
| `service` | Internal microservice within bounded context |
| `application` | Standalone application (batch, daemon, CLI) |
| `component` | Reusable library/component |

### runtime-model (REQUIRED)

How the artifact executes.

| Value | Description |
|-------|-------------|
| `request-response` | Responds to synchronous requests (REST, gRPC) |
| `daemon` | Long-running background process |
| `batch` | Scheduled/triggered execution |
| `event-driven` | Reacts to asynchronous events |

### stack (REQUIRED)

Technology and framework combination.

| Value | Description |
|-------|-------------|
| `java-spring` | Java with Spring Boot |
| `java-quarkus` | Java with Quarkus |
| `nodejs-express` | Node.js with Express |
| `nodejs-nestjs` | Node.js with NestJS |
| `go-gin` | Go with Gin |
| `kotlin-ktor` | Kotlin with Ktor |

### protocol (REQUIRED if artifact-type = api)

Communication protocol for APIs.

| Value | Description |
|-------|-------------|
| `rest` | RESTful HTTP API |
| `grpc` | gRPC with Protocol Buffers |
| `graphql` | GraphQL API |
| `async` | Async messaging (Kafka, RabbitMQ) |

### api-model (REQUIRED if artifact-type = api)

API architecture model.

| Value | Description |
|-------|-------------|
| `fusion` | Fusion 4-layer model (see below) |
| `standard` | Generic REST API without specific model |

#### Fusion API Model Layers

All Fusion layers are **SoI (System of Innovation)** from a technology perspective:

```
┌─────────────────────────────────────────────────────────────┐
│                    FUSION API MODEL                         │
│                     (All layers = SoI)                      │
├─────────────────────────────────────────────────────────────┤
│  Experience API / BFF  │ UI-facing APIs, aggregation       │
│  Composable API        │ Orchestration, SAGA, workflows    │
│  Domain API            │ Business domain logic             │
│  System API            │ Backend integration (mainframe)   │
└─────────────────────────────────────────────────────────────┘
```

> **Note:** SoE (System of Engagement) is reserved for Front-End technologies: Angular, React, TypeScript, Microfrontends.

---

## Tag Extraction Rules

These rules define how to extract tag values from user prompts.

### artifact-type

| Keywords (EN/ES) | Extracted value |
|------------------|-----------------|
| `API`, `REST API`, `Domain API`, `API de Dominio`, `System API`, `API de Sistema`, `Experience API`, `API de Experiencia`, `Composable API`, `API Compuesta`, `API Orquestadora`, `Fusion API`, `Fusion`, `BFF`, `Backend for Frontend` | `api` |
| `microservice`, `microservicio`, `service`, `servicio`, `internal service`, `servicio interno`, `backend service`, `servicio backend`, `servicio de negocio`, `business service` | `service` |
| `application`, `aplicación`, `batch`, `daemon`, `CLI`, `job`, `proceso`, `process`, `tarea programada`, `scheduled task` | `application` |
| `library`, `librería`, `component`, `componente`, `module`, `módulo`, `utility`, `utilidad`, `helper` | `component` |
| *(none detected)* | **ASK**: "¿Qué tipo de artefacto necesitas: API, microservicio, aplicación batch/daemon, o componente/librería?" |

### stack

| Keywords (EN/ES) | Extracted value |
|------------------|-----------------|
| `Java`, `Spring`, `Spring Boot` | `java-spring` |
| `Quarkus` | `java-quarkus` |
| `Node`, `NodeJS`, `Node.js`, `Express` | `nodejs-express` |
| `NestJS`, `Nest` | `nodejs-nestjs` |
| `Go`, `Golang`, `Gin` | `go-gin` |
| `Kotlin`, `Ktor` | `kotlin-ktor` |
| *(none detected)* | **DEFAULT**: `java-spring` |

### runtime-model

| Keywords (EN/ES) | Extracted value |
|------------------|-----------------|
| `REST`, `HTTP`, `request`, `endpoint`, `synchronous`, `síncrono`, `sincrónico`, `petición`, `llamada` | `request-response` |
| `daemon`, `demonio`, `background`, `segundo plano`, `servicio continuo`, `continuous service`, `long-running` | `daemon` |
| `batch`, `job`, `scheduled`, `programado`, `cron`, `tarea`, `task`, `proceso nocturno`, `nightly` | `batch` |
| `event`, `evento`, `Kafka`, `RabbitMQ`, `async`, `asynchronous`, `asíncrono`, `message`, `mensaje`, `publish`, `subscribe`, `stream` | `event-driven` |
| *(none detected)* | **DEFAULT**: `request-response` |

### protocol (only if artifact-type = api)

| Keywords (EN/ES) | Extracted value |
|------------------|-----------------|
| `REST`, `RESTful`, `HTTP`, `JSON API` | `rest` |
| `gRPC`, `protobuf`, `proto`, `Protocol Buffers` | `grpc` |
| `GraphQL` | `graphql` |
| `async`, `Kafka`, `eventos`, `events`, `mensajes`, `messages`, `streaming` | `async` |
| *(none detected)* | **DEFAULT**: `rest` |

### api-model (only if artifact-type = api)

#### HIGH Confidence (Direct Match → No ASK)

These keywords **directly indicate Fusion model** - select skill without asking:

| Keywords (EN/ES) | Extracted value | Confidence |
|------------------|-----------------|------------|
| `Fusion`, `Fusion API`, `API Fusion` | `fusion` | HIGH |
| `Domain API`, `API de Dominio`, `API del Dominio` | `fusion` | HIGH |
| `System API`, `API de Sistema`, `API del Sistema` | `fusion` | HIGH |
| `Experience API`, `API de Experiencia` | `fusion` | HIGH |
| `Composable API`, `API Compuesta`, `API Orquestadora`, `API de Orquestación`, `Orchestration API` | `fusion` | HIGH |
| `BFF`, `Backend for Frontend`, `Backend para Frontend` | `fusion` | HIGH |
| `SAGA`, `saga pattern`, `patrón saga` | `fusion` | HIGH (implies Composable) |

#### MEDIUM Confidence (Requires ASK)

These patterns are ambiguous - ask for clarification:

| Pattern | Action |
|---------|--------|
| `API` + `dominio` (but not "Domain API") | **ASK**: "¿Te refieres a una Domain API del modelo Fusion, o es una API genérica para el dominio de negocio?" |
| `REST API` without Fusion keywords | **ASK**: "¿La API sigue el modelo Fusion (Domain/System/Experience/Composable) o es una API REST genérica?" |
| `API genérica`, `standard API`, `simple API`, `API simple` | `standard` | HIGH |

#### LOW Confidence (No Match)

| Pattern | Action |
|---------|--------|
| `API` alone without qualifiers | **ASK**: "¿Qué tipo de API necesitas? Opciones: Domain API, System API, Experience API, Composable API (modelo Fusion), o API REST genérica" |

---

## Dimension Weights

Weights determine the importance of each dimension during discovery scoring.

| Dimension | Weight | Rationale |
|-----------|--------|-----------|
| `artifact-type` | 3 | Primary discriminator between skill types |
| `api-model` | 3 | Critical for distinguishing API skills |
| `protocol` | 2 | Important for API communication type |
| `stack` | 1 | Usually explicit or has clear default |
| `runtime-model` | 1 | Often implicit from artifact-type |

### Scoring Example

```
User: "Genera una Fusion Domain API para Customer"

Extracted tags:
  artifact-type: api (keyword: "API")
  api-model: fusion (keywords: "Fusion", "Domain API") → HIGH confidence
  protocol: rest (default)
  stack: java-spring (default)
  runtime-model: request-response (default)

Skill: skill-021-api-rest-java-spring
Tags:
  artifact-type: api ✓ (+3)
  api-model: fusion ✓ (+3)
  protocol: rest ✓ (+2)
  stack: java-spring ✓ (+1)
  runtime-model: request-response ✓ (+1)

Total Score: 10

Skill: skill-020-microservice-java-spring
Tags:
  artifact-type: service ✗ (0)
  stack: java-spring ✓ (+1)
  runtime-model: request-response ✓ (+1)

Total Score: 2

Winner: skill-021 (score 10 vs 2)
```

### Scoring Example with System API

```
User: "Implementa una System API para integración con mainframe"

Extracted tags:
  artifact-type: api (keyword: "System API")
  api-model: fusion (keyword: "System API") → HIGH confidence
  protocol: rest (default)
  stack: java-spring (default)
  runtime-model: request-response (default)

Result: skill-021 (score 10) - No ASK required
```

---

## Coherence Rules for Extension

When a skill extends another, these rules ensure tag coherence:

### Must Remain Consistent (Immutable)

These tags **must have the same value** as the parent:

| Tag | Rationale |
|-----|-----------|
| `stack` | A Java-Spring skill cannot extend a NodeJS skill |
| `runtime-model` | A batch skill cannot extend a request-response skill |

### May Change (Specialization)

These tags **may differ** from the parent:

| Tag | Valid changes | Rationale |
|-----|---------------|-----------|
| `artifact-type` | `service` → `api` | API is a specialization of service |

### May Add (New Dimensions)

Child skills may add tags not present in parent:

| Tag | Condition |
|-----|-----------|
| `protocol` | Only if child has `artifact-type: api` |
| `api-model` | Only if child has `artifact-type: api` |

### Coherence Validation Checklist

When creating a skill that extends another:

- [ ] `stack` matches parent exactly
- [ ] `runtime-model` matches parent exactly
- [ ] If `artifact-type` differs, it's a valid specialization (e.g., `service` → `api`)
- [ ] Added tags (`protocol`, `api-model`) are consistent with `artifact-type`

---

## Examples

### Example 1: Base Microservice

```yaml
---
id: skill-020-microservice-java-spring
version: 2.1.0
tags:
  artifact-type: service
  runtime-model: request-response
  stack: java-spring
---
```

### Example 2: REST API (extends base)

```yaml
---
id: skill-021-api-rest-java-spring
version: 2.2.0
extends: skill-020-microservice-java-spring
tags:
  artifact-type: api
  runtime-model: request-response  # Same as parent (explicit)
  stack: java-spring               # Same as parent (explicit)
  protocol: rest                   # Added
  api-model: fusion                # Added
---
```

### Example 3: Batch Application

```yaml
---
id: skill-030-batch-java-spring
version: 1.0.0
tags:
  artifact-type: application
  runtime-model: batch
  stack: java-spring
---
```

### Example 4: Event-Driven Service

```yaml
---
id: skill-025-event-consumer-java-spring
version: 1.0.0
tags:
  artifact-type: service
  runtime-model: event-driven
  stack: java-spring
---
```

### Example 5: gRPC API (future)

```yaml
---
id: skill-022-api-grpc-java-spring
version: 1.0.0
extends: skill-020-microservice-java-spring
tags:
  artifact-type: api
  runtime-model: request-response
  stack: java-spring
  protocol: grpc
  api-model: standard
---
```

---

## Anti-patterns

### ❌ Incoherent stack

```yaml
# BAD: Child has different stack than parent
extends: skill-020-microservice-java-spring  # stack: java-spring
tags:
  stack: nodejs-express  # INVALID!
```

### ❌ Incoherent runtime-model

```yaml
# BAD: Child has incompatible runtime-model
extends: skill-020-microservice-java-spring  # runtime-model: request-response
tags:
  runtime-model: batch  # INVALID!
```

### ❌ Missing conditional tags

```yaml
# BAD: API without protocol and api-model
tags:
  artifact-type: api
  runtime-model: request-response
  stack: java-spring
  # Missing: protocol, api-model
```

---

## Related Documents

- `model/standards/authoring/TAGS.md` - Generic tag format and discovery process
- `model/standards/authoring/SKILL.md` - Skill authoring guide
- `model/domains/code/DOMAIN.md` - CODE domain overview
- `runtime/discovery/skill-index.yaml` - Discovery index

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-24 | Initial version |
| 1.1 | 2025-12-24 | Added bilingual keywords (EN/ES), Fusion model documentation (4 layers all SoI), HIGH/MEDIUM/LOW confidence rules for api-model, added Composable API keywords |
