# Prompt Assembly Policy

## Purpose

Defines how to assemble the `prompt.md` that CODE pipeline receives. This prompt is the primary input for code generation — it must contain everything the LLM needs to produce correct business logic on the first attempt.

## Guiding Principle

**BDD as specification, not validation.** The prompt includes full BDD scenarios so the LLM reads expected behavior BEFORE generating code — exactly as a developer practicing BDD reads the acceptance criteria before writing implementation. Tests are confirmation, not discovery.

## Prompt Structure

Use the template `prompt.md.tpl`. The sections are:

### Section 1: Service Identity

```markdown
# Service: {context-name}

{Context description from bounded-context-map.yaml}

**Blueprint:** {blueprint-id}
**Building block:** {block-id}
**Tech stack:** {stack-id}
```

### Section 2: Domain Model

```markdown
## Domain Model

### Aggregate: {aggregate-name}
{Aggregate description}

**Entity:** {entity-name}
Fields:
- {field-name}: {type} — {description}

**Value Objects:**
- {vo-name}: {field definitions}

**State Machine:** (if applicable)
States: {state list}
Transitions: {transition list}
Terminal: {terminal states}
```

Source: `aggregate-definitions.yaml` entities, value_objects, and invariant-derived states.

### Section 3: API Contract

```markdown
## API Contract

See attached: `openapi-spec.yaml`

Summary of endpoints:
- POST /cards/{cardId}/block — Block a card
- POST /cards/{cardId}/reactivate — Reactivate a blocked card
- GET /cards — List customer cards
- ...
```

Do NOT inline the full OpenAPI spec. Reference it. Include a summary table for quick orientation.

### Section 4: Business Logic Specification (BDD)

```markdown
## Business Logic Specification

The following BDD scenarios define the expected behavior of this service.
Implement business logic that satisfies ALL scenarios.

{FULL CONTENT of .feature file — copy verbatim}
```

**Rules:**
- Include the COMPLETE .feature file content — all scenarios, all steps
- Do NOT summarize or abbreviate
- Do NOT rewrite scenarios in different format
- The Gherkin IS the specification

**Context window management:** If a context has >50 scenarios (unlikely but possible):
1. Always include: happy-path, invariant, validation scenarios (business logic)
2. Summarize ONLY: pagination and not-found scenarios (predictable boilerplate)
3. Never drop business-rule scenarios

### Section 5: Pre-Resolved Capabilities

```markdown
## Capabilities

The following capabilities are pre-resolved and MUST be applied:

| Capability | Source | Notes |
|-----------|--------|-------|
| architecture.hexagonal-light | inherent | Project structure |
| api-architecture.domain-api | inherent | API tier |
| persistence.systemapi | inferred | ACL to core-banking SoR |
| integration.api-rest | inferred | External service calls |
| resilience.circuit-breaker | inferred+stack | On all external calls |
| resilience.timeout | stack | On all external calls |

### Implementation Variants
- http_client: feign
- circuit_breaker: annotation
- timeout: annotation

Additional capabilities may be discovered from this prompt.
```

### Section 6: Integration Context

```markdown
## Integration Context

### Upstream dependencies (this service calls):
- **core-banking-gateway** (ACL): System API for card data, movements, PIN
  Contract: {reference to upstream contract if available}

### Downstream dependents (call this service):
- None (or list if applicable)

### Domain Events:
- **CardBlocked** — Published when card is blocked
- **CardReactivated** — Published when card is reactivated
(Future: event broker integration)
```

Source: `bounded-context-map.yaml` relationships filtered for this context.

### Section 7: Scenario Tracing (Optional)

```markdown
## Scenario Tracing

{Include scenario-tracing.yaml content}
```

This section helps CODE understand which scenario exercises which endpoint, what error codes to expect, and which requirements are validated. Include if context budget allows.

## Assembly Rules

1. **Sections 1-5 are MANDATORY.** Always include.
2. **Section 6 is MANDATORY** if context has relationships.
3. **Section 7 is OPTIONAL** — include if total prompt stays under ~8K tokens.
4. **Total prompt target: 4K-8K tokens.** This leaves ample room for CODE KB instructions within the context window.
5. **Language: English.** Even if original requirements were in Spanish, the prompt for CODE is in English (code and API conventions are English).

## What NOT to Include

- Implementation details (no "use Spring Data JPA" — that's CODE's job)
- Technology choices beyond what's in manifest variants
- Other contexts' full artifacts (only reference contracts)
- DESIGN-phase metadata (enrichment questions, gap analysis)
- Normalized requirements (already digested into aggregates and BDD)
