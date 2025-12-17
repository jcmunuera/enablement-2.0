# Discovery and Orchestration

**Version:** 2.0  
**Last Updated:** 2025-12-17

---

## Purpose

This folder contains the **discovery guidance and orchestration framework** that govern how the Enablement 2.0 system processes user requests, from natural language prompts to generated code.

> **REVISED in v2.0:** Discovery is now **interpretive**, not rule-based. The agent uses semantic understanding to identify domain and skill, not keyword matching.

---

## Contents

| Document | Purpose |
|----------|---------|
| `discovery-guidance.md` | **Interpretive** guidance for domain and skill identification |
| `execution-framework.md` | Generic execution framework |
| `prompt-template.md` | Template for users to provide complete information |

---

## Flow Overview

```
User Prompt
     │
     ▼
┌─────────────────────────────────────────┐
│ DISCOVERY (Interpretive)                │
│                                         │
│ Semantic interpretation of intent       │
│ Read DOMAIN.md → Identify domain        │
│ Read OVERVIEW.md → Select skill         │
│                                         │
│ See: discovery-guidance.md              │
└─────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│ EXECUTION (By Skill Type)               │
│                                         │
│ GENERATE: Holistic (modules as knowledge)│
│ ADD: Atomic (specific transformation)   │
│ ANALYZE: Evaluation (output is report)  │
│                                         │
│ See: runtime/flows/{domain}/{TYPE}.md   │
└─────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│ VALIDATION (Sequential)                 │
│                                         │
│ Tier-1 → Tier-2 → Tier-3 (per module)   │
│                                         │
│ See: runtime/validators/                │
└─────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│ TRACEABILITY                            │
│                                         │
│ .enablement/manifest.json               │
│ Records all decisions                   │
└─────────────────────────────────────────┘
```

---

## Key Concepts (v2.0)

### Interpretive Discovery

Discovery is **semantic interpretation**, not pattern matching:

| Old (v1.x) | New (v2.0) |
|------------|------------|
| IF "genera" AND "microservicio" THEN CODE | Agent interprets: output is code → CODE |
| IF "genera" AND "diagrama" THEN DESIGN | Agent interprets: output is diagram → DESIGN |
| Keyword matching | Semantic understanding |
| Rigid rules | Flexible interpretation with clarification |

### Holistic Execution (for GENERATE)

GENERATE skills work holistically:

| Old (v1.x) | New (v2.0) |
|------------|------------|
| Process modules sequentially | Consult all modules as knowledge |
| Generate base, then add features | Generate complete output in one pass |
| Modules are steps | Modules are knowledge sources |

### Multi-Domain Operations

Requests can span multiple domains:

```
"Analiza la calidad y corrige los problemas"
  │
  ▼
[QA/ANALYZE] → Analysis report
  │
  ▼
[CODE/REFACTOR] → Modified code (using report as context)
```

---

## Relationship to Other Components

```
runtime/discovery/      ← You are here (discovery guidance)
    │
    │ interprets
    ▼
model/domains/          ← Domain definitions with Discovery Guidance
    │
    │ identifies
    ▼
skills/                 ← Executable skills
    │
    ├── OVERVIEW.md     ← Discovery metadata (critical!)
    ├── SKILL.md        ← Full specification
    │
    │ consults (for GENERATE)
    ▼
modules/                ← Reusable knowledge
    │
    ├── MODULE.md       ← Templates & constraints
    └── templates/      ← Code patterns
    │
    │ executes
    ▼
runtime/flows/          ← Execution flows by domain/type
    │
    └── code/GENERATE.md ← Holistic execution
```

---

## Key Principles

### 1. Interpretive Discovery

The agent understands semantic context:
- **Output type** determines domain (code → CODE, diagram → DESIGN)
- **Action intent** refines skill selection
- **OVERVIEW.md** is the key document for matching

### 2. Holistic Generation

For GENERATE skills:
- Modules are knowledge to consult, not steps to execute
- All features generated together in one coherent pass
- Validation is sequential AFTER generation

### 3. Traceability

Every decision is recorded:
- Which domain and why
- Which skill and why
- Which modules were consulted
- Validation results

### 4. Graceful Ambiguity Handling

When uncertain:
- Ask for clarification (don't guess)
- Detect out-of-scope requests
- Support multi-domain decomposition

---

## Key Documents

| Document | Read When |
|----------|-----------|
| `discovery-guidance.md` | Understanding how discovery works |
| `execution-framework.md` | Understanding execution lifecycle |
| `model/domains/*/DOMAIN.md` | Understanding domain scope |
| `skills/*/OVERVIEW.md` | Understanding skill purpose |
| `runtime/flows/code/GENERATE.md` | Understanding holistic execution |

---

## Related

- [ENABLEMENT-MODEL-v1.6.md](../../model/ENABLEMENT-MODEL-v1.6.md) - Complete model
- [SYSTEM-PROMPT.md](../../model/SYSTEM-PROMPT.md) - Agent context
- [runtime/flows/](../flows/) - Execution flows
