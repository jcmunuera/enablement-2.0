---
id: eri-design-003-api-mapping
title: "ERI-DESIGN-003: API Architecture Mapping (DDD → Fusion API)"
sidebar_label: "API Mapping"
version: 1.0
date: 2026-02-16
updated: 2026-02-16
status: Active
author: "C4E Architecture Team"
domain: design
pattern: api-mapping
framework: agnostic
implements:
  - adr-design-003-api-architecture-mapping
tags:
  - api
  - ddd
  - fusion-api-model
  - mapping
  - openapi
  - rest
  - field-mapping
related:
  - eri-design-001-strategic-ddd
  - eri-design-002-tactical-design
  - eri-design-004-bdd-scenarios
derived_modules:
  - mod-design-005-tiered-api-mapping (planned)
  - mod-design-006-openapi-contracts (planned)
  - mod-design-007-field-mapping (planned)
---

# ERI-DESIGN-003: API Architecture Mapping (DDD → Fusion API)

## Overview

This ERI provides a complete reference implementation of the DDD-to-Fusion-API mapping as defined in ADR-DESIGN-003. It demonstrates how to map bounded contexts and aggregates to Fusion API tiers, produce API contracts, and define field-level transformations for System API integration.

**Implements:** ADR-DESIGN-003 (API Architecture Mapping)
**Status:** Active

**Input:** `bounded-context-map.yaml` (ERI-001) + `aggregate-definitions.yaml` (ERI-002)
**Reference:** Customer Core context → Domain API (REST) + System API (Parties mainframe)

---

## Output Formats

This ERI produces 4 artifacts:

| Artifact | Format | Purpose |
|----------|--------|---------|
| `api-mapping.yaml` | YAML | Tier assignment, resource mapping, dependencies |
| `field-mapping.json` | JSON | Domain ↔ System field transformations |
| `{api-name}-spec.yaml` | OpenAPI 3.0 | API contract per service |
| `prompt.md` | Markdown | Enriched context for CODE pipeline |

---

## Artifact 1: api-mapping.yaml

### Schema

```yaml
version: "1.0"
source_context: "{context-id}"
source_aggregate: "{aggregate-id}"
analysis_date: "YYYY-MM-DD"
api_type: rest|grpc|async|graphql        # Selected API type variant

# Tier assignment
api_tier: domain|system|composable|experience
api_name: "{service-name}-api"
api_version: "v1"
base_path: "/api/v1/{resources}"          # REST-specific; other types use their own addressing

# Resource mapping (REST variant)
resources:
  - name: "{ResourceName}"
    path: "/{resources}"
    aggregate: "{aggregate-id}"
    operations:
      - method: "{HTTP method or RPC name}"
        path: "{endpoint path}"
        command_or_query: "{command-id or query-id}"
        description: "{What this operation does}"
        pagination: true|false             # For collection queries
        idempotent: true|false

# Dependencies
system_api_dependencies:
  - system_api: "{system-api-name}"
    purpose: "{What backend system this integrates with}"
    field_mapping_ref: "{field-mapping-file}"

composable_api_participants:
  - composable_api: "{composable-api-name}"
    role: "{What role this API plays in the workflow}"
```

### Reference: Customer Core → api-mapping.yaml

```yaml
version: "1.0"
source_context: "customer-core"
source_aggregate: "customer"
analysis_date: "2026-02-16"
api_type: rest

api_tier: domain
api_name: "customer-management-api"
api_version: "v1"
base_path: "/api/v1/customers"

resources:
  - name: "Customer"
    path: "/customers"
    aggregate: "customer"
    operations:
      - method: "POST"
        path: "/customers"
        command_or_query: "create-customer"
        description: "Register a new customer"
        pagination: false
        idempotent: false

      - method: "GET"
        path: "/customers/{id}"
        command_or_query: "get-customer"
        description: "Retrieve customer by ID"
        pagination: false
        idempotent: true

      - method: "GET"
        path: "/customers"
        command_or_query: "list-customers"
        description: "List customers with filters and pagination"
        pagination: true
        idempotent: true

      - method: "PUT"
        path: "/customers/{id}"
        command_or_query: "update-customer"
        description: "Update customer personal data"
        pagination: false
        idempotent: true

      - method: "POST"
        path: "/customers/{id}/status"
        command_or_query: "change-status"
        description: "Change customer lifecycle status"
        pagination: false
        idempotent: false

      - method: "GET"
        path: "/customers/search"
        command_or_query: "search-customer-by-email"
        description: "Find customer by email address"
        pagination: false
        idempotent: true

system_api_dependencies:
  - system_api: "parties-system-api"
    purpose: "Core banking mainframe — customer data mastering (Parties system)"
    field_mapping_ref: "customer-parties-field-mapping.json"

composable_api_participants: []
```

---

## Artifact 2: field-mapping.json

### Schema

```json
{
  "version": "1.0",
  "domain_api": "{domain-api-name}",
  "system_api": "{system-api-name}",
  "system_description": "{What the backend system is}",
  "entity_mappings": [
    {
      "domain_entity": "{EntityName}",
      "system_entity": "{BackendEntityName}",
      "field_mappings": [
        {
          "domain_field": "{fieldName}",
          "domain_type": "{DomainType}",
          "system_field": "{BACKEND_FIELD}",
          "system_type": "{BackendType}",
          "transformation": "{transformation-type}",
          "direction": "bidirectional|domain-to-system|system-to-domain",
          "notes": "{Optional clarification}"
        }
      ]
    }
  ],
  "transformation_types": {
    "{transformation-type}": "{Description of the transformation logic}"
  }
}
```

### Supported Transformation Types

| Type | Description | Example |
|------|-------------|---------|
| `direct` | No transformation, same type | String → String |
| `uuid-to-string` | UUID ↔ String representation | UUID → "abc-123-..." |
| `enum-to-code` | Enum value ↔ legacy code | ACTIVE → "A" |
| `date-format` | Date format conversion | LocalDate → "YYYYMMDD" |
| `composite` | Multiple fields → single field or vice versa | firstName+lastName → FULL_NAME |
| `lookup` | Value lookup from mapping table | Country code → country name |
| `constant` | Fixed value (one direction only) | → "RETAIL" |

### Reference: customer-parties-field-mapping.json

```json
{
  "version": "1.0",
  "domain_api": "customer-management-api",
  "system_api": "parties-system-api",
  "system_description": "Core banking Parties mainframe system — customer master data",
  "entity_mappings": [
    {
      "domain_entity": "Customer",
      "system_entity": "PARTY",
      "field_mappings": [
        {
          "domain_field": "id",
          "domain_type": "UUID",
          "system_field": "PARTY_ID",
          "system_type": "String(20)",
          "transformation": "uuid-to-string",
          "direction": "bidirectional"
        },
        {
          "domain_field": "firstName",
          "domain_type": "String",
          "system_field": "FIRST_NM",
          "system_type": "String(50)",
          "transformation": "direct",
          "direction": "bidirectional"
        },
        {
          "domain_field": "lastName",
          "domain_type": "String",
          "system_field": "LAST_NM",
          "system_type": "String(50)",
          "transformation": "direct",
          "direction": "bidirectional"
        },
        {
          "domain_field": "email",
          "domain_type": "Email",
          "system_field": "EMAIL_ADDR",
          "system_type": "String(100)",
          "transformation": "direct",
          "direction": "bidirectional"
        },
        {
          "domain_field": "dateOfBirth",
          "domain_type": "LocalDate",
          "system_field": "BIRTH_DT",
          "system_type": "String(8)",
          "transformation": "date-format",
          "direction": "bidirectional",
          "notes": "Mainframe uses YYYYMMDD format"
        },
        {
          "domain_field": "status",
          "domain_type": "CustomerStatus",
          "system_field": "STATUS_CD",
          "system_type": "String(1)",
          "transformation": "enum-to-code",
          "direction": "bidirectional"
        },
        {
          "domain_field": "address.street",
          "domain_type": "String",
          "system_field": "ADDR_LINE_1",
          "system_type": "String(100)",
          "transformation": "direct",
          "direction": "bidirectional"
        },
        {
          "domain_field": "address.city",
          "domain_type": "String",
          "system_field": "CITY_NM",
          "system_type": "String(50)",
          "transformation": "direct",
          "direction": "bidirectional"
        },
        {
          "domain_field": "address.postalCode",
          "domain_type": "String",
          "system_field": "ZIP_CD",
          "system_type": "String(10)",
          "transformation": "direct",
          "direction": "bidirectional"
        },
        {
          "domain_field": "address.country",
          "domain_type": "String",
          "system_field": "CNTRY_CD",
          "system_type": "String(2)",
          "transformation": "direct",
          "direction": "bidirectional"
        },
        {
          "domain_field": null,
          "domain_type": null,
          "system_field": "PARTY_TYPE_CD",
          "system_type": "String(1)",
          "transformation": "constant",
          "direction": "domain-to-system",
          "notes": "Always 'I' (Individual) for retail banking customers"
        }
      ]
    }
  ],
  "transformation_types": {
    "uuid-to-string": "Convert UUID to/from string representation without dashes",
    "date-format": "Convert LocalDate (ISO) to/from mainframe YYYYMMDD string",
    "enum-to-code": "Map enum values to single-character legacy codes: ACTIVE↔A, DORMANT↔D, SUSPENDED↔S, CLOSED↔C",
    "direct": "No transformation, types are compatible",
    "constant": "Fixed value injected on write, ignored on read"
  }
}
```

---

## Artifact 3: OpenAPI Contract (REST variant)

For the REST variant, the mapping produces OpenAPI 3.0 specs. The reference example below shows the key structural elements. A complete spec would include all schemas, error models, and pagination structures per ADR-CODE-001.

### Reference: customer-management-api-spec.yaml (abbreviated)

```yaml
openapi: "3.0.3"
info:
  title: "Customer Management API"
  description: "Fusion Domain API for Customer Core bounded context"
  version: "1.0.0"
  contact:
    name: "Customer Squad"

servers:
  - url: "/api/v1"

paths:
  /customers:
    post:
      operationId: createCustomer
      summary: "Register a new customer"
      tags: ["Customer"]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/CreateCustomerRequest"
      responses:
        "201":
          description: "Customer created"
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/CustomerResponse"
        "409":
          description: "Duplicate email"
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/ErrorResponse"
    get:
      operationId: listCustomers
      summary: "List customers with pagination"
      tags: ["Customer"]
      parameters:
        - name: status
          in: query
          schema:
            $ref: "#/components/schemas/CustomerStatus"
        - name: page
          in: query
          schema:
            type: integer
            default: 0
        - name: size
          in: query
          schema:
            type: integer
            default: 20
      responses:
        "200":
          description: "Paginated customer list"

  /customers/{id}:
    get:
      operationId: getCustomer
      summary: "Retrieve customer by ID"
      tags: ["Customer"]
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
            format: uuid
      responses:
        "200":
          description: "Customer found"
        "404":
          description: "Customer not found"

  /customers/{id}/status:
    post:
      operationId: changeCustomerStatus
      summary: "Change customer lifecycle status"
      tags: ["Customer"]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/ChangeStatusRequest"
      responses:
        "200":
          description: "Status changed"
        "422":
          description: "Invalid status transition"

components:
  schemas:
    CustomerStatus:
      type: string
      enum: [ACTIVE, DORMANT, SUSPENDED, CLOSED]

    CreateCustomerRequest:
      type: object
      required: [firstName, lastName, email, dateOfBirth]
      properties:
        firstName:
          type: string
          maxLength: 100
        lastName:
          type: string
          maxLength: 100
        email:
          type: string
          format: email
        dateOfBirth:
          type: string
          format: date

    ChangeStatusRequest:
      type: object
      required: [newStatus, reason]
      properties:
        newStatus:
          $ref: "#/components/schemas/CustomerStatus"
        reason:
          type: string

    CustomerResponse:
      type: object
      properties:
        id:
          type: string
          format: uuid
        firstName:
          type: string
        lastName:
          type: string
        email:
          type: string
        status:
          $ref: "#/components/schemas/CustomerStatus"

    ErrorResponse:
      type: object
      properties:
        code:
          type: string
        message:
          type: string
        correlationId:
          type: string
```

---

## Artifact 4: prompt.md

The enriched prompt combines all design context into a single document consumable by the CODE pipeline. This is the **DESIGN → CODE boundary artifact**.

### Structure

```markdown
# {Service Name} — Development Prompt

## Functional Description
{Original requirements, rewritten with design context}

## Domain Model
{Summary of bounded context, aggregate, entities, value objects}

## API Contract
{Tier assignment, resource mapping, operations}
{Reference to OpenAPI spec file}

## System Integration
{System API dependencies, field mapping summary}
{Reference to field-mapping.json}

## Non-Functional Requirements
{Resilience, pagination, HATEOAS, security — derived from ADR-CODE-001}

## Constraints
{Invariants to enforce, status transitions, validation rules}
```

---

## Implementation Options

### Option A: REST Mapping ⭐ DEFAULT

**Status:** Active
**Produces:** OpenAPI 3.0 spec
**Governed by:** ADR-CODE-001 REST standards

### Option B: gRPC Mapping

**Status:** Planned
**Produces:** Protocol Buffer .proto file
**Governed by:** ADR-CODE-001 gRPC standards (when defined)

### Option C: AsyncAPI Mapping

**Status:** Planned
**Produces:** AsyncAPI 2.x/3.x spec
**Governed by:** ADR-CODE-001 AsyncAPI standards (when defined)

### Option D: GraphQL Mapping

**Status:** Evaluate
**Produces:** GraphQL SDL .graphql file

---

## Compliance Checklist

- [ ] Every aggregate root maps to exactly one primary API surface
- [ ] API tier assignment follows ADR-DESIGN-003 tier mapping rules
- [ ] All operations trace to a command or query from aggregate-definitions.yaml
- [ ] System API field mapping covers all entity attributes that exist in backend
- [ ] Transformation types are from the supported set
- [ ] Generated API contract is valid (OpenAPI linting, proto compilation, etc.)
- [ ] Enriched prompt includes all design sections
- [ ] Output is consumable by CODE pipeline

---

## Related Documentation

- **ADR:** [adr-design-003-api-architecture-mapping](../../ADRs/adr-design-003-api-architecture-mapping/)
- **Upstream ERI:** [eri-design-001-strategic-ddd](../eri-design-001-strategic-ddd/) — Context relationships
- **Upstream ERI:** [eri-design-002-tactical-design](../eri-design-002-tactical-design/) — Aggregate definitions
- **Downstream:** CODE pipeline (consumes prompt.md + specs + field-mapping)
- **Modules:** mod-design-005, mod-design-006, mod-design-007 (planned)
- **Capabilities:** `api-mapping`, `contract-generation`, `integration-mapping` in capability-index.yaml

---

## Changelog

| Date | Version | Change | Author |
|------|---------|--------|--------|
| 2026-02-16 | 1.0 | Initial version with REST variant reference | C4E Architecture Team |

---

## Annex: Implementation Constraints

> This annex defines rules that MUST be respected when creating Modules
> based on this ERI. Compliance is mandatory.

```yaml
eri_constraints:
  id: eri-design-003-api-mapping-constraints
  version: "1.0"
  eri_reference: eri-design-003-api-mapping
  adr_reference: adr-design-003-api-architecture-mapping

  implementation_options:
    type: disparate
    note: "API type variants produce different contract formats — separate modules per concern"
    options:
      - id: tiered-api-mapping
        name: "Tier + Resource Mapping"
        module: mod-design-005-tiered-api-mapping
        description: "Maps aggregates to Fusion tiers and API resources"

      - id: openapi-contracts
        name: "OpenAPI Contract Generation"
        module: mod-design-006-openapi-contracts
        description: "Generates OpenAPI 3.0 specs from mapping"
        applies_to_api_type: [rest]

      - id: field-mapping
        name: "Field Mapping Generation"
        module: mod-design-007-field-mapping
        description: "Generates domain↔system field transformations"

  structural_constraints:
    - id: aggregate-to-resource
      rule: "Every aggregate root MUST map to exactly one primary API resource"
      validation: "One resource entry per aggregate in api-mapping.yaml"
      severity: ERROR

    - id: operation-traces-to-command
      rule: "Every API operation MUST trace to a command or query from aggregate-definitions.yaml"
      validation: "command_or_query references valid command/query IDs"
      severity: ERROR

    - id: tier-follows-rules
      rule: "API tier assignment MUST follow ADR-DESIGN-003 tier mapping rules"
      validation: "core/supporting context → domain tier, generic → system tier"
      severity: ERROR

    - id: field-mapping-complete
      rule: "Field mapping MUST cover all entity attributes present in both domain and system models"
      validation: "Every domain entity attribute has a corresponding mapping entry"
      severity: ERROR

    - id: transformation-type-valid
      rule: "Transformation types MUST be from the supported set"
      validation: "Type is one of: direct, uuid-to-string, enum-to-code, date-format, composite, lookup, constant"
      severity: ERROR

    - id: contract-valid
      rule: "Generated API contract MUST be valid per its format specification"
      validation: "OpenAPI linting passes, proto compiles, AsyncAPI validates"
      severity: ERROR

    - id: output-valid-yaml-json
      rule: "api-mapping.yaml MUST be valid YAML, field-mapping.json MUST be valid JSON"
      validation: "Parsers accept both files without errors"
      severity: ERROR

  testing_constraints:
    - id: code-pipeline-consumable
      rule: "prompt.md + specs + field-mapping MUST be consumable by CODE pipeline"
      validation: "CODE pipeline discovery can process the output artifacts"
      severity: ERROR
```

---

**Status:** ✅ Active
**Domain:** design
**API Types:** REST (active) | gRPC (planned) | AsyncAPI (planned) | GraphQL (evaluate)
