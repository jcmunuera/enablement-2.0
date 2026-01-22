# Authoring Standards

**Version:** 3.1  
**Last Updated:** 2026-01-21  
**Model Version:** 3.0.1

---

## Purpose

This directory contains **authoring guides** for creating assets in the Enablement 2.0 knowledge base. Each guide provides:

- Complete templates with all required sections
- Field specifications and valid values
- Checklists for completeness validation
- Examples of well-formed assets
- Relationship requirements
- Coherence rules

---

## What's New in v3.1

> **Key change:** Capability taxonomy updated to foundational/layered/cross-cutting

| Change | Impact |
|--------|--------|
| **New Taxonomy** | CAPABILITY.md updated with foundational/layered/cross-cutting types |
| **phase_group** | New required attribute for automatic phase assignment |
| **default_feature** | Capability-level default when no specific feature matched |
| **requires Simplified** | Points to capability (not feature), uses default_feature |

### Entity Model Change

```
v2.x: Skill → Capability → Feature → Module
v3.0:         Capability → Feature → Implementation → Module

Capability Types (v2.2):
  - foundational: Base architecture (exactly-one, not transformable)
  - layered: Adds on foundational (multiple, transformable)
  - cross-cutting: Decorators (multiple, transformable, no foundational required)
```

---

## Authoring Guides Index

### Core Asset Types

| Asset Type | Guide | Version | Description |
|------------|-------|---------|-------------|
| ADR | [ADR.md](./ADR.md) | 1.0 | Architecture Decision Records |
| ERI | [ERI.md](./ERI.md) | **1.3** | Enterprise Reference Implementations ⭐ |
| Module | [MODULE.md](./MODULE.md) | **3.0** | Reusable code templates ⭐ |
| **Capability** | [CAPABILITY.md](./CAPABILITY.md) | **3.4** | **Feature definitions with implementations** ⭐ |
| Validator | [VALIDATOR.md](./VALIDATOR.md) | **1.1** | Artifact validation components ⭐ |
| Flow | [FLOW.md](./FLOW.md) | **3.1** | Execution flows (generate/transform) ⭐ |
| Tags | [TAGS.md](./TAGS.md) | 2.0 | Discovery keywords (deprecated, see CAPABILITY.md) |

### Removed in v3.0

| Asset Type | Status | Migration |
|------------|--------|-----------|
| ~~Skill~~ | **Eliminated** | Logic moved to Capability features |

---

## Asset Creation Order

Assets should be created in this order:

```
1. ADR (Strategic Decision)
   ↓
2. ERI (Reference Implementation)
   ↓
3. Module (Reusable Template)
   │  └─ MUST have derived_from pointing to ERI
   │  └─ MUST declare stack in frontmatter
   ↓
4. Validator (Quality Checks)
   ↓
5. Capability Feature (in capability-index.yaml)
   │  └─ References module
   │  └─ Defines config, input_spec
```

---

## Coherence Rules

When creating assets, ensure coherence:

| Rule | Description |
|------|-------------|
| **Module → ERI** | Every Module MUST have `derived_from` pointing to an ERI |
| **Module → Stack** | Every Module MUST declare its stack |
| **Feature → Module** | Every feature implementation MUST reference existing module |
| **Feature → Default** | Features with multiple implementations MUST have default |

---

## Common Principles

### 1. Self-Contained Documentation

Each asset MUST be understandable without external context.

### 2. Explicit Relationships

All relationships MUST be explicitly documented:

| Relationship | From | To |
|--------------|------|-----|
| `implements` | ERI | ADR |
| `derived_from` | Module | ERI |
| `module` | Feature Implementation | Module |

### 3. Machine-Readable Metadata

Assets MUST include YAML front matter:

```yaml
---
id: {type}-{id}
version: {semver}
status: draft|active|deprecated
---
```

---

## Quick Reference

| I want to... | Read this |
|--------------|-----------|
| Document a strategic decision | [ADR.md](./ADR.md) |
| Create a reference implementation | [ERI.md](./ERI.md) |
| Build reusable templates | [MODULE.md](./MODULE.md) |
| Define a capability feature | [CAPABILITY.md](./CAPABILITY.md) |
| Add validation for technology | [VALIDATOR.md](./VALIDATOR.md) |
| Document an execution flow | [FLOW.md](./FLOW.md) |

---

## Critical: Discovery and Execution

### CAPABILITY.md and Discovery

The **CAPABILITY.md** guide is essential because:

1. **capability-index.yaml is the single source of truth** - All discovery goes through it
2. **Features are enriched** - config, input_spec, implementations
3. **Multi-stack support** - Each feature can have multiple implementations

**Read CAPABILITY.md before defining any feature.**

### MODULE.md and Execution

The **MODULE.md** guide clarifies:

1. **Stack declaration required** - Every module declares its stack
2. **Templates as guidance** - Not scripts, but structured knowledge
3. **Determinism rules** - CRITICAL sections for consistent output

### FLOW.md and Execution

The **FLOW.md** guide explains:

1. **Two primary flows** - flow-generate and flow-transform
2. **Phase-based execution** - Features grouped by nature
3. **Automatic selection** - Based on context (existing code or not)

---

## Determinism Rules Architecture

Rules for deterministic code generation:

| Location | Contains | Priority |
|----------|----------|----------|
| `DETERMINISM-RULES.md` | Global patterns | Base |
| `MODULE.md ## ⚠️ CRITICAL` | Module-specific rules | **Highest** |

**Principle:** Module-specific rules override global rules.

---

## Related Documents

- [../../ENABLEMENT-MODEL-v3.0.md](../../ENABLEMENT-MODEL-v3.0.md) - Master model document
- [../../CONSUMER-PROMPT.md](../../CONSUMER-PROMPT.md) - Consumer agent system prompt
- [../../AUTHOR-PROMPT.md](../../AUTHOR-PROMPT.md) - Author system prompt
- [../ASSET-STANDARDS-v1.4.md](../ASSET-STANDARDS-v1.4.md) - Naming conventions
- [../DETERMINISM-RULES.md](../DETERMINISM-RULES.md) - Code generation patterns
- `runtime/discovery/capability-index.yaml` - Central capability index

---

**Last Updated:** 2026-01-21
