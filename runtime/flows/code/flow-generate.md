# Flow: Generate

## Overview

The Generate flow creates a new project from scratch based on discovered features and modules. This flow is selected when there is no existing code in the context.

## When to Use

- Creating a new microservice or API
- Starting a new project
- No existing codebase provided

## Input

From Discovery:
```yaml
flow: flow-generate
stack: java-spring
features:
  - architecture.hexagonal-light
  - api-architecture.domain-api
  - persistence.systemapi
  - integration.api-rest
  - resilience.circuit-breaker
modules:
  - mod-code-015
  - mod-code-019
  - mod-code-017
  - mod-code-018
  - mod-code-001
config:
  hateoas: true
  compensation_available: true
input_spec:
  serviceName: { type: string, required: true }
  basePackage: { type: string, required: true }
  entities: { type: array, required: true }
```

From User:
```yaml
serviceName: customer-api
basePackage: com.company.customer
entities:
  - name: Customer
    fields:
      - name: id
        type: UUID
      - name: name
        type: String
      - name: email
        type: String
      - name: status
        type: CustomerStatus
```

## Execution

### Phase Planning

Features are grouped into phases based on their **nature**:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           PHASE PLANNING                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  PHASE 1: STRUCTURAL                                                        │
│  ─────────────────────                                                       │
│  Nature: Defines the project structure                                      │
│  Features:                                                                  │
│    - architecture.hexagonal-light (mod-015)                                 │
│    - api-architecture.domain-api (mod-019)                                  │
│  Generates:                                                                 │
│    - pom.xml, application.yml                                               │
│    - Package structure                                                      │
│    - Domain model (entities, value objects)                                 │
│    - Ports (repository interfaces)                                          │
│    - Application service (with TODO stubs)                                  │
│    - REST controller, DTOs, Assembler                                       │
│    - Exception handlers, config                                             │
│  File mutability: All files IMMUTABLE after this phase                      │
│  Except: ApplicationService (will be modified in Phase 2)                   │
│                                                                              │
│  PHASE 2: IMPLEMENTATION                                                    │
│  ────────────────────────                                                    │
│  Nature: Implements ports, connects to backends                             │
│  Features:                                                                  │
│    - persistence.systemapi (mod-017)                                        │
│    - integration.api-rest (mod-018)                                         │
│  Generates:                                                                 │
│    - Adapter out (SystemApiAdapter)                                         │
│    - REST client (SystemApiClient)                                          │
│    - Mapper                                                                 │
│    - External DTOs                                                          │
│  Modifies:                                                                  │
│    - ApplicationService (replaces TODOs with repository calls)              │
│    - application.yml (adds backend config)                                  │
│    - pom.xml (adds dependencies)                                            │
│  File mutability: New files IMMUTABLE, modified files per contract          │
│                                                                              │
│  PHASE 3+: CROSS-CUTTING                                                    │
│  ───────────────────────                                                     │
│  Nature: Adds aspects on top of existing code                               │
│  Features:                                                                  │
│    - resilience.circuit-breaker (mod-001)                                   │
│    - resilience.retry (mod-002) [if selected]                               │
│    - resilience.timeout (mod-003) [if selected]                             │
│  Generates:                                                                 │
│    - Exception classes                                                      │
│    - Configuration files                                                    │
│  Modifies:                                                                  │
│    - Adapter (adds @CircuitBreaker, @Retry annotations)                     │
│    - pom.xml (adds resilience4j dependency)                                 │
│    - application.yml (adds resilience config)                               │
│  File mutability: Mostly annotation additions, minimal code changes         │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Phase Grouping Rules

```python
def group_into_phases(features: List[str]) -> List[Phase]:
    structural = []
    implementation = []
    cross_cutting = []
    
    for feature in features:
        nature = get_feature_nature(feature)
        
        if nature == "structural":
            structural.append(feature)
        elif nature == "implementation":
            implementation.append(feature)
        else:  # cross-cutting
            cross_cutting.append(feature)
    
    phases = []
    
    if structural:
        phases.append(Phase(1, "STRUCTURAL", structural))
    
    if implementation:
        phases.append(Phase(2, "IMPLEMENTATION", implementation))
    
    # Group cross-cutting by capability
    by_capability = group_by_capability(cross_cutting)
    phase_num = 3
    for capability, features in by_capability.items():
        phases.append(Phase(phase_num, f"CROSS_CUTTING_{capability}", features))
        phase_num += 1
    
    return phases
```

### Feature Nature Classification

| Capability | Nature | Rationale |
|------------|--------|-----------|
| architecture | structural | Defines project structure |
| api-architecture | structural | Defines API layer structure |
| persistence | implementation | Implements repository port |
| integration | implementation | Implements external clients |
| resilience | cross-cutting | Adds annotations on adapters |
| distributed-transactions | cross-cutting | Adds compensation aspects |

### Per-Phase Execution

For each phase:

```python
def execute_phase(phase: Phase, context: GenerationContext):
    # 1. Load modules for this phase
    modules = [resolve_module(f) for f in phase.features]
    
    # 2. Prepare context
    phase_context = {
        "modules": modules,
        "user_input": context.user_input,
        "config": context.config,
        "existing_code": context.generated_files if phase.number > 1 else None
    }
    
    # 3. Generate code
    generated = generate_with_modules(phase_context)
    
    # 4. Validate immutables (if not first phase)
    if phase.number > 1:
        validate_immutables(context.immutable_files, generated)
    
    # 5. Compile/validate
    compile_result = compile_project(generated)
    
    if not compile_result.success:
        # Iterate to fix errors
        generated = fix_compilation_errors(generated, compile_result.errors)
    
    # 6. Update context
    context.generated_files.update(generated)
    context.immutable_files.update(get_immutables(phase))
    
    return generated
```

### File Mutability Contract

**IMMUTABLE files (never modified after creation):**
- Domain model: `domain/model/*.java`
- Domain ports: `domain/port/*.java`
- DTOs: `application/dto/*.java`, `adapter/in/rest/dto/*.java`
- Controller: `adapter/in/rest/*Controller.java`
- Assembler: `adapter/in/rest/*Assembler.java`
- Value objects, enums

**MODIFIABLE files (with explicit contracts):**
- `ApplicationService.java`: Can add fields, modify method bodies
- `Adapter*.java`: Can add annotations, add fallback methods
- `pom.xml`: Can add dependencies
- `application.yml`: Can add configuration sections

### Context Size Management

Each phase loads only its required modules:

```
Phase 1: ~45KB (mod-015 + mod-019)
Phase 2: ~55KB (mod-017 + mod-018 + interfaces from Phase 1)
Phase 3: ~45KB (mod-001 + adapter to modify)

Total if loaded holistically: ~197KB
Iterative approach: max ~55KB per phase (72% reduction)
```

## Output

```
customer-api/
├── pom.xml
├── src/main/java/com/company/customer/
│   ├── CustomerApplication.java
│   ├── domain/
│   │   ├── model/
│   │   │   ├── Customer.java
│   │   │   ├── CustomerId.java
│   │   │   └── CustomerStatus.java
│   │   ├── port/
│   │   │   └── CustomerRepository.java
│   │   └── exception/
│   │       └── CustomerNotFoundException.java
│   ├── application/
│   │   ├── CustomerApplicationService.java
│   │   └── dto/
│   │       ├── CreateCustomerRequest.java
│   │       ├── UpdateCustomerRequest.java
│   │       └── CustomerResponse.java
│   └── infrastructure/
│       ├── adapter/
│       │   ├── in/rest/
│       │   │   ├── CustomerController.java
│       │   │   └── CustomerResponseAssembler.java
│       │   └── out/systemapi/
│       │       ├── PartiesSystemApiAdapter.java  # @CircuitBreaker
│       │       ├── PartiesSystemApiClient.java
│       │       └── PartiesSystemApiMapper.java
│       ├── config/
│       │   └── WebConfig.java
│       └── exception/
│           ├── GlobalExceptionHandler.java
│           └── ServiceUnavailableException.java
├── src/main/resources/
│   ├── application.yml
│   └── application-resilience.yml
└── src/test/java/...
```

## Validation

After each phase:
1. **Checksum validation:** Immutable files unchanged
2. **Compilation:** `mvn compile` succeeds
3. **Structure validation:** Expected files exist

After all phases:
1. **Full build:** `mvn package` succeeds
2. **Tests pass:** `mvn test` (if generated)
3. **Traceability:** All files have metadata

## Error Handling

| Error | Resolution |
|-------|------------|
| Compilation error in Phase N | Fix iteratively, retry compilation |
| Immutable file modified | Rollback, regenerate phase |
| Missing dependency | Add to pom.xml, retry |
| Module not found for stack | Error: "Feature X not available for Y" |

## Traceability

Each generated file includes metadata:

```java
/**
 * Generated by Enablement 2.0
 * 
 * @generated
 * @capability architecture.hexagonal-light
 * @module mod-code-015-hexagonal-base-java-spring
 * @phase 1-STRUCTURAL
 * @timestamp 2026-01-20T14:30:00Z
 */
```

## Output

The complete output package structure is defined in [Flow Generate - Output Specification](./flow-generate-output.md).

Summary:
```
gen_{service-name}_{timestamp}/
├── input/           # Original inputs (prompt, specs)
├── output/          # Generated project with .enablement/manifest.json
├── trace/           # Discovery and generation traces
└── validation/      # Validation scripts and results
```

## Related

- [Flow Generate - Output Specification](./flow-generate-output.md) - Package structure
- [Generation Orchestrator](./GENERATION-ORCHESTRATOR.md) - Execution flow
- [Discovery Guidance](../../discovery/discovery-guidance.md) - Capability detection
- [Flow: Transform](./flow-transform.md) - Modifying existing code
