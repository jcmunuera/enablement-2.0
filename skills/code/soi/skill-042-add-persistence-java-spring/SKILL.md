---
skill_id: skill-042-add-persistence-java-spring
skill_name: Add Persistence
version: 1.0.0
date: 2025-01-15
author: Fusion C4E Team
status: active

type: transformation
domain: code
layer: soi
stack: java-spring

target_capability: persistence

compatible_with:
  - architecture.hexagonal-base

tags:
  - transformation
  - persistence
  - jpa
  - database
  - system-api
---

# Skill: Add Persistence

**Skill ID:** skill-042-add-persistence-java-spring  
**Type:** Transformation  
**Target Capability:** persistence  
**Version:** 1.0.0  
**Status:** Active

---

## Overview

Adds persistence capabilities (JPA or System API integration) to an existing Java Spring microservice. This is a **transformation skill** that modifies existing code.

### When to Use

✅ **Use this skill when:**
- Adding database persistence to existing service
- Integrating with backend System APIs
- User says "add persistence", "add JPA", "add System API"

❌ **Do NOT use when:**
- Creating a new service (use skill-020 or skill-021)
- Service already has persistence (avoid conflicts)
- Needs different persistence type than available

---

## Target Capability

| Capability | Type | Transformable |
|------------|------|---------------|
| `persistence` | Compositional | Yes |

### Available Features

| Feature | Module | Keywords |
|---------|--------|----------|
| jpa | mod-code-016 | "JPA", "database", "Hibernate" |
| systemapi | mod-code-017 + mod-018 | "System API", "backend", "mainframe" |

> **Note:** Features `jpa` and `systemapi` are **mutually exclusive**.

---

## Feature Resolution

| User Prompt | Feature Applied |
|-------------|-----------------|
| "Add JPA persistence" | persistence.jpa |
| "Add database" | persistence.jpa |
| "Add System API integration" | persistence.systemapi |
| "Connect to backend" | persistence.systemapi |
| "Add persistence" | ASK: JPA or System API? |

### Resolution Algorithm

```python
def resolve_persistence_feature(prompt):
    if matches(prompt, ["JPA", "database", "Hibernate", "SQL"]):
        return "persistence.jpa"
    elif matches(prompt, ["System API", "backend", "mainframe", "host"]):
        return "persistence.systemapi"
    else:
        ask_clarification("What type of persistence? JPA (database) or System API (backend)?")
```

---

## Knowledge Dependencies

### ADR Compliance
- **ADR-011:** Persistence Patterns (JPA vs System API)
- **ADR-004:** Resilience Patterns (required for System API)

### Reference Implementations
- **ERI-012:** Persistence Patterns Java Spring

---

## Input Specification

### Required

| Parameter | Type | Description |
|-----------|------|-------------|
| `targetProject` | path | Path to existing microservice |
| `persistenceType` | enum | "jpa" or "systemapi" |

### Optional (JPA)

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `database` | enum | postgresql | Database type |
| `entities` | array | auto-detect | Entities to persist |

### Optional (System API)

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `client` | enum | restclient | HTTP client (restclient, feign) |
| `baseUrlEnv` | string | auto | Environment variable for URL |
| `resilience` | boolean | true | Apply resilience patterns |

---

## Output Specification

### JPA Feature (persistence.jpa)

| File | Purpose |
|------|---------|
| `adapter/out/persistence/entity/{Entity}JpaEntity.java` | JPA entity |
| `adapter/out/persistence/repository/{Entity}JpaRepository.java` | Spring Data repo |
| `adapter/out/persistence/{Entity}PersistenceAdapter.java` | Port implementation |
| `adapter/out/persistence/mapper/{Entity}PersistenceMapper.java` | Mapper |

### System API Feature (persistence.systemapi)

| File | Purpose |
|------|---------|
| `adapter/out/systemapi/dto/{Entity}Dto.java` | API DTO |
| `adapter/out/systemapi/client/{Entity}Client.java` | HTTP client |
| `adapter/out/systemapi/{Entity}SystemApiAdapter.java` | Port implementation |
| `adapter/out/systemapi/mapper/{Entity}Mapper.java` | Mapper |
| `infrastructure/config/RestClientConfig.java` | Client config |

### Files Modified

| File | Change |
|------|--------|
| `pom.xml` | Add persistence dependencies |
| `application.yml` | Add datasource or client config |

---

## Execution Flow

This skill follows the **ADD** execution flow.

### Skill-Specific Steps

1. **Validate Target Project**
   - Verify hexagonal structure
   - Check for existing persistence (avoid conflicts)
   - Identify domain entities and repository interfaces

2. **Determine Feature**
   - Extract from prompt or ask user
   - Validate mutual exclusivity

3. **Apply JPA Transformations** (if jpa)
   - Create JPA entities
   - Create Spring Data repositories
   - Create adapter implementations
   - Add datasource configuration

4. **Apply System API Transformations** (if systemapi)
   - Create DTOs
   - Create HTTP client
   - Create adapter with resilience
   - Add client configuration
   - (Auto-trigger resilience if enabled)

5. **Validate Changes**
   - Compile modified code
   - Run Tier-3 validators

---

## System API Resilience

When `persistenceType = systemapi`, resilience patterns are **automatically applied** to the adapter:

```java
@Component
public class CustomerSystemApiAdapter implements CustomerRepository {
    
    @CircuitBreaker(name = "customerSystemApi", fallbackMethod = "fallback")
    @Retry(name = "customerSystemApi")
    public Customer findById(String id) {
        return client.getCustomer(id);
    }
}
```

This is because System API calls are external and require fault tolerance per ADR-004.

---

## Validation

### Pre-Transformation
- [ ] Target project exists
- [ ] Has hexagonal structure
- [ ] Has repository interfaces in domain layer
- [ ] No existing persistence adapters (conflict check)

### Post-Transformation
- [ ] Code compiles
- [ ] Persistence dependencies added
- [ ] Adapters implement repository interfaces
- [ ] Configuration valid

---

## Related Skills

| Skill | Relationship |
|-------|--------------|
| skill-020 | Generates microservice that can receive persistence |
| skill-021 | Generates API that can receive persistence |
| skill-040 | Adds resilience (complementary for System API) |

---

## Changelog

### Version 1.0.0 (2025-01-15)
- Initial version (Model v2.0)
- Capability-level transformation skill
- Supports JPA and System API features
