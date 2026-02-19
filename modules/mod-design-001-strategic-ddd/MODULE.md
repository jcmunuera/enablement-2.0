---
id: mod-design-001-strategic-ddd
name: "Strategic DDD — Domain Decomposition"
version: "1.0.0"
date: 2026-02-16
status: Active
domain: design

implements:
  capability: domain-analysis
  feature: strategic-ddd

module_type: policy-driven
eri_reference: eri-design-001-strategic-ddd
adr_reference: adr-design-001-domain-decomposition
---

# mod-design-001: Strategic DDD — Domain Decomposition

## Overview

Policy-driven module that guides the LLM through strategic DDD analysis of functional requirements. Produces `bounded-context-map.yaml`.

**Type:** Policy-driven (LLM generates within strict constraints)
**Input:** Functional requirements in natural language
**Output:** `bounded-context-map.yaml` per ERI-DESIGN-001 schema

---

## Module Structure

```
mod-design-001-strategic-ddd/
├── MODULE.md              # This file
├── policies/
│   └── strategic-ddd.md   # Rules, heuristics, constraints for the LLM
├── schemas/
│   └── bounded-context-map.schema.yaml  # Output schema (from ERI)
├── examples/
│   └── customer-reference.yaml          # Customer domain reference (from ERI)
└── validation/
    ├── README.md
    └── context-map-check.sh             # Validates output against schema + rules
```

---

## Execution

### Input

The module receives functional requirements as natural language text. This can be:
- A user prompt describing a business domain
- A requirements document (extracted text)
- Output from a requirements gathering phase

### Process

1. **Load policies** — Inject `policies/strategic-ddd.md` into LLM context
2. **Load schema** — Include `schemas/bounded-context-map.schema.yaml` as output format reference
3. **Load example** — Include `examples/customer-reference.yaml` as few-shot example
4. **Generate** — LLM analyzes requirements and produces bounded-context-map.yaml
5. **Validate** — Run `validation/context-map-check.sh` against output

### Output

File: `bounded-context-map.yaml`
Schema: Per ERI-DESIGN-001

---

## Options

| Option | Description | When to Use |
|--------|-------------|-------------|
| `full-strategic` (default) | Complete analysis with subdomains, contexts, language, capabilities, relationships | New domain, complex business area |
| `lightweight` | Contexts and relationships only | Simple domain, 1-2 contexts |

Option is selected based on input complexity or user preference.

---

## Policies

The policies file (`policies/strategic-ddd.md`) contains:

1. **Bounded context identification heuristics** — from ADR-DESIGN-001
2. **Subdomain classification rules** — core/supporting/generic criteria
3. **Context relationship selection guide** — when to use ACL vs Customer-Supplier vs Partnership
4. **Ubiquitous language extraction rules** — minimum 3 terms per context
5. **Output format constraints** — field naming, required fields, valid values
6. **Anti-patterns to avoid** — anemic contexts, god contexts, circular dependencies

---

## Validation Rules

| Rule | Severity | Check |
|------|----------|-------|
| Valid YAML | ERROR | YAML parser succeeds |
| Context IDs unique | ERROR | No duplicate IDs |
| At least 1 capability per context | ERROR | Non-empty capabilities array |
| At least 3 UL terms per context (full) | ERROR | ubiquitous_language.length >= 3 |
| Subdomain type valid | ERROR | type in [core, supporting, generic] |
| Relationship type valid | ERROR | type in approved set |
| Relationship refs valid | ERROR | upstream/downstream exist as context IDs |
| No duplicate capabilities | WARNING | No capability in multiple contexts |

---

## Related

- **ERI:** [eri-design-001-strategic-ddd](../../knowledge/ERIs/eri-design-001-strategic-ddd/)
- **ADR:** [adr-design-001-domain-decomposition](../../knowledge/ADRs/adr-design-001-domain-decomposition/)
- **Downstream:** mod-design-002-tactical-design (consumes output)
