# TEMPLATE Authoring Guide

**Version:** 1.0  
**Last Updated:** 2026-02-04  
**Related Decisions:** DEC-025, DEC-026, DEC-036, DEC-037, DEC-040

---

## Overview

Templates (`.tpl` files) are the code blueprints that CodeGen Agent uses to generate actual source files. This guide defines the mandatory structure, headers, and conventions for authoring templates.

> **CRITICAL:** Templates are processed by an LLM. Strict adherence to these rules ensures deterministic, reproducible code generation.

---

## Template Location

Templates MUST be placed in the module's `templates/` directory:

```
modules/
└── mod-code-XXX-feature-name/
    ├── MODULE.md
    └── templates/
        ├── domain/
        │   └── Entity.java.tpl
        ├── application/
        │   └── Service.java.tpl
        └── adapter/
            └── out/
                └── Client.java.tpl
```

---

## Mandatory Headers

Every `.tpl` file MUST include these headers at the top:

### 1. Output Path (REQUIRED) - DEC-036

Specifies where the generated file will be placed.

```java
// Output: src/main/java/{{basePackagePath}}/domain/{{Entity}}.java
```

**Rules:**
- MUST be the first non-empty line in the template
- MUST use `{{placeholder}}` syntax for variable parts
- Path is relative to project root

**Common placeholders:**
| Placeholder | Example Value | Description |
|-------------|---------------|-------------|
| `{{basePackagePath}}` | `com/bank/customer` | Base package as path |
| `{{Entity}}` | `Customer` | Entity name (PascalCase) |
| `{{entity}}` | `customer` | Entity name (lowercase) |
| `{{ServiceName}}` | `CustomerApi` | Service name (PascalCase) |

### 2. Variant (CONDITIONAL) - DEC-040, DEC-041

Required when a module offers multiple implementation variants.

```java
// Variant: restclient
```

**Rules:**
- Place immediately after `// Output:` line
- Value MUST match an option defined in MODULE.md `variants` section
- Only ONE variant per template file
- CodeGen filters templates based on active variant

**Example - Multiple variant templates:**
```
templates/
└── client/
    ├── restclient.java.tpl    // Variant: restclient
    ├── feign.java.tpl         // Variant: feign
    └── resttemplate.java.tpl  // Variant: resttemplate
```

### 3. Description (OPTIONAL)

Brief description of what this template generates.

```java
// Output: src/main/java/{{basePackagePath}}/domain/{{Entity}}.java
// Variant: jpa
// Description: Domain entity with JPA annotations
```

---

## Template Structure

### Complete Example

```java
// Output: src/main/java/{{basePackagePath}}/adapter/out/{{Entity}}SystemApiClient.java
// Variant: restclient
// Description: REST client for System API using Spring RestClient

package {{basePackage}}.adapter.out;

import {{basePackage}}.domain.{{Entity}};
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

/**
 * REST client for {{Entity}} System API operations.
 */
@Component
public class {{Entity}}SystemApiClient {

    private final RestClient restClient;

    public {{Entity}}SystemApiClient(RestClient.Builder builder) {
        this.restClient = builder
            .baseUrl("${systemapi.base-url}")
            .build();
    }

    public {{Entity}}SystemApiResponse getById(String id) {
        return restClient.get()
            .uri("/{{entityPlural}}/{id}", id)
            .retrieve()
            .body({{Entity}}SystemApiResponse.class);
    }
}
```

---

## Anti-Improvisation Rules (DEC-025)

The LLM MUST follow these rules when processing templates:

### DO ✅

1. **Copy template structure exactly**
2. **Only replace `{{placeholders}}`** with context values
3. **Preserve all whitespace, comments, annotations**
4. **Maintain import order as written**

### DO NOT ❌

1. **Add methods, fields, or annotations** not in template
2. **Remove or simplify** any template content
3. **"Improve"** the template (even if you think it's better)
4. **Add explanatory comments** beyond what's in template
5. **Change coding style** (formatting, naming)

### Example

**Template:**
```java
public {{Entity}} findById({{Entity}}Id id) {
    return repository.findById(id)
        .orElseThrow(() -> new {{Entity}}NotFoundException(id.value().toString()));
}
```

**CORRECT output:**
```java
public Customer findById(CustomerId id) {
    return repository.findById(id)
        .orElseThrow(() -> new CustomerNotFoundException(id.value().toString()));
}
```

**WRONG output (improvised):**
```java
public Customer findById(CustomerId id) {
    // Find customer by ID  ← WRONG: Added comment
    Optional<Customer> result = repository.findById(id);  ← WRONG: Changed structure
    if (result.isEmpty()) {
        throw new CustomerNotFoundException(id.value().toString());
    }
    return result.get();
}
```

---

## Placeholder Syntax

### Basic Placeholders

```
{{variableName}}
```

Replaced with value from generation-context.json.

### Conditional Blocks (DEC-035)

For config flag-dependent content:

```java
{{#config.hateoas}}
// This block only appears if hateoas=true
extends RepresentationModel<{{Entity}}Response>
{{/config.hateoas}}

{{^config.hateoas}}
// This block only appears if hateoas=false or not present
// Simple POJO response
{{/config.hateoas}}
```

### Iteration

```java
{{#fields}}
private {{fieldType}} {{fieldName}};
{{/fields}}
```

---

## Enum Generation Rule (DEC-037)

If a template references an enum type, you MUST either:

1. **Include the enum in the same template**, OR
2. **Have a separate template** that generates the enum file

**WRONG:**
```java
// Template references CustomerStatus but no enum template exists
private CustomerStatus status;  // ❌ Where is CustomerStatus defined?
```

**CORRECT - Option 1 (inline):**
```java
// Output: src/main/java/{{basePackagePath}}/domain/{{Entity}}.java

public class {{Entity}} {
    private {{Entity}}Status status;
}

// Enum defined in same file or separate template exists
public enum {{Entity}}Status {
    ACTIVE, INACTIVE, PENDING
}
```

**CORRECT - Option 2 (separate template):**
```
templates/
├── domain/
│   ├── Entity.java.tpl           // References {{Entity}}Status
│   └── EntityStatus.java.tpl     // Defines the enum
```

---

## Cross-Cutting Templates (Phase 3) - DEC-028, DEC-030

Templates for cross-cutting concerns (resilience, logging, etc.) have special requirements.

### Transform Descriptor

Cross-cutting modules MUST include a `transform-descriptor.yaml`:

```yaml
# modules/mod-code-001-circuit-breaker/transform-descriptor.yaml
transform:
  type: decorator
  target_layer: adapter/out
  target_classes:
    - pattern: "*Client.java"
    - pattern: "*Adapter.java"
  
  annotations_to_add:
    - annotation: "@CircuitBreaker(name = \"{{entity}}\")"
      import: "io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker"
```

### Template for Transforms

Transform templates show the PATTERN to apply, not complete files:

```java
// Output: TRANSFORM_PATTERN (not a real file)
// Description: Circuit breaker annotation pattern

// ADD to class-level annotations:
@CircuitBreaker(name = "{{entity}}", fallbackMethod = "{{methodName}}Fallback")

// ADD fallback method after each public method:
public {{returnType}} {{methodName}}Fallback({{params}}, Exception ex) {
    throw new ServiceUnavailableException("Service temporarily unavailable", ex);
}
```

---

## Testing Templates (DEC-021)

Modules SHOULD include test templates alongside production code templates. Test templates follow the same rules as production templates.

```java
// Output: src/test/java/{{basePackagePath}}/domain/{{Entity}}Test.java

package {{basePackage}}.domain;

import org.junit.jupiter.api.Test;
import static org.assertj.core.api.Assertions.assertThat;

class {{Entity}}Test {

    @Test
    void shouldCreateEntity() {
        // Given
        String id = "test-id";
        
        // When
        {{Entity}} entity = {{Entity}}.reconstitute(
            {{Entity}}Id.of(id),
            // ... other fields
        );
        
        // Then
        assertThat(entity.getId().value()).isEqualTo(id);
    }
}
```

---

## Validation Checklist

Before committing a new template, verify:

- [ ] `// Output:` header present and correct
- [ ] `// Variant:` header present (if module has variants)
- [ ] All `{{placeholders}}` use valid context variables
- [ ] No hardcoded values that should be placeholders
- [ ] Enum types have corresponding templates
- [ ] Imports are complete (no missing imports)
- [ ] Code compiles when placeholders are replaced
- [ ] Follows anti-improvisation rules (no extra content)

---

## Related Documentation

- [MODULE.md](./MODULE.md) - Module authoring (variants, config flags)
- [CAPABILITY.md](./CAPABILITY.md) - Capability definition
- [DEC-025](../../DECISION-LOG.md#dec-025) - Anti-Improvisation Rule
- [DEC-036](../../DECISION-LOG.md#dec-036) - Explicit Output Paths
- [DEC-040](../../DECISION-LOG.md#dec-040) - Variant Headers
- [DEC-041](../../DECISION-LOG.md#dec-041) - Module Variants
