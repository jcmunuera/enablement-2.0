# Traceability Profile: Code Project

**Profile ID:** code-project  
**Version:** 1.0  
**Last Updated:** 2025-11-27  
**Extends:** BASE-MODEL.md

---

## Purpose

This profile extends the base traceability model for skills that **generate new code projects**. It captures additional fields specific to code generation including artifacts created, configuration applied, and ADR compliance.

## Used By

| Skill Pattern | Example |
|---------------|---------|
| `skill-code-*-generate-*` | skill-code-020-generate-microservice-java-spring |

---

## Extended Schema

In addition to BASE-MODEL fields, code-project traces include:

```json
{
  "profile": "code-project",
  "profile_version": "1.0",
  
  "artifacts_generated": [
    {
      "path": "src/main/java/com/company/service/CustomerService.java",
      "type": "java-class",
      "template_source": "mod-code-015-hexagonal/templates/service.java.hbs",
      "size_bytes": 2048,
      "checksum": "sha256:abc123..."
    }
  ],
  
  "project_structure": {
    "root_directory": "customer-service",
    "total_files": 45,
    "total_directories": 12,
    "by_category": {
      "source_code": 25,
      "test_code": 15,
      "configuration": 3,
      "documentation": 2
    }
  },
  
  "configuration_applied": {
    "application_name": "customer-service",
    "base_package": "com.company.customer",
    "server_port": 8080,
    "features_enabled": ["circuit-breaker", "actuator", "swagger"],
    "profiles": ["default", "local", "docker"]
  },
  
  "dependencies_added": [
    {
      "group_id": "org.springframework.boot",
      "artifact_id": "spring-boot-starter-web",
      "version": "3.2.0",
      "scope": "compile"
    },
    {
      "group_id": "io.github.resilience4j",
      "artifact_id": "resilience4j-spring-boot3",
      "version": "2.1.0",
      "scope": "compile",
      "added_by_module": "mod-code-001-circuit-breaker"
    }
  ],
  
  "adr_compliance": [
    {
      "adr_id": "adr-009-service-architecture-patterns",
      "requirement": "Hexagonal architecture",
      "status": "compliant",
      "evidence": "Package structure follows ports-adapters pattern"
    },
    {
      "adr_id": "adr-004-resilience-patterns",
      "requirement": "Circuit breaker on external calls",
      "status": "compliant",
      "evidence": "Resilience4j configured on HTTP clients"
    }
  ],
  
  "entry_points": {
    "main_class": "com.company.customer.CustomerServiceApplication",
    "api_base_path": "/api/v1",
    "health_endpoint": "/actuator/health",
    "swagger_url": "/swagger-ui.html"
  }
}
```

---

## Field Definitions

### artifacts_generated Array

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `path` | string | ✅ | Relative path from project root |
| `type` | enum | ✅ | `java-class`, `config`, `test`, `dockerfile`, etc. |
| `template_source` | string | ⚠️ | Template used to generate (if applicable) |
| `size_bytes` | number | ⚠️ | File size |
| `checksum` | string | ⚠️ | SHA-256 hash for verification |

### project_structure Object

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `root_directory` | string | ✅ | Project root directory name |
| `total_files` | number | ✅ | Total files generated |
| `total_directories` | number | ✅ | Total directories created |
| `by_category` | object | ⚠️ | File count by category |

### configuration_applied Object

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `application_name` | string | ✅ | Spring application name |
| `base_package` | string | ✅ | Root Java package |
| `server_port` | number | ✅ | HTTP server port |
| `features_enabled` | array | ✅ | List of enabled features |
| `profiles` | array | ⚠️ | Spring profiles created |

### dependencies_added Array

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `group_id` | string | ✅ | Maven group ID |
| `artifact_id` | string | ✅ | Maven artifact ID |
| `version` | string | ✅ | Dependency version |
| `scope` | enum | ✅ | `compile`, `test`, `runtime`, etc. |
| `added_by_module` | string | ⚠️ | Module that added this dependency |

### adr_compliance Array

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `adr_id` | string | ✅ | ADR identifier |
| `requirement` | string | ✅ | Specific requirement from ADR |
| `status` | enum | ✅ | `compliant`, `partial`, `non-compliant` |
| `evidence` | string | ✅ | How compliance was achieved |

### entry_points Object

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `main_class` | string | ✅ | Application entry point |
| `api_base_path` | string | ⚠️ | Base API path |
| `health_endpoint` | string | ⚠️ | Health check URL |
| `swagger_url` | string | ⚠️ | API documentation URL |

---

## Storage Structure

```
{generated-project}/
└── .enablement/
    ├── manifest.json           # Full trace (BASE-MODEL + this profile)
    ├── execution.log           # Human-readable narrative
    ├── inputs/
    │   └── skill-input.json    # Original input parameters
    └── validation/
        ├── results.json        # Validation results
        └── scripts/            # Copied validation scripts
```

---

## Example: Complete Trace

```json
{
  "traceability_version": "1.0",
  "profile": "code-project",
  "profile_version": "1.0",
  
  "generation": {
    "id": "gen-20251127-143022-x7y8",
    "timestamp": "2025-11-27T14:30:22Z",
    "duration_seconds": 67
  },
  
  "skill": {
    "id": "skill-code-020-generate-microservice-java-spring",
    "version": "1.0.0",
    "domain": "code"
  },
  
  "request": {
    "raw": "Generate a customer management microservice with circuit breaker",
    "parsed_intent": {
      "action": "generate",
      "target": "microservice",
      "parameters": {
        "name": "customer-service",
        "features": ["circuit-breaker"]
      }
    }
  },
  
  "artifacts_generated": [
    {
      "path": "pom.xml",
      "type": "config",
      "size_bytes": 4096
    },
    {
      "path": "src/main/java/com/company/customer/CustomerServiceApplication.java",
      "type": "java-class",
      "template_source": "mod-code-015-hexagonal/templates/Application.java.hbs"
    }
  ],
  
  "project_structure": {
    "root_directory": "customer-service",
    "total_files": 42,
    "total_directories": 10
  },
  
  "adr_compliance": [
    {
      "adr_id": "adr-009",
      "requirement": "Hexagonal architecture",
      "status": "compliant",
      "evidence": "Ports and adapters package structure"
    }
  ],
  
  "status": {
    "overall": "success",
    "errors": [],
    "warnings": []
  }
}
```

---

## Related

- `BASE-MODEL.md` - Base traceability schema
- `code-transformation.md` - For modification skills
- `model/standards/validation/README.md` - Validation system

---

**Last Updated:** 2025-11-27
