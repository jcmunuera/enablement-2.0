# Discovery Guidance v3.0

## Overview

Discovery is the process of determining which **capabilities, features, and modules** are needed to fulfill a user request. In v3.0, discovery follows a single unified path through the capability-index.

```
prompt + context → capabilities → features → implementations → modules
```

There is **no separate skill discovery**. All logic previously in skills is now embedded in features.

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

### Step 2: Feature Matching

Match user prompt against feature keywords to identify required features.

**Sources of features:**
1. **Direct mention:** User explicitly requests a feature
2. **Inference:** Context implies a feature is needed
3. **Requirements:** Other features require this feature

**Matching algorithm:**
```python
def match_features(prompt: str, context: dict) -> List[Feature]:
    matched = []
    
    for capability in capability_index.capabilities.values():
        # Check capability-level keywords
        for keyword in capability.get('keywords', []):
            if keyword.lower() in prompt.lower():
                # Capability mentioned but not specific feature
                # May need to ask user which feature
                pass
        
        # Check feature-level keywords
        for feature_id, feature in capability.features.items():
            for keyword in feature.keywords:
                if keyword.lower() in prompt.lower():
                    matched.append(f"{capability.id}.{feature_id}")
    
    return matched
```

**Examples:**
| Prompt | Matched Features |
|--------|------------------|
| "API de dominio para Customer" | `api-architecture.domain-api` |
| "con persistencia en System API" | `persistence.systemapi` |
| "añade circuit breaker" | `resilience.circuit-breaker` |
| "resilience" (generic) | Ask: "Which resilience patterns?" |

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
| "API" (no type specified) | Ask: "What type of API? Domain, System, Experience?" |
| Multiple stacks possible | Ask: "Which technology? Spring, Quarkus?" |
| Feature has no implementation for stack | Error: "X not available for Y stack" |

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
