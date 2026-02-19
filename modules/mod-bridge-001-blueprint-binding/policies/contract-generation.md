# Contract Generation Policy

## Purpose

Defines rules for translating DDD aggregate definitions into OpenAPI 3.0 contracts. This process is **template-driven** — the binding provides mechanical mappings, not creative interpretation.

## Input

- `aggregate-definitions.yaml` for one bounded context
- Methodology binding file (e.g., `fusion-api-rest.ddd-bdd.yaml`)

## Resource Path Derivation

```
aggregate_root.id → kebab-case → plural → resource path

Examples:
  aggregate id: "card"          → /cards
  aggregate id: "transfer"      → /transfers
  aggregate id: "periodic-transfer" → /periodic-transfers
  aggregate id: "account"       → /accounts
```

Pluralization rules:
- Standard English plural (add -s or -es)
- If aggregate ID is already plural, keep as-is
- If ambiguous, prefer the form that reads naturally as a REST resource

## Endpoint Derivation

### Commands → Endpoints

For each command in the aggregate:

| Command type | Detection | Method | Path | Request body |
|-------------|-----------|--------|------|-------------|
| Create | command.id starts with `create-` | POST | `/{resource}` | All command `input` fields |
| State change | command.id starts with `block-`, `pause-`, `resume-`, `cancel-`, `activate-`, `reactivate-`, `suspend-`, `deactivate-`, `execute-` | POST | `/{resource}/{id}/{action}` | Command `input` fields minus entity ID |
| Delete | command.id starts with `delete-` or `remove-` | DELETE | `/{resource}/{id}` | None |
| Update | command.id starts with `update-` or `modify-` | PUT | `/{resource}/{id}` | All command `input` fields minus entity ID |

Where `{action}` is derived from the command verb:
```
block-card       → /cards/{cardId}/block
pause-periodic-transfer → /periodic-transfers/{periodicTransferId}/pause
execute-transfer → /transfers (this is a CREATE, not state change)
```

**Special case: `execute-` prefix.** If the command creates a new entity (has no pre-existing entity ID in input), treat as CREATE (POST /{resource}). If it operates on an existing entity, treat as state change.

### Queries → Endpoints

For each query in the aggregate:

| Query type | Detection | Method | Path | Params |
|-----------|-----------|--------|------|--------|
| Get by ID | query.id starts with `get-` AND has required ID input | GET | `/{resource}/{id}` | None (ID in path) |
| List | query.id starts with `list-` OR `search-` | GET | `/{resource}` | Optional filters as query params |
| List paginated | List query + aggregate has pagination indicators | GET | `/{resource}?page=&size=` | Filters + page + size |

## Request/Response Schema Derivation

### Request body (for commands)

```yaml
# From command input fields:
input:
  - name: "originAccount"
    type: "Account"
    required: true
  - name: "amount"
    type: "Money"
    required: true

# Becomes OpenAPI schema:
CreateTransferRequest:
  type: object
  required: [originAccount, amount]
  properties:
    originAccount:
      type: string      # References resolve to string IDs
    amount:
      $ref: '#/components/schemas/Money'
```

Type mapping:
| DDD type | OpenAPI type |
|----------|-------------|
| String | `type: string` |
| Integer | `type: integer` |
| Money | `$ref: Money` (object with amount + currency) |
| Date / LocalDate | `type: string, format: date` |
| UUID | `type: string, format: uuid` |
| Boolean | `type: boolean` |
| Email | `type: string, format: email` |
| Binary | `type: string, format: binary` |
| Enum values listed | `type: string, enum: [values]` |
| Entity reference (as input) | `type: string` (ID reference) |
| List<X> | `type: array, items: {X schema}` |

### Response body (for queries)

Derive from aggregate's entity/value object definitions:
- Entity fields → response properties
- Value objects → embedded object schemas
- List queries → array wrapper (with pagination if applicable)

### Error responses

From invariants and binding `error_handling`:

```yaml
# Invariant:
- id: "balance-check-above-limit"
  enforced_by: domain-service

# Becomes:
responses:
  '400':
    description: "Business rule violation"
    content:
      application/json:
        schema:
          $ref: '#/components/schemas/ErrorResponse'
        example:
          code: "BALANCE_CHECK_ABOVE_LIMIT"
          message: "Insufficient balance for transfer amount"
```

Error code derivation: `invariant.id` → UPPER_SNAKE_CASE

Skip invariants with `enforced_by: query-validation` — these are input validation errors, covered by the generic 400 validation error response.

## Pagination Schema

For paginated list queries:

```yaml
PagedResponse:
  type: object
  properties:
    content:
      type: array
      items:
        $ref: '#/components/schemas/{Entity}'
    page:
      type: integer
    size:
      type: integer
    totalElements:
      type: integer
    totalPages:
      type: integer
```

## OpenAPI Structure

Use the template `openapi-base.yaml.tpl` and fill:

```yaml
openapi: "3.0.3"
info:
  title: "{Context Name} API"
  description: "{Context description from context-map}"
  version: "1.0.0"

paths:
  # Generated endpoints (sorted: commands first, then queries)

components:
  schemas:
    # Entity schemas (from aggregate entities + value objects)
    # Request schemas (from command inputs)
    # Response schemas (from query outputs)
    # Error schema (standard)
    # Pagination schema (if any paginated query)
    Money:
      type: object
      properties:
        amount:
          type: number
        currency:
          type: string
    ErrorResponse:
      type: object
      required: [code, message]
      properties:
        code:
          type: string
        message:
          type: string
```

## Validation

Run `contract-check.sh`:
- Valid OpenAPI 3.0 YAML
- Every command has a corresponding endpoint
- Every query has a corresponding endpoint
- Every invariant (enforced_by: aggregate-root or domain-service) has an error code in responses
- No orphan schemas (every schema referenced somewhere)
