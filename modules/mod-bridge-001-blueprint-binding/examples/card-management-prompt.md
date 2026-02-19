# Service: Card Management

Self-service card operations for retail banking customers. Provides card portfolio viewing, movement history, PIN recall, and card lifecycle management (block, reactivate, cancel).

**Blueprint:** fusion-soi-platform
**Building block:** fusion-api-rest
**Tech stack:** java-spring-boot-3

---

## Domain Model

### Aggregate: Card
Card operations including lifecycle state management and information queries.

**Entity:** Card
Fields:
- cardId: UUID — Unique card identifier
- cardNumber: String — Masked card number
- cardType: CardType (CREDIT, DEBIT) — Type of card
- status: CardStatus (ACTIVE, BLOCKED, CANCELLED) — Current lifecycle state
- spendSummary: SpendSummary — Accumulated spend information

**Value Objects:**
- SpendSummary: consumedAmount (Money), pendingSettlement (Money, credit only), monthlyLimit (Money, debit only)
- Money: amount (Decimal), currency (String)
- CardMovement: date (Date), merchant (String), amount (Money), status (String)

**State Machine:**
States: ACTIVE, BLOCKED, CANCELLED
Transitions: ACTIVE→BLOCKED, BLOCKED→ACTIVE, ACTIVE→CANCELLED, BLOCKED→CANCELLED
Terminal: CANCELLED (irreversible)

---

## API Contract

See attached: `openapi-spec.yaml`

Summary of endpoints:
- GET /cards — List customer cards with spend summary
- GET /cards/{cardId}/transactions — List card transactions (paginated, date filter)
- GET /cards/{cardId}/pin — Retrieve card PIN
- POST /cards/{cardId}/block — Block an active card
- POST /cards/{cardId}/reactivate — Reactivate a blocked card
- POST /cards/{cardId}/cancel — Cancel a card (irreversible)

---

## Business Logic Specification

The following BDD scenarios define the expected behavior of this service.
Implement business logic that satisfies ALL scenarios.

```gherkin
Feature: Card Management

  Scenario: List customer cards with spend summary
    Given the customer has active cards in their portfolio
    When the customer requests their card list
    Then the system returns all cards with type, status, and spend summary

  Scenario: List card transactions with default pagination
    Given the customer has a card with transaction history
    When the customer requests transactions for the card
    Then the system returns the last 50 transactions
    And pagination information is included in the response

  Scenario: Filter card transactions by date range
    Given the customer has a card with transaction history
    When the customer requests transactions with a date range filter
    Then only transactions within the specified range are returned

  Scenario: Reject card transaction date range exceeding one year
    Given the customer has a card
    When the customer requests transactions with a date range exceeding one year
    Then the system rejects the request with CARD_DATE_RANGE_MAX_ONE_YEAR error

  Scenario: Reject card transaction date range with invalid order
    Given the customer has a card
    When the customer requests transactions with from-date after to-date
    Then the system rejects the request with CARD_DATE_RANGE_VALID_ORDER error

  Scenario: Retrieve card PIN for active card
    Given the customer has an active card
    When the customer requests the card PIN
    Then the system returns the PIN code

  Scenario: Reject PIN recall for non-active card
    Given the customer has a blocked card
    When the customer requests the card PIN
    Then the system rejects the request with ONLY_ACTIVE_FOR_PIN_RECALL error

  Scenario: Block an active card
    Given the customer has a card in ACTIVE status
    When the customer requests to block the card
    Then the card status changes to BLOCKED
    And a CardBlocked event is emitted

  Scenario: Reject blocking a non-active card
    Given the customer has a card in BLOCKED status
    When the customer requests to block the card
    Then the system rejects the request with BLOCK_ONLY_ACTIVE error

  Scenario: Reactivate a blocked card
    Given the customer has a card in BLOCKED status
    When the customer requests to reactivate the card
    Then the card status changes to ACTIVE
    And a CardReactivated event is emitted

  Scenario: Reject reactivating a non-blocked card
    Given the customer has a card in ACTIVE status
    When the customer requests to reactivate the card
    Then the system rejects the request with UNBLOCK_ONLY_BLOCKED error

  Scenario: Cancel an active card
    Given the customer has a card in ACTIVE status
    When the customer requests to cancel the card
    Then the card status changes to CANCELLED
    And a CardCancelled event is emitted

  Scenario: Cancel a blocked card
    Given the customer has a card in BLOCKED status
    When the customer requests to cancel the card
    Then the card status changes to CANCELLED
    And a CardCancelled event is emitted

  Scenario: Reject cancelling an already cancelled card
    Given the customer has a card in CANCELLED status
    When the customer requests to cancel the card
    Then the system rejects the request with CANCELLED_IS_TERMINAL error

  Scenario: Reject blocking a cancelled card
    Given the customer has a card in CANCELLED status
    When the customer requests to block the card
    Then the system rejects the request with BLOCK_ONLY_ACTIVE error

  Scenario: Paginate through card transactions
    Given the customer has a card with more than 50 transactions
    When the customer requests the second page of transactions
    Then the system returns the next 50 transactions
    And pagination indicates more pages available
```

---

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

Additional capabilities may be discovered from this prompt by CODE discovery.

---

## Integration Context

### Upstream dependencies (this service calls):
- **core-banking-gateway** (ACL): System API for card data, card movements, PIN retrieval, and card status operations. All card data is mastered in the core banking SoR.

### Domain Events:
- **CardBlocked** — Published when a card is blocked by the customer
- **CardReactivated** — Published when a blocked card is reactivated
- **CardCancelled** — Published when a card is permanently cancelled
