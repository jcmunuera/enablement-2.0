# Model v2 - Impact Analysis and Migration Plan

## Executive Summary

The change from Module-in-Skill to Capability-based discovery is a **fundamental model change** that affects:
- Core model documentation
- Authoring standards and templates
- Runtime discovery mechanism
- Existing skills and their structure
- Capability definitions
- Module metadata

This document provides an exhaustive inventory of all changes required.

---

## Key Model Changes (v1.7 → v2.0)

### New Concepts Introduced

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         MODEL v2.0 KEY CONCEPTS                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  CAPABILITY TYPES                                                           │
│  ────────────────                                                           │
│  - STRUCTURAL: Core/foundational, defines code structure                    │
│    • NOT transformable (changing = regenerating)                            │
│    • Always REQUIRED in generation skills                                   │
│    • Example: architecture.hexagonal-base                                   │
│                                                                              │
│  - COMPOSITIONAL: Additive, can be layered on existing code                │
│    • IS transformable (can be added to existing code)                       │
│    • Can be REQUIRED or OPTIONAL in generation skills                       │
│    • Is the TARGET of transformation skills                                 │
│    • Examples: api-exposure, resilience, persistence, caching              │
│                                                                              │
│  SKILL TYPES                                                                │
│  ───────────                                                                │
│  - GENERATION: Creates artifacts from scratch                               │
│    • Declares required_capabilities (structural + some compositional)      │
│    • Additional compositional capabilities inferred from prompt            │
│                                                                              │
│  - TRANSFORMATION: Modifies existing code                                   │
│    • Declares target_capability (the compositional capability it adds)     │
│    • Features within capability determined from prompt context             │
│    • Cannot target structural capabilities                                  │
│                                                                              │
│  RELATIONSHIPS                                                              │
│  ─────────────                                                              │
│  - Skill → Capability (via required_capabilities or target_capability)     │
│  - Capability → Features (1:N, grouped variants)                           │
│  - Feature → Module (1:1, implementation)                                  │
│  - NO skill inheritance                                                     │
│  - NO direct skill → module relationship                                   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Removed Concepts

- ~~Skill inheritance (extends)~~
- ~~Skill declares modules directly~~
- ~~Conditional modules in skill~~
- ~~Atomic transformation skills (1 skill per feature)~~

---

## Current KB Structure (What Exists)

```
enablement-2.0/
├── model/
│   ├── ENABLEMENT-MODEL-v1.7.md           # Core model definition
│   ├── ENABLEMENT-TECHNICAL-GUIDE.md      # Technical guide
│   ├── CONSUMER-PROMPT.md                 # Consumer agent prompt
│   ├── AUTHOR-PROMPT.md                   # Author agent prompt
│   ├── standards/
│   │   ├── ASSET-STANDARDS-v1.4.md        # Asset standards
│   │   ├── DETERMINISM-RULES.md           # Determinism rules
│   │   └── authoring/
│   │       ├── SKILL.md                   # How to create skills
│   │       ├── MODULE.md                  # How to create modules
│   │       ├── CAPABILITY.md              # How to create capabilities
│   │       ├── FLOW.md                    # How to create flows
│   │       └── ...
│   └── domains/code/
│       ├── DOMAIN.md                      # Domain definition
│       ├── TAG-TAXONOMY.md                # Tag taxonomy
│       └── capabilities/
│           ├── resilience.md
│           ├── persistence.md
│           ├── integration.md
│           └── api_architecture.md
├── runtime/
│   ├── discovery/
│   │   ├── skill-index.yaml               # Skill index
│   │   ├── discovery-guidance.md          # Discovery guidance
│   │   └── execution-framework.md         # Execution framework
│   └── flows/code/
│       └── GENERATE.md                    # Generation flow
├── skills/
│   └── code/soi/
│       ├── skill-020-microservice-java-spring/
│       │   ├── OVERVIEW.md
│       │   ├── SKILL.md                   # Contains module references
│       │   └── ...
│       └── skill-021-api-rest-java-spring/
│           ├── OVERVIEW.md
│           ├── SKILL.md                   # Contains inheritance + modules
│           └── ...
└── modules/
    ├── mod-code-001-circuit-breaker.../
    ├── mod-code-015-hexagonal-base.../
    └── ...
```

---

## Impact Analysis by Component

### 1. CORE MODEL DOCUMENTATION

| File | Impact | Changes Required |
|------|--------|------------------|
| `model/ENABLEMENT-MODEL-v1.7.md` | 🔴 HIGH | Complete rewrite of entity relationships section. Remove skill inheritance. Add capability-index concept. Redefine Skill→Capability→Module flow. |
| `model/ENABLEMENT-TECHNICAL-GUIDE.md` | 🔴 HIGH | Update all diagrams and explanations of discovery flow. |
| `model/CONSUMER-PROMPT.md` | 🟡 MEDIUM | Update instructions for how to discover and use skills/capabilities. |
| `model/AUTHOR-PROMPT.md` | 🟡 MEDIUM | Update instructions for how to create skills and capabilities. |

**Key Conceptual Changes:**
```
BEFORE:
  Skill has modules (mandatory + conditional)
  Skill can extend another Skill
  Module is referenced by Skill directly

AFTER:
  Skill has required_capabilities only
  Skill does NOT have inheritance
  Capability has features that map to Modules
  Capability declares its own compatibility
```

---

### 2. ASSET STANDARDS

| File | Impact | Changes Required |
|------|--------|------------------|
| `model/standards/ASSET-STANDARDS-v1.4.md` | 🔴 HIGH | Update Skill standard (remove modules, inheritance). Update Capability standard (add compatibility, features→modules). |

**Specific Changes:**

#### Skill Standard (Current → New)
```yaml
# CURRENT (v1.7)
skill-021:
  extends: skill-020
  modules:
    mandatory: [mod-015, mod-019]
    conditional:
      - module: mod-001
        condition: "resilience.circuitBreaker=true"
      - module: mod-017
        condition: "persistence=systemapi"

# NEW (v2.0) - Generation Skill
skill-021-api-rest-java-spring:
  type: generation
  required_capabilities:
    - architecture.hexagonal-base
    - api-exposure.rest-hateoas
  # NO extends, NO modules, NO conditional
  # Additional compositional capabilities inferred from prompt

# NEW (v2.0) - Transformation Skill
skill-040-add-resilience-java-spring:
  type: transformation
  target_capability: resilience
  compatible_with: [architecture.hexagonal-base]
  # Features (CB, retry, timeout) determined from prompt
```

#### Capability Standard (Current → New)
```yaml
# CURRENT (capabilities/*.md)
# Free-form markdown with features listed

# NEW (capability-index.yaml + capabilities/*.md)
resilience:
  type: compositional
  transformable: true
  compatible_with: [architecture.hexagonal-base]
  stack: [java-spring]
  features:
    circuit-breaker:
      module: mod-001-circuit-breaker-java-resilience4j
      keywords: [circuit breaker, CB]
    retry:
      module: mod-002-retry-java-resilience4j
      keywords: [retry, reintento]

architecture:
  type: structural
  transformable: false  # Cannot be target of transformation
  features:
    hexagonal-base:
      module: mod-015-hexagonal-base-java-spring
```

---

### 3. AUTHORING STANDARDS

| File | Impact | Changes Required |
|------|--------|------------------|
| `model/standards/authoring/SKILL.md` | 🔴 HIGH | Complete rewrite. Remove inheritance. Remove modules. Add skill types (generation/transformation). Add required_capabilities for generation. Add target_capability for transformation. |
| `model/standards/authoring/MODULE.md` | 🟡 MEDIUM | Add requirement to link to capability.feature. Add compatibility metadata. |
| `model/standards/authoring/CAPABILITY.md` | 🔴 HIGH | Complete rewrite. Add capability types (structural/compositional). Add transformable flag. Add features structure. Add compatibility declarations. Add module mapping. |

**New Authoring Flow:**
```
BEFORE:
  1. Create Module
  2. Create Skill that references Module
  3. Add module to skill's conditional list

AFTER (Generation Skill):
  1. Create/Update Capability with new feature
  2. Create Module that implements feature
  3. Link feature→module in capability-index.yaml
  4. Skills automatically get access via compatibility

AFTER (Transformation Skill):
  1. Identify compositional capability to target
  2. Create skill with target_capability
  3. Skill uses capability's features/modules based on prompt
```

---

### 4. RUNTIME DISCOVERY

| File | Impact | Changes Required |
|------|--------|------------------|
| `runtime/discovery/skill-index.yaml` | 🔴 HIGH | Simplify structure. Remove module references. Add only required_capabilities. |
| `runtime/discovery/capability-index.yaml` | 🆕 NEW | Create new file. Central index for all capabilities, features, modules, compatibility. |
| `runtime/discovery/discovery-guidance.md` | 🔴 HIGH | Rewrite discovery algorithm. Two-phase: Skill discovery + Capability discovery. |
| `runtime/discovery/execution-framework.md` | 🟡 MEDIUM | Update to reflect new discovery output format. |
| `runtime/discovery/prompt-template.md` | 🟡 MEDIUM | Update prompt to handle capabilities. |

**New Discovery Flow:**
```
1. Prompt → skill-index.yaml → Skill
2. Skill.required_capabilities → capability-index.yaml → Base Modules
3. Prompt → capability-index.yaml → Additional Capabilities (validate compatibility)
4. All Capabilities → Modules
```

---

### 5. FLOWS

| File | Impact | Changes Required |
|------|--------|------------------|
| `runtime/flows/code/GENERATE.md` | 🔴 HIGH | Update Phase 1 (Discovery) completely. Update Module Resolution section. Remove inheritance resolution. |
| `runtime/flows/code/ADD.md` | 🟡 MEDIUM | Update to use capability-based discovery. |
| `runtime/flows/code/REFACTOR.md` | 🟡 MEDIUM | Update to use capability-based discovery. |
| `runtime/flows/code/REMOVE.md` | 🟡 MEDIUM | Update to use capability-based discovery. |
| `runtime/flows/code/MIGRATE.md` | 🟡 MEDIUM | Update to use capability-based discovery. |

---

### 6. EXISTING SKILLS

| Skill | Type | Impact | Changes Required |
|-------|------|--------|------------------|
| `skill-020-microservice-java-spring` | Generation | 🔴 HIGH | Add `type: generation`. Remove module references from SKILL.md. Add required_capabilities. Update OVERVIEW.md. |
| `skill-021-api-rest-java-spring` | Generation | 🔴 HIGH | Add `type: generation`. Remove extends. Remove module references. Add required_capabilities explicitly. Update OVERVIEW.md. |
| `skill-001-circuit-breaker` | Transformation | 🔴 HIGH | **RECONVERT** to `skill-040-add-resilience`. Change from atomic (1 feature) to capability-level. Add `type: transformation`. Add `target_capability: resilience`. |

**Example Migration - skill-021 (Generation):**

```markdown
# BEFORE (SKILL.md excerpt)
## Inheritance
Extends: skill-020-microservice-java-spring

## Modules
### Mandatory
- mod-015-hexagonal-base (inherited)
- mod-019-api-public-exposure

### Conditional
- mod-017-persistence-systemapi (if persistence=systemapi)
- mod-001-circuit-breaker (if resilience.circuitBreaker)
...

# AFTER (SKILL.md excerpt)
## Skill Type
Type: generation

## Required Capabilities
- architecture.hexagonal-base (structural)
- api-exposure.rest-hateoas (compositional)

## Semantic Relationship
This skill builds on the same architectural foundation as skill-020.
See skill-020 for internal microservice variant.

# NO modules section - resolved via capabilities
```

**Example Migration - skill-001 → skill-040 (Transformation):**

```markdown
# BEFORE (skill-001-circuit-breaker/SKILL.md)
## Purpose
Add Circuit Breaker pattern to existing code

## Modules
- mod-001-circuit-breaker-java-resilience4j

# AFTER (skill-040-add-resilience/SKILL.md)
## Skill Type
Type: transformation

## Target Capability
resilience (compositional)

## Compatible With
- architecture.hexagonal-base

## Feature Resolution
Features (circuit-breaker, retry, timeout, rate-limiter) determined from prompt:
- "add circuit breaker" → resilience.circuit-breaker
- "add full resilience" → all resilience features
- "add retry and timeout" → resilience.retry + resilience.timeout
```

---

### 7. EXISTING CAPABILITIES

| Capability | Impact | Changes Required |
|------------|--------|------------------|
| `resilience.md` | 🔴 HIGH | Restructure with features, module mappings, compatibility declarations. |
| `persistence.md` | 🔴 HIGH | Add features (jpa, systemapi), module mappings, incompatibilities. |
| `integration.md` | 🔴 HIGH | Add features (restclient, webclient), module mappings. |
| `api_architecture.md` | 🔴 HIGH | Potentially split into architecture + api-exposure. Add module mappings. |

**Current Structure vs New Structure:**

```markdown
# CURRENT (resilience.md)
## Features
### Circuit Breaker
[description]
### Retry
[description]
...

# NEW (resilience.md + capability-index.yaml)

## In capability-index.yaml:
resilience:
  compatible_with: [architecture.hexagonal-base]
  stack: [java-spring]
  features:
    circuit-breaker:
      module: mod-001-circuit-breaker-java-resilience4j
    retry:
      module: mod-002-retry-java-resilience4j
    timeout:
      module: mod-003-timeout-java-resilience4j

## In resilience.md:
[Detailed documentation, patterns, examples]
[References capability-index for definitive mapping]
```

---

### 8. EXISTING MODULES

| Module | Impact | Changes Required |
|--------|--------|------------------|
| `mod-code-015-hexagonal-base` | 🟡 MEDIUM | Add capability reference in MODULE.md header. |
| `mod-code-019-api-public-exposure` | 🟡 MEDIUM | Add capability reference. |
| `mod-code-001-circuit-breaker` | 🟡 MEDIUM | Add capability reference (resilience.circuit-breaker). |
| All other modules | 🟡 MEDIUM | Add capability.feature reference in metadata. |

**Module Metadata Addition:**
```yaml
# In MODULE.md frontmatter or header
implements:
  capability: resilience
  feature: circuit-breaker
```

---

### 9. DOMAIN DEFINITIONS

| File | Impact | Changes Required |
|------|--------|------------------|
| `model/domains/code/DOMAIN.md` | 🟡 MEDIUM | Update entity relationships diagram. |
| `model/domains/code/TAG-TAXONOMY.md` | 🟢 LOW | May need minor updates for capability keywords. |

---

### 10. NEW FILES TO CREATE

| File | Purpose |
|------|---------|
| `runtime/discovery/capability-index.yaml` | Central capability→feature→module index with types |
| `model/ENABLEMENT-MODEL-v2.0.md` | New version of model document |
| `model/standards/ASSET-STANDARDS-v2.0.md` | New version of asset standards |
| `skills/code/soi/skill-040-add-resilience-java-spring/` | New transformation skill (replaces skill-001) |
| `skills/code/soi/skill-041-add-api-exposure-java-spring/` | New transformation skill for API promotion |
| `skills/code/soi/skill-042-add-persistence-java-spring/` | New transformation skill for persistence |

### 11. FILES TO DEPRECATE/REMOVE

| File | Reason |
|------|--------|
| `skills/code/soi/skill-001-circuit-breaker-java-resilience4j/` | Replaced by skill-040-add-resilience (capability-level) |

---

## Migration Plan

### Phase 1: Core Model & Capability Index (Priority: Critical)

**Deliverables:**
1. `runtime/discovery/capability-index.yaml` - Central source of truth
2. `model/ENABLEMENT-MODEL-v2.0.md` - Updated model documentation

**Tasks:**

1.1 **Create capability-index.yaml**
   - Define all structural capabilities (architecture)
   - Define all compositional capabilities (api-exposure, resilience, persistence, integration)
   - Map features to modules
   - Add compatibility declarations
   - Add `type` and `transformable` flags

1.2 **Create ENABLEMENT-MODEL-v2.0.md**
   - New entity relationship diagram
   - Capability types (structural vs compositional)
   - Skill types (generation vs transformation)
   - Skill→Capability→Module flow
   - Compatibility-based discovery explanation
   - Remove inheritance documentation

**Validation Checkpoint:**
- [ ] capability-index.yaml passes YAML lint
- [ ] All existing modules are mapped to a capability.feature
- [ ] Model document is internally consistent

---

### Phase 2: Asset Standards (Priority: Critical)

**Deliverables:**
1. `model/standards/ASSET-STANDARDS-v2.0.md`
2. Updated authoring guides

**Tasks:**

2.1 **Update ASSET-STANDARDS to v2.0**
   - New Skill standard (generation type)
   - New Skill standard (transformation type)
   - New Capability standard (structural/compositional)
   - Updated Module standard (capability.feature reference)

2.2 **Rewrite authoring/SKILL.md**
   - Remove inheritance section
   - Remove modules section
   - Add skill types section
   - Add required_capabilities (generation)
   - Add target_capability (transformation)

2.3 **Rewrite authoring/CAPABILITY.md**
   - Add capability types
   - Add transformable flag
   - Add features structure
   - Add compatibility declarations
   - Add module mapping

2.4 **Update authoring/MODULE.md**
   - Add capability.feature reference requirement

**Validation Checkpoint:**
- [ ] Authoring guides are consistent with ASSET-STANDARDS
- [ ] Examples in guides match new model

---

### Phase 3: Runtime Discovery (Priority: High)

**Deliverables:**
1. Simplified `skill-index.yaml`
2. Updated discovery documentation

**Tasks:**

3.1 **Simplify skill-index.yaml**
   - Add `type: generation` to existing skills
   - Remove module references
   - Add required_capabilities
   - Add new transformation skills (040, 041, 042)

3.2 **Rewrite discovery-guidance.md**
   - Intent detection (generation vs transformation)
   - Two-phase discovery for generation
   - Target capability discovery for transformation
   - Compatibility validation

3.3 **Update execution-framework.md**
   - Reflect new discovery output format
   - Handle both skill types

3.4 **Update prompt-template.md**
   - Handle capability extraction from prompt

**Validation Checkpoint:**
- [ ] skill-index.yaml is valid YAML
- [ ] Discovery guidance covers both skill types
- [ ] No references to old model (inheritance, direct modules)

---

### Phase 4: Existing Assets Migration (Priority: High)

**Deliverables:**
1. Migrated generation skills (020, 021)
2. Migrated/new transformation skills (040, 041, 042)
3. Updated capability documentation
4. Updated module metadata

**Tasks:**

4.1 **Migrate skill-020-microservice-java-spring**
   - Add `type: generation`
   - Remove modules section
   - Add required_capabilities
   - Update OVERVIEW.md

4.2 **Migrate skill-021-api-rest-java-spring**
   - Add `type: generation`
   - Remove extends
   - Remove modules section
   - Add required_capabilities explicitly
   - Update OVERVIEW.md

4.3 **Create skill-040-add-resilience-java-spring**
   - New skill replacing skill-001
   - `type: transformation`
   - `target_capability: resilience`
   - Feature resolution logic in prompts

4.4 **Create skill-041-add-api-exposure-java-spring**
   - `type: transformation`
   - `target_capability: api-exposure`

4.5 **Create skill-042-add-persistence-java-spring**
   - `type: transformation`
   - `target_capability: persistence`

4.6 **Deprecate skill-001-circuit-breaker**
   - Mark as deprecated
   - Point to skill-040

4.7 **Restructure capabilities/*.md**
   - Align with capability-index.yaml
   - Add references to index for definitive mappings

4.8 **Update all MODULE.md files**
   - Add `implements.capability` and `implements.feature`

**Validation Checkpoint:**
- [ ] All skills have correct type
- [ ] No skill references modules directly
- [ ] All modules reference their capability.feature
- [ ] Deprecated skill-001 has redirect notice

---

### Phase 5: Flows Update (Priority: Medium)

**Deliverables:**
1. Updated GENERATE.md flow
2. Updated ADD.md flow (for transformations)
3. Other flows aligned

**Tasks:**

5.1 **Update GENERATE.md**
   - New Phase 1 (Discovery) for generation skills
   - Capability-based module resolution
   - Remove inheritance resolution

5.2 **Update ADD.md**
   - Transformation skill discovery
   - Target capability resolution
   - Feature extraction from prompt

5.3 **Update REFACTOR.md, REMOVE.md, MIGRATE.md**
   - Align with new model where applicable

**Validation Checkpoint:**
- [ ] All flows reference new model concepts
- [ ] No flows reference old model (inheritance, direct modules)

---

### Phase 6: Validation & Testing (Priority: High)

**Tasks:**

6.1 **End-to-end Generation Test**
   - Prompt: "Generate Customer API with resilience"
   - Verify skill discovery
   - Verify capability resolution
   - Verify module list

6.2 **End-to-end Transformation Test**
   - Prompt: "Add circuit breaker to Customer service"
   - Verify transformation skill discovery
   - Verify feature extraction
   - Verify module selection

6.3 **Compatibility Validation Test**
   - Test incompatible capability combinations
   - Verify proper rejection/warning

6.4 **Documentation Review**
   - Single-pass consistency check
   - Remove any remaining old model references

**Validation Checkpoint:**
- [ ] Generation flow produces correct modules
- [ ] Transformation flow produces correct modules
- [ ] Incompatibilities properly handled
- [ ] No documentation inconsistencies

---

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Incomplete migration breaks discovery | High | Critical | Phase-by-phase validation checkpoints |
| Capability compatibility misconfigured | Medium | High | Test matrix for all combinations |
| Documentation inconsistency | Medium | Medium | Single-pass review after migration |
| Authoring confusion during transition | Low | Medium | Clear migration guide + examples |
| Transformation skill feature resolution ambiguity | Medium | Medium | Clear examples in prompts folder |

---

## Estimated Effort

| Phase | Effort | Dependencies |
|-------|--------|--------------|
| Phase 1: Core Model & Capability Index | 3-4 hours | None |
| Phase 2: Asset Standards | 2-3 hours | Phase 1 |
| Phase 3: Runtime Discovery | 2-3 hours | Phases 1-2 |
| Phase 4: Existing Assets Migration | 4-5 hours | Phases 1-3 |
| Phase 5: Flows Update | 2-3 hours | Phases 1-4 |
| Phase 6: Validation & Testing | 2-3 hours | Phases 1-5 |
| **Total** | **15-21 hours** | |

---

## Decisions Confirmed

1. ✅ Remove skill inheritance completely
2. ✅ Skills only declare required_capabilities (generation) or target_capability (transformation)
3. ✅ Capabilities declare their own compatibility
4. ✅ capability-index.yaml as single source of truth for feature→module mapping
5. ✅ Two capability types: structural (non-transformable) and compositional (transformable)
6. ✅ Two skill types: generation and transformation
7. ✅ Transformation skills target capabilities, not individual features
8. ✅ Reconvert skill-001-circuit-breaker → skill-040-add-resilience

---

## Next Steps

1. ✅ Migration plan approved
2. → **Begin Phase 1**: Create capability-index.yaml + ENABLEMENT-MODEL-v2.0.md
3. Proceed phase by phase with validation checkpoints
