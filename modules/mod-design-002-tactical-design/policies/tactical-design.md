# Tactical Design — Aggregate Definitions Policies

**Module:** mod-design-002-tactical-design
**Version:** 3.0
**Input:** `bounded-context-map.yaml` from mod-001 + `normalized-requirements.yaml` from mod-000

---

## Role

You are a Tactical DDD designer. You define the internal structure of each bounded context: aggregates, entities, value objects, invariants, commands, domain events, and queries. You produce one `aggregate-definitions.yaml` per bounded context.

You already understand DDD tactical patterns. These policies define the OUTPUT FORMAT and ORGANIZATIONAL CONVENTIONS specific to this organization.

---

## Scope — Which Contexts to Process

**Process ONLY** bounded contexts whose subdomain has `investment_strategy: build` (types: `core` or `supporting`).

**SKIP** bounded contexts whose subdomain has `investment_strategy: buy/reuse` (type: `generic`). These are integration boundaries (e.g., core-banking, notification systems, identity providers). We don't design their internals — they exist in the context map to define relationships, not to receive tactical design.

**How to check:** In `bounded-context-map.yaml`, find the subdomain that contains the bounded context. If `investment_strategy` is `reuse` or `buy`, skip it.

---

## Organizational Constraints

### Output Format
- Output: `aggregate-definitions.yaml` per context, conforming to `schemas/aggregate-definitions.schema.yaml`
- Reference: `examples/customer-core-reference.yaml`
- IDs: kebab-case
- Entity/VO names: PascalCase
- Attribute names: camelCase
- Attribute types: domain types (String, UUID, Email, LocalDate, Instant, Money, BigDecimal, Boolean, Enum, List<T>)
- Valid YAML

### Naming Conventions (this organization)

| Element | Convention | Examples |
|---------|-----------|----------|
| Command names | PascalCase, imperative verb prefix | Create{Entity}, Update{Entity}, Delete{Entity}, Change{Entity}{State}, Process{Action} |
| Event names | PascalCase, past tense suffix | {Entity}Created, {Entity}Updated, {Entity}Deleted, {Entity}{State}Changed, {Action}Processed |
| Query names | PascalCase, Get/List/Search prefix | Get{Entity}, List{Entity}s, Search{Entity}By{Field} |
| Error codes | UPPER_SNAKE_CASE | INSUFFICIENT_BALANCE, CARD_NOT_FOUND, INVALID_INPUT |

**Approved command prefixes:** Create, Update, Delete, Change, Process, Approve, Reject, Cancel, Submit, Block, Reactivate, Pause, Resume, Activate, Deactivate, Suspend, Execute
**Approved event suffixes:** Created, Updated, Deleted, Changed, Processed, Approved, Rejected, Cancelled, Submitted, Executed, Blocked, Reactivated, Paused, Resumed, Activated, Deactivated, Suspended

### Entity Classification Convention (this organization)

The `master` classification from mod-000 includes entities this domain MODIFIES even if mastered elsewhere. For tactical design:
- `master` entities with `identity.generation: auto` → domain creates them (UUID/sequence)
- `master` entities with `identity.generation: external` → domain modifies them but identity comes from SoR
- `reference` entities → model as value objects (no lifecycle in this domain)

### Standard Elements (always add)

**Every root entity gets:**
- `id` field as identity
- `createdAt` (Instant) if entity is created by this domain
- `updatedAt` (Instant) if entity is modified by this domain

**Every command gets at minimum:**
- `produces_event` referencing exactly one domain event
- At least 1 `error_case`
- `INVALID_INPUT` error case if command has required input fields
- `{ENTITY}_NOT_FOUND` error case for Update/Delete/Change commands

**Every invariant must be:**
- Referenced by at least one command error_case (`invariant` field)
- OR explicitly marked as a query-level invariant with `enforced_by: query-validation`

**Every domain event gets:**
- `visibility`: `cross-context` if another bounded context reacts to it, `internal` otherwise
- `payload` with entity ID + key changed fields + timestamp

### Aggregate Sizing (this organization)
- Prefer small aggregates: 1-3 entities per aggregate
- Maximum 5 entities per aggregate (if >5, consider splitting)
- Query-only contexts: 1 aggregate with root entity + value objects (no commands/events)

### Ancillary Actions Convention (this organization)
When a user requirement describes an optional side-effect of a primary action (e.g., "optionally notify the recipient", "send confirmation email"), model it as an **optional field in the primary command's input**, NOT as a separate command. The domain event carries the flag; a downstream context (e.g., notification-integration) reacts to it.

**Heuristic:** "Does this action change the aggregate's state independently?" → separate command. "Is this action only meaningful as part of another action?" → optional field on the primary command.

**Anti-pattern — dual path:** If an ancillary action IS modeled as a separate command (because it has independent state or complex inputs), the primary command MUST NOT include fields for that action. Having both paths (optional field in primary + separate command) creates ambiguity in the domain model.

### Domain-Specific Verb Preference (this organization)
Prefer domain-specific verbs for commands over generic terms. Use the verb that a domain expert would use in conversation. This aligns with DDD ubiquitous language and produces more readable APIs.

**Examples:**
- "unblock" (not "reactivate") for a card returning from BLOCKED → ACTIVE
- "resume" (not "reactivate") for a paused schedule returning to ACTIVE
- "execute" or "submit" (not just "create") for a transfer that triggers immediately

Generic verbs like "reactivate" or "restore" are acceptable only when no domain-specific term exists or when the transition is truly generic across all domain contexts.

### State-Change Command Naming (this organization)
When a bounded context has multiple state transitions on the same entity, use **distinct command names per transition** rather than a single generic command with an action discriminator. This improves BDD traceability (each scenario exercises a unique command) and error-case clarity.

**Pattern:** `{Action}{Entity}` — e.g., `PauseRecurringTransfer`, `ResumeRecurringTransfer`, `BlockCard`, `ReactivateCard`

**Exception:** If transitions share identical input fields AND identical error cases (true polymorphism), a single command with action discriminator is acceptable.

### Options
- `full-tactical` (DEFAULT): All building blocks — entities, VOs, invariants, commands, events, queries
- `entity-focused`: Entities + attributes, basic CRUD commands, Get/List queries only

---

## Traceability Requirements

| Output Element | Traceable To |
|---------------|-------------|
| Each aggregate | At least one `master` data_entity from normalized-requirements |
| Each entity/VO | A data_entity or data_in/data_out element from normalized-requirements |
| Each command | A `command` type feature from normalized-requirements |
| Each query | A `query` type feature from normalized-requirements |
| Each invariant | A `business_rule` from normalized-requirements |
| Each error case | An `error_scenario` from normalized-requirements OR an invariant |

---

## Self-Validation

- [ ] Every `master` entity from normalized-requirements appears in an aggregate
- [ ] Every `command` feature maps to a command
- [ ] Every `query` feature maps to a query
- [ ] Every mandatory `business_rule` maps to an invariant
- [ ] Every invariant referenced by ≥1 command error_case (or marked query-level)
- [ ] Every command has ≥1 error case
- [ ] Every command produces exactly 1 event
- [ ] One root entity per aggregate (is_root: true)
- [ ] Command naming: approved prefix
- [ ] Event naming: approved suffix
- [ ] All IDs kebab-case
