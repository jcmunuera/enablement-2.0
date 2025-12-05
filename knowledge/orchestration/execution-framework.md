# Skill Execution Flow - Generic Framework

**Version:** 1.0  
**Last Updated:** 2025-12-05

---

## Overview

This document defines the **generic execution framework** that ALL skills follow, 
regardless of their type (GENERATE, ADD, REMOVE, ANALYZE, etc.). Each skill type 
has variations, but the core structure is consistent.

---

## Skill Types and Their Characteristics

| Type | Action | Input | Output | Modules |
|------|--------|-------|--------|---------|
| **GENERATE** | Create new artifacts | generation-request.json | New project/files | Multiple, resolved |
| **ADD** | Add feature to existing | transformation-request.json | Modified files | Single or few |
| **REMOVE** | Remove feature | transformation-request.json | Modified files | Single |
| **REFACTOR** | Restructure code | refactor-request.json | Modified files | Single or few |
| **ANALYZE** | Examine without changing | analysis-request.json | Report | Single |
| **VALIDATE** | Check compliance | validation-request.json | Report | Single |
| **DOCUMENT** | Generate documentation | document-request.json | Documents | Single |

---

## Generic Execution Flow

```
┌─────────────────────────────────────────────────────────────────┐
│ PHASE 1: INPUT                                                  │
│                                                                 │
│ All skills receive a JSON request with:                         │
│ - What to operate on (target)                                   │
│ - How to operate (options/config)                               │
│ - Context (additional files if needed)                          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ PHASE 2: VALIDATE                                               │
│                                                                 │
│ 1. Validate input against skill's input schema                  │
│ 2. Apply defaults for optional fields                           │
│ 3. Verify prerequisites exist (target files, dependencies)      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ PHASE 3: RESOLVE                                                │
│                                                                 │
│ GENERATE skills:                                                │
│ - Resolve multiple modules based on features                    │
│ - Dynamic: Module Resolution rules in SKILL.md                  │
│                                                                 │
│ ADD/REMOVE/REFACTOR skills:                                     │
│ - Use fixed module(s) defined in SKILL.md                       │
│ - Select template based on pattern/variant                      │
│                                                                 │
│ ANALYZE/VALIDATE/DOCUMENT skills:                               │
│ - Use single module for rules/templates                         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ PHASE 4: PREPARE                                                │
│                                                                 │
│ 1. Build variable context from input                            │
│ 2. Load Template Catalog from each module                       │
│ 3. Filter templates by conditions                               │
│ 4. Read .tpl files                                              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ PHASE 5: EXECUTE                                                │
│                                                                 │
│ GENERATE: Render templates → Create new files                   │
│ ADD: Render templates → Insert into existing files              │
│ REMOVE: Identify patterns → Remove from existing files          │
│ ANALYZE: Apply rules → Collect findings                         │
│ DOCUMENT: Render templates → Create documents                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ PHASE 6: VALIDATE                                               │
│                                                                 │
│ 1. Tier-1: Universal checks (structure, traceability)           │
│ 2. Tier-2: Technology checks (compile, lint)                    │
│ 3. Tier-3: Module-specific checks (from module/validation/)     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ PHASE 7: AUDIT                                                  │
│                                                                 │
│ Generate execution-audit.json with:                             │
│ - All inputs                                                    │
│ - All decisions (modules, templates, conditions)                │
│ - All outputs                                                   │
│ - Any improvisations (with GAP references)                      │
│ - Validation results                                            │
└─────────────────────────────────────────────────────────────────┘
```

---

## Relationship: Skill → Module → Template

This relationship is THE SAME for all skill types:

```
SKILL
│
├── Defines: Input schema (what information is needed)
├── Defines: Module resolution (which modules to use)
├── Defines: Execution flow (how to orchestrate)
│
└── References → MODULE(s)
                 │
                 ├── Defines: Template Catalog (template → output)
                 ├── Defines: Template Variables (what each template needs)
                 ├── Defines: Validation rules (Tier-3)
                 │
                 └── Contains → TEMPLATE(s)
                                │
                                └── .tpl files with {{placeholders}}
```

The **difference by skill type** is:

| Skill Type | Module Resolution | Template Usage |
|------------|-------------------|----------------|
| GENERATE | Dynamic (many modules by features) | All templates in catalog |
| ADD | Fixed (1-2 modules) | Select by pattern |
| REMOVE | Fixed (1 module) | N/A (pattern matching) |
| ANALYZE | Fixed (1 module) | Rules, not templates |

---

## Required Files for Each Skill

Every skill MUST have:

```
skill-{domain}-{NNN}-{type}-{target}/
├── SKILL.md              # Main specification
├── EXECUTION-FLOW.md     # Deterministic execution steps
├── README.md             # User-facing documentation
├── prompts/
│   ├── system.md         # System prompt for AI execution
│   └── user.md           # User prompt template
└── validation/
    └── *.sh              # Skill-level validation scripts
```

---

## EXECUTION-FLOW.md Structure

Every skill's EXECUTION-FLOW.md MUST have:

```markdown
# Execution Flow: {skill-id}

**Skill Type:** {GENERATE|ADD|REMOVE|...}

## Prerequisites
[What inputs are required]

## Input Schema
[JSON schema for the request]

## Execution Steps

### Step 1: Validate Input
[Validation rules]

### Step 2: Resolve Module(s)
[How modules are determined]

### Step 3: [Skill-type specific steps]
...

### Step N-1: Run Validations
[Tier 1, 2, 3 validations]

### Step N: Generate Execution Audit
[Audit schema]

## Error Handling
[What to do on errors]

## Determinism Guarantees
[How reproducibility is ensured]
```

---

## Traceability Requirements

### For GENERATE Skills (new files)

Every generated file MUST have a header:
```java
// =============================================================================
// GENERATED CODE - DO NOT EDIT
// Template: {template_name}
// Module: {module_id}
// Generated by: {skill_id}
// Timestamp: {ISO-8601}
// =============================================================================
```

### For ADD/REMOVE Skills (modified files)

Every modification MUST have a comment:
```java
// Modified by: {skill_id}
// Template: {template_name}
// Timestamp: {ISO-8601}
@CircuitBreaker(name = "...")  // The actual modification
```

### For All Skills

Generate `execution-audit.json` with complete trace.

---

## Determinism Principles

To ensure reproducible results across executions:

1. **No randomness:** No random values, UUIDs from input only
2. **Explicit ordering:** Process modules/templates alphabetically
3. **Deterministic defaults:** Same defaults always applied
4. **No external state:** No network calls, no environment dependencies
5. **Full logging:** Every decision recorded in audit
6. **Idempotency:** Same input → Same output (for applicable skills)
