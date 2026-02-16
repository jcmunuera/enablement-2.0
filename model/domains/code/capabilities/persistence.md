# Capability: Persistence

**Capability ID:** persistence  
**Version:** 1.2  
**Based on:** ADR-011

---

## Overview

Provides persistence patterns for data access in microservices. Supports both local database access (JPA) and delegation to System APIs for System of Record (SoR) access.

**Key Decision:** Domain APIs in this organization typically do NOT implement direct database persistence. Instead, they delegate to System APIs that wrap mainframe transactions (Z/OS, CICS, MQ).

---

## Type

- **Type:** Layered
- **Phase Group:** implementation
- **Cardinality:** multiple
- **Transformable:** Yes
- **Requires:** architecture (foundational)

---

## Discovery (v2.2)

### Capability-Level Keywords

```yaml
keywords:
  - persistence
  - persistencia
  - data
  - datos
  - storage
  - database
  - base de datos
```

### No Default Feature

**Important:** This capability has NO `default_feature` because `jpa` and `systemapi` are mutually exclusive. The user MUST specify which persistence strategy to use.

**Example:** 
- "con persistencia" → Ask: "Which persistence strategy? JPA or System API?"
- "persistencia JPA" → `persistence.jpa`
- "persistencia via System API" → `persistence.systemapi`

### Incompatibility

```yaml
persistence.jpa:
  incompatible_with:
    - persistence.systemapi

persistence.systemapi:
  incompatible_with:
    - persistence.jpa
```

---

## Sub-Features

### jpa

Direct database persistence using Spring Data JPA. Use for services that own their data.

```json
{
  "features": {
    "persistence": {
      "jpa": {
        "enabled": true,
        "database": "postgresql",
        "entities": ["Customer", "Order"]
      }
    }
  }
}
```

**Database Options:**

| Database | Driver | Use Case |
|----------|--------|----------|
| `postgresql` | PostgreSQL | Production default |
| `mysql` | MySQL | Legacy systems |
| `h2` | H2 (in-memory) | Testing only |
| `oracle` | Oracle | Enterprise systems |

**Generates:**
- JPA Entity classes in `adapter/persistence/entity/`
- Spring Data Repository interfaces
- JPA configuration
- Database migration scripts (Flyway/Liquibase)

**Module:** mod-code-016-persistence-jpa-spring

---

### system_api

Persistence via System API calls. The Domain API's repository delegates to a REST client that calls System APIs wrapping mainframe transactions.

```json
{
  "features": {
    "persistence": {
      "system_api": {
        "enabled": true,
        "client_type": "feign",
        "base_url": "${SYSTEM_API_CUSTOMER_URL}",
        "operations": ["findById", "save", "findByEmail"]
      }
    }
  }
}
```

**Client Type Options:**

| Type | Description | Use When |
|------|-------------|----------|
| `feign` | Declarative REST client | Preferred for most cases |
| `rest_template` | Synchronous REST client | Legacy/simple cases |
| `rest_client` | Modern Spring 6.1+ client | New projects, Spring Boot 3.2+ |

**Generates:**
- Repository interface in `domain/repository/`
- System API client adapter in `adapter/systemapi/`
- Client configuration with resilience patterns
- DTO mappings for System API contracts

**Modules:** 
- mod-code-017-persistence-systemapi-feign
- mod-code-018-persistence-systemapi-resttemplate
- mod-code-019-persistence-systemapi-restclient

---

## Architecture Pattern

### JPA Pattern (Data Owner)

```
┌─────────────────────────────────────────────────────────────┐
│                     Domain API                              │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐    ┌──────────────┐    ┌───────────────┐  │
│  │   Domain    │───▶│  Repository  │◀───│  JPA Adapter  │  │
│  │   Service   │    │  (Interface) │    │   (Entity)    │  │
│  └─────────────┘    └──────────────┘    └───────────────┘  │
│                                                │            │
└────────────────────────────────────────────────┼────────────┘
                                                 │
                                                 ▼
                                          ┌──────────────┐
                                          │   Database   │
                                          │  (PostgreSQL)│
                                          └──────────────┘
```

### System API Pattern (Delegation)

```
┌─────────────────────────────────────────────────────────────┐
│                     Domain API                              │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐    ┌──────────────┐    ┌───────────────┐  │
│  │   Domain    │───▶│  Repository  │◀───│  SystemAPI    │  │
│  │   Service   │    │  (Interface) │    │   Adapter     │  │
│  └─────────────┘    └──────────────┘    └───────────────┘  │
│                                                │            │
└────────────────────────────────────────────────┼────────────┘
                                                 │ REST/JSON
                                                 ▼
┌─────────────────────────────────────────────────────────────┐
│                     System API                              │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐    ┌──────────────┐    ┌───────────────┐  │
│  │  REST API   │───▶│   Service    │───▶│  Mainframe    │  │
│  │  Endpoint   │    │              │    │   Adapter     │  │
│  └─────────────┘    └──────────────┘    └───────────────┘  │
│                                                │            │
└────────────────────────────────────────────────┼────────────┘
                                                 │ CICS/MQ
                                                 ▼
                                          ┌──────────────┐
                                          │   Mainframe  │
                                          │   (Z/OS)     │
                                          └──────────────┘
```

---

## Dependencies

| ADR | Relationship |
|-----|--------------|
| ADR-011 | Defines persistence patterns and decision criteria |
| ADR-009 | Hexagonal architecture for adapter placement |
| ADR-004 | Resilience patterns for System API calls |

---

## Modules

| Sub-Feature | Module | ERI | Status |
|-------------|--------|-----|--------|
| jpa | mod-code-016-persistence-jpa-spring | ERI-CODE-012 | ✅ Active |
| system_api | mod-code-017-persistence-systemapi | ERI-CODE-012 | ✅ Active |

---

## Skills Using This Feature

| Skill | Usage |
|-------|-------|
| skill-code-020 | Generate new service with persistence |
| skill-code-005 (future) | Add JPA persistence to existing service |
| skill-code-006 (future) | Add System API persistence to existing service |

---

## Decision Criteria

### When to use JPA

- Service **owns its data** (is the System of Record)
- Data is **local** to the service domain
- Need **complex queries** or aggregations
- Examples: Audit logs, local caches, service-specific data

### When to use System API

- Data resides in **mainframe** (Z/OS, DB2)
- Service is a **Domain API** consuming System APIs
- Need **transactional integrity** with legacy systems
- Examples: Customer data, Account data, Transaction data

---

## Recommended Combinations

### Domain API with System API Backend
```json
{
  "persistence": {
    "system_api": {
      "enabled": true,
      "client_type": "feign"
    }
  },
  "resilience": {
    "circuit_breaker": { "enabled": true },
    "retry": { "enabled": true, "maxAttempts": 3 },
    "timeout": { "enabled": true, "duration": "5s" }
  }
}
```

### System API (Wrapper Service)
```json
{
  "persistence": {
    "jpa": {
      "enabled": true,
      "database": "postgresql"
    }
  },
  "resilience": {
    "circuit_breaker": { "enabled": true }
  }
}
```

### Hybrid (Local Cache + System API)
```json
{
  "persistence": {
    "jpa": {
      "enabled": true,
      "purpose": "cache"
    },
    "system_api": {
      "enabled": true,
      "client_type": "feign"
    }
  }
}
```

---

## Configuration Reference

### JPA Defaults

```yaml
spring:
  datasource:
    url: jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
  jpa:
    hibernate:
      ddl-auto: validate
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        format_sql: true
    show-sql: false
```

### System API Client Defaults

```yaml
system-api:
  customer:
    base-url: ${SYSTEM_API_CUSTOMER_URL:http://localhost:8081}
    connect-timeout: 5s
    read-timeout: 10s

feign:
  client:
    config:
      default:
        connectTimeout: 5000
        readTimeout: 10000
        loggerLevel: basic
```

---

## Validation Rules

```yaml
jpa:
  - entities must be in adapter/persistence/entity/
  - repositories must extend JpaRepository or CrudRepository
  - ddl-auto must be 'validate' in production

system_api:
  - client must be in adapter/systemapi/
  - must have resilience patterns (circuit breaker, retry, timeout)
  - must have proper error mapping
  - base URL must be externalized (environment variable)
```

---

## Example Full Configuration

```json
{
  "serviceName": "customer-service",
  "apiType": "domain_api",
  
  "features": {
    "persistence": {
      "system_api": {
        "enabled": true,
        "client_type": "feign",
        "base_url": "${SYSTEM_API_CUSTOMER_URL}",
        "operations": [
          {
            "name": "findById",
            "method": "GET",
            "path": "/customers/{id}"
          },
          {
            "name": "save",
            "method": "POST",
            "path": "/customers"
          },
          {
            "name": "findByEmail",
            "method": "GET",
            "path": "/customers?email={email}"
          }
        ]
      }
    },
    "resilience": {
      "circuit_breaker": {
        "enabled": true,
        "pattern": "basic_fallback"
      },
      "retry": {
        "enabled": true,
        "strategy": "exponential_backoff",
        "maxAttempts": 3
      },
      "timeout": {
        "enabled": true,
        "duration": "5s"
      }
    }
  }
}
```

---

## Changelog

### v1.0 (2025-11-28)
- Initial feature definition
- JPA and System API patterns documented
- Decision criteria for pattern selection
- Integration with resilience patterns
