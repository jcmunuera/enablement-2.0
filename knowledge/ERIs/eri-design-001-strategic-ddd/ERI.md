---
id: eri-design-001-strategic-ddd
title: "ERI-DESIGN-001: Strategic DDD — Domain Decomposition"
sidebar_label: "Strategic DDD"
version: 1.0
date: 2026-02-16
updated: 2026-02-16
status: Active
author: "C4E Architecture Team"
domain: design
pattern: strategic-ddd
framework: agnostic
implements:
  - adr-design-001-domain-decomposition
tags:
  - ddd
  - strategic-design
  - bounded-context
  - context-map
  - subdomain
  - domain-decomposition
related:
  - eri-design-002-tactical-design
  - eri-design-003-api-mapping
derived_modules:
  - mod-design-001-strategic-ddd (planned)
  - mod-design-002-lightweight-decomposition (planned)
---

# ERI-DESIGN-001: Strategic DDD — Domain Decomposition

## Overview

This ERI provides a complete reference implementation of Strategic DDD analysis as defined in ADR-DESIGN-001. It demonstrates how to decompose a business domain into bounded contexts, classify subdomains, map context relationships, and produce the `bounded-context-map.yaml` artifact.

**Implements:** ADR-DESIGN-001 (Domain Decomposition via Strategic DDD)
**Status:** Active

**Reference Domain:** Retail Banking — Customer Management area, demonstrating a core subdomain (Customer), a supporting subdomain (Notifications), and a generic subdomain (Identity Verification).

---

## Output Format

### Artifact: bounded-context-map.yaml

| Component | Format | Description |
|-----------|--------|-------------|
| **Output file** | YAML | Structured domain decomposition |
| **Schema version** | 1.0 | Versioned for forward compatibility |
| **Consumers** | ERI-DESIGN-002 (tactical), ERI-DESIGN-003 (API mapping) | Downstream design agents |

### Schema

```yaml
version: "1.0"
domain: "{domain-name}"
description: "{High-level domain description}"
analysis_date: "YYYY-MM-DD"
source_requirements:
  - "{Reference to functional requirements document or description}"

subdomains:
  - id: "{subdomain-id}"                    # kebab-case, unique within domain
    name: "{Subdomain Name}"                 # Human-readable
    type: core|supporting|generic            # Per ADR-DESIGN-001 classification
    description: "{What this subdomain does}"
    investment_strategy: "{build|buy|reuse}" # Derived from type

    bounded_contexts:
      - id: "{context-id}"                   # kebab-case, globally unique
        name: "{Context Name}"               # Human-readable
        description: "{What this context owns and does}"
        owner: "{Team or squad}"
        ubiquitous_language:
          - term: "{Term}"
            definition: "{What it means in THIS context}"
        capabilities:
          - "{Business capability 1}"
          - "{Business capability 2}"

context_relationships:
  - id: "{relationship-id}"
    upstream: "{context-id}"
    downstream: "{context-id}"
    type: customer-supplier|conformist|acl|partnership|shared-kernel|open-host|published-language
    description: "{Why this relationship exists and what flows between contexts}"
    integration_pattern: sync-api|async-event|shared-db
```

### Field Rules

| Field | Rule |
|-------|------|
| `subdomain.id` | Kebab-case, unique within domain |
| `subdomain.type` | One of: `core`, `supporting`, `generic` |
| `bounded_context.id` | Kebab-case, globally unique across all domains |
| `ubiquitous_language` | At least 3 terms per context |
| `capabilities` | At least 1 per context |
| `context_relationships.type` | One of the 7 approved types (ADR-DESIGN-001) |
| `integration_pattern` | How data flows between contexts |

---

## Reference Implementation: Retail Banking — Customer Area

### Input: Functional Requirements

> The Retail Banking division needs to manage customer lifecycle: onboarding new customers,
> maintaining customer data, managing customer status (active, dormant, suspended, closed),
> and supporting regulatory compliance (KYC). Customer data is mastered in the core banking
> mainframe (Parties system). Customers must be notified of status changes via email/SMS.
> Identity verification is performed by a third-party provider (Jumio).

### Output: bounded-context-map.yaml

```yaml
version: "1.0"
domain: "retail-banking-customer"
description: "Customer management area within Retail Banking division"
analysis_date: "2026-02-16"
source_requirements:
  - "Retail Banking Customer Management — Functional Requirements v2.1"

subdomains:
  - id: "customer-management"
    name: "Customer Management"
    type: core
    description: "Core business capability for managing customer lifecycle, data ownership, and status transitions. Competitive differentiator through customer experience."
    investment_strategy: build

    bounded_contexts:
      - id: "customer-core"
        name: "Customer Core"
        description: "Owns customer identity, personal data, and lifecycle. Single source of truth for customer state. Manages status transitions with business rule enforcement."
        owner: "Customer Squad"
        ubiquitous_language:
          - term: "Customer"
            definition: "An individual or entity with an active or historical banking relationship"
          - term: "Onboarding"
            definition: "The process of registering a new customer, including data capture and KYC validation"
          - term: "Status"
            definition: "The current lifecycle state of a customer: ACTIVE, DORMANT, SUSPENDED, or CLOSED"
          - term: "KYC"
            definition: "Know Your Customer — regulatory compliance verification of customer identity"
          - term: "Dormancy"
            definition: "Automatic status transition when a customer has no activity for 12+ months"
        capabilities:
          - "Customer registration and onboarding"
          - "Customer data maintenance (CRUD)"
          - "Customer status lifecycle management"
          - "Customer search and retrieval"

  - id: "customer-notifications"
    name: "Customer Notifications"
    type: supporting
    description: "Handles notification delivery for customer-related events. Not a differentiator but necessary for operations."
    investment_strategy: build

    bounded_contexts:
      - id: "notification-dispatch"
        name: "Notification Dispatch"
        description: "Receives notification requests from domain events and dispatches via appropriate channel (email, SMS, push). Manages templates and delivery preferences."
        owner: "Platform Squad"
        ubiquitous_language:
          - term: "Notification"
            definition: "A message sent to a customer through a specific channel"
          - term: "Channel"
            definition: "The delivery medium: email, SMS, or push notification"
          - term: "Template"
            definition: "A predefined notification format with variable placeholders"
        capabilities:
          - "Multi-channel notification dispatch"
          - "Notification template management"
          - "Delivery status tracking"

  - id: "identity-verification"
    name: "Identity Verification"
    type: generic
    description: "Third-party identity verification. Industry-standard capability with no competitive value."
    investment_strategy: buy

    bounded_contexts:
      - id: "kyc-verification"
        name: "KYC Verification"
        description: "Wraps the external identity verification provider (Jumio). Abstracts provider-specific details behind a standard interface."
        owner: "Platform Squad"
        ubiquitous_language:
          - term: "Verification"
            definition: "The process of validating a person's identity against official documents"
          - term: "Verification Result"
            definition: "The outcome: VERIFIED, REJECTED, or PENDING_REVIEW"
          - term: "Document"
            definition: "An identity document submitted for verification (passport, ID card, etc.)"
        capabilities:
          - "Identity document verification"
          - "Verification result retrieval"

context_relationships:
  - id: "rel-customer-to-kyc"
    upstream: "kyc-verification"
    downstream: "customer-core"
    type: acl
    description: "Customer Core consumes KYC results but translates them to its own domain model. The ACL protects Customer Core from changes in the external verification provider."
    integration_pattern: sync-api

  - id: "rel-customer-to-notifications"
    upstream: "customer-core"
    downstream: "notification-dispatch"
    type: customer-supplier
    description: "Customer Core publishes domain events (CustomerCreated, StatusChanged) that Notification Dispatch consumes to trigger notifications."
    integration_pattern: async-event

  - id: "rel-customer-to-parties"
    upstream: "customer-core"
    downstream: "customer-core"
    type: acl
    description: "Customer Core reads/writes to the Parties mainframe system via System API. The ACL translates between the domain model and the legacy data format."
    integration_pattern: sync-api
```

### Analysis Rationale

**Why 3 subdomains?**
- Customer Management is core — it's where we differentiate through customer experience
- Notifications are supporting — necessary but standard
- Identity Verification is generic — we buy this capability

**Why these context boundaries?**
- Customer Core is a single context because customer data and lifecycle are tightly coupled (status transitions depend on customer attributes)
- Notifications are separate because they have different ownership, different lifecycle, and different scaling requirements
- KYC is separate because it wraps an external provider and could be swapped

**Why ACL for both KYC and Parties?**
- Both are external systems whose models differ from our domain model
- ACL protects our domain from model changes in upstream systems

---

## Implementation Options

### Option A: Full Strategic Analysis ⭐ DEFAULT

**Description:** Complete DDD strategic decomposition with all elements: subdomains, bounded contexts, ubiquitous language, capabilities, and relationships.

**Recommended When:**
- New domain being analyzed for the first time
- Complex business area with multiple teams
- Domain with significant integration points

**Output:** Complete `bounded-context-map.yaml` as shown above.

### Option B: Lightweight Decomposition

**Description:** Simplified analysis producing only bounded contexts and basic relationships, without full ubiquitous language or subdomain classification.

**Recommended When:**
- Simple domain with a single team
- Domain with 1-2 bounded contexts
- Quick analysis for existing well-understood areas

**Output:** Reduced `bounded-context-map.yaml` with only contexts and relationships (no subdomains, minimal ubiquitous language).

---

## Compliance Checklist

Requirements that implementations MUST satisfy:

- [ ] Every bounded context has a unique `id` (globally unique)
- [ ] Every bounded context has at least one capability
- [ ] Every bounded context has at least 3 ubiquitous language terms
- [ ] Every subdomain has a `type` classification (core/supporting/generic)
- [ ] All context relationships use approved types from ADR-DESIGN-001
- [ ] No business capability appears in more than one bounded context
- [ ] Context relationship `upstream` and `downstream` reference valid context IDs
- [ ] Output YAML is valid and parseable

---

## Related Documentation

- **ADR:** [adr-design-001-domain-decomposition](../../ADRs/adr-design-001-domain-decomposition/) — Strategic decision
- **Downstream ERI:** [eri-design-002-tactical-design](../eri-design-002-tactical-design/) — Consumes bounded contexts
- **Module:** mod-design-001-strategic-ddd (planned) — Automates this analysis
- **Capability:** `domain-analysis` / `strategic-ddd` in capability-index.yaml

---

## Changelog

| Date | Version | Change | Author |
|------|---------|--------|--------|
| 2026-02-16 | 1.0 | Initial version with Retail Banking reference | C4E Architecture Team |

---

## Annex: Implementation Constraints

> This annex defines rules that MUST be respected when creating Modules
> based on this ERI. Compliance is mandatory.

```yaml
eri_constraints:
  id: eri-design-001-strategic-ddd-constraints
  version: "1.0"
  eri_reference: eri-design-001-strategic-ddd
  adr_reference: adr-design-001-domain-decomposition

  implementation_options:
    default: full-strategic
    options:
      - id: full-strategic
        name: "Full Strategic Analysis"
        status: default
        recommended_when:
          - "New domain analysis"
          - "Complex business area with multiple teams"
          - "Significant integration points"

      - id: lightweight
        name: "Lightweight Decomposition"
        status: alternative
        recommended_when:
          - "Simple domain with single team"
          - "1-2 bounded contexts"
          - "Well-understood existing area"

  structural_constraints:
    - id: context-id-unique
      rule: "Bounded context IDs MUST be globally unique across all domains"
      validation: "No duplicate context IDs in any bounded-context-map.yaml"
      severity: ERROR

    - id: context-has-capabilities
      rule: "Every bounded context MUST have at least one business capability"
      validation: "capabilities array is non-empty for every context"
      severity: ERROR

    - id: context-has-language
      rule: "Every bounded context MUST define at least 3 ubiquitous language terms"
      validation: "ubiquitous_language array has >= 3 entries"
      severity: ERROR
      applies_to: [full-strategic]

    - id: subdomain-classified
      rule: "Every subdomain MUST have a type classification"
      validation: "type field is one of: core, supporting, generic"
      severity: ERROR
      applies_to: [full-strategic]

    - id: relationship-valid-type
      rule: "Context relationships MUST use approved types"
      validation: "type field is one of the 7 approved types"
      severity: ERROR

    - id: relationship-valid-refs
      rule: "upstream and downstream MUST reference valid context IDs"
      validation: "All referenced IDs exist in the bounded_contexts definitions"
      severity: ERROR

    - id: no-duplicate-capabilities
      rule: "A business capability SHOULD NOT appear in more than one context"
      validation: "No capability string appears in multiple contexts"
      severity: WARNING

    - id: output-valid-yaml
      rule: "Output MUST be valid, parseable YAML"
      validation: "YAML parser accepts the output without errors"
      severity: ERROR

  testing_constraints:
    - id: downstream-consumable
      rule: "Output MUST be consumable by ERI-DESIGN-002 tactical design process"
      validation: "bounded-context-map.yaml can be loaded and context IDs resolved"
      severity: ERROR
```

---

**Status:** ✅ Active
**Domain:** design
**Options:** Full Strategic Analysis (default) | Lightweight Decomposition
