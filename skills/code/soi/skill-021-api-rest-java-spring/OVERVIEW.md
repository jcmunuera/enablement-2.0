---
id: skill-021-api-rest-java-spring
version: 3.0.0
type: generation
required_capabilities:
  - architecture.hexagonal-base
  - api-exposure.rest-hateoas
tags:
  artifact-type: api
  runtime-model: request-response
  stack: java-spring
  protocol: rest
  api-model: fusion
---

# skill-021-api-rest-java-spring

## Overview

**Skill ID:** skill-021-api-rest-java-spring  
**Type:** GENERATION  
**Stack:** Java Spring Boot  
**Protocol:** REST with HATEOAS

---

## Purpose

Generates a complete Fusion REST API microservice following the 4-layer API model (Experience, Composable, Domain, System) defined in ADR-001.

---

## When to Use

✅ **Use this skill when:**
- User mentions "Fusion" + API layer (Domain/System/BFF/Experience/Composable)
- Creating external-facing APIs with HATEOAS, pagination

⚠️ **ASK for clarification when:**
- User mentions API layer WITHOUT "Fusion"

❌ **Do NOT use when:**
- Creating internal microservices → use skill-020
- Adding features to existing code → use transformation skills (040-042)

---

## Required Capabilities (Model v2.0)

| Capability | Module |
|------------|--------|
| architecture.hexagonal-base | mod-code-015 |
| api-exposure.rest-hateoas | mod-code-019 |

Additional capabilities (resilience, persistence, compensation) are inferred from prompt/config.

---

## API Layers

| Layer | HATEOAS | Compensation |
|-------|---------|--------------|
| Experience | ✅ | ❌ |
| Composable | ❌ | ❌ |
| Domain | ✅ | ✅ (opt-in) |
| System | ❌ | ❌ |

---

## Output

- Complete Maven project structure
- Hexagonal Light architecture
- REST controllers with pagination
- HATEOAS assemblers (Experience/Domain)
- Compensation interfaces (Domain, if enabled)
- OpenAPI specification
- Tests

---

## Version

**Current:** 3.0.0  
**Model:** v2.0  
**Status:** Active
