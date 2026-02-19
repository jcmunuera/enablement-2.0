---
id: adr-design-002-tactical-design-patterns
title: "ADR-DESIGN-002: Tactical Design Patterns (DDD)"
sidebar_label: Tactical Design Patterns
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
  - tactical-design
  - aggregate
  - entity
  - value-object
  - domain-event
  - command
  - repository
related:
  - adr-design-001-domain-decomposition
  - adr-design-003-api-architecture-mapping
  - adr-code-009-service-architecture-patterns
implemented_by:
  - eri-design-002-tactical-design (planned)
---

# ADR-DESIGN-002: Tactical Design Patterns (DDD)

**Status:** Proposed
**Date:** 2026-02-16
**Author:** C4E Architecture Team

---

## Context

ADR-DESIGN-001 defines how to decompose a domain into bounded contexts. Once contexts are identified, we need a systematic method to define the **internal structure** of each context: what are the key entities, how they group into aggregates, what business rules (invariants) they enforce, and what events they produce.

### Problem Statement

We need a standard vocabulary and structure for defining:
- ✅ Aggregates with their boundaries and invariants
- ✅ Entities with identity and lifecycle
- ✅ Value Objects for immutable concepts
- ✅ Domain Events that represent state transitions
- ✅ Commands that trigger business operations
- ✅ Repository interfaces as persistence abstractions

This structure must be:
- Understandable by both architects and developers
- Expressed as structured artifacts (not just diagrams)
- Consumable by the API Mapping agent (ADR-DESIGN-003) and the CODE pipeline

---

## Decision

We adopt **DDD Tactical Patterns** as the standard vocabulary for defining the internal structure of bounded contexts. Each context produces an `aggregate-definitions.yaml` artifact.

### Pattern Catalog

#### Aggregate

The fundamental consistency boundary. An aggregate groups entities and value objects that must change together in a single transaction.

**Rules:**
1. An aggregate has exactly ONE aggregate root (the entry point)
2. External references to an aggregate MUST go through the root
3. A single transaction MUST NOT span multiple aggregates
4. Inter-aggregate communication is via domain events (eventual consistency)
5. Aggregate boundaries should be as small as possible (prefer fewer entities per aggregate)

**Identification heuristics:**
- What MUST be consistent within a single transaction?
- What is the smallest set of objects that must change atomically?
- If entity A cannot exist without entity B, they likely belong in the same aggregate

#### Entity

An object defined by its identity, not its attributes. Two entities with the same attributes but different IDs are different entities.

**Characteristics:**
- Has a unique identity (ID) that persists across time
- Has mutable state (attributes can change)
- Has lifecycle (created, modified, archived/deleted)
- Equality is based on identity, not attributes

**Examples:** Customer, Order, Account, Product

#### Value Object

An object defined by its attributes, not by identity. Two value objects with the same attributes are interchangeable.

**Characteristics:**
- Immutable (once created, never modified)
- No unique identity
- Equality is based on attribute values
- Can be freely shared and replaced

**Examples:** Address, Money, DateRange, EmailAddress, PhoneNumber

**Heuristic:** If the object could be replaced by another with the same values without business impact → Value Object.

#### Domain Event

A record of something significant that happened in the domain. Events are past-tense ("OrderPlaced", not "PlaceOrder").

**Characteristics:**
- Immutable (historical record)
- Past tense naming ("CustomerCreated", "OrderShipped")
- Contains the data relevant at the time of occurrence
- Can trigger reactions in other aggregates or contexts

**Heuristic:** "When [entity] does [action], other parts of the system need to know" → Domain Event.

#### Command

A request to perform an action. Commands are imperative ("CreateCustomer", "PlaceOrder").

**Characteristics:**
- Imperative naming ("CreateCustomer", not "CustomerCreated")
- May succeed or fail (with explicit error cases)
- Directed at a specific aggregate
- Contains the data needed to execute the action

#### Query (Read Model)

A request for information that does not change state.

**Characteristics:**
- Does not modify domain state
- May return denormalized or projected data
- Can be optimized independently of write model

---

## Aggregate Design Guidelines

### Sizing Principle

Prefer **small aggregates**. A common mistake is creating large aggregates that encompass too many entities.

| Approach | Trade-off |
|----------|-----------|
| Small aggregates (1-3 entities) | Better concurrency, simpler transactions, harder cross-entity invariants |
| Large aggregates (4+ entities) | Easier invariant enforcement, worse concurrency, complex transactions |

**Default:** Start small. Merge aggregates only when invariants demand it.

### Cross-Aggregate References

Aggregates reference each other **by ID only**, never by direct object reference.

```
✅ Order { customerId: CustomerId }           // Reference by ID
❌ Order { customer: Customer }                // Direct reference (wrong)
```

### Invariant Placement

| Invariant scope | Where to enforce |
|----------------|------------------|
| Within a single aggregate | Aggregate root methods |
| Across aggregates (same context) | Domain service + eventual consistency |
| Across bounded contexts | Saga / process manager |

---

## Output Artifacts

This process produces a structured aggregate definitions artifact per bounded context. The concrete format, schema, and worked examples are defined in the corresponding ERI (eri-design-002-tactical-design).

---

## Rationale

### Why This Pattern Vocabulary?

1. **Industry standard** — These patterns are universally recognized in DDD literature
2. **Precise semantics** — Each pattern has clear rules that can be validated
3. **Technology-agnostic** — Applies regardless of Java, Node, Python, etc.
4. **Automatable** — Structured output enables downstream agents to consume it

### Why Structured YAML over Free-form Documents?

1. **Machine-readable** — DESIGN agents can parse and validate
2. **Composable** — Multiple aggregate definitions combine into a full context model
3. **Traceable** — Each aggregate links to bounded context, each entity to aggregate
4. **Transformable** — API Mapping agent can directly consume and transform

---

## Consequences

### Positive

- ✅ Common vocabulary across all teams
- ✅ Structured artifacts enable automation
- ✅ Explicit invariants prevent business rule violations in generated code
- ✅ Domain events enable future event-driven patterns
- ✅ Direct input for API contract generation

### Negative

- ⚠️ Requires domain understanding to define correct aggregates
- ⚠️ Over-engineering risk for simple CRUD domains
- ⚠️ Learning curve for teams unfamiliar with DDD tactical patterns

### Mitigations

1. **Entity-focused variant** — Simplified tactical design for CRUD-dominant contexts (only entities + attributes, no commands/events)
2. **ERIs** — Complete worked examples for common domains
3. **AI-assisted** — DESIGN agents suggest aggregate boundaries from requirements

---

## Implementation

### Reference Implementations

| Domain Example | ERI | Status |
|---------------|-----|--------|
| Customer Management (full tactical) | eri-design-002-tactical-design | ⏳ Planned |

### Relationship to Other Artifacts

```
bounded-context-map.yaml (ADR-DESIGN-001)
    │
    │ per bounded context
    ▼
aggregate-definitions.yaml (this ADR)
    │
    │ per aggregate → API resource
    ▼
api-mapping.yaml (ADR-DESIGN-003)
    │
    │ per API → OpenAPI spec
    ▼
domain-api-spec.yaml (CODE pipeline input)
```

---

## Validation

### Success Criteria

- [ ] Every entity belongs to exactly one aggregate
- [ ] Every aggregate has exactly one root entity
- [ ] All invariants are explicitly documented
- [ ] Commands and events follow naming conventions (imperative / past-tense)
- [ ] Value objects are immutable (no lifecycle states)
- [ ] Cross-aggregate references use IDs only

### Compliance Checks

- No entity appears in multiple aggregates
- Aggregate root `is_root: true` for exactly one entity per aggregate
- Event names end in past participle ("-Created", "-Updated", "-Deleted")
- Command names start with verb ("Create-", "Update-", "Delete-", "Process-")
- Value objects have no `identity` field

---

## References

### Related ADRs

- **ADR-DESIGN-001:** Domain Decomposition (upstream: provides bounded contexts)
- **ADR-DESIGN-003:** API Architecture Mapping (downstream: consumes aggregates)
- **ADR-CODE-009:** Service Architecture Patterns (how aggregates map to code structure)

### External Resources

- [Domain-Driven Design (Eric Evans, 2003)](https://www.domainlanguage.com/ddd/) — Chapters 5-7
- [Implementing Domain-Driven Design (Vaughn Vernon, 2013)](https://www.oreilly.com/library/view/implementing-domain-driven-design/9780133039900/) — Chapters 10-11
- [Effective Aggregate Design (Vaughn Vernon)](https://www.dddcommunity.org/library/vernon_2011/) — 3-part essay
- [Domain Events vs Integration Events](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/domain-events-design-implementation)

---

## Changelog

| Date | Version | Change | Author |
|------|---------|--------|--------|
| 2026-02-16 | 1.0 | Initial version | C4E Architecture Team |

---

**Decision Status:** ⏳ Proposed
**Review Date:** 2026-02
