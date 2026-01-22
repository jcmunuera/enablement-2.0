# Discovery Guidance v3.1

## Overview

Discovery is the process of determining which **capabilities, features, and modules** are needed to fulfill a user request. In v3.0, discovery follows a single unified path through the capability-index.

```
prompt + context → capabilities → features → implementations → modules
```

There is **no separate skill discovery**. All logic previously in skills is now embedded in features.

---

## Capability Types (v2.3)

### Type Definitions

| Type | Description | Cardinality | Required for Generate | Transformable |
|------|-------------|-------------|----------------------|---------------|
| **foundational** | Base architecture, defines project structure | exactly-one | YES | NO |
| **layered** | Adds layers on top of foundational | multiple | NO | YES |
| **cross-cutting** | Decorators on existing code | multiple | NO | YES |

### Type Behaviors

**FOUNDATIONAL:**
- Exactly ONE required for `flow-generate`
- Cannot be added via transformation (must be set at creation)
- All `layered` capabilities implicitly require a foundational
- Example: `architecture`

**LAYERED:**
- Requires foundational to exist (auto-added if missing)
- Can be added via `flow-transform`
- Phase determined by `phase_group` attribute
- Examples: `api-architecture`, `persistence`, `integration`

**CROSS-CUTTING:**
- Does NOT require foundational (can apply to existing projects)
- Can be added via `flow-transform`
- Decorates existing code (annotations, config)
- Examples: `resilience`, `distributed-transactions`

### Phase Groups

| Phase Group | Phase | Description |
|-------------|-------|-------------|
| `structural` | 1 | Project structure, adapters IN (controllers) |
| `implementation` | 2 | External connections, adapters OUT (clients, repositories) |
| `cross-cutting` | 3+ | Decorators, annotations |

---

## Discovery Rules (v2.3)

### Rule 1: Keyword Matching Priority

```
feature.keywords > capability.keywords > stack.keywords
```

When matching keywords from prompt:
1. First check feature-level keywords (most specific)
2. If no feature match, check capability-level keywords
3. Stack keywords only affect stack resolution

### Rule 2: Default Feature Resolution

```python
if capability_matched and not feature_matched:
    if capability.default_feature:
        use(capability.default_feature)
    else:
        ask_user("Which feature of {capability}?")
```

### Rule 3: Dependency Resolution

```python
for feature in matched_features:
    for required in feature.requires:
        if required is capability_name:
            # Add default_feature of that capability
            add(required_capability.default_feature)
        else:
            # Add specific feature
            add(required)
```

### Rule 4: Foundational Guarantee (flow-generate only)

```python
if flow == "flow-generate":
    foundational_count = count(features where type == "foundational")
    
    if foundational_count == 0:
        # Auto-add default foundational
        add("architecture.hexagonal-light")
    elif foundational_count > 1:
        raise Error("Only one foundational allowed")
```

### Rule 5: Incompatibility Check

```python
for feature in all_features:
    for incompatible in feature.incompatible_with:
        if incompatible in all_features:
            raise Error(f"{feature} incompatible with {incompatible}")
```

**Note (v2.3):** `persistence.jpa` and `persistence.systemapi` are NOT incompatible. Hybrid persistence scenarios are valid.

### Rule 6: Phase Assignment

```python
def assign_phases(features):
    phase_1 = [f for f in features if f.capability.phase_group == "structural"]
    phase_2 = [f for f in features if f.capability.phase_group == "implementation"]
    phase_3 = [f for f in features if f.capability.phase_group == "cross-cutting"]
    
    # Order within phase by requires (dependencies first)
    return [sort_by_requires(p) for p in [phase_1, phase_2, phase_3]]
```

### Rule 7: Config Prerequisite Validation (NEW in v2.3)

Some features require specific config values in other selected features.

```python
def validate_config_prerequisites(all_features, capability_index):
    for feature in all_features:
        if 'requires_config' in feature:
            for prereq in feature['requires_config']:
                # Find the target capability's selected feature
                target_cap = prereq['capability']
                target_feature = find_selected_feature(all_features, target_cap)
                
                if target_feature is None:
                    raise ConfigPrerequisiteError(
                        f"{feature} requires {target_cap} to be selected"
                    )
                
                config_key = prereq['config_key']
                expected_value = prereq['value']
                actual_value = target_feature.config.get(config_key)
                
                if actual_value != expected_value:
                    raise ConfigPrerequisiteError(prereq['error_message'])
```

**Example:** `saga-compensation` requires `compensation_available=true` in the selected API type:

```yaml
# In capability-index.yaml
saga-compensation:
  requires_config:
    - capability: api-architecture
      config_key: compensation_available
      value: true
      error_message: "Compensation requires an API type that supports it (e.g., domain-api)"
```

| API Type | compensation_available | Can use saga-compensation? |
|----------|------------------------|---------------------------|
| standard | false | ❌ No |
| domain-api | true | ✅ Yes |
| system-api | false | ❌ No |
| experience-api | false | ❌ No |
| composable-api | false | ❌ No |

---

## Discovery Flow

### Step 1: Stack Resolution

Determine the technology stack before matching features.

**Priority order:**
1. **Explicit in prompt:** "API en Quarkus" → `java-quarkus`
2. **Detected from code:** `pom.xml` with `spring-boot-starter` → `java-spring`
3. **Organizational default:** `defaults.stack` → `java-spring`

**Detection rules (from capability-index.yaml):**
```yaml
stacks:
  java-spring:
    detection:
      - file: pom.xml
        contains: "spring-boot-starter"
  java-quarkus:
    detection:
      - file: pom.xml
        contains: "quarkus"
  nodejs:
    detection:
      - file: package.json
```

**Algorithm:**
```python
def resolve_stack(prompt: str, existing_code: dict) -> str:
    # 1. Check prompt for explicit stack mention
    for stack_id, stack in capability_index.stacks.items():
        for keyword in stack.keywords:
            if keyword.lower() in prompt.lower():
                return stack_id
    
    # 2. Check existing code for detection markers
    if existing_code:
        for stack_id, stack in capability_index.stacks.items():
            for rule in stack.detection:
                if rule.file in existing_code:
                    if rule.contains in existing_code[rule.file]:
                        return stack_id
    
    # 3. Return default
    return capability_index.defaults.stack
```

---

### Step 2: Feature Matching (v2.2 Algorithm)

Match user prompt against keywords to identify required features.

**Matching Priority (v2.2):**
1. **Exact feature keyword match** (highest priority)
2. **Capability keyword match + default_feature**
3. **Stack keyword match** (for stack resolution only)

**NEW v2.2: Default Feature Resolution**

When a capability matches but no specific feature is identified:
- If `default_feature` is defined → Use that feature automatically
- If no `default_feature` → Ask user for clarification

**Algorithm (v2.2):**
```python
def match_features(prompt: str, context: dict) -> List[Feature]:
    matched = []
    prompt_lower = prompt.lower()
    
    for cap_id, capability in capability_index.capabilities.items():
        feature_matched = False
        
        # First: Check feature-level keywords (highest priority)
        for feature_id, feature in capability.features.items():
            for keyword in feature.get('keywords', []):
                if keyword.lower() in prompt_lower:
                    matched.append(f"{cap_id}.{feature_id}")
                    feature_matched = True
                    break
            if feature_matched:
                break
        
        # Second: Check capability-level keywords
        if not feature_matched:
            for keyword in capability.get('keywords', []):
                if keyword.lower() in prompt_lower:
                    # Capability matched but not specific feature
                    if 'default_feature' in capability:
                        # Use default
                        matched.append(f"{cap_id}.{capability['default_feature']}")
                    else:
                        # No default - need to ask user
                        raise AmbiguousFeatureError(
                            f"Capability '{cap_id}' matched but no specific feature. "
                            f"Options: {list(capability.features.keys())}"
                        )
                    break
    
    return matched
```

**v2.2 Matching Rules:**

| Rule | Description | Example |
|------|-------------|---------|
| 1 | Feature keywords take priority over capability keywords | "Domain API" → `api-architecture.domain-api` (not default) |
| 2 | Capability keyword + default_feature = automatic selection | "API" → `api-architecture.domain-api` (via default) |
| 3 | Capability keyword without default_feature = ask user | "resilience" → Ask: "Which pattern?" |
| 4 | Multiple capability matches are valid | "microservicio con API" → both match |
| 5 | Dependencies are auto-added from requires | `domain-api` auto-adds `hexagonal-light` |
| 6 | Config prerequisites validated | `saga-compensation` requires `compensation_available=true` |

**v2.3 Test Cases:**

| # | Prompt | Expected Features | Reason |
|---|--------|-------------------|--------|
| 1 | "Genera un microservicio" | `architecture.hexagonal-light` | "microservicio" → architecture (capability) → default: hexagonal-light |
| 2 | "Genera una API" | `architecture.hexagonal-light`, `api-architecture.standard` | "API" → api-architecture (capability) → default: standard → requires: hexagonal-light |
| 3 | "Domain API con circuit breaker" | `architecture.hexagonal-light`, `api-architecture.domain-api`, `resilience.circuit-breaker` | Explicit feature matches + dependency |
| 4 | "JPA y System API" | Both persistence features (hybrid) | v2.3: No longer incompatible |
| 5 | "Añade retry" | `resilience.retry` | Direct feature keyword match |
| 6 | "Domain API con compensación" | `domain-api` + `saga-compensation` | Rule 7: compensation_available=true ✓ |
| 7 | "API con compensación" | ERROR | Rule 7: standard.compensation_available=false |

**Examples with v2.3 behavior:**

| Prompt | v2.1 Result | v2.3 Result |
|--------|-------------|-------------|
| "microservicio" | No match ❌ | `architecture.hexagonal-light` ✅ |
| "API" | Ask user ❓ | `api-architecture.standard` ✅ |
| "Domain API" | `api-architecture.domain-api` | `api-architecture.domain-api` (unchanged) |
| "hexagonal" | `architecture.hexagonal-light` | `architecture.hexagonal-light` (unchanged) |
| "resilience" | Ask user ❓ | Ask user ❓ (no default_feature) |
| "JPA y System API" | ERROR ❌ | Both features ✅ (hybrid) |

---

### Step 3: Resolve Dependencies

For each matched feature, resolve its `requires` dependencies.

```python
def resolve_dependencies(features: List[str]) -> List[str]:
    all_features = set(features)
    queue = list(features)
    
    while queue:
        feature = queue.pop(0)
        feature_def = get_feature(feature)
        
        for required in feature_def.get('requires', []):
            if required not in all_features:
                all_features.add(required)
                queue.append(required)
    
    return list(all_features)
```

**Example:**
```
Input: [api-architecture.domain-api, persistence.systemapi]

Resolve:
  - domain-api.requires → architecture.hexagonal-light
  - systemapi.requires → integration.api-rest

Output: [architecture.hexagonal-light, api-architecture.domain-api, 
         integration.api-rest, persistence.systemapi]
```

---

### Step 4: Validate Compatibility

Check for incompatible feature combinations.

```python
def validate_compatibility(features: List[str]) -> List[str]:
    errors = []
    
    for feature in features:
        feature_def = get_feature(feature)
        
        for incompatible in feature_def.get('incompatible_with', []):
            if incompatible in features:
                errors.append(f"{feature} is incompatible with {incompatible}")
    
    return errors
```

**Known incompatibilities:**
- `persistence.jpa` ↔ `persistence.systemapi`
- `integration.api-rest` ↔ `integration.api-webclient` (future)

---

### Step 5: Resolve Implementations

For each feature, select the implementation matching the resolved stack.

```python
def resolve_implementations(features: List[str], stack: str) -> List[Module]:
    modules = []
    
    for feature in features:
        feature_def = get_feature(feature)
        
        # Find implementation for this stack
        impl = None
        for i in feature_def.implementations:
            if i.stack == stack:
                impl = i
                break
        
        if not impl:
            # No implementation for this stack
            raise NoImplementationError(f"No {stack} implementation for {feature}")
        
        modules.append(impl.module)
    
    return modules
```

---

### Step 6: Determine Flow

Based on context, determine whether to generate or transform.

```python
def determine_flow(context: dict) -> str:
    if not context.get('existing_code'):
        return "flow-generate"
    else:
        return "flow-transform"
```

---

### Step 7: Extract Config and Input Spec

Merge configs from all features and extract input specification from primary feature.

```python
def extract_config(features: List[str]) -> dict:
    config = {}
    for feature in features:
        feature_def = get_feature(feature)
        if 'config' in feature_def:
            config.update(feature_def.config)
    return config

def get_input_spec(primary_feature: str) -> dict:
    feature_def = get_feature(primary_feature)
    return feature_def.get('input_spec', {})
```

---

## Discovery Output

The discovery process produces:

```python
@dataclass
class DiscoveryResult:
    flow: str                    # "flow-generate" or "flow-transform"
    stack: str                   # "java-spring"
    features: List[str]          # ["architecture.hexagonal-light", ...]
    modules: List[str]           # ["mod-code-015", "mod-code-019", ...]
    config: dict                 # {"hateoas": true, ...}
    input_spec: dict             # {"serviceName": {...}, ...}
```

---

## Complete Example

**User request:**
> "Desarrolla una API de dominio para Customer con persistencia en System API y circuit breaker"

**Discovery execution:**

```
Step 1: Stack Resolution
  - No explicit stack in prompt
  - No existing code
  - Default: java-spring

Step 2: Feature Matching
  - "API de dominio" → api-architecture.domain-api
  - "System API" → persistence.systemapi
  - "circuit breaker" → resilience.circuit-breaker

Step 3: Resolve Dependencies
  - domain-api.requires → architecture.hexagonal-light
  - systemapi.requires → integration.api-rest
  
  All features: [architecture.hexagonal-light, api-architecture.domain-api,
                 integration.api-rest, persistence.systemapi,
                 resilience.circuit-breaker]

Step 4: Validate Compatibility
  - No incompatibilities found ✓

Step 5: Resolve Implementations (stack=java-spring)
  - architecture.hexagonal-light → mod-code-015
  - api-architecture.domain-api → mod-code-019
  - integration.api-rest → mod-code-018
  - persistence.systemapi → mod-code-017
  - resilience.circuit-breaker → mod-code-001

Step 6: Determine Flow
  - No existing code → flow-generate

Step 7: Extract Config
  - hateoas: true (from domain-api)
  - compensation_available: true (from domain-api)

Output:
  flow: flow-generate
  stack: java-spring
  features: [architecture.hexagonal-light, api-architecture.domain-api,
             integration.api-rest, persistence.systemapi,
             resilience.circuit-breaker]
  modules: [mod-code-015, mod-code-019, mod-code-018, 
            mod-code-017, mod-code-001]
  config: {hateoas: true, compensation_available: true}
  input_spec: {serviceName: {...}, basePackage: {...}, entities: {...}}
```

---

## Handling Ambiguity

When the prompt is ambiguous, ask clarifying questions:

| Situation | Action |
|-----------|--------|
| "Add resilience" (no specific pattern) | Ask: "Which patterns? circuit-breaker, retry, timeout?" |
| "API" (no type specified) | Use `api-architecture.standard` (default) |
| "Domain API" / "System API" / "BFF" | Use specific feature (explicit match) |
| "persistence" (no type specified) | Ask: "Which persistence? JPA or System API?" |
| Multiple stacks possible | Ask: "Which technology? Spring, Quarkus?" |
| Feature has no implementation for stack | Error: "X not available for Y stack" |

**Note (v2.2):** Capabilities with `default_feature` no longer ask for clarification. Only capabilities without default (like `resilience`, `persistence`) require user input.

---

## Migration from v2.0

### Before (v2.0): Dual Discovery

```
# Path 1: Generation
prompt → skill-index → skill → required_capabilities → modules

# Path 2: Transformation  
prompt → capability-index → capability → modules
```

### After (v3.0): Single Discovery

```
# All requests
prompt → capability-index → features → implementations → modules
```

### What Moved Where

| v2.0 Location | v3.0 Location |
|---------------|---------------|
| skill.required_capabilities | feature.requires |
| skill.input_spec | feature.input_spec |
| skill.type (generation/transformation) | Determined by context (existing code?) |
| skill keywords | feature keywords |
| skill-index.yaml | **Eliminated** |

---

## Test Cases (v2.3 Validation)

### Test Case 1: Microservicio Básico

```
Prompt: "Genera un microservicio"

Expected Discovery:
  - "microservicio" → architecture.keywords → architecture capability
  - architecture.default_feature → hexagonal-light
  - NO api-architecture (not mentioned)

Result:
  flow: flow-generate
  features: [architecture.hexagonal-light]
  phases:
    Phase 1: architecture.hexagonal-light
```

### Test Case 2: API Genérica

```
Prompt: "Genera una API REST"

Expected Discovery:
  - "API REST" → api-architecture.keywords → api-architecture capability
  - api-architecture.default_feature → standard
  - standard.requires → architecture → auto-add hexagonal-light

Result:
  flow: flow-generate
  features: [architecture.hexagonal-light, api-architecture.standard]
  phases:
    Phase 1: architecture.hexagonal-light, api-architecture.standard
```

### Test Case 3: Domain API Explícita

```
Prompt: "Genera una Domain API para Customer"

Expected Discovery:
  - "Domain API" → api-architecture.domain-api.keywords → domain-api feature
  - domain-api.requires → architecture → auto-add hexagonal-light

Result:
  flow: flow-generate
  features: [architecture.hexagonal-light, api-architecture.domain-api]
  phases:
    Phase 1: architecture.hexagonal-light, api-architecture.domain-api
  config: {hateoas: true, compensation_available: true}
```

### Test Case 4: API con Persistencia System API

```
Prompt: "Genera una API con persistencia via System API"

Expected Discovery:
  - "API" → api-architecture.standard (default)
  - "System API" in persistence context → persistence.systemapi
  - systemapi.requires → integration.api-rest → auto-add
  - standard.requires → architecture → auto-add hexagonal-light

Result:
  flow: flow-generate
  features: [architecture.hexagonal-light, api-architecture.standard, 
             integration.api-rest, persistence.systemapi]
  phases:
    Phase 1: architecture.hexagonal-light, api-architecture.standard
    Phase 2: integration.api-rest, persistence.systemapi
```

### Test Case 5: Transformación (Sin Foundational)

```
Prompt: "Añade circuit breaker al servicio"
Context: Existing code detected

Expected Discovery:
  - Existing code → flow-transform
  - "circuit breaker" → resilience.circuit-breaker.keywords
  - NO foundational required (flow-transform)

Result:
  flow: flow-transform
  features: [resilience.circuit-breaker]
  phases:
    Phase 3: resilience.circuit-breaker
```

### Test Case 6: Persistencia Híbrida (válido en v2.3)

```
Prompt: "API con JPA y System API"

Expected Discovery:
  - "API" → api-architecture.standard (default)
  - "JPA" → persistence.jpa
  - "System API" → persistence.systemapi
  - v2.3: NO incompatibility (hybrid persistence allowed)
  - systemapi.requires → integration.api-rest → auto-add
  - standard.requires → architecture → auto-add hexagonal-light

Result:
  flow: flow-generate
  features: [architecture.hexagonal-light, api-architecture.standard,
             persistence.jpa, persistence.systemapi, integration.api-rest]
  phases:
    Phase 1: architecture.hexagonal-light, api-architecture.standard
    Phase 2: persistence.jpa, persistence.systemapi, integration.api-rest
```

Note: Hybrid persistence is valid for scenarios like:
- Customer entity → JPA (local database)
- Account entity → System API (mainframe)

### Test Case 7: Domain API con Compensación (válido)

```
Prompt: "Genera una Domain API con compensación"

Expected Discovery:
  - "Domain API" → api-architecture.domain-api
  - "compensación" → distributed-transactions.saga-compensation
  - Rule 7: saga-compensation.requires_config → check compensation_available
    - domain-api.config.compensation_available = true ✓
  - domain-api.requires → architecture → auto-add hexagonal-light

Result:
  flow: flow-generate
  features: [architecture.hexagonal-light, api-architecture.domain-api,
             distributed-transactions.saga-compensation]
  phases:
    Phase 1: architecture.hexagonal-light, api-architecture.domain-api
    Phase 3: distributed-transactions.saga-compensation
  config: {hateoas: true, compensation_available: true}
```

### Test Case 8: API Estándar con Compensación (error)

```
Prompt: "Genera una API REST con compensación"

Expected Discovery:
  - "API REST" → api-architecture.standard (default)
  - "compensación" → distributed-transactions.saga-compensation
  - Rule 7: saga-compensation.requires_config → check compensation_available
    - standard.config.compensation_available = false ❌

Result:
  ERROR: ConfigPrerequisiteError
  Message: "Compensation requires an API type that supports it (e.g., domain-api)"
  Suggestion: "Use 'Domain API' instead of 'API REST' for compensation support"
```

---

## Summary: Discovery Algorithm v2.3

```python
def discover(prompt: str, context: dict) -> DiscoveryResult:
    # 1. Determine flow
    flow = "flow-transform" if context.has_existing_code else "flow-generate"
    
    # 2. Resolve stack
    stack = resolve_stack(prompt, context)
    
    # 3. Match features (Rule 1)
    matched = match_keywords(prompt)
    
    # 4. Apply default features (Rule 2)
    matched = apply_defaults(matched)
    
    # 5. Resolve dependencies (Rule 3)
    all_features = resolve_dependencies(matched)
    
    # 6. Foundational guarantee for generate (Rule 4)
    if flow == "flow-generate":
        all_features = ensure_foundational(all_features)
    
    # 7. Validate compatibility (Rule 5)
    validate_incompatible(all_features)
    
    # 8. Validate config prerequisites (Rule 7) - NEW in v2.3
    validate_config_prerequisites(all_features)
    
    # 9. Assign phases (Rule 6)
    phases = assign_phases(all_features)
    
    # 10. Resolve modules
    modules = resolve_modules(all_features, stack)
    
    return DiscoveryResult(flow, stack, all_features, phases, modules)
```
