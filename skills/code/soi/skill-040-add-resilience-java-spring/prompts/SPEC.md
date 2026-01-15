# SPEC.md - LLM Prompt Specification

## Skill: skill-040-add-resilience-java-spring

**Version:** 1.0  
**Type:** Transformation  
**Updated:** 2025-01-15  

---

## Overview

This specification defines how an LLM should ADD resilience patterns to existing Java/Spring Boot code using the Enablement 2.0 Knowledge Base.

**Key Principle:** The LLM does NOT generate a new service. It **transforms existing code** by adding resilience annotations and configuration from MODULEs.

---

## Execution Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│ 1. RECEIVE transformation-request                                    │
│    - targetProject: path to existing service                        │
│    - features: which resilience patterns to add                     │
├─────────────────────────────────────────────────────────────────────┤
│ 2. VALIDATE target project                                           │
│    - Is it a Spring Boot project? (check pom.xml)                   │
│    - Has hexagonal architecture? (check structure)                  │
│    - Identify adapter classes with external calls                   │
├─────────────────────────────────────────────────────────────────────┤
│ 3. SELECT modules based on requested features                        │
│    - circuit-breaker → mod-code-001                                 │
│    - retry → mod-code-002                                           │
│    - timeout → mod-code-003                                         │
│    - rate-limiter → mod-code-004                                    │
├─────────────────────────────────────────────────────────────────────┤
│ 4. ANALYZE existing code                                             │
│    - Find adapter classes (adapter/out/*)                           │
│    - Identify methods calling external services                     │
│    - Check for existing resilience patterns                         │
├─────────────────────────────────────────────────────────────────────┤
│ 5. APPLY transformations                                             │
│    - Add dependencies to pom.xml                                    │
│    - Add configuration to application.yml                           │
│    - Add annotations to adapter methods                             │
│    - Create fallback methods                                        │
├─────────────────────────────────────────────────────────────────────┤
│ 6. VALIDATE output                                                   │
│    - Verify compilation                                             │
│    - Check annotation order (ADR-004)                               │
│    - Verify fallback methods exist                                  │
├─────────────────────────────────────────────────────────────────────┤
│ 7. OUTPUT transformation log                                         │
│    - Files modified                                                 │
│    - Changes applied                                                │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Module Resolution Rules

### Selected Based on Features

| Feature Requested | Module | What It Provides |
|-------------------|--------|------------------|
| circuit-breaker | mod-code-001-circuit-breaker-java-resilience4j | @CircuitBreaker, fallback patterns |
| retry | mod-code-002-retry-java-resilience4j | @Retry, backoff strategies |
| timeout | mod-code-003-timeout-java-resilience4j | @TimeLimiter, async patterns |
| rate-limiter | mod-code-004-rate-limiter-java-resilience4j | @RateLimiter, throttling |

### If "resilience" or "all" requested

Select ALL four modules.

---

## Transformation Rules

### 1. Dependencies (pom.xml)

Add if not present:

```xml
<dependency>
    <groupId>io.github.resilience4j</groupId>
    <artifactId>resilience4j-spring-boot3</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-aop</artifactId>
</dependency>
```

### 2. Configuration (application.yml)

Merge resilience4j configuration from module templates.

### 3. Annotations

Apply to adapter methods that call external services:

```java
// Order per ADR-004: @RateLimiter > @CircuitBreaker > @TimeLimiter > @Retry
@RateLimiter(name = "{{adapterName}}")
@CircuitBreaker(name = "{{adapterName}}", fallbackMethod = "{{methodName}}Fallback")
@TimeLimiter(name = "{{adapterName}}")
@Retry(name = "{{adapterName}}")
public {{ReturnType}} {{methodName}}({{params}}) {
    // existing code
}

// Add fallback method
private {{ReturnType}} {{methodName}}Fallback({{params}}, Exception ex) {
    throw new ServiceUnavailableException("Service unavailable", ex);
}
```

---

## Target Class Identification

### Auto-detect adapter classes

Look in:
- `adapter/out/persistence/*Adapter.java`
- `adapter/out/systemapi/*Adapter.java`
- `adapter/out/*Client.java`

### Methods to annotate

- Methods with `@Override` implementing repository interface
- Methods calling RestClient, WebClient, Feign, RestTemplate

---

## Validation Rules

### Pre-transformation

1. Project is Spring Boot (has spring-boot-starter-parent)
2. Has hexagonal structure (domain/, application/, adapter/)
3. No existing resilience4j dependency (or ask to override)

### Post-transformation

1. Code compiles (`mvn compile`)
2. Annotations in correct order
3. Each @CircuitBreaker has fallback method
4. Configuration is valid YAML

---

## Output Format

### Transformation Log

```json
{
  "skill": "skill-040-add-resilience-java-spring",
  "timestamp": "2025-01-15T10:00:00Z",
  "targetProject": "./customer-service",
  "features": ["circuit-breaker", "retry"],
  "filesModified": [
    {
      "path": "pom.xml",
      "changes": ["Added resilience4j-spring-boot3 dependency"]
    },
    {
      "path": "src/main/resources/application.yml",
      "changes": ["Added resilience4j.circuitbreaker config", "Added resilience4j.retry config"]
    },
    {
      "path": "src/main/java/.../CustomerSystemApiAdapter.java",
      "changes": ["Added @CircuitBreaker to findById", "Added @Retry to findById", "Added findByIdFallback method"]
    }
  ],
  "validation": {
    "compilation": "PASS",
    "annotationOrder": "PASS",
    "fallbackMethods": "PASS"
  }
}
```

---

## Error Handling

### Project validation fails

```
ERROR: Target project validation failed
Issue: Not a hexagonal architecture project
Expected: domain/, application/, adapter/ directories
Found: src/main/java/... (flat structure)
Action: This skill requires hexagonal architecture. Use skill-020 to generate a new service.
```

### Existing resilience detected

```
WARNING: Existing resilience patterns detected
File: CustomerSystemApiAdapter.java
Found: @CircuitBreaker annotation
Action: Skip this file? Override? (prompt user)
```

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-01-15 | Initial version for Model v2.0 |
