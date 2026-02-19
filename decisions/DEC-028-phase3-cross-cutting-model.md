# DEC-028: Phase 3 Cross-Cutting Transformation Model

**Status:** Accepted  
**Date:** 2026-01-27  
**Authors:** Enablement 2.0 Team  
**Relates to:** DEC-024 (Template-First), DEC-025 (Template Fingerprints), Model v3.0

---

## Context

In the v3.0 generation model, we introduced a phased approach to code generation:
- **Phase 1 (Structural):** Generate foundational code (hexagonal structure, filters)
- **Phase 2 (Implementation):** Generate business implementation (persistence, API exposure)
- **Phase 3+ (Cross-Cutting):** Apply concerns that span multiple files (resilience, transactions)

The challenge with Phase 3 is that cross-cutting modules must **transform existing code** rather than generate new files. For example:
- Circuit breaker: Add `@CircuitBreaker` annotations to existing adapter methods
- Retry: Add `@Retry` annotations (after circuit breaker)
- Timeout: Modify existing timeout values in `RestClientConfig.java`

We needed a standardized way to define these transformations.

---

## Decision

### Transform Descriptors

Each cross-cutting module defines a **Transform Descriptor** in YAML format:

```
modules/{module-id}/
├── MODULE.md              # Standard module documentation
├── templates/             # Templates for NEW file generation (if any)
├── validation/            # Tier-3 validation scripts
└── transform/             # NEW: Transform descriptors
    ├── {transform-name}.yaml   # Transform descriptor
    └── snippets/               # Code snippets to insert
        ├── annotation.java
        └── fallback-method.java
```

### Transform Descriptor Schema

```yaml
transformation:
  id: unique-transform-id
  type: annotation | modification | merge
  phase: 3
  description: "What this transformation does"
  
  # Optional: execution order (lower runs first)
  depends_on:
    - module-id-that-must-run-first
  
  targets:
    - pattern: "**/adapter/out/**/*Adapter.java"
      description: "What files to transform"
      generated_by: module-id-that-generated-the-file
      exclude:
        - "**/pattern/to/exclude/**"
  
  steps:
    - action: add_imports
      imports:
        - "package.Class"
      position: after_package
      
    - action: add_annotation_to_methods
      selector:
        visibility: public
        returns_not: void
      annotation:
        template: "@Annotation(param = value)"
      position: before_existing_annotations
      
    - action: add_method
      snippet: snippets/method.java
      position: after_class
      variables:
        key: value
  
  yaml_merge:
    file: application.yml
    template: ../templates/config/application-xxx.yml.tpl
    merge_strategy: deep_merge
    path: "resilience4j.xxx"
  
  pom_dependencies:
    - groupId: group
      artifactId: artifact
      version: "${version}"
```

### Execution Order

Cross-cutting modules specify `execution_order` in their MODULE.md frontmatter:

```yaml
phase_group: cross-cutting
execution_order: 1  # Lower numbers run first
```

Standard order for resilience:
1. **mod-001 (circuit-breaker):** First, outer wrapper
2. **mod-002 (retry):** Second, retries inside CB window
3. **mod-003 (timeout):** Third, modifies infrastructure config

This ensures correct annotation order in generated code:
```java
@CircuitBreaker(...)  // Applied first, outermost
@Retry(...)           // Applied second, inner
public Result method() { ... }
```

### Transformation Types

| Type | Description | Example |
|------|-------------|---------|
| `annotation` | Add annotations to existing methods | @CircuitBreaker, @Retry |
| `modification` | Modify existing code values | Change timeout from 30s to 5s |
| `merge` | Merge YAML configuration | Add resilience4j config |

### Fingerprints for Validation

Each transform descriptor includes fingerprints for Tier-0 validation:

```yaml
fingerprints:
  - pattern: "@CircuitBreaker"
    file: "*Adapter.java"
    description: "Circuit breaker annotation must be present"
```

---

## Consequences

### Positive

1. **Declarative:** Transformations defined in YAML, not code
2. **Traceable:** Each step documented and auditable
3. **Validatable:** Fingerprints enable automated conformance checks
4. **Ordered:** Explicit execution order prevents annotation conflicts
5. **Consistent:** Same transformation applied uniformly to all targets

### Negative

1. **Complexity:** Requires understanding of transform descriptor schema
2. **Two paradigms:** Generate (Phase 1-2) vs Transform (Phase 3+)
3. **Limited flexibility:** Complex transformations may not fit YAML format

### Mitigations

- Snippets allow complex code in separate files
- `add_method` action for arbitrary code insertion
- Documentation and examples in each module

---

## Implementation

### Files Created

| Module | Transform Descriptor | Type |
|--------|---------------------|------|
| mod-001 | `transform/circuit-breaker-transform.yaml` | annotation |
| mod-002 | `transform/retry-transform.yaml` | annotation |
| mod-003 | `transform/timeout-config-transform.yaml` | modification |

### MODULE.md Updates

Each cross-cutting module's frontmatter updated with:

```yaml
phase_group: cross-cutting
execution_order: N

transformation:
  type: annotation | modification
  descriptor: transform/{name}.yaml
  targets:
    - pattern: "**/*Adapter.java"
      generated_by: mod-017
```

### GENERATION-ORCHESTRATOR.md Updates

- Phase 3 documentation updated to reference transform descriptors
- New function `load_cross_cutting_modules()` documented
- Updated `apply_resilience_transformations()` to use descriptors

---

## Related Decisions

- **DEC-024:** Template-First Generation (no improvised code)
- **DEC-025:** Template Fingerprints (conformance validation)
- **DEC-029:** RMAS Import Fix (example of Phase 3 fix)

---

## References

- `runtime/flows/code/GENERATION-ORCHESTRATOR.md` - Phase 3 documentation
- `runtime/flows/code/flow-transform.md` - Transformation contracts
- `modules/mod-code-001*/transform/` - Circuit breaker transform
- `modules/mod-code-002*/transform/` - Retry transform
- `modules/mod-code-003*/transform/` - Timeout transform
