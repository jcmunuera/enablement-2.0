---
id: skill-040-add-resilience-java-spring
version: 1.0.0
type: transformation
target_capability: resilience
compatible_with:
  - architecture.hexagonal-base
tags:
  artifact-type: transformation
  stack: java-spring
  capability: resilience
---

# skill-040-add-resilience-java-spring

## Overview

**Skill ID:** skill-040-add-resilience-java-spring  
**Type:** TRANSFORMATION  
**Target Capability:** resilience  
**Stack:** Java Spring + Resilience4j

---

## Purpose

Adds resilience patterns (circuit breaker, retry, timeout, rate limiter) to existing Java Spring microservice code with hexagonal architecture.

---

## When to Use

✅ **Use this skill when:**
- Adding fault tolerance to existing microservice
- User says "add resilience", "add circuit breaker", "add retry"
- Protecting external service calls

❌ **Do NOT use when:**
- Creating new service (use skill-020/021)
- Code is not hexagonal architecture
- Code already has resilience patterns

---

## Features

| Feature | Applies When |
|---------|--------------|
| circuit-breaker | "circuit breaker", "CB" |
| retry | "retry", "reintento" |
| timeout | "timeout" |
| rate-limiter | "rate limit" |

If no specific feature mentioned, ALL are applied.

---

## Input Summary

```json
{
  "targetProject": "./customer-service",
  "features": ["circuit-breaker", "retry"]
}
```

---

## Replaces

- skill-001-circuit-breaker-java-resilience4j (deprecated)

---

## Version

**Current:** 1.0.0  
**Model:** v2.0  
**Status:** Active
