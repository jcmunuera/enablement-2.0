---
id: skill-041-add-api-exposure-java-spring
version: 1.0.0
type: transformation
target_capability: api-exposure
compatible_with:
  - architecture.hexagonal-base
tags:
  artifact-type: transformation
  stack: java-spring
  capability: api-exposure
---

# skill-041-add-api-exposure-java-spring

## Overview

**Skill ID:** skill-041-add-api-exposure-java-spring  
**Type:** TRANSFORMATION  
**Target Capability:** api-exposure  
**Stack:** Java Spring

---

## Purpose

Promotes an existing internal microservice to a public API by adding REST endpoints, HATEOAS support, pagination, and OpenAPI specification.

---

## When to Use

✅ **Use this skill when:**
- Promoting internal microservice to external API
- User says "promote to API", "expose REST", "add HATEOAS"

❌ **Do NOT use when:**
- Creating new API from scratch (use skill-021)
- Code is not hexagonal architecture

---

## Features

| Feature | Module |
|---------|--------|
| rest-hateoas | mod-019 |

---

## Input Summary

```json
{
  "targetProject": "./customer-service",
  "apiLayer": "domain"
}
```

---

## Version

**Current:** 1.0.0  
**Model:** v2.0  
**Status:** Active
