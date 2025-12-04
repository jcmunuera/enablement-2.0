# Feature: Resilience

**Feature ID:** resilience  
**Version:** 1.0  
**Based on:** ADR-004

---

## Overview

Provides resilience patterns for fault tolerance in microservices. Includes circuit breaker, retry, timeout, bulkhead, and rate limiting patterns.

---

## Sub-Features

### circuit_breaker

Prevents cascade failures by failing fast when a dependency is unavailable.

```json
{
  "features": {
    "resilience": {
      "circuit_breaker": {
        "enabled": true,
        "pattern": "basic_fallback"
      }
    }
  }
}
```

**Pattern Options:**

| Pattern | Description | Use When |
|---------|-------------|----------|
| `basic_fallback` | Single fallback method | Simple degraded response |
| `fail_fast` | No fallback, fail immediately | Prefer failure over stale data |
| `multiple_fallbacks` | Tiered fallback chain | Complex recovery logic |

**Generates:**
- Resilience4j configuration
- Circuit breaker annotations
- Fallback methods
- Metrics endpoints

**Module:** mod-001-circuit-breaker-java-resilience4j

---

### retry

Automatically retries failed operations with configurable backoff.

```json
{
  "features": {
    "resilience": {
      "retry": {
        "enabled": true,
        "strategy": "exponential_backoff",
        "maxAttempts": 3
      }
    }
  }
}
```

**Strategy Options:**

| Strategy | Description |
|----------|-------------|
| `fixed_delay` | Constant delay between retries |
| `exponential_backoff` | Increasing delay (1s, 2s, 4s...) |
| `random_delay` | Randomized delay to avoid thundering herd |

**Module:** mod-002-retry-java-resilience4j

---

### timeout

Limits execution time to prevent hanging operations.

```json
{
  "features": {
    "resilience": {
      "timeout": {
        "enabled": true,
        "strategy": "client_level",
        "duration": "10s",
        "connectTimeout": "5s"
      }
    }
  }
}
```

**Strategy Options:**

| Strategy | Description | Module | Use When |
|----------|-------------|--------|----------|
| `client_level` | HTTP client timeouts (RestClient/RestTemplate/WebClient) | mod-018-api-integration-rest-java-spring | **Default for new projects.** Simpler, synchronous code |
| `timelimiter` | Resilience4j @TimeLimiter annotation | mod-003-timeout-java-resilience4j | Need per-method control, fallback methods, or async patterns |

**Configuration Parameters:**

| Parameter | Applies To | Description | Default |
|-----------|-----------|-------------|---------|
| `duration` | Both | Read/operation timeout | `10s` |
| `connectTimeout` | client_level | Connection establishment timeout | `5s` |
| `cancelRunningFuture` | timelimiter | Cancel future on timeout | `true` |

**Default Strategy:** `client_level` (simpler for synchronous System API calls)

**Important:** `timelimiter` strategy requires methods to return `CompletableFuture<T>`, which adds complexity. Use only when async patterns are already in place or per-method timeout control is required.

**Modules:** 
- mod-003-timeout-java-resilience4j (timelimiter strategy)
- mod-018-api-integration-rest-java-spring (client_level strategy)

---

### bulkhead

Limits concurrent executions to isolate failures.

```json
{
  "features": {
    "resilience": {
      "bulkhead": {
        "enabled": true,
        "type": "semaphore",
        "maxConcurrentCalls": 25
      }
    }
  }
}
```

**Type Options:**

| Type | Description |
|------|-------------|
| `semaphore` | Limits concurrent calls (lighter) |
| `threadpool` | Dedicated thread pool (heavier, more isolation) |

**Module:** mod-005-bulkhead-java-resilience4j (future)

---

### rate_limiter

Limits the rate of calls to protect resources.

```json
{
  "features": {
    "resilience": {
      "rate_limiter": {
        "enabled": true,
        "limitForPeriod": 100,
        "limitRefreshPeriod": "1s"
      }
    }
  }
}
```

**Module:** mod-004-rate-limiter-java-resilience4j

---

## Dependencies

| ADR | Relationship |
|-----|--------------|
| ADR-004 | Defines resilience patterns and when to use them |

---

## Modules

| Sub-Feature | Module | ERI | Status |
|-------------|--------|-----|--------|
| circuit_breaker | mod-001-circuit-breaker-java-resilience4j | ERI-CODE-008 | ✅ Active |
| retry | mod-002-retry-java-resilience4j | ERI-CODE-009 | ✅ Active |
| timeout | mod-003-timeout-java-resilience4j | ERI-CODE-010 | ✅ Active |
| rate_limiter | mod-004-rate-limiter-java-resilience4j | ERI-CODE-011 | ✅ Active |
| bulkhead | mod-005-bulkhead-java-resilience4j | - | 🔜 Planned |

---

## Skills Using This Feature

| Skill | Usage |
|-------|-------|
| skill-001 | Add circuit breaker to existing service |
| skill-020 | Generate new service with resilience |
| skill-002 (future) | Add retry to existing service |

---

## Recommended Combinations

### For Domain API (External Calls)
```json
{
  "resilience": {
    "circuit_breaker": { "enabled": true, "pattern": "basic_fallback" },
    "timeout": { 
      "enabled": true, 
      "strategy": "client_level",
      "duration": "10s",
      "connectTimeout": "5s"
    }
  }
}
```

### For Composable API (Multiple Domain Calls)
```json
{
  "resilience": {
    "circuit_breaker": { "enabled": true, "pattern": "multiple_fallbacks" },
    "retry": { "enabled": true, "strategy": "exponential_backoff" },
    "timeout": { "enabled": true, "duration": "10s" },
    "bulkhead": { "enabled": true, "type": "semaphore" }
  }
}
```

### For Experience API (BFF)
```json
{
  "resilience": {
    "circuit_breaker": { "enabled": true, "pattern": "basic_fallback" },
    "timeout": { "enabled": true, "duration": "3s" }
  }
}
```

---

## Configuration Reference

### Resilience4j Circuit Breaker Defaults

```yaml
resilience4j:
  circuitbreaker:
    instances:
      default:
        slidingWindowType: COUNT_BASED
        slidingWindowSize: 100
        failureRateThreshold: 50
        waitDurationInOpenState: 30s
        permittedNumberOfCallsInHalfOpenState: 10
        slowCallRateThreshold: 100
        slowCallDurationThreshold: 2s
```

### Resilience4j Retry Defaults

```yaml
resilience4j:
  retry:
    instances:
      default:
        maxAttempts: 3
        waitDuration: 1s
        enableExponentialBackoff: true
        exponentialBackoffMultiplier: 2
```

---

## Validation Rules

```yaml
circuit_breaker:
  - must have fallback method if pattern != fail_fast
  - should have metrics enabled for observability

retry:
  - maxAttempts should be >= 2
  - should not retry on non-idempotent operations

timeout:
  - duration should be reasonable (1s - 30s)
  - should be shorter than client timeout

bulkhead:
  - maxConcurrentCalls should match expected load

rate_limiter:
  - should have sensible limits based on capacity
```

---

## Example Full Configuration

```json
{
  "serviceName": "order-service",
  "apiType": "composable_api",
  
  "features": {
    "resilience": {
      "circuit_breaker": {
        "enabled": true,
        "pattern": "multiple_fallbacks",
        "config": {
          "slidingWindowSize": 50,
          "failureRateThreshold": 60,
          "waitDurationInOpenState": "20s"
        }
      },
      "retry": {
        "enabled": true,
        "strategy": "exponential_backoff",
        "maxAttempts": 3,
        "initialDelay": "500ms"
      },
      "timeout": {
        "enabled": true,
        "duration": "10s"
      },
      "bulkhead": {
        "enabled": true,
        "type": "semaphore",
        "maxConcurrentCalls": 50
      }
    }
  }
}
```

---

## Changelog

### v1.1 (2025-11-28)
- Added ERI-CODE-009 (Retry) and mod-002
- Added ERI-CODE-010 (Timeout) and mod-003
- Added ERI-CODE-011 (Rate Limiter) and mod-004
- All resilience patterns now active except Bulkhead

### v1.0 (2025-11-24)
- Initial feature definition
- Circuit breaker fully documented (mod-001 ready)
- Other patterns planned
