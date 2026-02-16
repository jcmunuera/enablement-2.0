---
id: adr-design-003-api-architecture-mapping
title: "ADR-DESIGN-003: API Architecture Mapping (DDD → Fusion API Model)"
sidebar_label: API Architecture Mapping
version: 1.1
date: 2026-02-16
updated: 2026-02-16
status: Proposed
author: C4E Architecture Team
reviewers:
  - JCM
decision_type: pattern
scope: organization
tags:
  - api
  - ddd
  - fusion-api-model
  - mapping
  - domain-api
  - system-api
  - bounded-context
  - aggregate
  - api-first
  - rest
  - grpc
  - async-api
  - graphql
related:
  - adr-code-001-api-design-standards
  - adr-design-001-domain-decomposition
  - adr-design-002-tactical-design-patterns
  - adr-code-009-service-architecture-patterns
implemented_by:
  - eri-design-003-api-mapping (planned)
---

# ADR-DESIGN-003: API Architecture Mapping (DDD → Fusion API Model)

**Status:** Proposed
**Date:** 2026-02-16
**Updated:** 2026-02-16 (v1.1 — API-type agnostic, variant mapping rules)
**Author:** C4E Architecture Team

---

## Context

ADR-DESIGN-001 produces bounded contexts with relationships. ADR-DESIGN-002 defines the internal structure (aggregates, entities, events). ADR-CODE-001 defines the Fusion API Model with 4 tiers (Experience/BFF, Composable, Domain, System) and supports multiple API types (REST, gRPC, AsyncAPI).

We need a systematic method to **map DDD artifacts to Fusion API tiers**, producing API contracts and integration mappings that become the input for the CODE pipeline. The mapping must work across different API types, as not all services expose REST interfaces.

### Problem Statement

Given a bounded context with aggregates and entities, determine:
- ✅ Which Fusion API tier each aggregate exposes through
- ✅ What API surface corresponds to each aggregate root (resources, services, topics, types)
- ✅ What System APIs are needed for backend integration
- ✅ What field-level transformations exist between domain and system models
- ✅ What the API contract looks like, in the appropriate specification format

---

## Decision

We adopt a **deterministic mapping** from DDD artifacts to Fusion API tiers, governed by rules defined in this ADR. The mapping operates at two levels:

1. **Tier mapping** (API-type agnostic) — Which Fusion tier does each DDD artifact map to?
2. **Surface mapping** (API-type specific) — How do DDD concepts project onto the chosen API type?

The API type is an input to the mapping process, not a fixed assumption. The mapping agent selects the appropriate variant rules based on the API type.

---

## Part 1: Tier Mapping (API-Type Agnostic)

These rules apply regardless of whether the API is REST, gRPC, AsyncAPI, or GraphQL.

### Mapping Rules: Bounded Context → API Tier

| DDD Artifact | Fusion API Tier | Rule |
|-------------|-----------------|------|
| Bounded Context (core/supporting) | **Domain API** | Each context exposes one Domain API for its aggregate root operations |
| Bounded Context (generic) | **System API** or external service | Generic subdomains integrate via System API or are bought/reused |
| Cross-context workflow | **Composable API** | When a use case spans multiple bounded contexts |
| Channel-specific projection | **Experience/BFF API** | When a UI needs composed/filtered data from multiple Domain APIs |
| Backend/SoR integration | **System API** | When a context needs data from a legacy system or external provider |

### Mapping Rules: Context Relationships → API Dependencies

| Context Relationship | API Integration Pattern |
|---------------------|------------------------|
| Customer-Supplier | Downstream Domain API calls upstream Domain API |
| Conformist | Downstream uses upstream's contract as-is |
| ACL | Domain API calls System API (translation layer) |
| Open Host Service | Domain API exposes standardized contract |
| Published Language | Shared contract spec (OpenAPI, Proto, AsyncAPI, GraphQL SDL) |

### System API Identification

A System API is needed when:
1. A bounded context persists data in a legacy System of Record (SoR)
2. A bounded context integrates with an external provider
3. The data model of the backend differs from the domain model (requires transformation)

System API generation includes:
- Backend contract definition (what the SoR exposes)
- Field-level mapping (domain model ↔ system model)
- Transformation rules (type conversion, naming, enums)

---

## Part 2: Surface Mapping (API-Type Specific)

Once the Fusion tier is determined, the DDD concepts project onto the API surface differently depending on the API type. Each API type defines its own mapping variant.

### Common Mapping Principles (All API Types)

| DDD Concept | API Concept | Principle |
|------------|-------------|-----------|
| Aggregate Root | Primary API entry point | The aggregate root is the unit of exposure; external access goes through it |
| Entity (non-root) | Subordinate to root | Non-root entities are accessed via or nested within the aggregate root |
| Value Object | Embedded structure | Part of the aggregate representation, no independent API surface |
| Invariant | Validation / error | Enforced on mutation operations, produces error responses on violation |

### Variant: REST (Synchronous, Resource-Oriented)

**Contract format:** OpenAPI 3.0+

| DDD Concept | REST Mapping |
|------------|-------------|
| Aggregate Root | Primary resource (`/{root-plural}`) |
| Non-root Entity | Sub-resource (`/{root-plural}/{id}/{entity-plural}`) |
| Command | Mutating HTTP method (POST, PUT, PATCH, DELETE) |
| Query | GET endpoint (single resource or collection with pagination) |
| Domain Event | Not directly exposed; available via webhook or polling (future) |
| Custom Action | POST to action sub-resource (`/{root-plural}/{id}/{action}`) |

**Governed by:** ADR-CODE-001 REST standards (pagination, HATEOAS, error format, versioning).

### Variant: gRPC (Synchronous, Service-Oriented)

**Contract format:** Protocol Buffers (.proto)

| DDD Concept | gRPC Mapping |
|------------|-------------|
| Aggregate Root | Service definition (`service {Aggregate}Service`) |
| Non-root Entity | Nested message type within aggregate messages |
| Command | RPC method (unary or client-streaming) |
| Query | RPC method (unary or server-streaming for collections) |
| Domain Event | Server-streaming RPC or separate event service |
| Custom Action | Named RPC method on the service |

**Governed by:** ADR-CODE-001 gRPC standards (when defined).

### Variant: AsyncAPI (Asynchronous, Event-Oriented)

**Contract format:** AsyncAPI 2.x / 3.x

| DDD Concept | AsyncAPI Mapping |
|------------|-----------------|
| Aggregate Root | Channel namespace (`{context}/{aggregate}`) |
| Domain Event | Message on channel (`{aggregate}.{event-name}`) |
| Command | Command message on inbound channel |
| Query | Not applicable (async is not request/response) |
| Non-root Entity | Part of event/command payload |

**Governed by:** ADR-CODE-001 AsyncAPI standards (when defined).

### Variant: GraphQL (Synchronous, Query-Oriented)

**Contract format:** GraphQL SDL (.graphql)

| DDD Concept | GraphQL Mapping |
|------------|----------------|
| Aggregate Root | Type definition (`type {Aggregate}`) |
| Non-root Entity | Nested type or field on aggregate type |
| Command | Mutation (`create{Aggregate}`, `update{Aggregate}`) |
| Query | Query field (`{aggregate}(id)`, `{aggregates}(filter)`) |
| Domain Event | Subscription (`on{Aggregate}{Event}`) |

**Governed by:** Organization GraphQL standards (when defined).

### API Type Selection Criteria

The API type is determined by the context's communication requirements:

| Criterion | REST | gRPC | AsyncAPI | GraphQL |
|-----------|------|------|----------|---------|
| External consumers (public) | ✅ Default | ⚠️ Limited | ❌ | ⚠️ BFF only |
| Internal service-to-service | ✅ | ✅ Preferred for perf | ⚠️ | ❌ |
| Event-driven / reactive | ❌ | ⚠️ Streaming | ✅ Default | ❌ |
| Multi-consumer aggregation | ⚠️ | ❌ | ❌ | ✅ BFF layer |
| Existing organization standard | ✅ Primary | 🔜 Planned | 🔜 Planned | ⚠️ Evaluate |

**Default:** REST is the default API type for Domain APIs and System APIs, per ADR-CODE-001.

---

## Output Artifacts

This process produces multiple artifacts that together form the input for the CODE pipeline:

- **API mapping** — Relates DDD aggregates to Fusion API tiers, resources/services, and selected API type
- **Field mapping** — Domain-to-system field transformations (when System API present)
- **API contract** — Contract definition in the format appropriate for the API type (OpenAPI, Proto, AsyncAPI, GraphQL SDL)
- **Enriched prompt** — Combined design context for CODE pipeline consumption

The concrete format, schema, and worked examples for each artifact are defined in the corresponding ERI (eri-design-003-api-mapping). Each artifact serves a different consumer: architecture review (mapping), CODE pipeline (contracts, field mapping, prompt).

---

## Rationale

### Why Deterministic Mapping Rules?

1. **Consistency** — Same DDD input always produces same API structure
2. **Automatable** — Rules can be implemented by DESIGN agents
3. **Auditable** — Mapping decisions are traceable from requirement to API
4. **Aligned with ADR-CODE-001** — Rules enforce Fusion API Model constraints

### Why API-Type Variants?

1. **Not everything is REST** — Event-driven contexts need AsyncAPI, high-performance internals need gRPC
2. **Same DDD model, different projections** — An aggregate can expose REST externally and emit events via AsyncAPI simultaneously
3. **Future-proof** — New API types can be added as variants without changing the tier mapping
4. **Aligned with ADR-CODE-001** — Which already defines multiple API type standards

### Why Produce Multiple Artifacts?

Each artifact serves a different purpose and consumer — architecture review, CODE pipeline codegen, and enriched context for LLM-based generation. Separating concerns enables independent validation and evolution of each artifact type.

---

## Consequences

### Positive

- ✅ DDD analysis automatically produces development-ready API contracts
- ✅ Fusion API Model constraints are enforced by design, not by review
- ✅ Field mapping captured at design time, not discovered during coding
- ✅ Complete traceability: requirement → context → aggregate → API → code
- ✅ Supports multiple API types without changing the core mapping model
- ✅ An aggregate can have multiple API projections (REST + AsyncAPI)

### Negative

- ⚠️ More variants increase mapping complexity
- ⚠️ gRPC, AsyncAPI, and GraphQL variants are less mature than REST
- ⚠️ Custom actions (non-standard operations) require manual input
- ⚠️ System API mapping requires knowledge of backend data model

### Mitigations

1. **REST as default** — Teams only deal with other variants when explicitly needed
2. **Incremental variant maturity** — REST variant is complete; others mature as adoption grows
3. **Override mechanism** — Allow manual overrides of mapping rules with justification
4. **Backend spec input** — System API specs can be provided as input (e.g., existing Swagger from mainframe wrapper)

---

## Implementation

### Reference Implementations

| Domain Example | ERI | Status |
|---------------|-----|--------|
| Customer → Domain API (REST) + System API | eri-design-003-api-mapping | ⏳ Planned |

### API Type Variant Status

| Variant | Status | Contract Format |
|---------|--------|----------------|
| REST | ✅ Active (default) | OpenAPI 3.0+ |
| gRPC | 🔜 Planned | Protocol Buffers |
| AsyncAPI | 🔜 Planned | AsyncAPI 2.x/3.x |
| GraphQL | 🔜 Evaluate | GraphQL SDL |

### Relationship to CODE Pipeline

```
aggregate-definitions.yaml (ADR-DESIGN-002)
    │
    │ tier mapping + surface mapping (this ADR)
    │ API type selected per context/aggregate
    ▼
api-mapping + field-mapping + API contract (per type)
    │
    │ ═══════ DESIGN → CODE boundary ═══════
    ▼
Enablement CODE Pipeline (discovery → codegen → compilation)
```

---

## Validation

### Success Criteria

- [ ] Every aggregate root maps to exactly one primary API surface per API type
- [ ] API tier assignment follows tier mapping rules
- [ ] API type selection is justified and documented
- [ ] System APIs identified for all backend integrations
- [ ] Field mappings include type transformations
- [ ] Generated API contracts are valid (linting per contract format)
- [ ] Output artifacts are consumable by CODE pipeline

### Compliance Checks

- API tier assignment matches DDD subdomain type
- No Domain API calls another Domain API directly (use Composable)
- System APIs are not exposed beyond Domain API tier
- Contract format matches selected API type
- Surface mapping follows variant rules for the selected type

---

## References

### Related ADRs

- **ADR-CODE-001:** Fusion API Model (target architecture, API type standards)
- **ADR-DESIGN-001:** Domain Decomposition (source: bounded contexts)
- **ADR-DESIGN-002:** Tactical Design (source: aggregates, entities)
- **ADR-CODE-009:** Service Architecture Patterns (how APIs become services)

---

## Changelog

| Date | Version | Change | Author |
|------|---------|--------|--------|
| 2026-02-16 | 1.0 | Initial version (REST-only mapping) | C4E Architecture Team |
| 2026-02-16 | 1.1 | API-type agnostic: separated tier mapping from surface mapping, added gRPC/AsyncAPI/GraphQL variants, API type selection criteria | C4E Architecture Team |

---

**Decision Status:** ⏳ Proposed
**Review Date:** 2026-02
