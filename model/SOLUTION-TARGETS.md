---
id: solution-targets
title: "Solution Targets — Golden Paths for Design-to-Code"
version: 3.0
date: 2026-02-16
updated: 2026-02-16
status: Proposed
author: C4E Architecture Team
---

# Solution Targets

## Purpose

A **Solution Target** is a golden path that bridges DESIGN output (DDD/BDD artifacts) to CODE input (enriched prompt + contracts). It defines the inherent architectural decisions for a type of system and produces the input that CODE discovery consumes.

---

## How It Works

```
DESIGN Analysis (DDD/BDD)
    │ produces domain model (bounded contexts, aggregates, scenarios)
    ▼
Solution Target (golden path)
    │ applies inherent capabilities (always, non-negotiable)
    │ maps DDD artifacts → contracts (OpenAPI, AsyncAPI, etc.)
    │ generates enriched prompt.md
    ▼
CODE Pipeline
    │ receives prompt.md + contracts + inherent capabilities
    │ CODE discovery finds additional capabilities from prompt
    │ (resilience, caching, compensation, etc.)
    ▼
Generated Code
```

The Solution Target does NOT pre-resolve every capability. It establishes the architectural base and produces an enriched prompt that is functionally equivalent to what an architect would write manually — but richer and more structured. CODE discovery handles the rest.

---

## Solution Target Definition

```yaml
id: "{target-id}"
name: "{Human-readable name}"
description: "{What this golden path builds}"
enterprise_layer: soe|soi|sor
status: active|planned|evaluate

# Capabilities that are ALWAYS applied — non-negotiable for this target
inherent_capabilities:
  - "{capability.feature}"

# What DESIGN produces for this target
design_mapping:
  ddd_projection: "{How DDD concepts map — reference to mapping rules}"
  contracts: [openapi|proto|asyncapi|graphql-sdl|component-manifest]
  field_mapping: true|false
  prompt_template: "{Reference to prompt.md template for this target}"

# What CODE receives
code_input:
  inherent_preselection:
    - "{capability.feature}"       # Same as inherent_capabilities
  discovery_source: "prompt.md"    # CODE discovery extracts additional capabilities from here
```

---

## Active Targets

### soi-fusion-api-rest

The current (and only active) golden path. Produces a Fusion API microservice.

```yaml
id: "soi-fusion-api-rest"
name: "Fusion API Service (REST)"
description: "Integration layer service based on the Fusion API Model. REST microservice with hexagonal architecture. Supports Domain, Composable, Experience, and System API tiers."
enterprise_layer: soi
status: active

inherent_capabilities:
  - architecture.hexagonal-light
  - api-architecture.domain-api      # Tier varies per Fusion layer

design_mapping:
  ddd_projection: "ADR-DESIGN-003, REST variant"
  contracts: [openapi]
  field_mapping: true                 # When System API persistence detected
  prompt_template: "design-prompt-soi-api-rest.md"

code_input:
  inherent_preselection:
    - architecture.hexagonal-light
    - api-architecture.domain-api
  discovery_source: "prompt.md"
  # CODE discovery will find from prompt.md:
  # - persistence (jpa or system-api) based on integration mentions
  # - resilience (circuit-breaker, retry, timeout) based on external calls
  # - api-architecture.public-exposure based on public API mentions
  # - distributed-transactions.compensation based on saga/workflow mentions
  # etc.
```

---

## Planned Targets

These are registered for future implementation. Each requires its own DESIGN mapping rules, CODE capabilities, and modules.

| Target ID | Name | Layer | Description | Prerequisite |
|-----------|------|-------|-------------|-------------|
| `soi-event-processor` | Event Processor | SoI | Reactive daemon consuming domain events via broker | Eventing capabilities in CODE KB |
| `soi-batch-job` | Batch Processing | SoI | Scheduled job for data processing/synchronization | Batch capabilities in CODE KB |
| `soe-microfrontend` | Micro-Frontend Module | SoE | UI module based on web components or framework | Frontend CODE KB |
| `sor-system-api-wrapper` | System API Wrapper | SoR | Mainframe/legacy system abstraction service | Already partially supported via persistence.system-api |

---

## Organization Customization

An organization can create **opinionated variants** of a base target that pre-bake additional decisions:

```yaml
# Example: organization-specific variant
id: "soi-fusion-api-rest-acme"
name: "ACME Corp API Service"
extends: "soi-fusion-api-rest"
description: "ACME standard: Apigee gateway, Anthos Service Mesh, GKE deployment"

# Additional inherent capabilities for this org
additional_inherent_capabilities:
  - auth.service-mesh-opa           # AuthZ via mesh, not in-app
  - observability.mesh-tracing      # Tracing via mesh, not in-app

# Org-specific defaults override
defaults_override:
  deployment_platform: "gke"
  gateway: "apigee"
  service_mesh: "anthos"
```

This is NOT required for v1. It shows how the model extends when an organization needs platform-specific golden paths.

---

## Discovery in DESIGN

### When Target Is Obvious

If the input clearly describes an API/service need, apply `soi-fusion-api-rest` automatically.

Signals: "API", "servicio", "microservicio", "Domain API", "REST", "endpoint", "integración".

### When Target Is Ambiguous

If the DDD analysis produces components that don't fit a single target (e.g., both an API and an event processor), ask:

> "El análisis identifica varios tipos de componentes. ¿Qué necesitas implementar?"
> - API REST (servicio de dominio)
> - Procesador de eventos
> - Proceso batch
> - Varios de los anteriores

### When Multiple Targets Apply

The same DDD model can project to multiple targets. Each produces its own mapping and prompt.md. Example: Customer bounded context → `soi-fusion-api-rest` (Domain API) + `soi-event-processor` (status change handler).

---

## Relationship to Capability Index

### DESIGN KB

Solution Targets determine the **mapping phase** of the DESIGN flow:

| DESIGN Phase | Driven By |
|-------------|-----------|
| Analysis (DDD/BDD) | Fixed methodology — always executes |
| Target Selection | Discovery or user selection |
| Mapping | Solution Target's `design_mapping` rules |
| Output Assembly | Solution Target's `contracts` + `prompt_template` |

### CODE KB

Solution Targets pre-select inherent capabilities and produce the prompt that CODE discovery processes:

| CODE Input | Source |
|-----------|--------|
| Inherent capabilities | `inherent_preselection` from target — skip discovery for these |
| Additional capabilities | CODE discovery extracts from `prompt.md` — normal discovery flow |

---

## Changelog

| Date | Version | Change | Author |
|------|---------|--------|--------|
| 2026-02-16 | 1.0 | Initial — atomic targets | C4E Architecture Team |
| 2026-02-16 | 2.0 | Composition model — architectural dimensions | C4E Architecture Team |
| 2026-02-16 | 3.0 | Simplified — golden paths with inherent + discovery | C4E Architecture Team |

---

**Status:** ⏳ Proposed
**Review Date:** 2026-02
