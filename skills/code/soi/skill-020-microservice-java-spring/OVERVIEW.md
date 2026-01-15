---
id: skill-020-microservice-java-spring
version: 2.0.0
type: generation
required_capabilities:
  - architecture.hexagonal-base
tags:
  artifact-type: service
  runtime-model: request-response
  stack: java-spring
  architecture: hexagonal
---

# skill-020-microservice-java-spring

## Overview

**Skill ID:** skill-020-microservice-java-spring  
**Type:** GENERATION  
**Stack:** Java Spring Boot  
**Architecture:** Hexagonal Light

---

## Purpose

Generates a complete, production-ready Spring Boot microservice with Hexagonal Light architecture. This is the **foundation skill** for creating internal microservices in the Fusion platform.

---

## When to Use

✅ **Use this skill when:**
- Creating internal microservices
- User does NOT mention "Fusion API" or specific API layer
- User says "microservicio", "servicio interno", "internal service"

❌ **Do NOT use when:**
- User mentions "Fusion" + API layer → use skill-021
- Adding features to existing code → use transformation skills (040-042)

---

## Required Capabilities (Model v2.0)

| Capability | Module |
|------------|--------|
| architecture.hexagonal-base | mod-code-015 |

Additional capabilities (resilience, persistence) are inferred from prompt/config.

---

## Output

- Complete Maven project structure
- Domain layer (pure POJOs)
- Application layer
- Adapter layer (REST, persistence)
- Infrastructure
- Tests
- OpenAPI specification
- Docker files (optional)

---

## Version

**Current:** 2.0.0  
**Model:** v2.0  
**Status:** Active
