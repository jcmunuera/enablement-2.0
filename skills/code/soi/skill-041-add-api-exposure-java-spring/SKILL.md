---
skill_id: skill-041-add-api-exposure-java-spring
skill_name: Add API Exposure
version: 1.0.0
date: 2025-01-15
author: Fusion C4E Team
status: active

type: transformation
domain: code
layer: soi
stack: java-spring

target_capability: api-exposure

compatible_with:
  - architecture.hexagonal-base

tags:
  - transformation
  - api
  - rest
  - hateoas
---

# Skill: Add API Exposure

**Skill ID:** skill-041-add-api-exposure-java-spring  
**Type:** Transformation  
**Target Capability:** api-exposure  
**Version:** 1.0.0  
**Status:** Active

---

## Overview

Promotes an existing internal microservice to a public API by adding REST endpoints, HATEOAS support, pagination, and OpenAPI specification. This is a **transformation skill** that modifies existing code.

### When to Use

✅ **Use this skill when:**
- Promoting an internal microservice to external API
- Adding REST endpoints to existing service
- User says "promote to API", "expose as REST", "add HATEOAS"

❌ **Do NOT use when:**
- Creating a new API from scratch (use skill-021)
- Adding non-REST exposure (gRPC, GraphQL - future skills)
- Code doesn't have hexagonal architecture

---

## Target Capability

| Capability | Type | Transformable |
|------------|------|---------------|
| `api-exposure` | Compositional | Yes |

### Available Features

| Feature | Module | Keywords |
|---------|--------|----------|
| rest-hateoas | mod-code-019 | "REST", "HATEOAS", "API" |

---

## Feature Resolution

| User Prompt | Features Applied |
|-------------|------------------|
| "Add REST API" | api-exposure.rest-hateoas |
| "Promote to API" | api-exposure.rest-hateoas |
| "Add HATEOAS" | api-exposure.rest-hateoas |
| "Expose as Fusion API" | api-exposure.rest-hateoas |

---

## Knowledge Dependencies

### ADR Compliance
- **ADR-001:** API Design Standards (Fusion model, REST, pagination, HATEOAS)

### Reference Implementations
- **ERI-014:** API Public Exposure Java Spring

---

## Input Specification

### Required

| Parameter | Type | Description |
|-----------|------|-------------|
| `targetProject` | path | Path to existing microservice |

### Optional

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `apiLayer` | enum | domain | API layer (experience, composable, domain, system) |
| `entities` | array | auto-detect | Entities to expose |
| `pagination.defaultSize` | int | 20 | Default page size |
| `pagination.maxSize` | int | 100 | Max page size |

---

## Output Specification

### Files Created

| File | Purpose |
|------|---------|
| `adapter/in/rest/controller/{Entity}Controller.java` | REST endpoints |
| `adapter/in/rest/dto/PageResponse.java` | Pagination DTO |
| `adapter/in/rest/dto/{Entity}Filter.java` | Filter DTO |
| `adapter/in/rest/assembler/{Entity}ModelAssembler.java` | HATEOAS |
| `infrastructure/web/PageableConfig.java` | Pagination config |
| `src/main/resources/openapi/api.yaml` | OpenAPI spec |

### Files Modified

| File | Change |
|------|--------|
| `pom.xml` | Add spring-hateoas, springdoc dependencies |
| `application.yml` | Add pagination config |

---

## Execution Flow

This skill follows the **ADD** execution flow.

### Skill-Specific Steps

1. **Validate Target Project**
   - Verify hexagonal structure
   - Identify domain entities
   - Check for existing REST controllers

2. **Resolve Features**
   - Determine HATEOAS enablement based on apiLayer
   - Map to modules

3. **Apply Transformations**
   - Create REST controllers for each entity
   - Add pagination DTOs
   - Add HATEOAS assemblers (if experience/domain layer)
   - Create OpenAPI specification
   - Update pom.xml

4. **Validate Changes**
   - Compile modified code
   - Validate OpenAPI spec
   - Run Tier-3 validators

---

## Layer-Based Features

| Feature | Experience | Composable | Domain | System |
|---------|------------|------------|--------|--------|
| REST Controllers | ✅ | ✅ | ✅ | ✅ |
| Pagination | ✅ | ✅ | ✅ | ✅ |
| HATEOAS | ✅ | ❌ | ✅ | ❌ |
| OpenAPI | ✅ | ✅ | ✅ | ✅ |

---

## Related Skills

| Skill | Relationship |
|-------|--------------|
| skill-020 | Generates base microservice |
| skill-021 | Generates API from scratch (includes this capability) |
| skill-040 | Adds resilience (different capability) |

---

## Changelog

### Version 1.0.0 (2025-01-15)
- Initial version (Model v2.0)
- Capability-level transformation skill
