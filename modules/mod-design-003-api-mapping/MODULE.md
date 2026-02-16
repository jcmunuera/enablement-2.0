---
id: mod-design-003-api-mapping
name: "API Architecture Mapping (DDD → Fusion API)"
version: "1.0.0"
date: 2026-02-16
status: Active
domain: design

implements:
  capability: api-mapping
  feature: tier-assignment

module_type: template-driven
eri_reference: eri-design-003-api-mapping
adr_reference: adr-design-003-api-architecture-mapping

# This module also serves contract-generation.openapi, integration-mapping.field-mapping,
# and output-assembly.prompt-enrichment — a single module covering the full target-mapping
# phase for soi-fusion-api-rest. When additional targets are added, these may split.
additional_capabilities:
  - contract-generation.openapi
  - integration-mapping.field-mapping
  - output-assembly.prompt-enrichment
---

# mod-design-003: API Architecture Mapping

## Overview

Template-driven module that maps DDD artifacts to Fusion API tiers, generates REST contracts, field mappings, and assembles the enriched prompt for the CODE pipeline.

**Type:** Template-driven (mechanically derivable from DDD artifacts)
**Input:** `bounded-context-map.yaml` + `aggregate-definitions.yaml` + solution target config
**Output:** `api-mapping.yaml` + `field-mapping.json` + OpenAPI spec + `prompt.md`

---

## Module Structure

```
mod-design-003-api-mapping/
├── MODULE.md
├── policies/
│   └── tier-assignment.md      # Fusion tier rules: when Domain vs System vs Composable
├── schemas/
│   ├── api-mapping.schema.yaml
│   └── field-mapping.schema.json
├── templates/
│   ├── api-mapping.yaml.tpl         # api-mapping.yaml generation template
│   ├── openapi-spec.yaml.tpl        # OpenAPI 3.0 skeleton
│   ├── field-mapping.json.tpl       # Field mapping structure
│   └── prompt.md.tpl                # Enriched prompt for CODE pipeline
└── validation/
    ├── README.md
    ├── api-mapping-check.sh
    ├── openapi-lint.sh
    └── field-mapping-check.sh
```

---

## Execution

### Sub-steps (sequential within Phase 3)

| Step | Input | Output | Type |
|------|-------|--------|------|
| 3.1 Tier Assignment | bounded-context-map.yaml | api-mapping.yaml (tier section) | Template |
| 3.2 Resource Mapping | aggregate-definitions.yaml | api-mapping.yaml (resources section) | Template |
| 3.3 Contract Generation | api-mapping.yaml + aggregates | {api-name}-spec.yaml (OpenAPI) | Template |
| 3.4 Field Mapping | api-mapping.yaml (system deps) | field-mapping.json | Policy (LLM) |
| 3.5 Prompt Assembly | All artifacts | prompt.md | Template |

### Step 3.1 — Tier Assignment (template-driven)

Mapping rules from ADR-DESIGN-003 Part 1:

| Context Characteristic | Fusion Tier |
|------------------------|-------------|
| Core subdomain, owns business logic | Domain API |
| Orchestrates multiple domains | Composable API |
| Wraps external/legacy system | System API |
| UI-facing aggregation | Experience API / BFF |

### Step 3.2 — Resource Mapping (template-driven)

DDD → REST projection from ADR-DESIGN-003 REST variant:

| DDD Concept | REST Projection |
|-------------|-----------------|
| Aggregate root | `/{aggregate-plural}` resource |
| Command (Create*) | `POST /{resources}` |
| Command (Update*) | `PUT /{resources}/{id}` |
| Command (Delete*) | `DELETE /{resources}/{id}` |
| Command (other) | `POST /{resources}/{id}/{action}` |
| Query (get by ID) | `GET /{resources}/{id}` |
| Query (list) | `GET /{resources}` with pagination |
| Query (search) | `GET /{resources}/search` |

### Step 3.3 — Contract Generation (template-driven)

Generates OpenAPI 3.0 from api-mapping + aggregate attributes:
- Entity attributes → schema properties
- Value objects → embedded schema objects
- Command inputs → request body schema
- Error codes → error response schemas
- Pagination queries → page/size parameters + page metadata

### Step 3.4 — Field Mapping (policy-driven, conditional)

Only executes when `system_api_dependencies` is non-empty in api-mapping.yaml.
LLM generates field mappings between domain model and system model using:
- Transformation types from ERI-DESIGN-003 (direct, uuid-to-string, enum-to-code, date-format, composite, lookup, constant)
- System model knowledge from requirements (mainframe field names, formats)

### Step 3.5 — Prompt Assembly (template-driven)

Assembles `prompt.md` from template, inserting:
- Functional description (from original requirements)
- Domain model summary (from bounded-context-map + aggregates)
- API contract reference (from OpenAPI spec)
- Integration context (from field-mapping)
- Constraints (from invariants)

This prompt.md is functionally equivalent to what an architect would write manually for the CODE pipeline.

---

## Options

| Option | Description | Status |
|--------|-------------|--------|
| REST (default) | OpenAPI 3.0 contracts | ✅ Active |
| gRPC | Protocol Buffer .proto | 🔜 Planned |
| AsyncAPI | AsyncAPI 2.x/3.x specs | 🔜 Planned |

---

## Validation Rules

| Rule | Severity | Check |
|------|----------|-------|
| api-mapping.yaml valid YAML | ERROR | YAML parser |
| Every aggregate has one resource | ERROR | 1:1 mapping |
| Every operation traces to command/query | ERROR | Valid refs |
| Tier assignment follows rules | ERROR | Per ADR-DESIGN-003 |
| OpenAPI spec valid | ERROR | openapi-lint.sh |
| field-mapping.json valid JSON | ERROR | JSON parser |
| Transformation types valid | ERROR | From supported set |
| prompt.md non-empty sections | ERROR | All sections populated |

---

## Related

- **ERI:** [eri-design-003-api-mapping](../../knowledge/ERIs/eri-design-003-api-mapping/)
- **ADR:** [adr-design-003-api-architecture-mapping](../../knowledge/ADRs/adr-design-003-api-architecture-mapping/)
- **Upstream:** mod-design-001 (contexts), mod-design-002 (aggregates)
- **Downstream:** CODE pipeline (consumes prompt.md + specs + field-mapping)
- **Solution Target:** soi-fusion-api-rest
