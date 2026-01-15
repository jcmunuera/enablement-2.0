# Knowledge Base Updates - Model v2.0

## Summary

This package contains all the files needed to upgrade the Enablement 2.0 Knowledge Base from Model v1.7 to Model v2.0.

## What Changed

### Conceptual Changes

| Before (v1.7) | After (v2.0) |
|---------------|--------------|
| Skills reference modules directly | Skills reference capabilities |
| Skills can extend other skills | No inheritance - skills are self-contained |
| Atomic transformation skills (1 feature) | Capability-level transformation skills |
| Modules referenced by conditional rules | Modules discovered via capability-index.yaml |

### New Concepts

| Concept | Description |
|---------|-------------|
| **Capability Types** | `structural` (core) vs `compositional` (additive) |
| **Skill Types** | `generation` vs `transformation` |
| **target_capability** | What a transformation skill adds |
| **compatible_with** | Architecture requirements for capabilities |
| **transformable** | Whether a capability can be target of transformation |

## Package Contents

```
kb-updates-v2/
├── MODEL-v2-MIGRATION-PLAN.md              # Complete migration plan
├── model/
│   ├── ENABLEMENT-MODEL-v2.0.md            # Core model documentation
│   └── standards/authoring/
│       ├── SKILL.md                        # Skill authoring guide (v3.0)
│       ├── CAPABILITY.md                   # Capability authoring guide (v2.0)
│       └── MODULE.md                       # Module authoring guide (v2.0)
└── runtime/discovery/
    ├── capability-index.yaml               # NEW: Central capability→feature→module index
    └── skill-index.yaml                    # Updated skill index (v3.0)
```

## How to Apply

### Step 1: Backup Current KB
```bash
cp -r enablement-2.0 enablement-2.0-backup-v1.7
```

### Step 2: Copy New Files
```bash
# Copy model documentation
cp model/ENABLEMENT-MODEL-v2.0.md enablement-2.0/model/

# Copy authoring guides
cp model/standards/authoring/*.md enablement-2.0/model/standards/authoring/

# Copy runtime discovery files
cp runtime/discovery/*.yaml enablement-2.0/runtime/discovery/
```

### Step 3: Update Existing Skills

Skills need to be updated to the new format. See `MODEL-v2-MIGRATION-PLAN.md` for:
- Removing `extends`
- Removing `modules` sections
- Adding `type: generation` or `type: transformation`
- Adding `required_capabilities` or `target_capability`

### Step 4: Update Existing Modules

Modules need the new `implements` section:
```yaml
implements:
  capability: {capability-name}
  feature: {feature-name}
```

### Step 5: Validate

Run validation to ensure:
- All skills have correct type
- All modules have implements section
- capability-index.yaml maps all features correctly
- skill-index.yaml references all skills

## Remaining Work (Phase 4-6)

The following items still need to be completed:

### Phase 4: Existing Assets
- [ ] Update skill-020 SKILL.md (add type, required_capabilities)
- [ ] Update skill-021 SKILL.md (add type, required_capabilities, remove extends)
- [ ] Create skill-040-add-resilience (new transformation skill)
- [ ] Create skill-041-add-api-exposure (new transformation skill)
- [ ] Create skill-042-add-persistence (new transformation skill)
- [ ] Deprecate skill-001-circuit-breaker
- [ ] Update all MODULE.md files with implements section
- [ ] Update capabilities/*.md documentation

### Phase 5: Flows
- [ ] Update GENERATE.md with new discovery flow
- [ ] Update ADD.md for transformation skills

### Phase 6: Validation
- [ ] End-to-end generation test
- [ ] End-to-end transformation test
- [ ] Compatibility validation test
- [ ] Documentation consistency review

## Key Files Reference

| File | Purpose |
|------|---------|
| `capability-index.yaml` | **Single source of truth** for capability→feature→module |
| `skill-index.yaml` | Skill definitions with types and capabilities |
| `ENABLEMENT-MODEL-v2.0.md` | Complete model documentation |
| `authoring/SKILL.md` | How to create skills (generation & transformation) |
| `authoring/CAPABILITY.md` | How to create/update capabilities |
| `authoring/MODULE.md` | How to create modules with implements |

## Questions?

See `MODEL-v2-MIGRATION-PLAN.md` for detailed analysis and rationale.
