# Validation - skill-040-add-resilience-java-spring

## Overview

This directory contains validation scripts for the resilience transformation skill.

## Scripts

| Script | Purpose |
|--------|---------|
| `validate.sh` | Main validation script |

## Usage

```bash
./validate.sh /path/to/project
```

## Checks Performed

### 1. Project Structure
- pom.xml exists
- src/main/java exists
- Hexagonal structure (adapter/ directory)

### 2. Dependencies
- resilience4j-spring-boot3 in pom.xml
- spring-boot-starter-aop in pom.xml

### 3. Configuration
- resilience4j section in application.yml
- circuitbreaker/retry/timeout/ratelimiter configs

### 4. Annotations
- @CircuitBreaker present on adapter methods
- fallbackMethod defined for each @CircuitBreaker
- @Retry present where configured

### 5. ADR-004 Compliance
- Annotation order: @RateLimiter > @CircuitBreaker > @TimeLimiter > @Retry
- Fallback methods have correct signature

### 6. Compilation
- `mvn compile` succeeds

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All validations passed |
| N | N validation errors found |

## Integration

This validation is called automatically after transformation by the Enablement 2.0 runtime.
