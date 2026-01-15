# SPEC.md - LLM Prompt Specification

## Skill: skill-042-add-persistence-java-spring

**Version:** 1.0  
**Type:** Transformation  
**Updated:** 2025-01-15  

---

## Overview

This specification defines how an LLM should ADD persistence capabilities to an existing Java/Spring Boot microservice.

**Supports two persistence types:**
- **JPA** - Local database (PostgreSQL, MySQL, H2)
- **System API** - Backend integration via REST client

---

## Execution Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│ 1. RECEIVE transformation-request                                    │
│    - targetProject: path to existing service                        │
│    - persistenceType: jpa | systemapi                               │
├─────────────────────────────────────────────────────────────────────┤
│ 2. VALIDATE target project                                           │
│    - Has hexagonal architecture?                                    │
│    - Has domain entities?                                           │
│    - Has repository interfaces in domain layer?                     │
├─────────────────────────────────────────────────────────────────────┤
│ 3. SELECT modules                                                    │
│    - jpa → mod-code-016                                             │
│    - systemapi → mod-code-017 + mod-code-018                        │
├─────────────────────────────────────────────────────────────────────┤
│ 4. GENERATE persistence adapters                                     │
│    - JPA: entities, repositories, adapters                          │
│    - System API: DTOs, clients, adapters with resilience            │
├─────────────────────────────────────────────────────────────────────┤
│ 5. VALIDATE output                                                   │
│    - Compilation succeeds                                           │
│    - Adapters implement repository interfaces                       │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Module Resolution

| Persistence Type | Modules |
|------------------|---------|
| jpa | mod-code-016-persistence-jpa-spring |
| systemapi | mod-code-017-persistence-systemapi + mod-code-018-api-integration-rest-java-spring |

---

## JPA Transformation

### Generated Files

```
adapter/out/persistence/
├── entity/
│   └── {Entity}JpaEntity.java
├── repository/
│   └── {Entity}JpaRepository.java
├── mapper/
│   └── {Entity}PersistenceMapper.java
└── {Entity}PersistenceAdapter.java
```

### Dependencies

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <scope>runtime</scope>
</dependency>
```

---

## System API Transformation

### Generated Files

```
adapter/out/systemapi/
├── dto/
│   └── {Entity}Dto.java
├── client/
│   └── {Entity}Client.java
├── mapper/
│   └── {Entity}SystemApiMapper.java
└── {Entity}SystemApiAdapter.java       # With @CircuitBreaker, @Retry
```

### Dependencies

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>
<!-- Plus resilience4j for fault tolerance -->
```

### Auto-applied Resilience

System API adapters AUTOMATICALLY get resilience annotations:

```java
@CircuitBreaker(name = "{entity}SystemApi", fallbackMethod = "...")
@Retry(name = "{entity}SystemApi")
public {Entity} findById(String id) {
    return client.get(id);
}
```

---

## Validation Rules

### Pre-transformation

1. Repository interfaces exist in domain/repository/
2. No existing persistence adapters (avoid conflicts)

### Post-transformation

1. Adapters implement domain repository interfaces
2. JPA entities have @Entity, @Table, @Id
3. System API adapters have resilience annotations
4. Code compiles

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-01-15 | Initial version |
