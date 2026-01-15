---
skill_id: skill-040-add-resilience-java-spring
skill_name: Add Resilience Patterns
version: 1.0.0
date: 2025-01-15
author: Fusion C4E Team
status: active

# ═══════════════════════════════════════════════════════════════════
# MODEL v2.0 - Transformation Skill
# ═══════════════════════════════════════════════════════════════════
type: transformation
domain: code
layer: soi
stack: java-spring

# The capability this skill ADDS to existing code
target_capability: resilience

# What existing architecture this skill can work with
compatible_with:
  - architecture.hexagonal-base

tags:
  - transformation
  - resilience
  - circuit-breaker
  - retry
  - fault-tolerance
---

# Skill: Add Resilience Patterns

**Skill ID:** skill-040-add-resilience-java-spring  
**Type:** Transformation  
**Target Capability:** resilience  
**Version:** 1.0.0  
**Status:** Active

---

## Overview

Adds resilience patterns (circuit breaker, retry, timeout, rate limiter) to existing Java Spring microservice code. This is a **transformation skill** that modifies existing code rather than generating from scratch.

### When to Use

✅ **Use this skill when:**
- Adding fault tolerance to an existing microservice
- Protecting external service calls with resilience patterns
- User says "add resilience", "add circuit breaker", "add retry"
- Existing code lacks resilience patterns

❌ **Do NOT use when:**
- Creating a new service (use skill-020 or skill-021)
- Code is not Java Spring
- Code doesn't use hexagonal architecture

---

## Model v2.0

**Skill Type:** Transformation  
**Target Capability:** resilience  
**Compatible With:** architecture.hexagonal-base

> Transformation skills ADD capabilities to existing code. The `target_capability` 
> defines WHAT is added. The specific features within that capability are 
> determined from the user prompt.

---

## Target Capability

| Capability | Type | Transformable |
|------------|------|---------------|
| `resilience` | Compositional | Yes |

### Available Features

| Feature | Module | Keywords |
|---------|--------|----------|
| circuit-breaker | mod-code-001 | "circuit breaker", "CB" |
| retry | mod-code-002 | "retry", "reintento" |
| timeout | mod-code-003 | "timeout" |
| rate-limiter | mod-code-004 | "rate limit", "throttling" |

---

## Feature Resolution

The specific features to apply are determined from the user prompt:

| User Prompt | Features Applied |
|-------------|------------------|
| "Add circuit breaker" | resilience.circuit-breaker |
| "Add resilience" | ALL features |
| "Add retry and timeout" | resilience.retry, resilience.timeout |
| "Add fault tolerance" | ALL features (synonym) |
| "Add CB and retry" | resilience.circuit-breaker, resilience.retry |

### Resolution Algorithm

```python
def resolve_features(prompt, target_capability):
    """Extract features from prompt for the target capability."""
    
    features = []
    capability_def = load_capability(target_capability)
    
    # Check for full capability keywords
    if matches_any(prompt, capability_def.keywords):
        return capability_def.features.all()  # All features
    
    # Check for individual feature keywords
    for feature in capability_def.features:
        if matches_any(prompt, feature.keywords):
            features.append(feature)
    
    # If nothing specific found, ask for clarification
    if not features:
        ask_clarification("Which resilience patterns? (circuit breaker, retry, timeout, rate limiter)")
    
    return features
```

---

## Compatible Architecture

This skill requires the target code to use:

| Requirement | Check |
|-------------|-------|
| `architecture.hexagonal-base` | Verify hexagonal structure exists |
| Java Spring | Check pom.xml for Spring Boot |
| Adapter layer | Resilience is applied at adapter boundaries |

### Pre-Transformation Validation

```bash
# Check target project
1. Verify pom.xml exists and contains spring-boot-starter
2. Verify hexagonal structure: domain/, application/, adapter/
3. Identify adapter classes for external calls
4. Check for existing resilience patterns (avoid duplicates)
```

---

## Knowledge Dependencies

### ADR Compliance
- **ADR-004:** Resilience Patterns (circuit breaker, retry, timeout, rate limiter)

### Reference Implementations
- **ERI-008:** Circuit Breaker Java Resilience4j
- **ERI-009:** Retry Java Resilience4j
- **ERI-010:** Timeout Java Resilience4j
- **ERI-011:** Rate Limiter Java Resilience4j

---

## Input Specification

### Required

| Parameter | Type | Description |
|-----------|------|-------------|
| `targetProject` | path | Path to existing Java Spring project |

### Optional

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `features` | array | all | Specific features: ["circuit-breaker", "retry"] |
| `targetClasses` | array | auto-detect | Classes to apply resilience to |

### Example Input

```json
{
  "targetProject": "./customer-service",
  "features": ["circuit-breaker", "retry"],
  "targetClasses": ["CustomerSystemApiAdapter"]
}
```

---

## Output Specification

### Files Modified

| File | Change |
|------|--------|
| `pom.xml` | Add resilience4j dependencies |
| `application.yml` | Add resilience4j configuration |
| `*Adapter.java` | Add @CircuitBreaker, @Retry annotations |

### Files Created

| File | When |
|------|------|
| `infrastructure/config/ResilienceConfig.java` | Always |
| `infrastructure/config/CircuitBreakerConfig.java` | If circuit-breaker |
| `infrastructure/config/RetryConfig.java` | If retry |

### Traceability Output

| File | Content |
|------|---------|
| `.enablement/transformation-log.json` | What was changed |

---

## Execution Flow

This skill follows the **ADD** execution flow.

**See:** `runtime/flows/code/ADD.md`

### Skill-Specific Steps

1. **Validate Target Project**
   - Verify hexagonal structure
   - Verify Spring Boot project
   - Check for existing resilience

2. **Resolve Features**
   - Extract features from prompt
   - Map to modules via capability-index.yaml

3. **Identify Target Classes**
   - Scan adapter/ directory
   - Find classes with external calls
   - Filter by user specification (if provided)

4. **Apply Transformations**
   - Add dependencies to pom.xml
   - Add configuration to application.yml
   - Add annotations to target classes
   - Create config classes

5. **Validate Changes**
   - Compile modified code
   - Run Tier-3 validators
   - Generate transformation log

---

## Transformation Details

### Circuit Breaker Addition

```java
// BEFORE
public class CustomerSystemApiAdapter implements CustomerRepository {
    public Customer findById(String id) {
        return client.getCustomer(id);
    }
}

// AFTER
@Component
public class CustomerSystemApiAdapter implements CustomerRepository {
    
    @CircuitBreaker(name = "customerSystemApi", fallbackMethod = "findByIdFallback")
    public Customer findById(String id) {
        return client.getCustomer(id);
    }
    
    private Customer findByIdFallback(String id, Exception ex) {
        throw new SystemApiUnavailableException("Customer API unavailable", ex);
    }
}
```

### Retry Addition

```java
// Add to method
@Retry(name = "customerSystemApi")
@CircuitBreaker(name = "customerSystemApi", fallbackMethod = "findByIdFallback")
public Customer findById(String id) {
    return client.getCustomer(id);
}
```

### Annotation Order

Per ADR-004, annotations MUST be in this order:
```
@RateLimiter
@CircuitBreaker
@TimeLimiter
@Retry
```

---

## Validation

### Pre-Transformation
- [ ] Target project exists
- [ ] Is Spring Boot project
- [ ] Has hexagonal structure
- [ ] No duplicate resilience patterns

### Post-Transformation
- [ ] Code compiles
- [ ] Resilience4j dependencies added
- [ ] Configuration valid
- [ ] Annotations applied correctly
- [ ] Fallback methods exist

### Tier-3 Validators

| Validator | Module | Check |
|-----------|--------|-------|
| circuit-breaker-check.sh | mod-001 | @CircuitBreaker present, fallback exists |
| retry-check.sh | mod-002 | @Retry present, config valid |
| timeout-check.sh | mod-003 | Timeout config valid |
| rate-limiter-check.sh | mod-004 | @RateLimiter present |

---

## Error Handling

| Error | Cause | Recovery |
|-------|-------|----------|
| Not hexagonal | Missing expected structure | Reject with explanation |
| Not Spring | No Spring Boot in pom.xml | Reject with explanation |
| Already has resilience | Patterns already present | Ask what to do (skip/override) |
| Compile failure | Invalid transformation | Rollback changes, report error |

---

## Related Skills

| Skill | Relationship |
|-------|--------------|
| skill-020 | Generates microservice that can receive resilience |
| skill-021 | Generates API that can receive resilience |
| skill-041 | Adds API exposure (different capability) |

---

## Deprecates

This skill replaces:
- **skill-001-circuit-breaker-java-resilience4j** (atomic, single-feature)

The old skill was feature-level (just circuit breaker). This new skill is 
capability-level (all resilience features) per Model v2.0.

---

## Changelog

### Version 1.0.0 (2025-01-15)
- Initial version (Model v2.0)
- Replaces skill-001-circuit-breaker
- Capability-level transformation skill
- Supports all resilience features
