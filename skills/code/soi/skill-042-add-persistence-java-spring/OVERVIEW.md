---
id: skill-042-add-persistence-java-spring
version: 1.0.0
type: transformation
target_capability: persistence
compatible_with:
  - architecture.hexagonal-base
tags:
  artifact-type: transformation
  stack: java-spring
  capability: persistence
---

# skill-042-add-persistence-java-spring

## Overview

**Skill ID:** skill-042-add-persistence-java-spring  
**Type:** TRANSFORMATION  
**Target Capability:** persistence  
**Stack:** Java Spring

---

## Purpose

Adds persistence capabilities (JPA or System API integration) to an existing Java Spring microservice with hexagonal architecture.

---

## When to Use

✅ **Use this skill when:**
- Adding database persistence to existing service
- Integrating with backend System APIs
- User says "add persistence", "add JPA", "add System API"

❌ **Do NOT use when:**
- Creating new service (use skill-020/021)
- Service already has persistence

---

## Features

| Feature | Module | Keywords |
|---------|--------|----------|
| jpa | mod-016 | "JPA", "database" |
| systemapi | mod-017 | "System API", "backend" |

> Features are mutually exclusive.

---

## Input Summary

```json
{
  "targetProject": "./customer-service",
  "persistenceType": "jpa"
}
```

---

## Version

**Current:** 1.0.0  
**Model:** v2.0  
**Status:** Active
