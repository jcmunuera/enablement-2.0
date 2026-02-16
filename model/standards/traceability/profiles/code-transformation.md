# Traceability Profile: Code Transformation

**Profile ID:** code-transformation  
**Version:** 1.0  
**Last Updated:** 2025-11-27  
**Extends:** BASE-MODEL.md

---

## Purpose

This profile extends the base traceability model for skills that **modify existing code projects**. It captures before/after states, specific changes made, and enables rollback understanding.

## Used By

| Skill Pattern | Example |
|---------------|---------|
| `skill-code-*-add-*` | skill-code-001-add-circuit-breaker-java-resilience4j |
| `skill-code-*-remove-*` | skill-code-XXX-remove-deprecated-endpoints |
| `skill-code-*-update-*` | skill-code-XXX-update-spring-version |
| `skill-code-*-refactor-*` | skill-code-XXX-refactor-to-hexagonal |

---

## Extended Schema

In addition to BASE-MODEL fields, code-transformation traces include:

```json
{
  "profile": "code-transformation",
  "profile_version": "1.0",
  
  "transformation_type": "add|remove|update|refactor",
  
  "target_project": {
    "path": "/path/to/existing/project",
    "detected_stack": "java-spring",
    "detected_modules": ["mod-code-015-hexagonal"],
    "state_before_hash": "sha256:abc123..."
  },
  
  "artifacts_modified": [
    {
      "path": "src/main/java/com/company/service/CustomerService.java",
      "action": "modified",
      "before_hash": "sha256:abc123...",
      "after_hash": "sha256:def456...",
      "diff_summary": {
        "lines_added": 15,
        "lines_removed": 2,
        "lines_unchanged": 45
      },
      "change_description": "Added circuit breaker annotation and fallback method"
    }
  ],
  
  "artifacts_added": [
    {
      "path": "src/main/java/com/company/config/Resilience4jConfig.java",
      "type": "java-class",
      "template_source": "mod-code-001-circuit-breaker/templates/config.java.hbs",
      "size_bytes": 1024
    }
  ],
  
  "artifacts_removed": [
    {
      "path": "src/main/java/com/company/deprecated/OldService.java",
      "reason": "Deprecated and replaced by new implementation",
      "backup_location": ".enablement/backup/OldService.java"
    }
  ],
  
  "dependencies_changed": {
    "added": [
      {
        "group_id": "io.github.resilience4j",
        "artifact_id": "resilience4j-spring-boot3",
        "version": "2.1.0"
      }
    ],
    "removed": [],
    "updated": [
      {
        "group_id": "org.springframework.boot",
        "artifact_id": "spring-boot-starter-parent",
        "from_version": "3.1.0",
        "to_version": "3.2.0"
      }
    ]
  },
  
  "configuration_changes": {
    "files_modified": ["application.yml"],
    "properties_added": [
      {
        "file": "application.yml",
        "path": "resilience4j.circuitbreaker.instances.default",
        "value": "{ slidingWindowSize: 10, ... }"
      }
    ],
    "properties_removed": [],
    "properties_updated": []
  },
  
  "rollback_info": {
    "can_rollback": true,
    "backup_created": true,
    "backup_location": ".enablement/backup/",
    "rollback_script": ".enablement/rollback.sh"
  },
  
  "impact_analysis": {
    "files_impacted": 5,
    "tests_affected": 3,
    "api_changes": false,
    "breaking_changes": false,
    "requires_migration": false
  }
}
```

---

## Field Definitions

### transformation_type

| Value | Description |
|-------|-------------|
| `add` | Adding new functionality to existing code |
| `remove` | Removing functionality from existing code |
| `update` | Updating versions, configurations, or implementations |
| `refactor` | Restructuring without changing functionality |

### target_project Object

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `path` | string | ✅ | Path to existing project |
| `detected_stack` | string | ✅ | Detected technology stack |
| `detected_modules` | array | ⚠️ | Already present modules |
| `state_before_hash` | string | ⚠️ | Hash of project state before transformation |

### artifacts_modified Array

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `path` | string | ✅ | Relative file path |
| `action` | enum | ✅ | `modified` |
| `before_hash` | string | ✅ | Hash before modification |
| `after_hash` | string | ✅ | Hash after modification |
| `diff_summary` | object | ✅ | Lines added/removed/unchanged |
| `change_description` | string | ✅ | Human-readable change description |

### artifacts_added Array

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `path` | string | ✅ | Relative file path |
| `type` | string | ✅ | File type |
| `template_source` | string | ⚠️ | Source template if applicable |
| `size_bytes` | number | ⚠️ | File size |

### artifacts_removed Array

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `path` | string | ✅ | Relative file path |
| `reason` | string | ✅ | Why it was removed |
| `backup_location` | string | ✅ | Where backup is stored |

### rollback_info Object

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `can_rollback` | boolean | ✅ | Whether rollback is possible |
| `backup_created` | boolean | ✅ | Whether backup was made |
| `backup_location` | string | ⚠️ | Backup directory |
| `rollback_script` | string | ⚠️ | Script to execute rollback |

### impact_analysis Object

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `files_impacted` | number | ✅ | Total files changed |
| `tests_affected` | number | ⚠️ | Tests that may need updating |
| `api_changes` | boolean | ✅ | Whether API surface changed |
| `breaking_changes` | boolean | ✅ | Whether changes break compatibility |
| `requires_migration` | boolean | ✅ | Whether data migration needed |

---

## Storage Structure

```
{existing-project}/
└── .enablement/
    ├── manifest.json           # Full trace (appended to existing)
    ├── execution.log           # Human-readable narrative (appended)
    ├── backup/                  # Backup of modified/removed files
    │   ├── CustomerService.java.bak
    │   └── OldService.java.bak
    ├── inputs/
    │   └── skill-input.json    # Input parameters
    └── rollback.sh             # Rollback script (if applicable)
```

---

## Example: Add Circuit Breaker Trace

```json
{
  "traceability_version": "1.0",
  "profile": "code-transformation",
  "profile_version": "1.0",
  
  "generation": {
    "id": "gen-20251127-153045-z9w0",
    "timestamp": "2025-11-27T15:30:45Z",
    "duration_seconds": 23
  },
  
  "skill": {
    "id": "skill-code-001-add-circuit-breaker-java-resilience4j",
    "version": "1.0.0",
    "domain": "code"
  },
  
  "transformation_type": "add",
  
  "target_project": {
    "path": "/projects/customer-service",
    "detected_stack": "java-spring",
    "detected_modules": ["mod-code-015-hexagonal"]
  },
  
  "artifacts_modified": [
    {
      "path": "src/main/java/com/company/adapter/out/PaymentClient.java",
      "action": "modified",
      "before_hash": "sha256:abc123",
      "after_hash": "sha256:def456",
      "diff_summary": {
        "lines_added": 12,
        "lines_removed": 1,
        "lines_unchanged": 35
      },
      "change_description": "Added @CircuitBreaker annotation and fallback method"
    },
    {
      "path": "pom.xml",
      "action": "modified",
      "diff_summary": {
        "lines_added": 8,
        "lines_removed": 0
      },
      "change_description": "Added resilience4j dependency"
    }
  ],
  
  "artifacts_added": [
    {
      "path": "src/main/java/com/company/config/Resilience4jConfig.java",
      "type": "java-class"
    }
  ],
  
  "dependencies_changed": {
    "added": [
      {
        "group_id": "io.github.resilience4j",
        "artifact_id": "resilience4j-spring-boot3",
        "version": "2.1.0"
      }
    ]
  },
  
  "rollback_info": {
    "can_rollback": true,
    "backup_created": true,
    "backup_location": ".enablement/backup/"
  },
  
  "impact_analysis": {
    "files_impacted": 4,
    "api_changes": false,
    "breaking_changes": false
  },
  
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
- `code-project.md` - For generation skills
- `model/standards/validation/README.md` - Validation system

---

**Last Updated:** 2025-11-27
