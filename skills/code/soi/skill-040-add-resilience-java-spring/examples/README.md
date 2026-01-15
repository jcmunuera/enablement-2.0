# Examples - skill-040-add-resilience-java-spring

## Overview

This directory contains example transformations showing before/after states.

## Examples

### Example 1: Add Circuit Breaker and Retry

**Input:** A microservice with System API adapter but no resilience patterns.

**Request:**
```json
{
  "targetProject": "./customer-service",
  "features": ["circuit-breaker", "retry"]
}
```

**Before (CustomerSystemApiAdapter.java):**
```java
@Component
public class CustomerSystemApiAdapter implements CustomerRepository {
    
    private final CustomerClient client;
    
    public Customer findById(String id) {
        return client.getCustomer(id);
    }
    
    public List<Customer> findAll() {
        return client.getAllCustomers();
    }
}
```

**After (CustomerSystemApiAdapter.java):**
```java
@Component
public class CustomerSystemApiAdapter implements CustomerRepository {
    
    private static final Logger log = LoggerFactory.getLogger(CustomerSystemApiAdapter.class);
    private final CustomerClient client;
    
    @CircuitBreaker(name = "customerSystemApi", fallbackMethod = "findByIdFallback")
    @Retry(name = "customerSystemApi")
    public Customer findById(String id) {
        return client.getCustomer(id);
    }
    
    private Customer findByIdFallback(String id, Exception ex) {
        log.error("Fallback for findById({}): {}", id, ex.getMessage());
        throw new ServiceUnavailableException("Customer service unavailable", ex);
    }
    
    @CircuitBreaker(name = "customerSystemApi", fallbackMethod = "findAllFallback")
    @Retry(name = "customerSystemApi")
    public List<Customer> findAll() {
        return client.getAllCustomers();
    }
    
    private List<Customer> findAllFallback(Exception ex) {
        log.error("Fallback for findAll(): {}", ex.getMessage());
        throw new ServiceUnavailableException("Customer service unavailable", ex);
    }
}
```

**Added to application.yml:**
```yaml
resilience4j:
  circuitbreaker:
    instances:
      customerSystemApi:
        registerHealthIndicator: true
        slidingWindowSize: 10
        minimumNumberOfCalls: 5
        failureRateThreshold: 50
        waitDurationInOpenState: 5s
  retry:
    instances:
      customerSystemApi:
        maxAttempts: 3
        waitDuration: 500ms
        enableExponentialBackoff: true
```

---

### Example 2: Add All Resilience Patterns

**Request:**
```json
{
  "targetProject": "./account-service",
  "features": ["circuit-breaker", "retry", "timeout", "rate-limiter"]
}
```

**After (AccountSystemApiAdapter.java):**
```java
@RateLimiter(name = "accountSystemApi")
@CircuitBreaker(name = "accountSystemApi", fallbackMethod = "getBalanceFallback")
@TimeLimiter(name = "accountSystemApi")
@Retry(name = "accountSystemApi")
public CompletableFuture<BigDecimal> getBalance(String accountId) {
    return CompletableFuture.supplyAsync(() -> client.getBalance(accountId));
}
```

> Note: @TimeLimiter requires CompletableFuture return type.

---

## Directory Structure

```
examples/
├── README.md                           # This file
├── example-01-circuit-breaker-retry/   # (future)
│   ├── before/                         # Original project
│   ├── after/                          # Transformed project
│   └── request.json                    # Transformation request
└── example-02-all-patterns/            # (future)
    ├── before/
    ├── after/
    └── request.json
```

## Running Examples

```bash
# Validate transformation result
../validation/validate.sh ./example-01-circuit-breaker-retry/after
```
