# Authoring Guide: Execution Flows

**Version:** 3.2  
**Date:** 2026-02-04  
**Model Version:** 3.0.16  
**capability-index Version:** 2.8

---

## What's New in v3.2

| Change | Description |
|--------|-------------|
| **Traceability Manifest** | Flows must produce `.trace/manifest.json` with defined structure (DEC-038) |
| **Phase Catalogs** | Each phase produces `phase-catalog-{phase}.json` for cross-phase references |

## What's New in v3.1

| Change | Description |
|--------|-------------|
| **phase_group Attribute** | Phase assignment now reads `phase_group` from capability-index (not hardcoded) |
| **Cross-cutting Independence** | Cross-cutting capabilities can apply without foundational (flow-transform) |

## What's New in v3.0

| Change | Description |
|--------|-------------|
| **Skills Eliminated** | Flows are now triggered by discovery, not by skill selection |
| **Two Primary Flows** | `flow-generate` and `flow-transform` replace GENERATE/ADD |
| **Phase-Based Execution** | Features grouped by `phase_group` attribute |
| **Flow Selection** | Automatic based on context (existing code or not) |

---

## Overview

Execution Flows define HOW capabilities are applied to generate or transform code. They are located in `runtime/flows/{domain}/`.

### Flow Types (DEC-005)

| Flow | Purpose | When Used |
|------|---------|-----------|
| **flow-generate** | Create project from scratch | No existing code |
| **flow-transform** | Modify existing project | Existing code provided |
| flow-migrate | *(TBD)* Version/pattern migration | - |
| flow-refactor | *(TBD)* Restructure code | - |
| flow-remove | *(TBD)* Remove capability | - |

---

## Flow Selection

Flow selection is **automatic** based on context:

```python
def select_flow(context):
    if not context.has_existing_code:
        return "flow-generate"
    else:
        return "flow-transform"
```

**Key principle:** The user doesn't choose the flow; the discovery process determines it.

---

## Location

```
runtime/flows/{domain}/flow-{type}.md
```

Examples:
- `runtime/flows/code/flow-generate.md`
- `runtime/flows/code/flow-transform.md`

---

## Required Structure

Every flow document MUST include:

```markdown
# Flow: {Type}

## Overview
[What this flow does and when it's used]

## When to Use
[Conditions that trigger this flow]

## Input
[What the flow receives from discovery]

## Execution
### Phase Planning
[How features are grouped into phases]

### Per-Phase Execution
[Steps executed in each phase]

## Output
[Structure of generated/modified files]

## Validation
[How to validate the output]

## Error Handling
[How to handle common errors]
```

---

## Flow Input (from Discovery)

Every flow receives the **Discovery Result**:

```yaml
flow: flow-generate          # Selected flow
stack: java-spring           # Resolved technology stack
features:                    # Matched features
  - architecture.hexagonal-light
  - api-architecture.domain-api
  - persistence.systemapi
  - resilience.circuit-breaker
modules:                     # Resolved modules
  - mod-code-015
  - mod-code-019
  - mod-code-017
  - mod-code-001
config:                      # Merged feature configs
  hateoas: true
  distributed_transactions:
    participant: true
    manager: false
input_spec:                  # Required user input
  serviceName: { type: string, required: true }
  basePackage: { type: string, required: true }
  entities: { type: array, required: true }
```

---

## Phase Planning

Features are grouped into phases based on their **`phase_group`** attribute in capability-index.yaml:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           PHASE PLANNING (v2.2)                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  PHASE 1: STRUCTURAL (phase_group: structural)                              │
│  Nature: Defines project structure, cannot be modified later                │
│  Capabilities: architecture, api-architecture                               │
│  Examples: hexagonal-light, standard, domain-api                            │
│                                                                              │
│  PHASE 2: IMPLEMENTATION (phase_group: implementation)                      │
│  Nature: Implements ports, connects to backends                             │
│  Capabilities: persistence, integration                                     │
│  Examples: jpa, systemapi, api-rest                                         │
│                                                                              │
│  PHASE 3+: CROSS-CUTTING (phase_group: cross-cutting)                       │
│  Nature: Adds aspects on top of existing code                               │
│  Capabilities: resilience, distributed-transactions                         │
│  Examples: circuit-breaker, retry, saga-compensation                        │
│                                                                              │
│  NOTE: Cross-cutting capabilities do NOT require foundational.              │
│        They can be applied via flow-transform to any existing code.         │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Phase Grouping Algorithm (v2.2)

Phase assignment reads from `capability-index.yaml`, NOT from hardcoded lists:

```python
def get_feature_phase_group(feature: str, capability_index: dict) -> str:
    """
    Get phase_group for a feature from capability-index.yaml.
    
    In v2.2, each capability has an explicit phase_group attribute:
    - structural → Phase 1
    - implementation → Phase 2  
    - cross-cutting → Phase 3+
    """
    capability_name = feature.split('.')[0]
    capability = capability_index['capabilities'][capability_name]
    return capability['phase_group']


def group_features_by_phase(features: list, capability_index: dict) -> dict:
    """Group features into phases based on their phase_group."""
    phases = {
        'structural': [],      # Phase 1
        'implementation': [],  # Phase 2
        'cross-cutting': []    # Phase 3+
    }
    
    for feature in features:
        phase_group = get_feature_phase_group(feature, capability_index)
        phases[phase_group].append(feature)
    
    return phases
```

### Why phase_group is Explicit

In capability-index v2.2, `phase_group` is a required attribute because:

1. **Type ≠ Phase:** `api-architecture` is type `layered` but phase_group `structural`
2. **Flexibility:** New capabilities can be assigned to any phase
3. **No Ambiguity:** Phase assignment is deterministic from the index

```yaml
# Example from capability-index.yaml v2.2
api-architecture:
  type: layered              # What it IS
  phase_group: structural    # When it EXECUTES (Phase 1)

persistence:
  type: layered              # What it IS  
  phase_group: implementation # When it EXECUTES (Phase 2)
```

---

## Per-Phase Execution

Each phase follows this sequence:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        PER-PHASE EXECUTION                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. LOAD MODULES                                                            │
│     Load only the modules for features in this phase                        │
│     Keeps context size manageable                                           │
│                                                                              │
│  2. PREPARE CONTEXT                                                         │
│     - User input                                                            │
│     - Feature config                                                        │
│     - Previously generated code (if phase > 1)                              │
│                                                                              │
│  3. GENERATE/TRANSFORM                                                      │
│     Execute code generation using module templates                          │
│                                                                              │
│  4. VALIDATE IMMUTABLES                                                     │
│     Ensure files from previous phases aren't incorrectly modified           │
│                                                                              │
│  5. COMPILE/CHECK                                                           │
│     Verify generated code compiles                                          │
│     If errors, iterate to fix                                               │
│                                                                              │
│  6. UPDATE CONTEXT                                                          │
│     Add generated files to context for next phase                           │
│     Mark files as immutable if appropriate                                  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Output Structure

### Flow Output (flow-generate)

```
{flow-execution}/
├── input/                          # All inputs
│   ├── prompt.md                   # Original user prompt
│   ├── generation-request.json     # Structured request
│   └── {referenced-files}          # API specs, etc.
│
├── output/                         # Generated artifact
│   └── {serviceName}/              # Project directory
│       ├── .enablement/
│       │   └── manifest.json       # Traceability
│       ├── pom.xml
│       ├── src/
│       └── ...
│
├── .trace/                         # Execution traceability (DEC-038)
│   ├── manifest.json               # Generation manifest
│   ├── phase-catalog-1.1.json      # Phase 1 class catalog
│   ├── phase-catalog-2.1.json      # Phase 2 class catalog
│   └── generation-trace.md         # Discovery & generation decisions
│
└── validation/                     # Validation scripts
    ├── compile.sh
    └── test.sh
```

### Flow Output (flow-transform)

```
{flow-execution}/
├── input/                          # Inputs
│   ├── prompt.md
│   └── existing-code/              # Code to modify
│
├── output/                         # Modified files only
│   ├── modified/                   # Files that were changed
│   │   └── {path}/
│   └── created/                    # New files
│       └── {path}/
│
├── .trace/
│   ├── manifest.json
│   └── transformation-trace.md     # What was changed and why
│
└── validation/
    └── compile.sh
```

---

## Traceability Manifest (DEC-038)

Every flow execution MUST produce a `.trace/manifest.json` with this structure:

```json
{
  "generation": {
    "id": "uuid",
    "timestamp": "ISO-8601",
    "service_name": "customer-api"
  },
  "enablement": {
    "version": "3.0.16",
    "domain": "code",
    "flow": "flow-generate"
  },
  "modules": [
    {
      "id": "mod-code-015-hexagonal-base-java-spring",
      "capability": "architecture.hexagonal-light",
      "phase": 1
    },
    {
      "id": "mod-code-017-persistence-systemapi",
      "capability": "persistence.systemapi",
      "phase": 2
    }
  ],
  "status": {
    "success": true,
    "phases_completed": [1, 2, 3],
    "files_generated": 31
  }
}
```

### Phase Catalogs

Each phase produces a `phase-catalog-{subphase}.json` for cross-phase reference:

```json
{
  "subphase": "1.1",
  "timestamp": "ISO-8601",
  "classes": [
    {
      "fqcn": "com.bank.customer.domain.Customer",
      "file": "src/main/java/com/bank/customer/domain/Customer.java",
      "type": "entity"
    }
  ]
}
```

**Purpose:** Phase 2 modules can reference Phase 1 classes by FQCN (fully qualified class name).

---

## File Mutability

### Immutable Files (never modified after creation)

```
domain/model/*.java          # Entities, Value Objects
domain/port/*.java           # Repository interfaces
application/dto/*.java       # DTOs
adapter/in/rest/*Controller.java
```

### Modifiable Files (with contract)

```
ApplicationService.java      # Method bodies can be modified
Adapter*.java               # Annotations can be added
pom.xml                     # Dependencies can be added
application.yml             # Sections can be added
```

---

## Determinism Rules

During code generation, the agent MUST follow:

- `model/standards/DETERMINISM-RULES.md` (global patterns)
- Each module's `## Determinism` section (module-specific)

Key rules:
1. Same input → Same output (deterministic)
2. Follow module templates exactly
3. Respect file mutability contracts
4. Use validation to verify output

---

## Validation Requirements

### Per-Phase Validation

After each phase:
1. **Immutable check:** Files from previous phases unchanged
2. **Compilation:** `mvn compile` succeeds
3. **Structure:** Expected files exist

### Final Validation

After all phases:
1. **Full build:** `mvn package` succeeds
2. **Tests:** `mvn test` passes
3. **Traceability:** Manifest complete

---

## Creating a New Flow

### Step 1: Determine Need

Create a new flow when:
- A new execution pattern is needed
- Existing flows don't cover the use case
- The pattern is fundamentally different from generate/transform

### Step 2: Document the Flow

Create `runtime/flows/{domain}/flow-{type}.md` following required structure.

### Step 3: Update References

- Update `runtime/flows/README.md`
- Update `discovery-guidance.md` flow selection logic

---

## Validation Checklist

Before considering a flow complete:

- [ ] Document follows required structure
- [ ] Phase planning is clearly defined
- [ ] Per-phase execution steps documented
- [ ] Output structure defined
- [ ] File mutability rules defined
- [ ] Validation requirements specified
- [ ] Error handling documented
- [ ] Example execution included

---

## Related Documents

- `runtime/discovery/capability-index.yaml` - Source of `phase_group` attribute (v2.2)
- `runtime/discovery/discovery-guidance.md` - Flow selection logic and 6 discovery rules
- `runtime/flows/code/flow-generate.md` - Generation flow
- `runtime/flows/code/flow-transform.md` - Transformation flow
- `model/standards/DETERMINISM-RULES.md` - Code generation rules
- `authoring/MODULE.md` - Module structure
- `authoring/CAPABILITY.md` - Capability types and phase_group

---

**Last Updated:** 2026-01-22
