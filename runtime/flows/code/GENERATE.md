# Skill Type: CODE/GENERATE

**Version:** 2.2  
**Date:** 2025-12-23  
**Domain:** CODE

---

## Purpose

GENERATE skills create new code projects from scratch based on requirements. They produce complete, runnable project structures.

---

## Execution Philosophy

> **REVISED in v2.0:** GENERATE execution is HOLISTIC, not sequential.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    HOLISTIC EXECUTION                                     │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  Modules are KNOWLEDGE to consult, not steps to execute.                 │
│                                                                          │
│  The agent:                                                              │
│  1. Identifies ALL features/capabilities required                        │
│  2. Resolves which modules apply                                         │
│  3. READS module templates as guidance                                   │
│  4. Generates COMPLETE output in ONE PASS                                │
│  5. Considers all features TOGETHER (not iteratively)                    │
│                                                                          │
│  This is NOT:                                                            │
│  ✗ Process module 1, generate output, process module 2, modify...        │
│  ✗ Sequential pipeline transformations                                   │
│  ✗ Iterative feature addition                                            │
│                                                                          │
│  VALIDATION is sequential (after generation)                             │
│  GENERATION is holistic (all at once)                                    │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Characteristics

| Aspect | Description |
|--------|-------------|
| Input | Requirements (JSON/YAML generation request) |
| Output | Complete project structure |
| Modules | Multiple modules consulted as knowledge |
| Execution | Holistic - all features generated together |
| Validation | Sequential - each module's validators run |
| Complexity | High - requires synthesizing multiple concerns |

---

## Execution Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     CODE/GENERATE EXECUTION FLOW                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│  PHASE A: PREPARATION                                                        │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  STEP 1: VALIDATE INPUT                                                      │
│  ───────────────────────────────────────────────────────────────────────────│
│  Action: Validate generation-request against skill schema                    │
│  Input:  generation-request.json                                             │
│  Output: Validated request or ERROR                                          │
│                                                                              │
│  ───────────────────────────────────────────────────────────────────────────│
│                                                                              │
│  STEP 2: RESOLVE MODULES                                                     │
│  ───────────────────────────────────────────────────────────────────────────│
│  Action: Determine which modules to consult based on features                │
│  Input:  Validated request + Feature→Module mappings                         │
│  Output: List of modules to consult                                          │
│                                                                              │
│  This step IS deterministic. Feature flags map to modules:                   │
│  - resilience.circuit_breaker → mod-code-001                                │
│  - resilience.retry → mod-code-002                                          │
│  - etc.                                                                      │
│                                                                              │
│  ───────────────────────────────────────────────────────────────────────────│
│                                                                              │
│  STEP 3: LOAD KNOWLEDGE                                                      │
│  ───────────────────────────────────────────────────────────────────────────│
│  Action: Read MODULE.md and templates from each resolved module              │
│  Input:  List of modules                                                     │
│  Output: Accumulated knowledge (templates, patterns, constraints)            │
│                                                                              │
│  For each module:                                                            │
│  - Read MODULE.md (understand purpose, constraints)                          │
│  - Read templates/*.tpl (understand code patterns)                           │
│  - Note validation requirements for later                                    │
│                                                                              │
│  ───────────────────────────────────────────────────────────────────────────│
│                                                                              │
│  STEP 3.5: RESOLVE VARIANTS (v2.1)                                           │
│  ───────────────────────────────────────────────────────────────────────────│
│  Action: Select implementation variant for each module that has variants     │
│  Input:  List of modules + Request features                                  │
│  Output: Selected variant per module (default or alternative)                │
│                                                                              │
│  For each module with variants.enabled = true:                               │
│                                                                              │
│  1. CHECK INPUT for explicit variant selection:                              │
│     If input specifies variant for this module:                              │
│       → Use specified variant                                                │
│       → Log: "Using explicitly requested variant: {variantId}"               │
│                                                                              │
│  2. EVALUATE recommendation conditions (if selection_mode = auto-suggest):   │
│     For each alternative variant:                                            │
│       If recommend_when conditions match input context:                      │
│         → Add to suggested_alternatives list                                 │
│                                                                              │
│  3. IF suggested_alternatives is not empty:                                  │
│     → ASK USER:                                                              │
│       "Para {moduleName}, la implementación por defecto es {default}.        │
│        Sin embargo, {alternative} podría ser más apropiada porque {reason}.  │
│        ¿Deseas usar {alternative}? [Y/n]"                                    │
│     → If user confirms: Use alternative variant                              │
│     → If user declines: Use default variant                                  │
│                                                                              │
│  4. OTHERWISE:                                                               │
│     → Use default variant                                                    │
│     → Log: "Using default variant: {defaultVariantId}"                       │
│                                                                              │
│  5. RECORD selection in manifest:                                            │
│     ```json                                                                  │
│     {                                                                        │
│       "modules": {                                                           │
│         "{moduleId}": {                                                      │
│           "variant": "{selectedVariantId}",                                  │
│           "selection": "explicit|suggested|default",                         │
│           "reason": "{why this variant}"                                     │
│         }                                                                    │
│       }                                                                      │
│     }                                                                        │
│     ```                                                                      │
│                                                                              │
│  ───────────────────────────────────────────────────────────────────────────│
│                                                                              │
│  STEP 4: BUILD CONTEXT                                                       │
│  ───────────────────────────────────────────────────────────────────────────│
│  Action: Prepare all variables and configuration for generation              │
│  Input:  Request + Module knowledge                                          │
│  Output: Complete generation context                                         │
│                                                                              │
│  Variables include:                                                          │
│  - From request: serviceName, package, entities, features                   │
│  - Computed: PascalCase names, path formats                                 │
│  - From modules: configuration defaults, constraints                        │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│  PHASE B: GENERATION (Holistic)                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  STEP 5: GENERATE COMPLETE OUTPUT                                            │
│  ───────────────────────────────────────────────────────────────────────────│
│  Action: Generate the entire project in one coherent pass                    │
│  Input:  Context + All module knowledge                                      │
│  Output: Complete project structure                                          │
│                                                                              │
│  The agent synthesizes ALL knowledge and generates:                          │
│  - All source files considering ALL features together                       │
│  - Configurations that combine ALL modules' requirements                    │
│  - Tests that cover ALL functionality                                        │
│                                                                              │
│  Example: A service method with circuit-breaker AND retry AND timeout        │
│  is generated ONCE with all three annotations, not added iteratively.        │
│                                                                              │
│  Templates are GUIDANCE:                                                     │
│  - The agent understands the pattern from templates                          │
│  - The agent generates code following those patterns                         │
│  - The agent may adapt patterns to fit the specific context                  │
│  - Templates are NOT executed as scripts                                     │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│  PHASE C: VALIDATION (Sequential)                                            │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  STEP 6: TIER-1 VALIDATION (Universal)                                       │
│  ───────────────────────────────────────────────────────────────────────────│
│  Location: runtime/validators/tier-1-universal/                              │
│  Execute: traceability-check.sh, project-structure-check.sh, etc.           │
│                                                                              │
│  ───────────────────────────────────────────────────────────────────────────│
│                                                                              │
│  STEP 7: TIER-2 VALIDATION (Technology)                                      │
│  ───────────────────────────────────────────────────────────────────────────│
│  Location: runtime/validators/tier-2-technology/                             │
│  Execute: Based on detected technology (java-spring, etc.)                   │
│  - compile-check.sh                                                          │
│  - application-yml-check.sh                                                  │
│  - actuator-check.sh                                                         │
│                                                                              │
│  ───────────────────────────────────────────────────────────────────────────│
│                                                                              │
│  STEP 8: TIER-3 VALIDATION (Module)                                          │
│  ───────────────────────────────────────────────────────────────────────────│
│  For EACH module that was consulted during generation:                       │
│  - Run modules/{mod}/validation/{check}.sh                                   │
│  - Order of execution doesn't matter                                         │
│  - ALL must pass                                                             │
│                                                                              │
│  This ensures that even though generation was holistic,                      │
│  each module's constraints are verified.                                     │
│                                                                              │
│  Example: If mod-001 (circuit-breaker) was consulted:                        │
│  - Run circuit-breaker-check.sh                                              │
│  - Verify @CircuitBreaker annotations have fallback methods                  │
│  - Verify configuration is present                                           │
│                                                                              │
│  ════════════════════════════════════════════════════════════════════════   │
│  PHASE D: TRACEABILITY                                                       │
│  ════════════════════════════════════════════════════════════════════════   │
│                                                                              │
│  STEP 9: GENERATE MANIFEST                                                   │
│  ───────────────────────────────────────────────────────────────────────────│
│  Action: Create traceability manifest                                        │
│  Output: .enablement/manifest.json                                           │
│                                                                              │
│  Manifest must include:                                                      │
│  - Generation timestamp                                                      │
│  - Skill used and version                                                    │
│  - ALL modules consulted                                                     │
│  - ADRs/ERIs that apply                                                      │
│  - File→Template guidance mapping                                            │
│  - Validation results                                                        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Module Resolution Table

Feature flags in the request map to modules:

| Feature Path | Condition | Module |
|--------------|-----------|--------|
| (always for CODE/GENERATE) | - | mod-code-015-hexagonal-base-java-spring |
| `features.resilience.circuit_breaker.enabled` | `true` | mod-code-001-circuit-breaker-java-resilience4j |
| `features.resilience.retry.enabled` | `true` | mod-code-002-retry-java-resilience4j |
| `features.resilience.timeout.enabled` | `true` | mod-code-003-timeout-java-resilience4j |
| `features.resilience.rate_limiter.enabled` | `true` | mod-code-004-rate-limiter-java-resilience4j |
| `features.persistence.type` | `jpa` | mod-code-016-persistence-jpa-spring |
| `features.persistence.type` | `system_api` | mod-code-017-persistence-systemapi |
| `features.integration.rest_clients` | not empty | mod-code-018-api-integration-rest-java-spring |

---

## Why Holistic Matters

### Sequential (WRONG for GENERATE)

```java
// Step 1: Generate base service
public Customer getCustomer(String id) {
    return repository.findById(id);
}

// Step 2: Add circuit-breaker
@CircuitBreaker(name = "backend")
public Customer getCustomer(String id) {
    return repository.findById(id);
}

// Step 3: Add retry
@CircuitBreaker(name = "backend")
@Retry(name = "backend")  // Added
public Customer getCustomer(String id) {
    return repository.findById(id);
}

// Step 4: Add timeout
@CircuitBreaker(name = "backend")
@Retry(name = "backend")
@TimeLimiter(name = "backend")  // Added
public Customer getCustomer(String id) {
    return repository.findById(id);
}
```

This iterative approach:
- Requires 4 generation passes
- May create inconsistencies
- Doesn't consider interactions between features

### Holistic (CORRECT)

```java
// Generated in one pass, all features considered together
@CircuitBreaker(name = "backend", fallbackMethod = "getCustomerFallback")
@Retry(name = "backend")
@TimeLimiter(name = "backend")
public Customer getCustomer(String id) {
    return repository.findById(id);
}

public Customer getCustomerFallback(String id, Throwable t) {
    log.error("Fallback for getCustomer: {}", t.getMessage());
    throw new ServiceUnavailableException("Customer service unavailable");
}
```

This holistic approach:
- Single coherent generation
- All features integrated naturally
- Interactions considered (e.g., fallback handles all failure modes)

---

## Output Structure

```
{serviceName}/
├── .enablement/
│   └── manifest.json           # Traceability (REQUIRED)
├── src/
│   ├── main/
│   │   ├── java/{package}/
│   │   │   ├── Application.java
│   │   │   ├── domain/         # Pure POJOs
│   │   │   ├── application/    # @Service orchestration
│   │   │   ├── adapter/        # REST, persistence
│   │   │   └── infrastructure/ # Config, exceptions
│   │   └── resources/
│   │       └── application.yml
│   └── test/
├── pom.xml
└── README.md
```

---

## Flow Execution Output Structure

When a GENERATE flow executes, it produces a standardized output structure that enables reproducibility, traceability, and validation.

```
{execution-id}/
├── input/                          # Inputs received by the flow
│   ├── prompt.md                   # Structured prompt (from specialized agent)
│   └── generation-request.json     # Generated request (created during execution)
│
├── output/                         # Generated artifact
│   └── {serviceName}/              # The complete project structure
│       ├── .enablement/
│       │   └── manifest.json
│       ├── src/
│       ├── pom.xml
│       └── ...
│
├── trace/                          # Decision traceability
│   └── generation-trace.md         # Skills activated, modules consulted, decisions made
│
└── validation/                     # Validation scripts for reproducibility
    ├── tier-1-universal.sh         # Re-run tier-1 validations
    ├── tier-2-technology.sh        # Re-run tier-2 validations (tech-specific)
    ├── tier-3-skill.sh             # Re-run tier-3 validations (skill-specific)
    ├── compile.sh                  # Compile artifact (mvn compile, npm build, etc.)
    ├── test.sh                     # Run tests (mvn test, npm test, etc.)
    └── package.sh                  # Package artifact (mvn package, npm pack, etc.)
```

### Directory Purposes

| Directory | Purpose |
|-----------|---------|
| `input/` | Store all inputs for reproducibility. `generation-request.json` is generated during execution from `prompt.md`. |
| `output/` | Contains the generated artifact (project). Structure depends on the skill/technology. |
| `trace/` | Records all decisions made during execution: skill selection, module resolution, variant choices. |
| `validation/` | Scripts to re-execute validations and verify artifact integrity. |

### Validation Scripts

The `validation/` directory contains scripts that allow re-running all validations:

| Script | Purpose |
|--------|---------|
| `tier-1-universal.sh` | Re-execute universal validations (traceability, naming, structure) |
| `tier-2-technology.sh` | Re-execute technology-specific validations (Java/Spring, Node, etc.) |
| `tier-3-skill.sh` | Re-execute skill/module-specific validations |
| `compile.sh` | Compile the generated artifact |
| `test.sh` | Execute unit tests |
| `package.sh` | Package the artifact for deployment |

These scripts enable:
1. **Reproducibility**: Anyone can re-validate the generated code
2. **CI/CD Integration**: Scripts can be executed in pipelines
3. **Comparison**: Results can be compared across different generation runs

---

## Traceability Requirements

The manifest.json MUST include:

```json
{
  "generatedAt": "ISO-8601 timestamp",
  "skill": {
    "id": "skill-code-020-generate-microservice-java-spring",
    "version": "1.x.x"
  },
  "modulesConsulted": [
    {
      "module": "mod-code-015-hexagonal-base-java-spring",
      "reason": "Base architecture for all CODE/GENERATE"
    },
    {
      "module": "mod-code-001-circuit-breaker-java-resilience4j",
      "reason": "features.resilience.circuit_breaker.enabled = true"
    }
  ],
  "adrsApplied": ["adr-009", "adr-004"],
  "validation": {
    "tier1": "PASS",
    "tier2": "PASS",
    "tier3": {
      "mod-code-015": "PASS",
      "mod-code-001": "PASS"
    }
  }
}
```

---

## Error Handling

| Error | Handling |
|-------|----------|
| Invalid input schema | Return validation errors, stop |
| Module not found | Return error, list available modules |
| Generation failure | Return error with context |
| Validation failure | Return report, mark as failed |

---

## Determinism Rules (v2.1)

During STEP 5 (GENERATE COMPLETE OUTPUT), the agent MUST follow determinism rules:

### Mandatory Reference

Before generating code, the agent MUST consult:
- `model/standards/DETERMINISM-RULES.md` - Global patterns
- Each module's `## Determinism` section - Module-specific patterns

### Key Rules Summary

| Element | Required Pattern |
|---------|-----------------|
| Entity IDs | `record` with `UUID` |
| Request DTOs | `record` |
| Response DTOs | `record` (no HATEOAS) / `class` (HATEOAS) |
| Domain Entities | `class` |
| Domain Enums | Simple (no attributes) |
| Code mapping | In Mapper class, NOT in Enum |
| External DTOs | `record` with `@JsonProperty` |

### Required Annotations

All generated classes MUST include:

```java
/**
 * @generated {skill-id} v{version}
 * @module {module-id}
 * @variant {variant-id}  // If non-default
 */
```

---

## Example Skills

- `skill-code-020-generate-microservice-java-spring`
- `skill-code-021-generate-rest-api-java-spring`
- `skill-code-022-generate-event-consumer-java-kafka` (future)

---

**END OF DOCUMENT**
