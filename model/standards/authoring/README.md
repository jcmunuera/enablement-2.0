# Authoring Standards

**Version:** 3.2  
**Last Updated:** 2026-02-04  
**Model Version:** 3.0.16

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

## What's New in v3.2

> **Key changes:** Template authoring guide, Module variants, Stack-specific style files

| Change | Impact |
|--------|--------|
| **TEMPLATE.md** | NEW guide for authoring .tpl files (DEC-025, DEC-036, DEC-040) |
| **Module Variants** | Modules can define implementation variants (DEC-041) |
| **Stack Style Files** | Code style rules in runtime/codegen/styles/ (DEC-042) |
| **// Output: header** | MANDATORY in all templates for deterministic paths |
| **// Variant: header** | Required when module has multiple implementations |

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
| ERI | [ERI.md](./ERI.md) | 1.3 | Enterprise Reference Implementations |
| Module | [MODULE.md](./MODULE.md) | **3.2** | Reusable code modules with variants ⭐ |
| **Template** | [TEMPLATE.md](./TEMPLATE.md) | **1.0** | **Code template files (.tpl)** ⭐ NEW |
| Capability | [CAPABILITY.md](./CAPABILITY.md) | **3.7** | Feature definitions with implementations ⭐ |
| Validator | [VALIDATOR.md](./VALIDATOR.md) | **1.2** | Artifact validation with Tier-0 ⭐ |
| Flow | [FLOW.md](./FLOW.md) | **3.2** | Execution flows with traceability ⭐ |
| Tags | [TAGS.md](./TAGS.md) | 2.0 | Discovery keywords (deprecated) |

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
3. Module (Reusable Template Package)
   │  └─ MUST have derived_from pointing to ERI
   │  └─ MUST declare stack in frontmatter
   │  └─ MAY define variants for implementation options
   ↓
4. Templates (Code Files in module/templates/)
   │  └─ MUST have // Output: header
   │  └─ MUST have // Variant: header if module has variants
   ↓
5. Validator (Quality Checks)
   ↓
6. Capability Feature (in capability-index.yaml)
   │  └─ References module
   │  └─ Defines config, input_spec
   │  └─ MAY publish config_flags (NOT variants)
```

---

## Critical Concepts

### Config Flags vs Module Variants (DEC-041)

**IMPORTANT:** Understand the difference:

| Concept | Config Flags | Variants |
|---------|--------------|----------|
| **Purpose** | Feature affects other modules | User selects implementation |
| **Defined in** | capability-index.yaml | MODULE.md |
| **Example** | `hateoas: true` | `http_client: feign` |

**Read:** MODULE.md "Module Variants" and CAPABILITY.md "Config Flags vs Module Variants"

### Template Headers (DEC-036, DEC-040)

**ALL templates MUST include:**

```java
// Output: src/main/java/{{basePackagePath}}/path/File.java
// Variant: option_id  // Only if module has variants
```

**Read:** TEMPLATE.md for complete guide

### Stack Style Files (DEC-042)

Code style rules are in `runtime/codegen/styles/{stack}.style.md`:

- `java-spring.style.md` - Rules for Java/Spring code generation
- Future: `nodejs.style.md`, etc.

**Style rules are injected into CodeGen prompt, not in MODULE.md documentation.**

---

## Coherence Rules

When creating assets, ensure coherence:

| Rule | Description |
|------|-------------|
| **Module → ERI** | Every Module MUST have `derived_from` pointing to an ERI |
| **Module → Stack** | Every Module MUST declare its stack |
| **Template → Output** | Every .tpl MUST have `// Output:` header |
| **Template → Variant** | If module has variants, templates MUST have `// Variant:` |
| **Feature → Module** | Every feature implementation MUST reference existing module |
| **Feature → Default** | Features with multiple implementations MUST have default |
| **Variant → Keywords** | Each variant option SHOULD have discovery keywords |

---

## Quick Reference

| I want to... | Read this |
|--------------|-----------|
| Document a strategic decision | [ADR.md](./ADR.md) |
| Create a reference implementation | [ERI.md](./ERI.md) |
| Build reusable template package | [MODULE.md](./MODULE.md) |
| **Write code templates (.tpl)** | **[TEMPLATE.md](./TEMPLATE.md)** |
| Define a capability feature | [CAPABILITY.md](./CAPABILITY.md) |
| Add validation for technology | [VALIDATOR.md](./VALIDATOR.md) |
| Document an execution flow | [FLOW.md](./FLOW.md) |

---

## Related Decisions

All decisions that impact authoring are documented in the relevant guides:

| Decision | Topic | Guide(s) |
|----------|-------|----------|
| DEC-001 | Skills eliminated | README (migration notes) |
| DEC-005 | Flow types (generate/transform) | FLOW.md |
| DEC-008 | `requires` → capability | CAPABILITY.md |
| DEC-013 | `implies`, `config_rules` | CAPABILITY.md |
| DEC-021 | Test templates | TEMPLATE.md |
| DEC-025 | Anti-improvisation rules | TEMPLATE.md |
| DEC-027 | Tier-0 conformance | VALIDATOR.md |
| DEC-028 | Cross-cutting transforms | TEMPLATE.md |
| DEC-030 | Transform descriptors | TEMPLATE.md |
| DEC-035 | Config flags pub/sub | CAPABILITY.md, MODULE.md |
| DEC-036 | `// Output:` header | TEMPLATE.md |
| DEC-037 | Enum generation | TEMPLATE.md |
| DEC-038 | Traceability manifest | FLOW.md |
| DEC-040 | `// Variant:` header | TEMPLATE.md, MODULE.md |
| DEC-041 | Module variants | MODULE.md, CAPABILITY.md |
| DEC-042 | Stack style files | README.md |
| ODEC-016 | Inter-module dependencies | MODULE.md |

---

## Related Documents

- [../../ENABLEMENT-MODEL-v3.0.md](../../ENABLEMENT-MODEL-v3.0.md) - Master model document
- [../../DECISION-LOG.md](../../DECISION-LOG.md) - All architectural decisions
- [../DETERMINISM-RULES.md](../DETERMINISM-RULES.md) - Code generation patterns
- `runtime/discovery/capability-index.yaml` - Central capability index
- `runtime/codegen/styles/` - Stack-specific style rules

---

**Last Updated:** 2026-02-04
