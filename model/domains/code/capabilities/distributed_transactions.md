# Capability: Distributed Transactions

## Overview

The Distributed Transactions capability provides patterns for maintaining data consistency across multiple services or systems without relying on traditional ACID transactions.

## Type

- **Type:** Compositional
- **Transformable:** Yes
- **Required:** No (opt-in for Domain APIs)

## Features

### saga-compensation

**Description:** Implements the SAGA pattern with compensation-based rollback. Each step in a distributed transaction has a corresponding compensation action that can undo its effects if a later step fails.

**Key Concepts:**
- **Saga:** A sequence of local transactions where each transaction updates data within a single service
- **Compensation:** An action that semantically undoes the effect of a previous action
- **Eventual Consistency:** The system reaches consistency after all compensations complete

**When to Use:**
- Multi-service transactions that span business boundaries
- Long-running business processes
- Operations that can be logically reversed

**When NOT to Use:**
- Simple single-service operations
- Operations that cannot be compensated (e.g., sending email)
- When strong consistency is strictly required

**Module:** `mod-code-020-compensation-java-spring`

**Related ADR:** [adr-013-distributed-transactions](../../../knowledge/ADRs/adr-013-distributed-transactions/ADR.md)

### saga-orchestration (Future)

**Description:** SAGA pattern with a central orchestrator that coordinates the transaction steps. The orchestrator maintains the state machine and directs participants.

**Differences from Compensation:**
- Centralized coordination vs. choreography
- Explicit state machine
- Better visibility into transaction state

### two-phase-commit (Future)

**Description:** Traditional 2PC for scenarios requiring strong consistency with XA-compatible resources. Use sparingly due to blocking nature.

## Usage

### Availability by API Type

| API Type | Compensation Available | Default |
|----------|----------------------|---------|
| Domain API | ✅ Yes | Opt-in via config |
| System API | ❌ No | - |
| Experience API | ❌ No | - |
| Composable API | ❌ No | - |

### In Discovery

```yaml
# Inferred when:
# - API type is Domain API
# - User mentions: saga, compensation, distributed transaction
# - Config enables: features.compensation.enabled = true
```

### In Generation

When enabled, generates:
- `CompensatableOperation` interface
- `CompensationRegistry` for tracking
- `SagaCoordinator` for orchestration
- Compensation annotations and aspects

## Pattern Details

### Compensation Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SAGA WITH COMPENSATION                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Happy Path:                                                        │
│  ┌──────┐    ┌──────┐    ┌──────┐    ┌──────┐                     │
│  │Step 1│───▶│Step 2│───▶│Step 3│───▶│Success│                     │
│  └──────┘    └──────┘    └──────┘    └──────┘                     │
│                                                                     │
│  Failure at Step 3:                                                 │
│  ┌──────┐    ┌──────┐    ┌──────┐                                 │
│  │Step 1│───▶│Step 2│───▶│Step 3│──╳ (fails)                      │
│  └──────┘    └──────┘    └──────┘                                 │
│      │           │                                                  │
│      │           ▼                                                  │
│      │     ┌──────────┐                                            │
│      │     │Compensate│                                            │
│      │     │  Step 2  │                                            │
│      │     └──────────┘                                            │
│      ▼                                                              │
│  ┌──────────┐                                                      │
│  │Compensate│                                                      │
│  │  Step 1  │                                                      │
│  └──────────┘                                                      │
│      │                                                              │
│      ▼                                                              │
│  ┌──────────┐                                                      │
│  │ Rollback │                                                      │
│  │ Complete │                                                      │
│  └──────────┘                                                      │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Code Example

```java
@CompensatableOperation(
    name = "createCustomer",
    compensation = "deleteCustomer"
)
public Customer createCustomer(CreateCustomerRequest request) {
    // Forward operation
    return customerRepository.save(customer);
}

@Compensation
public void deleteCustomer(Customer customer) {
    // Compensation operation
    customerRepository.delete(customer.getId());
}
```

## Compatibility

- **Requires:** `architecture.hexagonal-light`
- **Works with:** All persistence features
- **Works with:** All resilience features

## Implementation Matrix

| Feature | Java Spring | Java Quarkus | Node.js |
|---------|-------------|--------------|---------|
| saga-compensation | ✅ mod-020 | 🔜 Planned | - |
| saga-orchestration | 🔜 Planned | - | - |
| two-phase-commit | 🔜 Planned | - | - |

## Decision Rationale

SAGA with compensation was chosen as the primary pattern because:

1. **No Distributed Locks:** Avoids the availability issues of 2PC
2. **Service Autonomy:** Each service manages its own transactions
3. **Resilience:** System can recover from partial failures
4. **Scalability:** No central coordinator bottleneck

See [ADR-013](../../../knowledge/ADRs/adr-013-distributed-transactions/ADR.md) for detailed decision record.
