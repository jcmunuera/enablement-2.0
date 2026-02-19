# CODE Domain: Module Structure

**Version:** 1.0  
**Last Updated:** 2025-12-12

---

## Overview

Modules in the CODE domain encapsulate reusable code generation capabilities. They contain templates that produce code files, configuration, and build artifacts.

---

## Required Structure

```
mod-code-{NNN}-{pattern}-{framework}-{library}/
├── MODULE.md                 # Module specification (required)
├── templates/                # Code templates (required)
│   ├── {Name}.java.tpl
│   ├── {name}.yml.tpl
│   └── ...
├── variables.md              # Variable definitions (required)
└── validation/               # Tier 3 validators (required)
    ├── README.md
    └── validate-{module}.sh
```

---

## MODULE.md Specification

### Required Sections

```markdown
# Module: mod-code-{NNN}-{name}

**Version:** X.Y.Z  
**Domain:** CODE  
**Status:** Draft | Active | Deprecated

## Overview
[What this module provides]

## Source
- **ERI:** eri-code-{NNN}-...
- **ADR Compliance:** adr-XXX, adr-YYY

## Dependencies
[Maven/Gradle dependencies this module adds]

## Template Catalog

| Template | Output Path | Merge Strategy |
|----------|-------------|----------------|
| `File.java.tpl` | `src/main/java/{{package}}/...` | Create |
| `config.yml.tpl` | `application.yml` | Merge |

## Variables

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `{{serviceName}}` | string | ✅ | - | Service name |

## Configuration Merge Rules
[How this module's config merges with others]

## Validation Rules
[What Tier 3 validators check]
```

---

## Template Catalog

The Template Catalog is the **single source of truth** for what files a module produces.

### Merge Strategies

| Strategy | Description | Example |
|----------|-------------|---------|
| `Create` | Create new file, fail if exists | Java classes |
| `Merge` | Deep merge with existing content | application.yml |
| `Append` | Append to existing file | pom.xml dependencies |
| `Replace` | Overwrite existing file | Regenerated configs |

### Output Path Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `{{package}}` | Java package as path | `com/example/service` |
| `{{serviceName}}` | Service name | `customer-service` |
| `{{ServiceName}}` | PascalCase service name | `CustomerService` |
| `{{layer}}` | Architecture layer | `application`, `domain`, `infrastructure` |

---

## Template Syntax

Templates use Mustache-like syntax:

```java
// {{Name}}Config.java.tpl

package {{package}}.config;

import org.springframework.context.annotation.Configuration;

@Configuration
public class {{Name}}Config {
    
    {{#properties}}
    private {{type}} {{name}} = {{default}};
    {{/properties}}
    
}
```

### Supported Constructs

| Construct | Syntax | Description |
|-----------|--------|-------------|
| Variable | `{{variable}}` | Simple substitution |
| Section | `{{#section}}...{{/section}}` | Conditional/loop |
| Inverted | `{{^section}}...{{/section}}` | If not present |
| Comment | `{{! comment }}` | Ignored in output |

---

## Variables Definition

The `variables.md` file documents all variables:

```markdown
# Variables: mod-code-001-circuit-breaker

## Input Variables (from generation request)

| Variable | Source | Transform |
|----------|--------|-----------|
| `serviceName` | `request.serviceName` | As-is |
| `ServiceName` | `request.serviceName` | PascalCase |
| `package` | `request.groupId` + `request.artifactId` | Dot to slash |

## Computed Variables

| Variable | Computation |
|----------|-------------|
| `configClassName` | `{{ServiceName}}CircuitBreakerConfig` |
| `fallbackMethodName` | `{{methodName}}Fallback` |

## Default Values

| Variable | Default | Override |
|----------|---------|----------|
| `failureRateThreshold` | `50` | `request.features.resilience.circuit_breaker.config.failureRateThreshold` |
```

---

## Validation (Tier 3)

Each module provides validators for its specific constraints:

```bash
#!/bin/bash
# validate-circuit-breaker.sh

# Check @CircuitBreaker annotations have fallbackMethod
grep -r "@CircuitBreaker" "$PROJECT_PATH/src" | while read line; do
    if [[ ! "$line" =~ "fallbackMethod" ]]; then
        echo "ERROR: @CircuitBreaker without fallbackMethod: $line"
        exit 1
    fi
done

# Check fallback methods exist
# ...
```

### Validator Contract

| Exit Code | Meaning |
|-----------|---------|
| 0 | All checks passed |
| 1 | ERROR - Must fix |
| 2 | WARNING - Should fix |

---

## Configuration Merge Rules

When multiple modules contribute to the same file (e.g., `application.yml`):

```yaml
# Module merge order is determined by skill's module resolution

# mod-code-015 (base) provides:
spring:
  application:
    name: ${serviceName}

# mod-code-001 (circuit-breaker) adds:
resilience4j:
  circuitbreaker:
    instances:
      default:
        failureRateThreshold: 50

# mod-code-002 (retry) adds:
resilience4j:
  retry:
    instances:
      default:
        maxAttempts: 3

# Result: Deep merge of all contributions
```

### Merge Conflict Resolution

| Conflict Type | Resolution |
|---------------|------------|
| Same key, different values | Later module wins (with warning) |
| Same key, both objects | Deep merge recursively |
| Same key, array vs object | Error - incompatible |

---

## Example Module

See `modules/modules/mod-code-001-circuit-breaker-java-resilience4j/` for a complete example.
