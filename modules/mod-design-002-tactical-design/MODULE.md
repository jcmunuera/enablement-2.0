---
id: mod-design-002-tactical-design
name: "Tactical Design — Aggregate Definitions"
version: "1.0.0"
date: 2026-02-16
status: Active
domain: design

implements:
  capability: tactical-design
  feature: full-tactical

module_type: policy-driven
eri_reference: eri-design-002-tactical-design
adr_reference: adr-design-002-tactical-design-patterns
---

# mod-design-002: Tactical Design — Aggregate Definitions

## Overview

Policy-driven module that guides the LLM through tactical DDD analysis of each bounded context. Produces `aggregate-definitions.yaml` per context.

**Type:** Policy-driven
**Input:** `bounded-context-map.yaml` (from mod-design-001)
**Output:** `aggregate-definitions.yaml` per bounded context, per ERI-DESIGN-002 schema

---

## Module Structure

```
mod-design-002-tactical-design/
├── MODULE.md
├── policies/
│   └── tactical-design.md   # Pattern catalog, sizing rules, naming conventions
├── schemas/
│   └── aggregate-definitions.schema.yaml
├── examples/
│   └── customer-core-reference.yaml     # Customer aggregate reference (from ERI)
└── validation/
    ├── README.md
    └── aggregate-check.sh
```

---

## Execution

### Input

`bounded-context-map.yaml` from Phase 1.1 (strategic DDD).
The module processes each bounded context sequentially.

### Process

1. **Load policies** — Inject `policies/tactical-design.md`
2. **Load schema** — Include output schema
3. **Load example** — Include Customer aggregate as few-shot
4. **For each bounded context:**
   a. Extract context description, capabilities, ubiquitous language
   b. LLM defines aggregates, entities, value objects, commands, events, queries, invariants
   c. Validate output per context
5. **Collect** — Assemble all context outputs

### Output

Files: `{context-id}/aggregate-definitions.yaml` (one per bounded context)
Schema: Per ERI-DESIGN-002

---

## Options

| Option | Description | When to Use |
|--------|-------------|-------------|
| `full-tactical` (default) | All DDD building blocks | Complex contexts (3+ invariants) |
| `entity-focused` | Entities + basic CRUD only | Pure CRUD, simple contexts |

---

## Policies

The policies file contains:

1. **Aggregate sizing guidelines** — prefer small (1-3 entities)
2. **Pattern catalog** — entity, value object, command, event, query rules
3. **Naming conventions** — PascalCase entities, imperative commands, past-tense events
4. **Cross-aggregate reference rules** — by ID only, never direct reference
5. **Invariant definition rules** — human-readable, linked to error codes
6. **Event visibility rules** — internal vs cross-context
7. **Anti-patterns** — god aggregates, anemic entities, missing invariants

---

## Validation Rules

| Rule | Severity | Check |
|------|----------|-------|
| Valid YAML | ERROR | YAML parser succeeds |
| Single root per aggregate | ERROR | Exactly one is_root=true |
| Entity unique to aggregate | ERROR | No entity ID in multiple aggregates |
| VOs have no identity | ERROR | No identity field in value_objects |
| Command naming | ERROR | PascalCase, imperative verb prefix |
| Event naming | ERROR | PascalCase, past tense suffix |
| Command has error cases | ERROR | Non-empty error_cases (full-tactical) |
| Invariant linked | WARNING | Each invariant referenced by ≥1 error case |
| Context ref valid | ERROR | bounded_context exists in input |

---

## Related

- **ERI:** [eri-design-002-tactical-design](../../knowledge/ERIs/eri-design-002-tactical-design/)
- **ADR:** [adr-design-002-tactical-design-patterns](../../knowledge/ADRs/adr-design-002-tactical-design-patterns/)
- **Upstream:** mod-design-001-strategic-ddd (provides input)
- **Downstream:** mod-design-003-api-mapping, mod-design-004-bdd-scenarios
