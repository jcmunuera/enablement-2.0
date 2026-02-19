# BDD Scenarios — Gherkin Generation Policies

**Module:** mod-design-004-bdd-scenarios
**Version:** 1.0
**Source ADR:** adr-design-004-behavior-validation
**Source ERI:** eri-design-004-bdd-scenarios

---

## Purpose

You are a BDD scenario generator. Your task is to produce Gherkin scenarios from DDD artifacts (commands, invariants, queries) and a traceability mapping. Every scenario traces back to a requirement, a DDD element, and a target API endpoint.

You MUST follow ALL rules in this document. Use the examples in `examples/` as reference.

---

## Input

- `aggregate-definitions.yaml` — commands, queries, invariants, events (from mod-design-002)
- `bounded-context-map.yaml` — ubiquitous language, capabilities (from mod-design-001)
- `api-mapping.yaml` — API endpoints for tracing (from mod-design-003, if available)

Process each aggregate sequentially.

**Scope:** Generate BDD scenarios ONLY for contexts that have an `aggregate-definitions.yaml` with at least one command OR one query. Skip integration-only contexts that were excluded from tactical design (GENERIC subdomains).

---

## Output

Per aggregate, produce two files:

1. **`{context-id}/{aggregate-id}.feature`** — Gherkin scenarios
2. **`{context-id}/scenario-tracing.yaml`** — Traceability mapping

---

## Generation Rules

Generate scenarios in this EXACT order of categories:

| # | Category | Source | Minimum Count |
|---|----------|--------|---------------|
| 1 | Happy path per command | Each command in aggregate | 1 per command |
| 2 | Happy path per query | Each query in aggregate | 1 per query |
| 3 | Validation errors | Each command's required inputs | 1 per command |
| 4 | Business rule violations | Each invariant (enforced_by: aggregate-root or domain-service ONLY) | 1 per invariant |
| 5 | Not found | Each query/command with a required ID filter | 1 per ID-targeting operation (MANDATORY) |
| 6 | Integration | Each system API dependency | 1 per system API |
| 7 | Pagination | Each query with pagination=true | 1 per paginated query |

### Category Details

**Category 1 — Happy path (commands):**
- One scenario per command showing successful execution
- Given sets up preconditions (existing or non-existing entities as needed)
- When submits the command by name with input data
- Then asserts success outcome + event published
- Use data tables for commands with 3+ input fields

**Category 2 — Happy path (queries):**
- One scenario per query showing successful retrieval
- Given ensures data exists
- When submits the query by name
- Then asserts data returned correctly

**Category 3 — Validation errors:**
- One scenario per command showing rejection of invalid input
- Focus on missing required fields
- Then asserts rejection with specific error code from error_cases

**Category 4 — Business rule violations:**
- One scenario per invariant showing the rule being violated
- **Only for invariants with `enforced_by: aggregate-root` or `enforced_by: domain-service`**
- **Skip invariants with `enforced_by: query-validation`** — these are tested through query validation scenarios (Category 3/5)
- Given sets up the precondition that triggers the invariant
- When submits the command that would violate it
- Then asserts rejection with the error code linked to the invariant

**Category 5 — Not found:**
- For queries/commands that target a **single** existing entity by ID (Get/Search queries, not List queries)
- **MANDATORY** for every Get/Search query with a required identifier filter (field name ends in `Id` or type is `UUID`)
- List queries returning empty results are NOT errors — skip not-found for List queries
- Given asserts entity does not exist
- When submits the operation
- Then asserts NOT_FOUND error

**Category 6 — Integration (conditional):**
- Only when api-mapping.yaml has system_api_dependencies
- Tests that data flows to/from external systems
- Focus on the integration boundary, not implementation details

**Category 7 — Pagination:**
- For each query with `pagination: true`
- Given asserts multiple entities exist
- When submits paginated query
- Then asserts correct page size and metadata

---

## Gherkin Standards

### File Structure

```gherkin
# File: {context-id}/{aggregate-id}.feature
# Source: aggregate-definitions.yaml (context: {context-id}, aggregate: {aggregate-id})
# Tracing: scenario-tracing.yaml

Feature: {Aggregate Name} Management
  As the {Context Name} domain
  I want to manage {aggregate description — abbreviated}
  So that {business value from context capabilities}

  # ============================================================
  # HAPPY PATH — Commands
  # ============================================================

  Scenario: {Descriptive name}
    Given {precondition using ubiquitous language}
    When {command/query by name}
    Then {expected outcome}
```

### Writing Rules

1. **Use ubiquitous language** from bounded-context-map.yaml — terms from the context's glossary
2. **Reference commands by name** — "a CreateCustomer command is submitted" (not "the user creates")
3. **Reference queries by name** — "a GetCustomer query is submitted" (not "the user searches")
4. **Invariant violations produce named errors** — use error_cases.code from aggregate-definitions.yaml
5. **NO technology-specific details** — No HTTP codes (200, 404), no JSON, no SQL, no database names
6. **One behavior per scenario** — Single When step per scenario. Never multiple When steps.
7. **Data tables for complex input** — Use Gherkin data tables when a command has 3+ input fields
8. **Section separators** — Use comment blocks to separate categories visually

### Naming Convention for Scenarios

Use descriptive, behavior-focused names:
- ✅ "Register a new customer with valid data"
- ✅ "Reject duplicate customer email"
- ❌ "Test POST /customers returns 201" (technical)
- ❌ "Happy path 1" (meaningless)

---

## Scenario Tracing Schema

Each scenario MUST have a corresponding entry in `scenario-tracing.yaml`:

```yaml
version: "1.0"
bounded_context: "{context-id}"
aggregate: "{aggregate-id}"
scenarios:
  - id: "{scenario-kebab-id}"                   # Unique, kebab-case
    scenario: "{Exact scenario name from .feature}"
    category: "happy-path|validation|invariant|not-found|integration|pagination"
    validates_requirement: "{Capability from bounded-context-map.yaml}"
    exercises: "{command-id or query-id}"        # DDD element being tested
    tests_invariant: "{invariant-id}"            # Only for invariant category
    expected_error: "{ERROR_CODE}"               # Only for error scenarios
```

---

## Coverage Validation (the "hybrid" part)

After generating scenarios, validate minimum coverage:

```
FOR each command in aggregate-definitions.yaml:
  ASSERT: ≥1 scenario with category=happy-path exercises this command
  ASSERT: ≥1 scenario with category=validation exercises this command

FOR each query in aggregate-definitions.yaml:
  ASSERT: ≥1 scenario with category=happy-path exercises this query
  IF query is a Get/Search query (id starts with 'get-' or 'search-') AND has a required ID filter:
    ASSERT: ≥1 scenario with category=not-found exercises this query

FOR each invariant in aggregate-definitions.yaml WHERE enforced_by != 'query-validation':
  ASSERT: ≥1 scenario with tests_invariant=this invariant

FOR each system_api_dependency in api-mapping.yaml (if available):
  ASSERT: ≥1 scenario with category=integration
```

If gaps are found, generate additional scenarios to fill them.

---

## Anti-Patterns to Avoid

| Anti-Pattern | Description | Fix |
|-------------|-------------|-----|
| **Technical scenarios** | HTTP codes, JSON, SQL in scenarios | Use business language only |
| **Multiple behaviors** | Several When steps in one scenario | Split into separate scenarios |
| **Missing error coverage** | Commands without error/validation scenarios | Add per category rules |
| **Orphan scenarios** | Scenarios not in tracing YAML | Ensure 1:1 mapping |
| **Vague assertions** | "Then it works" or "Then no errors" | Be specific about outcome |
| **Implementation details** | "Then the database is updated" | "Then the customer is created" |

---

## Quality Checklist (self-validate before output)

- [ ] Every command has ≥1 happy-path scenario
- [ ] Every command-level invariant (enforced_by ≠ query-validation) has ≥1 violation scenario
- [ ] Every query has ≥1 happy-path scenario
- [ ] Every query with a required ID filter has ≥1 not-found scenario
- [ ] Error codes in scenarios match error_cases.code
- [ ] No HTTP codes, JSON, or database references in .feature
- [ ] Single When step per scenario
- [ ] scenario-tracing.yaml maps every scenario
- [ ] Ubiquitous language terms used where applicable
- [ ] Feature file is valid Gherkin syntax
