# Flow: Transform

## Overview

The Transform flow modifies an existing project by adding new capabilities or features. This flow is selected when existing code is provided in the context.

## When to Use

- Adding resilience patterns to existing service
- Adding persistence to existing API
- Adding new endpoints to existing controller
- Modifying existing implementation

## Input

From Discovery:
```yaml
flow: flow-transform
stack: java-spring  # Detected from existing pom.xml
features:
  - resilience.circuit-breaker
  - resilience.retry
modules:
  - mod-code-001
  - mod-code-002
config: {}
```

From Context:
```yaml
existing_code:
  pom.xml: "..."
  src/main/java/.../PartiesSystemApiAdapter.java: "..."
  src/main/resources/application.yml: "..."
```

## Execution

### Step 1: Analyze Existing Code

Identify what exists and what needs to be modified:

```python
def analyze_existing_code(existing_code: dict, features: List[str]) -> Analysis:
    analysis = Analysis()
    
    for feature in features:
        feature_def = get_feature(feature)
        
        # Determine what this feature needs to modify
        if feature.startswith("resilience"):
            # Resilience features modify adapters
            adapters = find_adapters(existing_code)
            analysis.files_to_modify.extend(adapters)
            analysis.modification_type = "annotation"
            
        elif feature.startswith("persistence"):
            # Persistence features implement ports
            ports = find_unimplemented_ports(existing_code)
            analysis.ports_to_implement = ports
            analysis.files_to_create.append("adapter/out/*")
            
    return analysis
```

### Step 2: Load Relevant Modules

Only load modules for the features being added:

```python
def prepare_context(features: List[str], existing_code: dict) -> Context:
    modules = [resolve_module(f) for f in features]
    
    # Only include existing files that will be modified
    files_to_modify = identify_files_to_modify(features, existing_code)
    
    return Context(
        modules=modules,
        existing_code={k: v for k, v in existing_code.items() 
                       if k in files_to_modify}
    )
```

### Step 3: Apply Transformations

For each feature, apply the appropriate transformation:

```python
def transform(context: Context) -> dict:
    modified_files = {}
    
    for module in context.modules:
        transformation = get_transformation_type(module)
        
        if transformation == "annotation":
            # Add annotations to existing methods
            modified = add_annotations(context.existing_code, module)
            
        elif transformation == "implementation":
            # Create new files implementing interfaces
            modified = implement_interfaces(context.existing_code, module)
            
        elif transformation == "configuration":
            # Add configuration sections
            modified = add_configuration(context.existing_code, module)
        
        modified_files.update(modified)
    
    return modified_files
```

### Transformation Types

| Type | Description | Example |
|------|-------------|---------|
| **annotation** | Add annotations to existing methods | `@CircuitBreaker` on adapter |
| **implementation** | Create new classes implementing interfaces | `JpaRepositoryImpl` |
| **configuration** | Add config sections | Resilience4j config in `application.yml` |
| **extension** | Add new methods to existing classes | New endpoints in controller |

## Modification Contracts

### Resilience Annotations

**Allowed modifications:**
```java
// BEFORE
public Customer findById(CustomerId id) {
    return client.getParty(id.value());
}

// AFTER
@CircuitBreaker(name = "parties", fallbackMethod = "findByIdFallback")
@Retry(name = "parties")
public Customer findById(CustomerId id) {
    return client.getParty(id.value());
}

// ADDED
private Customer findByIdFallback(CustomerId id, Exception ex) {
    log.warn("Fallback for findById: {}", ex.getMessage());
    throw new ServiceUnavailableException("Service temporarily unavailable");
}
```

**Prohibited modifications:**
- Change method signatures
- Change method logic (except for wrapping)
- Remove existing annotations
- Change class structure

### Configuration Additions

**Allowed modifications:**
```yaml
# application.yml - ADDING sections

# Existing
spring:
  application:
    name: customer-api

# Added by transformation
resilience4j:
  circuitbreaker:
    instances:
      parties:
        slidingWindowSize: 10
        failureRateThreshold: 50
```

**Prohibited modifications:**
- Changing existing configuration values
- Removing existing sections

### Dependency Additions

**Allowed modifications:**
```xml
<!-- pom.xml - ADDING dependencies -->
<dependencies>
    <!-- Existing dependencies preserved -->
    
    <!-- Added by transformation -->
    <dependency>
        <groupId>io.github.resilience4j</groupId>
        <artifactId>resilience4j-spring-boot3</artifactId>
    </dependency>
</dependencies>
```

## Validation

### Pre-transformation

1. **Code compiles:** Existing code must compile before transformation
2. **Structure recognized:** Can identify adapters, services, etc.
3. **No conflicts:** Annotations/config don't already exist

### Post-transformation

1. **Code compiles:** Modified code must compile
2. **Tests pass:** Existing tests still pass
3. **New tests pass:** If transformation adds tests
4. **Contract respected:** Only allowed modifications made

## Example: Add Circuit Breaker

**User request:**
> "Añade circuit breaker al adapter de parties"

**Discovery result:**
```yaml
flow: flow-transform
features: [resilience.circuit-breaker]
modules: [mod-code-001]
```

**Transformation:**

1. **Analyze:** Find `PartiesSystemApiAdapter.java`
2. **Load:** mod-001 (circuit breaker module)
3. **Transform:**
   - Add `@CircuitBreaker` to public methods
   - Add fallback methods
   - Add logger field
   - Add imports
4. **Configure:**
   - Add resilience4j dependency to pom.xml
   - Add circuit breaker config to application.yml
5. **Validate:**
   - Compile: `mvn compile`
   - Test: `mvn test`

**Files modified:**
```
PartiesSystemApiAdapter.java  # Annotations + fallbacks
pom.xml                       # Dependency added
application.yml               # Config section added
```

**Files created:**
```
ServiceUnavailableException.java  # For fallbacks
application-resilience.yml        # Resilience config
```

## Error Handling

| Error | Resolution |
|-------|------------|
| Can't find adapter | Ask: "Which class should I modify?" |
| Annotation already exists | Skip or warn |
| Compilation fails | Show error, suggest fix |
| Incompatible code structure | Error: "Code structure not recognized" |

## Output

```yaml
transformation_result:
  files_modified:
    - path: src/main/java/.../PartiesSystemApiAdapter.java
      changes:
        - type: annotation_added
          target: findById
          annotation: "@CircuitBreaker"
        - type: method_added
          name: findByIdFallback
    - path: pom.xml
      changes:
        - type: dependency_added
          artifact: resilience4j-spring-boot3
    - path: application.yml
      changes:
        - type: section_added
          path: resilience4j.circuitbreaker
  files_created:
    - path: src/main/java/.../ServiceUnavailableException.java
    - path: src/main/resources/application-resilience.yml
  validation:
    compilation: success
    tests: success
```

## Related Flows (TBD)

The following flows are variants of Transform, to be detailed in future versions:

- **flow-migrate:** Transform code from one pattern/version to another
- **flow-refactor:** Restructure code while preserving behavior
- **flow-remove:** Remove a capability from existing code

## Related

- [Discovery Guidance](./discovery-guidance.md)
- [Flow: Generate](./flow-generate.md)
