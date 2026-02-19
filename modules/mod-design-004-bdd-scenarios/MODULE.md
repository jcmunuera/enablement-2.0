---
id: mod-design-004-bdd-scenarios
name: "BDD Scenarios — Behavior Validation"
version: "1.0.0"
date: 2026-02-16
status: Active
domain: design

implements:
  capability: behavior-validation
  feature: gherkin-scenarios

module_type: hybrid
eri_reference: eri-design-004-bdd-scenarios
adr_reference: adr-design-004-behavior-validation
---

# mod-design-004: BDD Scenarios — Behavior Validation

## Overview

Hybrid module that generates Gherkin scenarios from DDD artifacts and validates coverage completeness. The LLM writes scenarios; the module ensures every command, invariant, and query has coverage.

**Type:** Hybrid (LLM generates + module validates coverage)
**Input:** `aggregate-definitions.yaml` + `bounded-context-map.yaml`
**Output:** `{aggregate}.feature` + `scenario-tracing.yaml` per aggregate

---

## Module Structure

```
mod-design-004-bdd-scenarios/
├── MODULE.md
├── policies/
│   └── gherkin-generation.md    # Generation rules, category order, Gherkin standards
├── schemas/
│   └── scenario-tracing.schema.yaml
├── examples/
│   └── customer-reference.feature       # Customer scenarios (from ERI)
│   └── customer-tracing-reference.yaml  # Customer tracing (from ERI)
└── validation/
    ├── README.md
    ├── gherkin-syntax-check.sh    # Valid Gherkin
    ├── coverage-check.sh          # Every command/invariant/query covered
    └── tracing-check.sh           # Every scenario traced
```

---

## Execution

### Input

- `aggregate-definitions.yaml` — commands, queries, invariants, events
- `bounded-context-map.yaml` — ubiquitous language for Gherkin terminology

### Process

1. **Load policies** — Inject `policies/gherkin-generation.md` (generation rules, category order)
2. **Load example** — Include Customer .feature as few-shot
3. **For each aggregate:**
   a. LLM generates scenarios following category order (ERI-DESIGN-004 rules)
   b. LLM generates scenario-tracing.yaml with mappings
   c. Run coverage validation
   d. If gaps found → prompt LLM to fill missing scenarios
4. **Collect** — Assemble all aggregate outputs

### Generation Rules (from ERI)

| # | Category | Source | Min Count |
|---|----------|--------|-----------|
| 1 | Happy path per command | Each command | 1 per command |
| 2 | Happy path per query | Each query | 1 per query |
| 3 | Validation errors | Required inputs per command | 1 per command |
| 4 | Business rule violations | Each invariant | 1 per invariant |
| 5 | Not found | Entity-targeting operations | 1 per entity-targeting op |
| 6 | Integration | Each system API dependency | 1 per system API |
| 7 | Pagination | Each paginated query | 1 per paginated query |

### Output

Per aggregate:
- `{context-id}/{aggregate-id}.feature` — Gherkin scenarios
- `{context-id}/scenario-tracing.yaml` — Traceability mapping

---

## Coverage Validation (the "hybrid" part)

The module validates that LLM output meets minimum coverage:

```
coverage-check.sh:
  FOR each command in aggregate-definitions.yaml:
    ASSERT: ≥1 scenario with category=happy-path exercises this command
    ASSERT: ≥1 scenario with category=validation exercises this command
  FOR each query in aggregate-definitions.yaml:
    ASSERT: ≥1 scenario with category=happy-path exercises this query
  FOR each invariant in aggregate-definitions.yaml:
    ASSERT: ≥1 scenario with tests_invariant=this invariant
  FOR each system_api_dependency in api-mapping.yaml (if available):
    ASSERT: ≥1 scenario with category=integration
```

If coverage gaps are found, the module reports them and can trigger a second LLM pass to generate missing scenarios.

---

## Validation Rules

| Rule | Severity | Check |
|------|----------|-------|
| Valid Gherkin syntax | ERROR | gherkin-syntax-check.sh |
| Every command has happy-path | ERROR | coverage-check.sh |
| Every invariant has violation | ERROR | coverage-check.sh |
| Every query has happy-path | ERROR | coverage-check.sh |
| Error codes match aggregate | ERROR | Codes exist in error_cases |
| No tech details in scenarios | ERROR | No HTTP codes, no JSON |
| Tracing complete | ERROR | 1:1 scenario↔tracing entries |
| UL terms used | WARNING | Key nouns match ubiquitous_language |
| One behavior per scenario | ERROR | Single When step |
| Requirement coverage | WARNING | All capabilities traced |

---

## Related

- **ERI:** [eri-design-004-bdd-scenarios](../../knowledge/ERIs/eri-design-004-bdd-scenarios/)
- **ADR:** [adr-design-004-behavior-validation](../../knowledge/ADRs/adr-design-004-behavior-validation/)
- **Upstream:** mod-design-002 (aggregates), mod-design-001 (contexts, UL)
- **Downstream:** Acceptance test generation (CODE pipeline, future)
