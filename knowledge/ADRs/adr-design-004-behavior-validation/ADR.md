---
id: adr-design-004-behavior-validation
title: "ADR-DESIGN-004: Behavior Validation via BDD"
sidebar_label: Behavior Validation (BDD)
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
  - bdd
  - gherkin
  - behavior
  - validation
  - acceptance-criteria
  - testing
  - given-when-then
related:
  - adr-design-001-domain-decomposition
  - adr-design-002-tactical-design-patterns
  - adr-design-003-api-architecture-mapping
implemented_by:
  - eri-design-004-bdd-scenarios (planned)
---

# ADR-DESIGN-004: Behavior Validation via BDD

**Status:** Proposed
**Date:** 2026-02-16
**Author:** C4E Architecture Team

---

## Context

ADRs DESIGN-001 through 003 produce a complete design: bounded contexts, aggregates, and API contracts. However, there is no systematic validation that the design **actually fulfills the original functional requirements**.

### Problem Statement

We need a method to:
- ✅ Validate that every functional requirement maps to a concrete behavior in the design
- ✅ Express expected behavior in a format understandable by business and technical stakeholders
- ✅ Generate acceptance criteria that can later become automated tests
- ✅ Identify gaps where requirements are not covered by the design
- ✅ Use domain language (ubiquitous language) consistently in behavior descriptions

---

## Decision

We adopt **Behavior-Driven Development (BDD) with Gherkin syntax** as the standard for validating design completeness against functional requirements. BDD scenarios are generated from the combination of requirements + DDD artifacts + API contracts.

### Scenario Generation Rules

Scenarios are generated per aggregate, covering:

| Category | Template | Priority |
|----------|----------|----------|
| **Happy path** | Given valid preconditions, When command executes, Then expected outcome | Always |
| **Validation errors** | Given invalid input, When command executes, Then error returned | Always |
| **Not found** | Given entity doesn't exist, When queried/modified, Then 404 error | Always |
| **Business rules** | Given precondition violates invariant, When command executes, Then rule enforced | Per invariant |
| **Integration** | Given system API dependency, When called, Then data transformed correctly | When System API present |
| **Edge cases** | Given boundary conditions, When command executes, Then handled correctly | When identified |

### Gherkin Standards

**Language:** Scenarios use the ubiquitous language defined in the bounded context (ADR-DESIGN-001).

**Naming convention:**
```gherkin
Feature: {Aggregate Name} Management
  As a {role/system}
  I want to {capability}
  So that {business value}
```

**Scenario structure:**
```gherkin
Scenario: {Concise description of behavior}
  Given {precondition using domain language}
  And {additional precondition if needed}
  When {action/command in imperative form}
  Then {expected outcome}
  And {additional assertion if needed}
```

**Rules:**
1. Given/When/Then MUST use ubiquitous language from the bounded context
2. Scenarios MUST reference commands and queries from ADR-DESIGN-002
3. Error scenarios MUST reference invariants from ADR-DESIGN-002
4. One behavior per scenario (no multi-action scenarios)
5. Scenarios are technology-agnostic (no HTTP codes, no JSON — those are in API specs)

### Scenario-to-API Traceability

Each scenario traces to:
- The functional requirement it validates
- The command or query it exercises
- The aggregate invariant it checks (for error cases)
- The API endpoint that will implement it (from ADR-DESIGN-003)

The concrete traceability format is defined in the corresponding ERI.

---

## Output Artifacts

This process produces Gherkin feature files per aggregate, covering happy paths, validation errors, business rule enforcement, not-found cases, and integration scenarios. The concrete format, scenario templates, and worked examples are defined in the corresponding ERI (eri-design-004-bdd-scenarios).

---

## Rationale

### Why BDD at Design Time (not just Test Time)?

1. **Validation before coding** — Catch design gaps before writing a single line of code
2. **Shared understanding** — Business and technical stakeholders agree on behavior
3. **Traceability** — Every requirement has a corresponding scenario
4. **Test generation** — Scenarios become acceptance tests in the CODE pipeline

### Why Gherkin?

1. **Human-readable** — Business stakeholders can review
2. **Machine-parseable** — Tools can process (Cucumber, Behave, etc.)
3. **Domain language enforced** — Given/When/Then naturally use ubiquitous language
4. **Industry standard** — Widely understood, extensive tooling

### Why Technology-Agnostic Scenarios?

Scenarios describe **behavior**, not implementation. "A new customer is created" not "Returns HTTP 201 with Location header". The API-level details are in the OpenAPI specs (ADR-DESIGN-003).

---

## Consequences

### Positive

- ✅ Design validated against requirements before coding starts
- ✅ Shared language between business and technical teams
- ✅ Generated scenarios become acceptance test specifications
- ✅ Gaps in design are visible (requirement without scenario = missing behavior)
- ✅ Invariants are tested by design, not as afterthought

### Negative

- ⚠️ Scenario generation requires both domain knowledge and requirement understanding
- ⚠️ Not all behaviors are easily expressible in Given/When/Then
- ⚠️ Scenarios may need manual refinement for complex business rules

### Mitigations

1. **AI-assisted generation** — DESIGN agent generates initial scenarios from commands + invariants
2. **Human review** — Generated scenarios reviewed by domain experts
3. **Iterative** — Scenarios refined as understanding deepens

---

## Validation

### Success Criteria

- [ ] Every command has at least one happy-path scenario
- [ ] Every invariant has at least one error scenario
- [ ] Scenarios use ubiquitous language from bounded context
- [ ] No scenario references technology-specific details
- [ ] Traceability complete: requirement → scenario → command → API endpoint

---

## References

### Related ADRs

- **ADR-DESIGN-001:** Domain Decomposition (provides ubiquitous language)
- **ADR-DESIGN-002:** Tactical Design (provides commands, invariants, events)
- **ADR-DESIGN-003:** API Mapping (provides endpoint tracing)

### External Resources

- [BDD in Action (John Ferguson Smart)](https://www.manning.com/books/bdd-in-action)
- [Gherkin Reference](https://cucumber.io/docs/gherkin/reference/)
- [Specification by Example (Gojko Adzic)](https://gojko.net/books/specification-by-example/)

---

## Changelog

| Date | Version | Change | Author |
|------|---------|--------|--------|
| 2026-02-16 | 1.0 | Initial version | C4E Architecture Team |

---

**Decision Status:** ⏳ Proposed
**Review Date:** 2026-02
