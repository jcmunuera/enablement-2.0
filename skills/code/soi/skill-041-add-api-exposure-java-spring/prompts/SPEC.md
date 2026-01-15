# SPEC.md - LLM Prompt Specification

## Skill: skill-041-add-api-exposure-java-spring

**Version:** 1.0  
**Type:** Transformation  
**Updated:** 2025-01-15  

---

## Overview

This specification defines how an LLM should ADD API exposure (REST endpoints, pagination, HATEOAS) to an existing Java/Spring Boot microservice.

**Key Principle:** The LLM transforms an internal microservice into a public API by adding REST controllers, pagination support, and optionally HATEOAS links.

---

## Execution Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│ 1. RECEIVE transformation-request                                    │
│    - targetProject: path to existing service                        │
│    - apiLayer: experience | composable | domain | system            │
├─────────────────────────────────────────────────────────────────────┤
│ 2. VALIDATE target project                                           │
│    - Is it a Spring Boot project?                                   │
│    - Has hexagonal architecture?                                    │
│    - Identify domain entities                                       │
├─────────────────────────────────────────────────────────────────────┤
│ 3. SELECT module                                                     │
│    - mod-code-019-api-public-exposure-java-spring                   │
├─────────────────────────────────────────────────────────────────────┤
│ 4. ANALYZE existing code                                             │
│    - Find domain entities in domain/model/                          │
│    - Find application services                                      │
│    - Check for existing REST controllers                            │
├─────────────────────────────────────────────────────────────────────┤
│ 5. APPLY transformations                                             │
│    - Add spring-hateoas dependency (if HATEOAS enabled)             │
│    - Add springdoc-openapi dependency                               │
│    - Create REST controllers with pagination                        │
│    - Create PageResponse DTO                                        │
│    - Create Filter DTOs                                             │
│    - Create HATEOAS assemblers (if applicable)                      │
│    - Generate OpenAPI specification                                 │
├─────────────────────────────────────────────────────────────────────┤
│ 6. VALIDATE output                                                   │
│    - Verify compilation                                             │
│    - Check pagination endpoints                                     │
│    - Validate OpenAPI spec                                          │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Module Resolution

| Always | Module |
|--------|--------|
| Yes | mod-code-019-api-public-exposure-java-spring |

---

## Layer-Based Features

| Feature | Experience | Composable | Domain | System |
|---------|------------|------------|--------|--------|
| REST Controllers | ✅ | ✅ | ✅ | ✅ |
| Pagination | ✅ | ✅ | ✅ | ✅ |
| Filtering | ✅ | ✅ | ✅ | ✅ |
| HATEOAS | ✅ | ❌ | ✅ | ❌ |
| OpenAPI | ✅ | ✅ | ✅ | ✅ |

---

## Transformation Rules

### 1. Dependencies (pom.xml)

```xml
<!-- Always -->
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.3.0</version>
</dependency>

<!-- If HATEOAS enabled (experience, domain layers) -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-hateoas</artifactId>
</dependency>
```

### 2. Generated Files

For each domain entity:

| File | Purpose |
|------|---------|
| `adapter/in/rest/controller/{Entity}Controller.java` | REST endpoints |
| `adapter/in/rest/dto/{Entity}Response.java` | Response DTO |
| `adapter/in/rest/dto/{Entity}Filter.java` | Filter criteria |
| `adapter/in/rest/dto/PageResponse.java` | Pagination wrapper |
| `adapter/in/rest/assembler/{Entity}ModelAssembler.java` | HATEOAS (if enabled) |
| `infrastructure/web/PageableConfig.java` | Pagination config |

### 3. Controller Pattern

```java
@RestController
@RequestMapping("/api/v1/{entities}")
@Tag(name = "{Entity} API")
public class {Entity}Controller {

    @GetMapping
    @Operation(summary = "List {entities} with pagination")
    public ResponseEntity<PageResponse<{Entity}Response>> findAll(
            @Valid {Entity}Filter filter,
            @PageableDefault(size = 20) Pageable pageable) {
        // ...
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get {entity} by ID")
    public ResponseEntity<{Entity}Response> findById(@PathVariable String id) {
        // ...
    }

    @PostMapping
    @Operation(summary = "Create {entity}")
    public ResponseEntity<{Entity}Response> create(
            @Valid @RequestBody Create{Entity}Request request) {
        // ...
    }
}
```

### 4. HATEOAS Pattern (if enabled)

```java
@Component
public class {Entity}ModelAssembler 
        implements RepresentationModelAssembler<{Entity}, EntityModel<{Entity}Response>> {

    @Override
    public EntityModel<{Entity}Response> toModel({Entity} entity) {
        return EntityModel.of(
            toResponse(entity),
            linkTo(methodOn({Entity}Controller.class).findById(entity.getId())).withSelfRel(),
            linkTo(methodOn({Entity}Controller.class).findAll(null, null)).withRel("{entities}")
        );
    }
}
```

---

## Validation Rules

### Pre-transformation

1. Project has hexagonal structure
2. Domain entities exist in domain/model/
3. No existing REST controllers (or confirm override)

### Post-transformation

1. Code compiles
2. Controllers have @RestController annotation
3. Pagination endpoints accept Pageable parameter
4. OpenAPI annotations present (@Tag, @Operation)

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-01-15 | Initial version for Model v2.0 |
