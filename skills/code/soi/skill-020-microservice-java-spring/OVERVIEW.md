# skill-020-generate-microservice-java-spring

## Overview

**Skill ID:** skill-020-generate-microservice-java-spring  
**Type:** CREATION  
**Framework:** Java 17+ / Spring Boot 3.2.x  
**Architecture:** Hexagonal Light

---

## Purpose

Generates a complete, production-ready Spring Boot microservice with Hexagonal Light architecture from a JSON configuration. Supports multiple API types (Domain API, Composable API, etc.) and optional features (resilience, persistence, etc.).

---

## When to Use

✅ **Use this skill when:**
- Creating a new microservice from scratch
- Need Hexagonal Light architecture
- Building Domain, Composable, System, or Experience APIs
- Want to enforce organizational standards automatically
- Need consistent project structure across teams

❌ **Do NOT use when:**
- Modifying existing code (use ADD/TRANSFORMATION skills)
- Need Full Hexagonal architecture for complex domains
- Building non-REST services (Kafka-only, batch jobs)
- Simple CRUD with <3 business rules (consider Traditional style)

---

## Capabilities

| Capability | Description |
|------------|-------------|
| **Project generation** | Complete Maven project with all dependencies |
| **Hexagonal Light structure** | Domain, Application, Adapter, Infrastructure layers |
| **Multiple API types** | domain_api, composable_api, system_api, experience_api |
| **Entity generation** | Domain entities, DTOs, mappers from config |
| **Test generation** | Unit tests for domain layer, integration tests |
| **Feature integration** | Circuit breaker, persistence, health checks, logging |
| **OpenAPI output** | Generates OpenAPI spec from config |

---

## Input Summary

```json
{
  "serviceName": "customer-service",
  "basePackage": "com.company.customer",
  "apiType": "domain_api",
  "entities": [{ "name": "Customer", "fields": [...] }],
  "features": {
    "resilience": { "circuit_breaker": { "enabled": true } }
  }
}
```

---

## Output Summary

```
customer-service/
├── pom.xml
├── src/main/java/.../
│   ├── domain/          # Pure POJOs
│   ├── application/     # @Service orchestration  
│   ├── adapter/         # REST, persistence
│   └── infrastructure/  # Config, exceptions
├── src/test/java/.../
├── src/main/resources/
│   ├── application.yml
│   └── openapi.yaml     # Generated OpenAPI spec
└── README.md
```

---

## Dependencies

### Knowledge Dependencies
- **ADR-009:** Service Architecture Patterns (Hexagonal Light)
- **ADR-001:** API Design Standards (API types, constraints)
- **ERI-001:** Hexagonal Light Java Spring (reference implementation)

### Module Dependencies
- **mod-code-015:** hexagonal-base-java-spring (base templates)
- **mod-code-001:** circuit-breaker-java-resilience4j (if resilience enabled)

---

## Tags

`creation` `generation` `spring-boot` `java` `hexagonal` `microservice` `domain-api`

---

## Version

**Current:** 1.0.0  
**Status:** Active  
**Last Updated:** 2025-11-24
