---
id: eri-design-004-bdd-scenarios
title: "ERI-DESIGN-004: BDD Scenarios — Behavior Validation"
sidebar_label: "BDD Scenarios"
version: 1.0
date: 2026-02-16
updated: 2026-02-16
status: Active
author: "C4E Architecture Team"
domain: design
pattern: bdd-validation
framework: agnostic
implements:
  - adr-design-004-behavior-validation
tags:
  - bdd
  - gherkin
  - behavior
  - validation
  - acceptance-criteria
  - testing
related:
  - eri-design-001-strategic-ddd
  - eri-design-002-tactical-design
  - eri-design-003-api-mapping
derived_modules:
  - mod-design-008-gherkin-scenarios (planned)
---

# ERI-DESIGN-004: BDD Scenarios — Behavior Validation

## Overview

This ERI provides a complete reference implementation of BDD scenario generation as defined in ADR-DESIGN-004. It demonstrates how to produce Gherkin scenarios from DDD artifacts (commands, invariants, queries) and trace each scenario to its source requirement and target API endpoint.

**Implements:** ADR-DESIGN-004 (Behavior Validation via BDD)
**Status:** Active

**Input:** `aggregate-definitions.yaml` (ERI-002) + `api-mapping.yaml` (ERI-003) + original requirements
**Reference:** Customer aggregate → scenarios.feature + scenario-tracing.yaml

---

## Output Formats

| Artifact | Format | Purpose |
|----------|--------|---------|
| `{aggregate}.feature` | Gherkin | Human/machine-readable behavior scenarios |
| `scenario-tracing.yaml` | YAML | Traceability from scenario → requirement → command → endpoint |

---

## Artifact 1: {aggregate}.feature

### Generation Rules

For each aggregate, generate scenarios in this order:

| # | Category | Source | Count |
|---|----------|--------|-------|
| 1 | **Happy path per command** | Each command in aggregate | 1 per command |
| 2 | **Happy path per query** | Each query in aggregate | 1 per query |
| 3 | **Validation errors** | Each command's required inputs | 1 per command |
| 4 | **Business rule violations** | Each invariant | 1 per invariant |
| 5 | **Not found** | Each query/command referencing existing entity | 1 per entity-targeting operation |
| 6 | **Integration** | Each system API dependency | 1 per system API |
| 7 | **Pagination** | Each query with pagination=true | 1 per paginated query |

### Gherkin Standards

```gherkin
# File: {context-id}/{aggregate-id}.feature
# Source: aggregate-definitions.yaml (context: {context-id}, aggregate: {aggregate-id})
# Tracing: scenario-tracing.yaml

Feature: {Aggregate Name} Management
  As the {Context Name} domain
  I want to manage {aggregate description — abbreviated}
  So that {business value from context capabilities}
```

**Rules:**
1. Given/When/Then use ubiquitous language from bounded-context-map.yaml
2. Commands referenced by name (e.g., "a CreateCustomer command is submitted")
3. Queries referenced by name (e.g., "a GetCustomer query is submitted")
4. Invariant violations produce named errors matching error_cases.code
5. No technology-specific details (no HTTP codes, no JSON, no database)
6. One behavior per scenario
7. Data tables for commands with 3+ input fields

---

### Reference: customer.feature

```gherkin
# File: customer-core/customer.feature
# Source: aggregate-definitions.yaml (context: customer-core, aggregate: customer)
# Tracing: scenario-tracing.yaml

Feature: Customer Management
  As the Customer Core domain
  I want to manage customer lifecycle and personal data
  So that customer data is accurate, consistent, and compliant

  # ============================================================
  # HAPPY PATH — Commands
  # ============================================================

  Scenario: Register a new customer with valid data
    Given no customer exists with email "john.doe@example.com"
    When a CreateCustomer command is submitted with:
      | field       | value                  |
      | firstName   | John                   |
      | lastName    | Doe                    |
      | email       | john.doe@example.com   |
      | dateOfBirth | 1990-05-15             |
    Then a new customer is created with status ACTIVE
    And a CustomerCreated event is published

  Scenario: Update customer personal data
    Given a customer exists with id "cust-001"
    When an UpdateCustomer command is submitted with:
      | field     | value           |
      | firstName | Jonathan        |
      | address   | 123 Main St, Springfield |
    Then the customer data is updated
    And a CustomerUpdated event is published

  Scenario: Change customer status to DORMANT
    Given a customer exists with id "cust-001" and status ACTIVE
    When a ChangeCustomerStatus command is submitted with:
      | field     | value                    |
      | newStatus | DORMANT                  |
      | reason    | No activity for 12 months |
    Then the customer status changes to DORMANT
    And a CustomerStatusChanged event is published

  # ============================================================
  # HAPPY PATH — Queries
  # ============================================================

  Scenario: Retrieve an existing customer by ID
    Given a customer exists with id "cust-001"
    When a GetCustomer query is submitted for id "cust-001"
    Then the customer details are returned

  Scenario: List customers with pagination
    Given 25 customers exist in the system
    When a ListCustomers query is submitted with page 1 and size 10
    Then 10 customers are returned
    And pagination metadata indicates 3 total pages

  Scenario: Search customer by email
    Given a customer exists with email "john.doe@example.com"
    When a SearchCustomerByEmail query is submitted for "john.doe@example.com"
    Then the matching customer is returned

  # ============================================================
  # VALIDATION ERRORS
  # ============================================================

  Scenario: Reject customer creation with missing required fields
    When a CreateCustomer command is submitted without email
    Then the command is rejected with error INVALID_INPUT
    And the error indicates "email is required"

  Scenario: Reject customer update for non-existent customer
    Given no customer exists with id "nonexistent"
    When an UpdateCustomer command is submitted for id "nonexistent"
    Then the command is rejected with error CUSTOMER_NOT_FOUND

  # ============================================================
  # BUSINESS RULE VIOLATIONS (Invariants)
  # ============================================================

  Scenario: Reject duplicate customer email
    Given a customer already exists with email "john.doe@example.com"
    When a CreateCustomer command is submitted with email "john.doe@example.com"
    Then the command is rejected with error DUPLICATE_EMAIL
    And the error indicates "a customer with this email already exists"

  Scenario: Reject invalid status transition
    Given a customer exists with id "cust-001" and status CLOSED
    When a ChangeCustomerStatus command is submitted with newStatus ACTIVE
    Then the command is rejected with error INVALID_TRANSITION
    And the error indicates "invalid status transition from CLOSED to ACTIVE"

  Scenario: Reject activation without verified KYC
    Given a customer exists with id "cust-001" and kycStatus PENDING
    When a ChangeCustomerStatus command is submitted with newStatus ACTIVE
    Then the command is rejected with error KYC_NOT_VERIFIED
    And the error indicates "customer cannot be activated without verified KYC"

  Scenario: Reject underage customer registration
    Given today's date is "2026-02-16"
    When a CreateCustomer command is submitted with dateOfBirth "2010-06-01"
    Then the command is rejected with error UNDERAGE
    And the error indicates "customer must be at least 18 years old"

  # ============================================================
  # NOT FOUND
  # ============================================================

  Scenario: Return error when customer does not exist
    Given no customer exists with id "nonexistent"
    When a GetCustomer query is submitted for id "nonexistent"
    Then a CUSTOMER_NOT_FOUND error is returned

  # ============================================================
  # INTEGRATION (System API)
  # ============================================================

  Scenario: Customer data persisted via Parties system API
    Given the Parties system API is available
    When a CreateCustomer command is processed successfully
    Then customer data is transformed to the Parties format
    And persisted via the Parties system API

  Scenario: Customer data retrieved from Parties system API
    Given the Parties system API is available
    When a GetCustomer query is processed
    Then data is retrieved from the Parties system API
    And transformed from Parties format to domain model
```

---

## Artifact 2: scenario-tracing.yaml

### Schema

```yaml
version: "1.0"
bounded_context: "{context-id}"
aggregate: "{aggregate-id}"
feature_file: "{aggregate}.feature"

scenarios:
  - id: "{scenario-id}"                    # kebab-case, unique
    scenario: "{Scenario title from .feature}"
    category: happy-path|validation|invariant|not-found|integration|pagination
    validates_requirement: "{Requirement reference}"
    exercises: "{command-id or query-id}"
    tests_invariant: "{invariant-id}"       # Only for invariant category
    target_endpoint: "{HTTP method + path}" # From api-mapping.yaml
    expected_error: "{error code}"          # For error scenarios
```

### Reference: scenario-tracing.yaml

```yaml
version: "1.0"
bounded_context: "customer-core"
aggregate: "customer"
feature_file: "customer.feature"

scenarios:
  # Happy path — Commands
  - id: "register-customer-happy"
    scenario: "Register a new customer with valid data"
    category: happy-path
    validates_requirement: "Customer registration and onboarding"
    exercises: "create-customer"
    target_endpoint: "POST /customers"

  - id: "update-customer-happy"
    scenario: "Update customer personal data"
    category: happy-path
    validates_requirement: "Customer data maintenance (CRUD)"
    exercises: "update-customer"
    target_endpoint: "PUT /customers/{id}"

  - id: "change-status-happy"
    scenario: "Change customer status to DORMANT"
    category: happy-path
    validates_requirement: "Customer status lifecycle management"
    exercises: "change-status"
    target_endpoint: "POST /customers/{id}/status"

  # Happy path — Queries
  - id: "get-customer-happy"
    scenario: "Retrieve an existing customer by ID"
    category: happy-path
    validates_requirement: "Customer search and retrieval"
    exercises: "get-customer"
    target_endpoint: "GET /customers/{id}"

  - id: "list-customers-pagination"
    scenario: "List customers with pagination"
    category: pagination
    validates_requirement: "Customer search and retrieval"
    exercises: "list-customers"
    target_endpoint: "GET /customers"

  - id: "search-by-email-happy"
    scenario: "Search customer by email"
    category: happy-path
    validates_requirement: "Customer search and retrieval"
    exercises: "search-customer-by-email"
    target_endpoint: "GET /customers/search"

  # Validation
  - id: "create-missing-fields"
    scenario: "Reject customer creation with missing required fields"
    category: validation
    validates_requirement: "Customer registration and onboarding"
    exercises: "create-customer"
    target_endpoint: "POST /customers"
    expected_error: "INVALID_INPUT"

  - id: "update-not-found"
    scenario: "Reject customer update for non-existent customer"
    category: not-found
    validates_requirement: "Customer data maintenance (CRUD)"
    exercises: "update-customer"
    target_endpoint: "PUT /customers/{id}"
    expected_error: "CUSTOMER_NOT_FOUND"

  # Invariants
  - id: "duplicate-email"
    scenario: "Reject duplicate customer email"
    category: invariant
    validates_requirement: "Customer registration and onboarding"
    exercises: "create-customer"
    tests_invariant: "unique-email"
    target_endpoint: "POST /customers"
    expected_error: "DUPLICATE_EMAIL"

  - id: "invalid-transition"
    scenario: "Reject invalid status transition"
    category: invariant
    validates_requirement: "Customer status lifecycle management"
    exercises: "change-status"
    tests_invariant: "valid-status-transition"
    target_endpoint: "POST /customers/{id}/status"
    expected_error: "INVALID_TRANSITION"

  - id: "kyc-not-verified"
    scenario: "Reject activation without verified KYC"
    category: invariant
    validates_requirement: "Customer status lifecycle management"
    exercises: "change-status"
    tests_invariant: "kyc-required-for-active"
    target_endpoint: "POST /customers/{id}/status"
    expected_error: "KYC_NOT_VERIFIED"

  - id: "underage-customer"
    scenario: "Reject underage customer registration"
    category: invariant
    validates_requirement: "Customer registration and onboarding"
    exercises: "create-customer"
    tests_invariant: "minimum-age"
    target_endpoint: "POST /customers"
    expected_error: "UNDERAGE"

  # Not found
  - id: "get-customer-not-found"
    scenario: "Return error when customer does not exist"
    category: not-found
    validates_requirement: "Customer search and retrieval"
    exercises: "get-customer"
    target_endpoint: "GET /customers/{id}"
    expected_error: "CUSTOMER_NOT_FOUND"

  # Integration
  - id: "persist-via-parties"
    scenario: "Customer data persisted via Parties system API"
    category: integration
    validates_requirement: "Customer registration and onboarding"
    exercises: "create-customer"
    target_endpoint: "POST /customers"

  - id: "retrieve-via-parties"
    scenario: "Customer data retrieved from Parties system API"
    category: integration
    validates_requirement: "Customer search and retrieval"
    exercises: "get-customer"
    target_endpoint: "GET /customers/{id}"
```

---

## Coverage Summary

The reference implementation produces:

| Category | Scenarios | Source |
|----------|-----------|--------|
| Happy path (commands) | 3 | 3 commands |
| Happy path (queries) | 3 | 3 queries |
| Validation | 2 | Required field validation + not found on update |
| Invariants | 4 | 4 invariants |
| Not found | 1 | Entity lookup |
| Integration | 2 | 1 System API (write + read) |
| Pagination | 1 | 1 paginated query |
| **Total** | **16** | |

**Coverage check:** Every command has happy + error scenarios. Every invariant has a violation scenario. Every query has a happy path. System API integration tested bidirectionally.

---

## Compliance Checklist

- [ ] Every command has at least one happy-path scenario
- [ ] Every invariant has at least one violation scenario
- [ ] Every query has at least one happy-path scenario
- [ ] All error codes in scenarios match error_cases.code from aggregate-definitions.yaml
- [ ] Scenarios use ubiquitous language from bounded-context-map.yaml
- [ ] No scenario contains technology-specific details (HTTP codes, JSON, database)
- [ ] scenario-tracing.yaml maps every scenario to a requirement and endpoint
- [ ] Feature file is valid Gherkin (parseable by Cucumber/Behave)
- [ ] Output is consumable for acceptance test generation

---

## Related Documentation

- **ADR:** [adr-design-004-behavior-validation](../../ADRs/adr-design-004-behavior-validation/)
- **Upstream ERI:** [eri-design-002-tactical-design](../eri-design-002-tactical-design/) — Commands, invariants, queries
- **Upstream ERI:** [eri-design-003-api-mapping](../eri-design-003-api-mapping/) — API endpoints for tracing
- **Module:** mod-design-008-gherkin-scenarios (planned)
- **Capability:** `behavior-validation` / `gherkin-scenarios` in capability-index.yaml

---

## Changelog

| Date | Version | Change | Author |
|------|---------|--------|--------|
| 2026-02-16 | 1.0 | Initial version with Customer reference | C4E Architecture Team |

---

## Annex: Implementation Constraints

> This annex defines rules that MUST be respected when creating Modules
> based on this ERI. Compliance is mandatory.

```yaml
eri_constraints:
  id: eri-design-004-bdd-scenarios-constraints
  version: "1.0"
  eri_reference: eri-design-004-bdd-scenarios
  adr_reference: adr-design-004-behavior-validation

  structural_constraints:
    - id: command-happy-path
      rule: "Every command MUST have at least one happy-path scenario"
      validation: "For each command in aggregate, a scenario with category=happy-path exists"
      severity: ERROR

    - id: invariant-violation
      rule: "Every invariant MUST have at least one violation scenario"
      validation: "For each invariant, a scenario with tests_invariant={id} exists"
      severity: ERROR

    - id: query-happy-path
      rule: "Every query MUST have at least one happy-path scenario"
      validation: "For each query in aggregate, a scenario with category=happy-path exists"
      severity: ERROR

    - id: error-code-match
      rule: "Error codes in scenarios MUST match error_cases.code from aggregate-definitions.yaml"
      validation: "expected_error values exist as error codes in source aggregate"
      severity: ERROR

    - id: no-tech-details
      rule: "Scenarios MUST NOT contain technology-specific details"
      validation: "No HTTP codes (200, 404), no JSON, no database references in .feature"
      severity: ERROR

    - id: ubiquitous-language
      rule: "Scenarios SHOULD use terms from the bounded context ubiquitous language"
      validation: "Key nouns in Given/When/Then match terms in ubiquitous_language"
      severity: WARNING

    - id: one-behavior-per-scenario
      rule: "Each scenario MUST test exactly one behavior"
      validation: "Single When step per scenario"
      severity: ERROR

    - id: tracing-complete
      rule: "Every scenario MUST have a corresponding entry in scenario-tracing.yaml"
      validation: "Scenario count in .feature equals scenario count in tracing YAML"
      severity: ERROR

    - id: valid-gherkin
      rule: "Feature file MUST be valid Gherkin syntax"
      validation: "Gherkin parser accepts the file without errors"
      severity: ERROR

  testing_constraints:
    - id: requirement-coverage
      rule: "Every capability from bounded-context-map.yaml SHOULD be traced by at least one scenario"
      validation: "validates_requirement covers all capabilities"
      severity: WARNING
```

---

**Status:** ✅ Active
**Domain:** design
**Output:** Gherkin .feature + scenario-tracing.yaml
