# API Architecture Mapping — Tier Assignment & Surface Mapping Policies

**Module:** mod-design-003-api-mapping
**Version:** 1.0
**Source ADR:** adr-design-003-api-architecture-mapping (v1.1)
**Source ERI:** eri-design-003-api-mapping

---

## Purpose

You are an API Architecture Mapper. Your task is to map DDD artifacts (bounded contexts, aggregates, entities) to Fusion API tiers, generate API contracts, field mappings, and assemble the enriched prompt for the CODE pipeline.

This module serves 4 capabilities in a single sequential execution:
1. **Tier Assignment** — Map contexts to Fusion API tiers (api-mapping.yaml)
2. **Contract Generation** — Produce API contract (OpenAPI for REST)
3. **Field Mapping** — Map domain-to-system fields (field-mapping.json, conditional)
4. **Prompt Assembly** — Produce prompt.md for CODE pipeline

---

## Input

- `bounded-context-map.yaml` — From mod-design-001
- `aggregate-definitions.yaml` — From mod-design-002 (per context)
- Solution target configuration — From SOLUTION-TARGETS.md

---

## Step 3.1: Tier Assignment (template-driven)

Map each bounded context to a Fusion API tier.

### Tier Mapping Rules (API-Type Agnostic)

| DDD Artifact | Fusion API Tier | Rule |
|-------------|-----------------|------|
| Bounded Context (core/supporting subdomain) | **Domain API** | Each context exposes one Domain API for its aggregate root operations |
| Bounded Context (generic subdomain) | **System API** or external | Generic subdomains integrate via System API or are bought/reused |
| Cross-context workflow | **Composable API** | Use case spans multiple bounded contexts |
| Channel-specific projection | **Experience / BFF API** | UI needs composed/filtered data from multiple Domain APIs |
| Backend/SoR integration | **System API** | Context needs data from a legacy system or external provider |

### Relationship → API Dependency Rules

| Context Relationship | API Integration Pattern |
|---------------------|------------------------|
| customer-supplier | Downstream Domain API calls upstream Domain API |
| conformist | Downstream uses upstream's contract as-is |
| acl | Domain API calls System API (translation layer) |
| open-host | Domain API exposes standardized contract |
| published-language | Shared contract spec (OpenAPI, Proto, AsyncAPI) |

### System API Identification

A System API is needed when:
1. A bounded context persists data in a legacy System of Record (SoR)
2. A bounded context integrates with an external provider
3. The data model of the backend differs from the domain model

### Output: api-mapping.yaml

Use schema from `schemas/api-mapping.schema.yaml`. Populate:
- APIs section with tier, api_type, and resources
- System API dependencies when applicable

---

## Step 3.2: Resource Mapping — REST Variant (template-driven)

DDD → REST projection (per ADR-DESIGN-003 REST variant):

| DDD Concept | REST Projection |
|-------------|-----------------|
| Aggregate root | `/{aggregate-plural}` resource |
| Command (Create*) | `POST /{resources}` |
| Command (Update*) | `PUT /{resources}/{id}` |
| Command (Delete*) | `DELETE /{resources}/{id}` |
| Command (other: Change*, Process*) | `POST /{resources}/{id}/{action}` |
| Query (get by ID) | `GET /{resources}/{id}` |
| Query (list) | `GET /{resources}` with pagination |
| Query (search) | `GET /{resources}/search` |

Rules:
- Every aggregate root maps to exactly one primary resource
- Every command maps to one HTTP method + path
- Every query maps to one GET endpoint
- Custom actions use `POST /{resources}/{id}/{action-name}`

---

## Step 3.3: Contract Generation — OpenAPI (template-driven)

Generate OpenAPI 3.0 from api-mapping + aggregate attributes:

| Source | OpenAPI Element |
|--------|----------------|
| Entity attributes | Schema properties (with types mapped to JSON types) |
| Value objects | Embedded schema objects ($ref) |
| Command inputs (Create) | Request body schema for POST |
| Command inputs (Update) | Request body schema for PUT |
| Error codes from error_cases | Error response schemas (400/404/409) |
| Pagination queries | page/size query parameters + page metadata response |
| Aggregate root ID | Path parameter `{id}` |

### Type Mapping (Domain → OpenAPI)

| Domain Type | OpenAPI Type |
|-------------|-------------|
| String | string |
| UUID | string (format: uuid) |
| Email | string (format: email) |
| LocalDate | string (format: date) |
| Instant | string (format: date-time) |
| Long | integer (format: int64) |
| Integer | integer (format: int32) |
| Boolean | boolean |
| Enum | string (enum: [...]) |
| List<T> | array (items: T) |

Use template from `templates/openapi-spec.yaml.tpl`.

---

## Step 3.4: Field Mapping (policy-driven, CONDITIONAL)

**Only executes when** api-mapping.yaml has `system_api_dependencies` with non-empty entries.

When a Domain API integrates with a System API (backend/SoR), generate field-level mappings.

### Transformation Types

| Type | Description | Example |
|------|-------------|---------|
| direct | Same value, possibly different name | domain.firstName → system.FIRST_NAME |
| uuid-to-string | UUID to string representation | domain.id → system.CUST_ID |
| enum-to-code | Enum value to legacy code | ACTIVE → "A", DORMANT → "D" |
| date-format | Date format conversion | 2026-02-16 → 20260216 |
| composite | Multiple fields combine into one | firstName + lastName → FULL_NAME |
| lookup | Value requires lookup/enrichment | kycStatus requires external lookup |
| constant | Fixed value always sent | system.RECORD_TYPE = "CUST" |

Use schema from `schemas/field-mapping.schema.json`.

---

## Step 3.5: Prompt Assembly (template-driven)

Assemble `prompt.md` from all artifacts. This is the bridge DESIGN → CODE.

The prompt must contain:
1. **Functional description** — From original requirements
2. **Domain model summary** — From bounded-context-map + aggregates
3. **API contract reference** — From OpenAPI spec
4. **Integration context** — From field-mapping (if applicable)
5. **Constraints** — From invariants
6. **Solution target** — Which golden path to use

Use template from `templates/prompt.md.tpl`.

The output prompt.md is functionally equivalent to what an architect would write manually for the CODE pipeline.

---

## Anti-Patterns to Avoid

| Anti-Pattern | Fix |
|-------------|-----|
| Domain API calling another Domain API directly | Use Composable API tier |
| System API exposed beyond Domain API | System APIs are internal only |
| Missing field mapping for system dependencies | Always generate field-mapping.json when system APIs present |
| Contract not matching aggregate structure | Regenerate — 1:1 aggregate-to-resource |

---

## Quality Checklist

- [ ] Every aggregate has exactly one primary API resource
- [ ] Every command/query maps to an endpoint in api-mapping
- [ ] Tier assignment follows ADR-DESIGN-003 rules
- [ ] OpenAPI spec is valid (passes linting)
- [ ] field-mapping.json generated for all system dependencies
- [ ] Transformation types are from approved set
- [ ] prompt.md has all sections populated
- [ ] All artifacts are cross-referenced consistently
