---
id: design
name: "DESIGN"
version: 2.0
status: Active
created: 2025-12-12
updated: 2026-02-17
swarm_alignment: "DESIGN Swarm"
---

# Domain: DESIGN

## Purpose

Software design and architecture analysis. This domain produces design artifacts that can feed other domains (CODE, QA, GOVERNANCE) or serve as standalone deliverables (diagrams, documentation).

---

## Capabilities

| Capability | Description | Status | Variants |
|-----------|-------------|--------|----------|
| `implementation-design` | Design for code generation — produces structured artifacts that feed into a Blueprint and CODE pipeline | Active | `ddd-bdd` (default) |
| `architecture-diagramming` | C4 models, sequence diagrams, component diagrams | Planned | — |
| `application-manual` | Application documentation generation | Planned | — |

### implementation-design

Produces solution-target agnostic design artifacts from user requirements. The methodology determines what artifacts are produced and how they map to implementation.

**Current variant: `ddd-bdd`**
- Methodology: Domain-Driven Design (strategic + tactical) + Behavior-Driven Development
- Phases: Requirements Normalization → Strategic DDD → Tactical DDD → BDD Scenarios
- Output: normalized-requirements, bounded-context-map, aggregate-definitions, BDD scenarios
- Modules: mod-design-000 through mod-design-004
- Knowledge: ADR-DESIGN-001 through 004, ERI-DESIGN-001 through 004

Other methodologies may be added as variants in the future without changing the domain model.

---

## Discovery Guidance

### When is a request DESIGN domain?

| Signal | Examples |
|--------|----------|
| **Output is design artifact** | Domain model, architecture diagram, specs, ADRs |
| **Action is design/analysis** | Design, architect, model, decompose, analyze domain |
| **Goal is implementation input** | "Design for development", "prepare for code generation" |
| **SDLC phase is design** | Pre-implementation, architectural planning |

### NOT DESIGN Domain

| Request | Actual Domain | Reason |
|---------|--------------|--------|
| "Genera un microservicio" | CODE | Output is code, not design |
| "Implementa la arquitectura hexagonal" | CODE | Action is implement |
| "Analiza si cumple estándares" | QA | Action is validate |

### Capability Discovery (from prompt)

Discovery follows the same pattern as CODE — intent from the user prompt activates capabilities:

| User intent | Capability | Variant |
|------------|------------|---------|
| "Diseña para implementación", "genera el diseño para desarrollo" | `implementation-design` | `ddd-bdd` (default) |
| "Usa DDD", "aplica domain-driven design" | `implementation-design` | `ddd-bdd` (explicit) |
| "Genera diagrama C4" | `architecture-diagramming` | — (future) |
| "Genera manual de la aplicación" | `application-manual` | — (future) |

If no methodology is specified for `implementation-design`, the default variant applies.

---

## Module Types (DEC-052)

DESIGN modules come in three types:

| Type | Characteristics | Examples |
|------|----------------|----------|
| **Policy-driven** | LLM generates content within organizational constraints. Module provides: policies, schemas, examples, validation. | Strategic DDD, Tactical DDD |
| **Template-driven** | Deterministic output from input. Module provides: templates, transform rules, validation. | API mapping, contract generation |
| **Hybrid** | LLM generates, module validates coverage/completeness. | BDD scenarios |

---

## Blueprint Integration

Design capabilities that produce implementation input (like `implementation-design`) integrate with Blueprints for the design-to-code bridge:

```
User Requirements
  → DESIGN capability (e.g., implementation-design.ddd-bdd)
    → Solution-target agnostic artifacts
      → BIND POINT: Blueprint selection
        → Blueprint applies methodology-specific bindings
          → CODE pipeline input (prompt.md + contracts)
```

Blueprint bindings are methodology-specific: each variant of `implementation-design` defines its own mapping to implementation patterns. See `blueprints/README.md`.

---

## Knowledge Assets

| Asset Type | Naming Pattern | Example |
|-----------|---------------|---------|
| ADR | `adr-design-{NNN}-{topic}` | `adr-design-001-domain-decomposition` |
| ERI | `eri-design-{NNN}-{topic}` | `eri-design-001-strategic-ddd` |
| Module | `mod-design-{NNN}-{topic}` | `mod-design-000-requirements-normalization` |

---

## Key Design Principles

1. **Methodology-agnostic domain model** (DEC-065): The domain supports multiple design methodologies as capability variants. DDD/BDD is one variant, not the domain.

2. **Solution-target agnostic output** (DEC-059): Design artifacts contain no implementation decisions (no HTTP methods, no API tiers, no sync/async patterns).

3. **Policies as organizational constraints** (DEC-056): Module policies define output format and organizational conventions, not methodology teaching. The LLM already knows the methodologies.

4. **Interactive enrichment** (DEC-057): Design capabilities that need domain knowledge from the user implement enrichment protocols with Gap Detection Rules.
