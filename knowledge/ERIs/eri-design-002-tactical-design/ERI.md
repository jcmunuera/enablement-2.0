---
id: eri-design-002-tactical-design
title: "ERI-DESIGN-002: Tactical Design — Aggregate Definitions"
sidebar_label: "Tactical Design"
version: 1.0
date: 2026-02-16
updated: 2026-02-16
status: Active
author: "C4E Architecture Team"
domain: design
pattern: tactical-ddd
framework: agnostic
implements:
  - adr-design-002-tactical-design-patterns
tags:
  - ddd
  - tactical-design
  - aggregate
  - entity
  - value-object
  - domain-event
  - command
related:
  - eri-design-001-strategic-ddd
  - eri-design-003-api-mapping
  - eri-design-004-bdd-scenarios
derived_modules:
  - mod-design-003-tactical-full (planned)
  - mod-design-004-tactical-entity (planned)
---

# ERI-DESIGN-002: Tactical Design — Aggregate Definitions

## Overview

This ERI provides a complete reference implementation of DDD Tactical Design as defined in ADR-DESIGN-002. It demonstrates how to define the internal structure of a bounded context: aggregates, entities, value objects, invariants, commands, domain events, and queries, producing the `aggregate-definitions.yaml` artifact.

**Implements:** ADR-DESIGN-002 (Tactical Design Patterns)
**Status:** Active

**Input:** `bounded-context-map.yaml` from ERI-DESIGN-001
**Reference Context:** `customer-core` from the Retail Banking reference domain.

---

## Output Format

### Artifact: aggregate-definitions.yaml

| Component | Format | Description |
|-----------|--------|-------------|
| **Output file** | YAML | Structured aggregate model per bounded context |
| **Schema version** | 1.0 | Versioned for forward compatibility |
| **Consumers** | ERI-DESIGN-003 (API mapping), ERI-DESIGN-004 (BDD scenarios) | Downstream design agents |

### Schema

```yaml
version: "1.0"
bounded_context: "{context-id}"          # From bounded-context-map.yaml
context_name: "{Context Name}"
analysis_date: "YYYY-MM-DD"

aggregates:
  - id: "{aggregate-id}"                  # kebab-case, unique within context
    name: "{AggregateName}"                # PascalCase
    root_entity: "{entity-id}"             # References the root entity below
    description: "{What this aggregate represents and owns}"

    entities:
      - id: "{entity-id}"                 # kebab-case, unique within aggregate
        name: "{EntityName}"               # PascalCase
        is_root: true|false
        description: "{What this entity represents}"
        identity:
          field: "{fieldName}"             # e.g., "id"
          type: "UUID|Long|String"
          generation: "auto|external|composite"
        attributes:
          - name: "{attributeName}"        # camelCase
            type: "{type}"                 # Domain type, not implementation type
            required: true|false
            description: "{What this attribute represents}"
            constraints: "{Optional validation rules}"

    value_objects:
      - id: "{vo-id}"                     # kebab-case
        name: "{ValueObjectName}"          # PascalCase
        description: "{What this value object represents}"
        attributes:
          - name: "{attributeName}"
            type: "{type}"
            constraints: "{Optional validation rules}"
        used_by:
          - "{entity-id}"                  # Which entities use this VO

    invariants:
      - id: "{invariant-id}"              # kebab-case
        rule: "{Human-readable business rule}"
        scope: "aggregate|entity"
        enforced_by: "{aggregate-root|domain-service}"
        error: "{Error message when violated}"

    commands:
      - id: "{command-id}"                # kebab-case
        name: "{CommandName}"              # PascalCase, imperative verb
        description: "{What this command does}"
        input:
          - name: "{fieldName}"
            type: "{type}"
            required: true|false
        produces_event: "{event-id}"
        error_cases:
          - code: "{ERROR_CODE}"
            description: "{When this error occurs}"
            invariant: "{invariant-id}"    # Optional: links to invariant

    domain_events:
      - id: "{event-id}"                  # kebab-case
        name: "{EventName}"                # PascalCase, past tense
        description: "{What happened}"
        payload:
          - name: "{fieldName}"
            type: "{type}"
        triggered_by: "{command-id}"
        visibility: internal|cross-context  # Who should see this event

    queries:
      - id: "{query-id}"                  # kebab-case
        name: "{QueryName}"                # PascalCase
        description: "{What information is requested}"
        returns: "{entity-id|projection}"
        filters:
          - name: "{filterName}"
            type: "{type}"
            required: true|false
        pagination: true|false
```

### Field Rules

| Field | Rule |
|-------|------|
| `aggregate.id` | Kebab-case, unique within bounded context |
| `entity.name` | PascalCase, noun |
| `entity.is_root` | Exactly ONE entity per aggregate must be `true` |
| `value_object` | No `identity` field (immutable, no ID) |
| `command.name` | PascalCase, starts with imperative verb (Create, Update, Delete, Process...) |
| `domain_event.name` | PascalCase, past tense (CustomerCreated, StatusChanged...) |
| `invariant.rule` | Human-readable, starts with "A/An/The {entity}..." |
| `error_cases.code` | UPPER_SNAKE_CASE |

---

## Reference Implementation: Customer Core Context

### Input

Bounded context `customer-core` from ERI-DESIGN-001 reference, with capabilities:
- Customer registration and onboarding
- Customer data maintenance (CRUD)
- Customer status lifecycle management
- Customer search and retrieval

### Output: aggregate-definitions.yaml

```yaml
version: "1.0"
bounded_context: "customer-core"
context_name: "Customer Core"
analysis_date: "2026-02-16"

aggregates:
  - id: "customer"
    name: "Customer"
    root_entity: "customer-entity"
    description: "Represents a banking customer with their personal data, contact information, and lifecycle status. Owns the customer identity and enforces status transition rules."

    entities:
      - id: "customer-entity"
        name: "Customer"
        is_root: true
        description: "The aggregate root. Represents an individual or entity with a banking relationship."
        identity:
          field: "id"
          type: "UUID"
          generation: "auto"
        attributes:
          - name: "firstName"
            type: "String"
            required: true
            description: "Customer's legal first name"
            constraints: "1-100 characters"
          - name: "lastName"
            type: "String"
            required: true
            description: "Customer's legal last name"
            constraints: "1-100 characters"
          - name: "email"
            type: "Email"
            required: true
            description: "Customer's primary email address, used for notifications and as unique identifier"
          - name: "dateOfBirth"
            type: "LocalDate"
            required: true
            description: "Customer's date of birth for age verification and regulatory compliance"
          - name: "status"
            type: "CustomerStatus"
            required: true
            description: "Current lifecycle state of the customer"
          - name: "kycStatus"
            type: "KycStatus"
            required: true
            description: "Current KYC verification status"
          - name: "createdAt"
            type: "Instant"
            required: true
            description: "Timestamp of customer creation"
          - name: "updatedAt"
            type: "Instant"
            required: true
            description: "Timestamp of last modification"

    value_objects:
      - id: "customer-status"
        name: "CustomerStatus"
        description: "Enumeration of valid customer lifecycle states"
        attributes:
          - name: "value"
            type: "Enum"
            constraints: "ACTIVE, DORMANT, SUSPENDED, CLOSED"
        used_by:
          - "customer-entity"

      - id: "kyc-status"
        name: "KycStatus"
        description: "Enumeration of KYC verification states"
        attributes:
          - name: "value"
            type: "Enum"
            constraints: "PENDING, VERIFIED, REJECTED, EXPIRED"
        used_by:
          - "customer-entity"

      - id: "address"
        name: "Address"
        description: "A postal address associated with the customer"
        attributes:
          - name: "street"
            type: "String"
            constraints: "1-200 characters"
          - name: "city"
            type: "String"
            constraints: "1-100 characters"
          - name: "postalCode"
            type: "String"
            constraints: "Pattern depends on country"
          - name: "country"
            type: "String"
            constraints: "ISO 3166-1 alpha-2"
        used_by:
          - "customer-entity"

      - id: "phone-number"
        name: "PhoneNumber"
        description: "A phone number in E.164 format"
        attributes:
          - name: "number"
            type: "String"
            constraints: "E.164 format (+XXXXXXXXXXX)"
          - name: "type"
            type: "Enum"
            constraints: "MOBILE, HOME, WORK"
        used_by:
          - "customer-entity"

    invariants:
      - id: "unique-email"
        rule: "A customer's email address must be unique across all customers"
        scope: "aggregate"
        enforced_by: "aggregate-root"
        error: "A customer with this email already exists"

      - id: "valid-status-transition"
        rule: "Customer status transitions must follow the allowed state machine: ACTIVE→DORMANT, ACTIVE→SUSPENDED, ACTIVE→CLOSED, DORMANT→ACTIVE, DORMANT→CLOSED, SUSPENDED→ACTIVE, SUSPENDED→CLOSED"
        scope: "aggregate"
        enforced_by: "aggregate-root"
        error: "Invalid status transition from {current} to {target}"

      - id: "kyc-required-for-active"
        rule: "A customer cannot transition to ACTIVE status unless KYC is VERIFIED"
        scope: "aggregate"
        enforced_by: "aggregate-root"
        error: "Customer cannot be activated without verified KYC"

      - id: "minimum-age"
        rule: "A customer must be at least 18 years old at the time of registration"
        scope: "entity"
        enforced_by: "aggregate-root"
        error: "Customer must be at least 18 years old"

    commands:
      - id: "create-customer"
        name: "CreateCustomer"
        description: "Register a new customer in the system with initial ACTIVE status (if KYC verified) or PENDING status"
        input:
          - name: "firstName"
            type: "String"
            required: true
          - name: "lastName"
            type: "String"
            required: true
          - name: "email"
            type: "Email"
            required: true
          - name: "dateOfBirth"
            type: "LocalDate"
            required: true
          - name: "address"
            type: "Address"
            required: false
          - name: "phone"
            type: "PhoneNumber"
            required: false
        produces_event: "customer-created"
        error_cases:
          - code: "DUPLICATE_EMAIL"
            description: "A customer with this email already exists"
            invariant: "unique-email"
          - code: "UNDERAGE"
            description: "Customer is under 18 years old"
            invariant: "minimum-age"
          - code: "INVALID_INPUT"
            description: "Required fields missing or malformed"

      - id: "update-customer"
        name: "UpdateCustomer"
        description: "Update customer personal data (name, address, phone)"
        input:
          - name: "customerId"
            type: "UUID"
            required: true
          - name: "firstName"
            type: "String"
            required: false
          - name: "lastName"
            type: "String"
            required: false
          - name: "address"
            type: "Address"
            required: false
          - name: "phone"
            type: "PhoneNumber"
            required: false
        produces_event: "customer-updated"
        error_cases:
          - code: "CUSTOMER_NOT_FOUND"
            description: "No customer exists with the given ID"

      - id: "change-status"
        name: "ChangeCustomerStatus"
        description: "Transition customer to a new lifecycle status"
        input:
          - name: "customerId"
            type: "UUID"
            required: true
          - name: "newStatus"
            type: "CustomerStatus"
            required: true
          - name: "reason"
            type: "String"
            required: true
        produces_event: "customer-status-changed"
        error_cases:
          - code: "CUSTOMER_NOT_FOUND"
            description: "No customer exists with the given ID"
          - code: "INVALID_TRANSITION"
            description: "The requested status transition is not allowed"
            invariant: "valid-status-transition"
          - code: "KYC_NOT_VERIFIED"
            description: "Cannot activate customer without verified KYC"
            invariant: "kyc-required-for-active"

    domain_events:
      - id: "customer-created"
        name: "CustomerCreated"
        description: "A new customer has been registered in the system"
        payload:
          - name: "customerId"
            type: "UUID"
          - name: "email"
            type: "Email"
          - name: "firstName"
            type: "String"
          - name: "lastName"
            type: "String"
          - name: "status"
            type: "CustomerStatus"
          - name: "createdAt"
            type: "Instant"
        triggered_by: "create-customer"
        visibility: cross-context

      - id: "customer-updated"
        name: "CustomerUpdated"
        description: "Customer personal data has been modified"
        payload:
          - name: "customerId"
            type: "UUID"
          - name: "updatedFields"
            type: "List<String>"
          - name: "updatedAt"
            type: "Instant"
        triggered_by: "update-customer"
        visibility: internal

      - id: "customer-status-changed"
        name: "CustomerStatusChanged"
        description: "Customer lifecycle status has transitioned"
        payload:
          - name: "customerId"
            type: "UUID"
          - name: "previousStatus"
            type: "CustomerStatus"
          - name: "newStatus"
            type: "CustomerStatus"
          - name: "reason"
            type: "String"
          - name: "changedAt"
            type: "Instant"
        triggered_by: "change-status"
        visibility: cross-context

    queries:
      - id: "get-customer"
        name: "GetCustomer"
        description: "Retrieve a customer by their unique identifier"
        returns: "customer-entity"
        filters:
          - name: "customerId"
            type: "UUID"
            required: true
        pagination: false

      - id: "list-customers"
        name: "ListCustomers"
        description: "Retrieve a paginated list of customers with optional filters"
        returns: "customer-entity"
        filters:
          - name: "status"
            type: "CustomerStatus"
            required: false
          - name: "email"
            type: "String"
            required: false
          - name: "lastName"
            type: "String"
            required: false
        pagination: true

      - id: "search-customer-by-email"
        name: "SearchCustomerByEmail"
        description: "Find a customer by their unique email address"
        returns: "customer-entity"
        filters:
          - name: "email"
            type: "Email"
            required: true
        pagination: false
```

---

## Implementation Options

### Option A: Full Tactical Design ⭐ DEFAULT

**Description:** Complete tactical analysis with all DDD building blocks: aggregates, entities, value objects, invariants, commands, domain events, and queries.

**Recommended When:**
- Bounded context has complex business rules (3+ invariants)
- Domain events are needed for cross-context communication
- CQRS or event sourcing may be considered
- Multiple commands with distinct business logic

### Option B: Entity-Focused Design

**Description:** Simplified tactical analysis with only entities, attributes, and basic CRUD commands. No explicit invariants, domain events, or value objects.

**Recommended When:**
- Pure CRUD context with minimal business rules (0-2 invariants)
- No cross-context event communication needed
- Simple data management with standard operations

**Reduced output:** Only `entities`, `commands` (CRUD only), and `queries` sections. No `value_objects`, `invariants`, or `domain_events`.

---

## Compliance Checklist

- [ ] Every aggregate has exactly one root entity (`is_root: true`)
- [ ] No entity appears in more than one aggregate
- [ ] Value objects have no `identity` field
- [ ] Command names are PascalCase and start with imperative verb
- [ ] Event names are PascalCase and use past tense
- [ ] Every command has at least one error case
- [ ] Every invariant is referenced by at least one command error case
- [ ] Cross-aggregate references use IDs only (no embedded entities from other aggregates)
- [ ] `bounded_context` references a valid ID from bounded-context-map.yaml
- [ ] Output YAML is valid and parseable

---

## Related Documentation

- **ADR:** [adr-design-002-tactical-design-patterns](../../ADRs/adr-design-002-tactical-design-patterns/)
- **Upstream ERI:** [eri-design-001-strategic-ddd](../eri-design-001-strategic-ddd/) — Provides bounded context input
- **Downstream ERI:** [eri-design-003-api-mapping](../eri-design-003-api-mapping/) — Consumes aggregates
- **Downstream ERI:** [eri-design-004-bdd-scenarios](../eri-design-004-bdd-scenarios/) — Consumes commands/invariants
- **Module:** mod-design-003-tactical-full (planned)
- **Capability:** `tactical-design` / `full-tactical` in capability-index.yaml

---

## Changelog

| Date | Version | Change | Author |
|------|---------|--------|--------|
| 2026-02-16 | 1.0 | Initial version with Customer Core reference | C4E Architecture Team |

---

## Annex: Implementation Constraints

> This annex defines rules that MUST be respected when creating Modules
> based on this ERI. Compliance is mandatory.

```yaml
eri_constraints:
  id: eri-design-002-tactical-design-constraints
  version: "1.0"
  eri_reference: eri-design-002-tactical-design
  adr_reference: adr-design-002-tactical-design-patterns

  implementation_options:
    default: full-tactical
    options:
      - id: full-tactical
        name: "Full Tactical Design"
        status: default
        recommended_when:
          - "Complex business rules (3+ invariants)"
          - "Cross-context event communication needed"
          - "CQRS or event sourcing considered"

      - id: entity-focused
        name: "Entity-Focused Design"
        status: alternative
        recommended_when:
          - "Pure CRUD context (0-2 invariants)"
          - "No cross-context events"
          - "Simple data management"

  structural_constraints:
    - id: single-root-per-aggregate
      rule: "Every aggregate MUST have exactly one entity with is_root: true"
      validation: "Count of is_root=true equals 1 per aggregate"
      severity: ERROR

    - id: entity-unique-to-aggregate
      rule: "An entity MUST NOT appear in more than one aggregate"
      validation: "No entity ID duplicated across aggregates"
      severity: ERROR

    - id: vo-no-identity
      rule: "Value objects MUST NOT have an identity field"
      validation: "No value_object contains identity key"
      severity: ERROR

    - id: command-naming
      rule: "Command names MUST be PascalCase starting with imperative verb"
      validation: "Regex: ^(Create|Update|Delete|Change|Process|Approve|Reject|Cancel|Submit)[A-Z]"
      severity: ERROR

    - id: event-naming
      rule: "Domain event names MUST be PascalCase in past tense"
      validation: "Regex: ^[A-Z][a-zA-Z]+(Created|Updated|Deleted|Changed|Processed|Approved|Rejected|Cancelled|Submitted)$"
      severity: ERROR

    - id: command-has-errors
      rule: "Every command MUST define at least one error case"
      validation: "error_cases array is non-empty for every command"
      severity: ERROR
      applies_to: [full-tactical]

    - id: invariant-linked
      rule: "Every invariant SHOULD be referenced by at least one command error case"
      validation: "invariant field in error_cases references a valid invariant ID"
      severity: WARNING
      applies_to: [full-tactical]

    - id: context-ref-valid
      rule: "bounded_context MUST reference a valid ID from bounded-context-map.yaml"
      validation: "ID exists in upstream artifact"
      severity: ERROR

    - id: output-valid-yaml
      rule: "Output MUST be valid, parseable YAML"
      validation: "YAML parser accepts the output without errors"
      severity: ERROR

  testing_constraints:
    - id: downstream-consumable-api
      rule: "Output MUST be consumable by ERI-DESIGN-003 API mapping process"
      validation: "aggregate-definitions.yaml can be loaded and aggregate IDs resolved"
      severity: ERROR

    - id: downstream-consumable-bdd
      rule: "Output MUST be consumable by ERI-DESIGN-004 BDD scenario generation"
      validation: "Commands and invariants can be resolved for scenario generation"
      severity: ERROR
```

---

**Status:** ✅ Active
**Domain:** design
**Options:** Full Tactical Design (default) | Entity-Focused Design
