---
id: adr-design-001-domain-decomposition
title: "ADR-DESIGN-001: Domain Decomposition via Strategic DDD"
sidebar_label: Domain Decomposition
version: 1.0
date: 2026-02-16
updated: 2026-02-16
status: Proposed
author: C4E Architecture Team
reviewers:
  - JCM
decision_type: pattern
scope: organization
tags:
  - ddd
  - strategic-design
  - bounded-context
  - context-map
  - subdomain
  - domain-decomposition
related:
  - adr-code-001-api-design-standards
  - adr-code-009-service-architecture-patterns
  - adr-design-002-tactical-design-patterns
  - adr-design-003-api-architecture-mapping
implemented_by:
  - eri-design-001-strategic-ddd (planned)
---

# ADR-DESIGN-001: Domain Decomposition via Strategic DDD

**Status:** Proposed
**Date:** 2026-02-16
**Author:** C4E Architecture Team

---

## Context

### Current Situation

Our organization develops 400+ microservices, but the decomposition of business domains into services is inconsistent:

1. **Ad-hoc service boundaries**
   - Services are defined by technical layers or team structures, not business domains
   - Unclear ownership of business capabilities
   - Overlapping responsibilities between services
   - Data duplication without clear source of truth

2. **Missing upstream design**
   - Development starts from technical specifications (OpenAPI) without formal domain analysis
   - Architectural decisions are implicit and undocumented
   - No systematic method to identify bounded contexts from requirements
   - Knowledge lives in people's heads, not in artifacts

3. **Inconsistent domain language**
   - Same business concept named differently across teams ("customer", "client", "party", "user")
   - No ubiquitous language defined per domain
   - Integration contracts mismatch due to terminology gaps
   - Onboarding difficulty for new team members

4. **Automation gap**
   - The Enablement 2.0 CODE pipeline can generate microservices from specs
   - But the specs themselves are handcrafted, which is the bottleneck
   - No automation exists between "functional requirements" and "development-ready specs"

### Business Context

- **Input:** Functional requirements in natural language (business descriptions, user stories, process flows)
- **Desired output:** Bounded context map, subdomain classification, domain relationships
- **Consumers:** Architecture team, development squads, Enablement CODE pipeline
- **Scale:** New bounded contexts identified quarterly; existing contexts refined continuously

### Problem Statement

We need a systematic, repeatable method to:
- ✅ Decompose functional requirements into bounded contexts
- ✅ Classify subdomains (core, supporting, generic) for investment prioritization
- ✅ Map relationships between contexts (ACL, shared kernel, customer-supplier, etc.)
- ✅ Produce artifacts that feed downstream design and development
- ✅ Automate this analysis via AI agents using codified patterns

---

## Decision

We adopt **Strategic Domain-Driven Design** as the standard method for decomposing business domains into bounded contexts. The process produces structured artifacts that feed the API Design and Code Generation pipelines.

### Decomposition Process

```
Functional Requirements (natural language)
    │
    ├─ 1. IDENTIFY SUBDOMAINS
    │     Classify business areas as Core / Supporting / Generic
    │
    ├─ 2. DEFINE BOUNDED CONTEXTS
    │     Group cohesive business capabilities with explicit boundaries
    │     Each context owns its ubiquitous language
    │
    ├─ 3. MAP CONTEXT RELATIONSHIPS
    │     Define how contexts interact:
    │     Partnership, Shared Kernel, Customer-Supplier,
    │     Conformist, ACL, Open Host Service, Published Language
    │
    └─ 4. PRODUCE ARTIFACTS
          bounded-context-map.yaml
          → Input for ADR-DESIGN-002 (Tactical Design)
          → Input for ADR-DESIGN-003 (API Mapping)
```

### Bounded Context Identification Heuristics

A bounded context boundary should be placed where:

1. **Language changes** — The same word means different things (e.g., "account" in banking vs. CRM)
2. **Ownership changes** — Different teams are responsible for different aspects
3. **Lifecycle differs** — Entities have different creation/update/deletion patterns
4. **Consistency boundary** — A transaction must be atomic within the boundary
5. **Autonomy required** — The capability should be independently deployable

### Subdomain Classification

| Type | Definition | Investment | Example |
|------|-----------|------------|---------|
| **Core** | Competitive differentiator, unique business logic | Maximum (custom development) | Loan origination, risk scoring |
| **Supporting** | Necessary but not differentiating | Moderate (standard patterns) | Customer management, notifications |
| **Generic** | Industry-standard, no competitive value | Minimum (buy or reuse) | Authentication, email, file storage |

### Context Relationship Types

| Relationship | Direction | Description | When to Use |
|-------------|-----------|-------------|-------------|
| **Partnership** | Bidirectional | Two teams collaborate; changes coordinated | Close-knit teams, shared goals |
| **Shared Kernel** | Bidirectional | Shared model subset, jointly owned | Common domain model (use sparingly) |
| **Customer-Supplier** | Upstream → Downstream | Upstream provides, downstream consumes | Service provider/consumer pattern |
| **Conformist** | Upstream → Downstream | Downstream accepts upstream model as-is | External APIs, no negotiation possible |
| **Anticorruption Layer (ACL)** | Downstream isolation | Translation layer protects downstream model | Legacy integration, model mismatch |
| **Open Host Service** | Upstream publishes | Well-defined protocol for multiple consumers | API-first, multiple consumers |
| **Published Language** | Shared format | Documented interchange format (e.g., OpenAPI) | Standardized contracts |

---

## Rationale

### Why Strategic DDD?

1. **Business-aligned decomposition** — Contexts mirror business capabilities, not technical layers
2. **Explicit boundaries** — Clear ownership reduces coupling and cross-team conflicts
3. **Scalable method** — Works for 5 or 500 services
4. **Industry-proven** — Used by Amazon, Netflix, Spotify for microservice decomposition
5. **Automatable** — Heuristics can be codified for AI-assisted analysis

### Why NOT pure Event Storming?

Event Storming is valuable for discovery workshops but:
- Requires physical/synchronous collaboration
- Output is ephemeral (sticky notes)
- Not easily automatable by AI agents
- We incorporate its insights into our structured process instead

### Why NOT decomposition by team/org structure?

Conway's Law suggests architecture follows organization, but:
- Org structure changes frequently
- Team boundaries don't always align with business domains
- Leads to technically-driven rather than domain-driven decomposition

### Alternatives Considered

- **Service per entity:** Too granular, leads to distributed monolith
- **Decomposition by use case:** Overlapping boundaries, unclear ownership
- **Decomposition by technical layer:** Violates domain cohesion

---

## Consequences

### Positive

- ✅ Consistent domain decomposition across the organization
- ✅ Clear ownership and boundaries for each business capability
- ✅ Ubiquitous language per context reduces communication errors
- ✅ Direct feed into API Design and Code Generation pipelines
- ✅ Automatable via Enablement DESIGN agents
- ✅ Subdomain classification guides investment decisions

### Negative

- ⚠️ Requires domain knowledge to identify correct boundaries
- ⚠️ Initial analysis takes time (but saves time downstream)
- ⚠️ May require organizational changes to align teams with contexts
- ⚠️ Over-decomposition risk if heuristics applied too aggressively

### Mitigations

1. **ERIs as examples** — Provide complete reference decompositions for common domains
2. **AI-assisted analysis** — DESIGN agents apply heuristics systematically
3. **Iterative refinement** — Context boundaries can be adjusted as understanding grows
4. **Review gates** — Architecture team validates decomposition before downstream consumption

---

## Implementation

### Reference Implementations

| Domain Example | ERI | Status |
|---------------|-----|--------|
| Banking - Customer Management | eri-design-001-strategic-ddd | ⏳ Planned |

### Output Artifacts

This process produces a structured bounded context map artifact. The concrete format, schema, and worked examples are defined in the corresponding ERI (eri-design-001-strategic-ddd).

---

## Validation

### Success Criteria

- [ ] Every bounded context has a clear owner
- [ ] No business capability belongs to more than one context
- [ ] Ubiquitous language defined for each context
- [ ] All cross-context relationships explicitly documented
- [ ] Output artifact is parseable by downstream agents

### Compliance Checks

- Bounded context names are unique within the domain
- Every context has at least one business capability
- Relationship types are from the approved set
- No circular dependencies in context relationships

---

## References

### Related ADRs

- **ADR-CODE-001:** API Design - Fusion API Model (defines API tiers that contexts map to)
- **ADR-CODE-009:** Service Architecture Patterns (defines how contexts become services)
- **ADR-DESIGN-002:** Tactical Design Patterns (defines internal context structure)
- **ADR-DESIGN-003:** API Architecture Mapping (maps contexts to Fusion API tiers)

### External Resources

- [Domain-Driven Design (Eric Evans, 2003)](https://www.domainlanguage.com/ddd/)
- [Implementing Domain-Driven Design (Vaughn Vernon, 2013)](https://www.oreilly.com/library/view/implementing-domain-driven-design/9780133039900/)
- [Context Mapping (DDD Reference)](https://www.domainlanguage.com/ddd/reference/)
- [Team Topologies (Skelton & Pais)](https://teamtopologies.com/)

---

## Changelog

| Date | Version | Change | Author |
|------|---------|--------|--------|
| 2026-02-16 | 1.0 | Initial version | C4E Architecture Team |

---

**Decision Status:** ⏳ Proposed
**Review Date:** 2026-02
