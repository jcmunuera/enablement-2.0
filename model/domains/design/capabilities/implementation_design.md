# Capability: Implementation Design

## Overview

The Implementation Design capability produces structured design artifacts from user requirements, intended to feed into a Blueprint binding and ultimately into the CODE pipeline. It is a **foundational capability** — required for any design-to-code workflow.

The specific design methodology is selected via **variants**. The current (and default) variant is `ddd-bdd`.

## Type

- **Type:** Foundational
- **Phase Group:** design-methodology
- **Mandatory:** Yes (for design-to-code workflows)
- **Default Variant:** ddd-bdd

## Discovery

### Capability-Level Keywords

These activate the capability regardless of variant:

```yaml
keywords:
  - diseño para implementación
  - diseño para desarrollo
  - design for implementation
  - implementation design
  - diseña para código
  - genera el diseño
```

### Variant Selection

If the prompt contains variant-specific keywords, that variant is activated. Otherwise, the `default_variant` applies.

| Variant | Keywords | Status |
|---------|----------|--------|
| `ddd-bdd` | DDD, domain-driven, BDD, behavior driven, bounded context, aggregate | Active (default) |

---

## Variant: ddd-bdd

**Methodology:** Domain-Driven Design (strategic + tactical) + Behavior-Driven Development

**Principle:** Output is solution-target agnostic (DEC-059). No HTTP methods, no API tiers, no sync/async patterns. Implementation decisions are deferred to Blueprint binding.

### Features (sequential, by phase_order)

| Phase | Feature | Module | Output |
|-------|---------|--------|--------|
| 0 | `requirements-normalization` | mod-design-000 | `normalized-requirements.yaml` |
| 1 | `strategic-ddd` | mod-design-001 | `bounded-context-map.yaml` |
| 2 | `tactical-design` | mod-design-002 | `aggregate-definitions.yaml` (per context) |
| 3 | `behavior-validation` | mod-design-004 | `{context}.feature` + `scenario-tracing.yaml` |

### Phase 0: Requirements Normalization

- **Module:** mod-design-000-requirements-normalization
- **Type:** Policy-driven
- **Input:** Unstructured requirements (any language)
- **Output:** `normalized-requirements.yaml`
- **Key mechanism:** Interactive Enrichment Protocol (DEC-057) — agent asks user domain questions instead of guessing
- **Validation:** Structural checks + Gap Detection Rules G1-G6 (DEC-058)
- **Gap rules:** G1 (data sources), G2 (state machines), G3 (criticality), G4 (integration access), G5 (deferred to Blueprint), G6 (terminal states)

### Phase 1: Strategic DDD

- **Module:** mod-design-001-strategic-ddd
- **Type:** Policy-driven
- **Input:** `normalized-requirements.yaml`
- **Output:** `bounded-context-map.yaml`
- **ADR:** adr-design-001-domain-decomposition
- **ERI:** eri-design-001-strategic-ddd
- **Options:** full-strategic (default) | lightweight (simple domains)
- **Key elements:** Subdomains, bounded contexts, ubiquitous language, context relationships

### Phase 2: Tactical DDD

- **Module:** mod-design-002-tactical-design
- **Type:** Policy-driven
- **Input:** `bounded-context-map.yaml` + `normalized-requirements.yaml`
- **Output:** `aggregate-definitions.yaml` (one per bounded context)
- **ADR:** adr-design-002-tactical-design-patterns
- **ERI:** eri-design-002-tactical-design
- **Options:** full-tactical (default) | entity-focused (pure CRUD)
- **Key elements:** Aggregates, entities, value objects, commands, domain events, queries, invariants, error cases

### Phase 3: BDD Scenarios

- **Module:** mod-design-004-bdd-scenarios
- **Type:** Hybrid (LLM generates, module validates coverage)
- **Input:** `aggregate-definitions.yaml` + `bounded-context-map.yaml`
- **Output:** `{context}.feature` + `scenario-tracing.yaml`
- **ADR:** adr-design-004-behavior-validation
- **ERI:** eri-design-004-bdd-scenarios
- **Key elements:** Gherkin scenarios in business language, traceability to DDD elements

---

## Blueprint Integration

After this capability completes (phases 0-3), the output enters the **bind point** where a Blueprint is selected. The Blueprint defines methodology-specific bindings that map this capability's output to implementation patterns.

```
implementation-design.ddd-bdd output (agnostic)
  → Blueprint methodology_bindings.ddd-bdd
    → target-mapping capabilities (api-mapping, contracts, etc.)
      → CODE pipeline input
```

See `blueprints/README.md` for binding definitions.

---

## Policy Design Principles (DEC-056)

Module policies for this capability define ORGANIZATIONAL CONSTRAINTS, not methodology teaching:
- The LLM already knows DDD/BDD from training
- Policies capture: naming conventions, output schemas, sizing rules, classification criteria
- Policies explicitly state "You already understand DDD"

---

## Relationship to Other Capabilities

| Capability | Relationship |
|-----------|-------------|
| `api-mapping` | Downstream — consumes this capability's output via Blueprint |
| `contract-generation` | Downstream — consumes api-mapping output |
| `output-assembly` | Downstream — assembles all artifacts for CODE pipeline |

---

## References

| Asset | ID |
|-------|----|
| ADRs | adr-design-001, adr-design-002, adr-design-004 |
| ERIs | eri-design-001, eri-design-002, eri-design-004 |
| Modules | mod-design-000, mod-design-001, mod-design-002, mod-design-004 |
| Decisions | DEC-055, DEC-056, DEC-057, DEC-058, DEC-059, DEC-065 |
