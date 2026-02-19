# Runtime

> Discovery, execution flows, and validation

**Version:** 3.0  
**Last Updated:** 2026-01-20

## Purpose

This folder contains everything needed to **execute code generation at runtime**:
- **Discovery**: Rules to map user prompts to capabilities and modules
- **Flows**: Step-by-step execution processes (generate, transform)
- **Validators**: Tier-1 and Tier-2 validation scripts

## Structure

```
runtime/
├── discovery/              # Prompt → Capabilities → Modules
│   ├── README.md
│   ├── capability-index.yaml  # ⭐ Single source of truth
│   ├── discovery-guidance.md  # How discovery works
│   └── execution-framework.md
│
├── flows/                  # Execution flows by domain
│   └── code/
│       ├── flow-generate.md   # Create project from scratch
│       ├── flow-transform.md  # Modify existing code
│       ├── MIGRATE.md         # (TBD)
│       ├── REFACTOR.md        # (TBD)
│       └── REMOVE.md          # (TBD)
│
└── validators/             # Validation scripts
    ├── README.md
    ├── tier-1-universal/   # Universal validators
    └── tier-2-technology/  # Technology-specific validators
```

## Execution Flow Overview (v3.0)

```
1. INPUT
   └── User prompt + context (existing code if any)

2. DISCOVERY (runtime/discovery/)
   ├── Resolve STACK (explicit > detected > default)
   ├── Match FEATURES from capability-index.yaml
   ├── Resolve DEPENDENCIES (requires)
   ├── Validate COMPATIBILITY (incompatible_with)
   └── Resolve IMPLEMENTATIONS → MODULES

3. SELECT FLOW
   ├── No existing code → flow-generate
   └── Existing code → flow-transform

4. PHASE PLANNING
   ├── Group features by nature
   │   ├── Phase 1: STRUCTURAL (architecture, api-architecture)
   │   ├── Phase 2: IMPLEMENTATION (persistence, integration)
   │   └── Phase 3+: CROSS-CUTTING (resilience, etc.)
   └── Plan context loading per phase

5. EXECUTE (per phase)
   ├── Load phase modules
   ├── Generate/transform code
   ├── Validate immutables
   └── Compile check

6. VALIDATE
   ├── Tier-1: runtime/validators/tier-1-universal/
   ├── Tier-2: runtime/validators/tier-2-technology/
   └── Tier-3: modules/{mod}/validation/

7. OUTPUT
   └── Generated code + manifest.json
```

## Flow Types (CODE Domain)

| Type | Purpose | When |
|------|---------|------|
| **flow-generate** | Create new project from scratch | No existing code |
| **flow-transform** | Modify existing project | Existing code provided |
| **MIGRATE** | Version/pattern migration | (TBD) |
| **REFACTOR** | Transform code structure | (TBD) |
| **REMOVE** | Remove capability | (TBD) |

## Validation Tiers

| Tier | Scope | Location |
|------|-------|----------|
| **Tier-1** | Universal (all outputs) | runtime/validators/tier-1-universal/ |
| **Tier-2** | Technology-specific | runtime/validators/tier-2-technology/ |
| **Tier-3** | Module-specific | modules/{mod}/validation/ |
| **Tier-4** | Runtime/CI (future) | External CI/CD |

## Key Files

| File | Purpose |
|------|---------|
| `discovery/capability-index.yaml` | Single source of truth for capabilities, features, implementations |
| `discovery/discovery-guidance.md` | Step-by-step discovery algorithm |
| `flows/code/flow-generate.md` | Project generation with phase planning |
| `flows/code/flow-transform.md` | Code transformation rules |

## Related

- Modules: `/modules/`
- Model: `/model/`
- Capability documentation: `/model/domains/code/capabilities/`
