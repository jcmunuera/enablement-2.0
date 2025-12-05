# Orchestration Layer

**Version:** 1.0  
**Last Updated:** 2025-12-05

---

## Purpose

This folder contains the **orchestration rules** that govern how the Enablement 2.0 
system processes user requests, from natural language prompts to generated code.

These documents ensure **deterministic execution** - the same input should always 
produce the same output, regardless of which AI agent or system executes the flow.

---

## Contents

| Document | Purpose |
|----------|---------|
| `discovery-rules.md` | How to transform user prompts into capabilities and skill selection |
| `execution-framework.md` | Generic execution flow that all skills follow |
| `prompt-template.md` | Template for users to provide complete information |
| `audit-schema.json` | JSON Schema for execution audit trails |

---

## Flow Overview

```
User Prompt
     │
     ▼
┌─────────────────────────────────────────┐
│ DISCOVERY (discovery-rules.md)          │
│                                         │
│ Prompt → Entities → Capabilities → Skill│
└─────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│ INPUT GENERATION                        │
│                                         │
│ Entities → generation-request.json      │
└─────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│ SKILL EXECUTION (execution-framework.md)│
│                                         │
│ Follows EXECUTION-FLOW.md in each skill │
│ Uses modules, templates deterministically│
└─────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│ AUDIT (audit-schema.json)               │
│                                         │
│ Records all decisions for traceability  │
└─────────────────────────────────────────┘
```

---

## Relationship to Other Components

```
orchestration/          ← You are here (the "how to orchestrate")
    │
    │ uses
    ▼
capabilities/           ← What can be done
    │
    │ maps to
    ▼
skills/                 ← How to do it
    │
    ├── SKILL.md        ← Specification
    ├── EXECUTION-FLOW.md ← Deterministic steps
    │
    │ uses
    ▼
skills/modules/         ← Reusable components
    │
    ├── MODULE.md       ← Spec + Template Catalog
    └── templates/*.tpl ← Actual templates
```

---

## Key Principles

### 1. Determinism

Same input → Same output. No randomness, no external dependencies.

### 2. Traceability

Every decision is recorded. You can always trace back:
- Which skill was used and why
- Which modules were included and why
- Which templates generated which files
- Any improvisations and why they happened

### 3. Single Source of Truth

- **Discovery rules** → Here in `orchestration/`
- **Execution flow** → In each skill's `EXECUTION-FLOW.md`
- **Template catalogs** → In each module's `MODULE.md`
- **Templates** → In module's `templates/*.tpl`

### 4. Skill Autonomy

Each skill has its own `EXECUTION-FLOW.md` that defines exactly how it executes.
The orchestration layer doesn't dictate implementation details, only the framework.

---

## Adding New Orchestration Rules

When adding new rules:

1. **Discovery rules:** Add to `discovery-rules.md`
2. **Execution patterns:** Add to `execution-framework.md`
3. **Audit fields:** Update `audit-schema.json`

Always maintain backwards compatibility - existing inputs should continue to work.

---

## Validation

Orchestration rules should be validated by:

1. **Manual review:** Rules should be unambiguous
2. **PoC execution:** Run actual generations and verify audit trail
3. **Reproducibility test:** Run same input twice, compare outputs

---

## Future Enhancements

- [ ] JSON Schema for discovery outputs
- [ ] Automated validation of EXECUTION-FLOW.md completeness
- [ ] Orchestration rule versioning
- [ ] Multi-skill orchestration (pipelines)
