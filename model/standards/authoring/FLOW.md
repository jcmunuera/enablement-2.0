# Authoring Guide: Execution Flows

**Version:** 1.2  
**Date:** 2025-12-23

---

## Overview

Execution Flows define HOW skills of a specific type are executed within a domain. They are located in `runtime/flows/{domain}/{TYPE}.md`.

---

## When to Create a Flow

Create a new execution flow when:

- A new skill type is introduced to a domain
- The execution pattern for a skill type needs formal documentation
- A domain is being activated (moving from "Planned" to "Active")

---

## Location

```
runtime/flows/{domain}/{SKILL_TYPE}.md
```

Examples:
- `runtime/flows/code/GENERATE.md`
- `runtime/flows/code/ADD.md`
- `runtime/flows/design/ARCHITECTURE.md`

---

## Required Structure

Every execution flow document MUST include:

```markdown
# Skill Type: {DOMAIN}/{TYPE}

**Version:** X.Y  
**Date:** YYYY-MM-DD  
**Domain:** {DOMAIN}

---

## Purpose

[What this skill type does and when it's used]

---

## Execution Philosophy

[Key principles for this type - e.g., holistic vs atomic]

---

## Characteristics

| Aspect | Description |
|--------|-------------|
| Input | [What the skill receives] |
| Output | [What the skill produces] |
| Modules | [How modules are used] |
| Complexity | [Low/Medium/High] |

---

## Execution Flow

[Detailed step-by-step flow, preferably with ASCII diagram]

---

## Required Steps (v1.1)

Every execution flow that uses modules MUST include these steps:

### Variant Resolution Step

If the flow uses modules, it MUST include a **Variant Resolution** step after module loading:

```
STEP N: RESOLVE VARIANTS
───────────────────────────────────────────────────────────────────────────
Action: Select implementation variant for each module that has variants
Input:  List of modules + Request features
Output: Selected variant per module (default or alternative)

For each module with variants.enabled = true:

1. CHECK INPUT for explicit variant selection
2. EVALUATE recommendation conditions (if selection_mode = auto-suggest)
3. IF alternative recommended → ASK USER for confirmation
4. OTHERWISE → Use default variant
5. RECORD selection in manifest
───────────────────────────────────────────────────────────────────────────
```

### Determinism Rules Reference

For CODE domain flows, add reference to determinism rules:

```
During code generation, the agent MUST follow:
- model/standards/DETERMINISM-RULES.md (global patterns)
- Each module's ## Determinism section (module-specific patterns)
```

---

## Module Resolution Table

[If applicable - how features map to modules]

---

## Output Structure

Flows MUST define two output structures:

### 1. Artifact Output Structure

The structure of the generated artifact itself (e.g., project structure for CODE/GENERATE):

```markdown
## Artifact Output Structure

{serviceName}/
├── src/
│   ├── main/
│   └── test/
├── pom.xml
└── README.md
```

### 2. Flow Execution Output Structure (v1.2)

The standardized structure for the complete flow execution output, enabling reproducibility and traceability:

```markdown
## Flow Execution Output Structure

{execution-id}/
├── input/                          # Inputs received by the flow
│   ├── prompt.md                   # Original request
│   └── ...                         # Other inputs (generated during execution)
│
├── output/                         # Generated artifact
│   └── {artifact}/                 # The artifact with its own structure
│
├── trace/                          # Decision traceability
│   └── generation-trace.md         # Skills, modules, decisions
│
└── validation/                     # Validation scripts
    ├── tier-1-universal.sh         # Re-run tier-1 validations
    ├── tier-2-technology.sh        # Re-run tier-2 validations
    ├── tier-3-skill.sh             # Re-run tier-3 validations
    └── {artifact-specific}.sh      # Artifact validation (compile, test, etc.)
```

**Directory purposes:**

| Directory | Purpose |
|-----------|---------|
| `input/` | Store all inputs for reproducibility |
| `output/` | Contains the generated artifact |
| `trace/` | Records all decisions made during execution |
| `validation/` | Scripts to re-execute validations |

**Validation scripts must include:**

- `tier-1-universal.sh` - Re-execute universal validations
- `tier-2-technology.sh` - Re-execute technology-specific validations  
- `tier-3-skill.sh` - Re-execute skill/module-specific validations
- Artifact-specific scripts (e.g., `compile.sh`, `test.sh`, `package.sh` for Java)

---

## Validation Requirements

[What validations apply]

---

## Error Handling

[How to handle common errors]

---

## Example Skills

[List of skills that use this flow]
```

---

## Post-Creation Checklist

> ⚠️ **CRITICAL:** After creating a new execution flow, you MUST complete these steps.

### 1. Update CONSUMER-PROMPT.md

Location: `model/CONSUMER-PROMPT.md`

Update the **Domain-Specific Execution** table:

```markdown
| Domain | Execution Flows Location | Notes |
|--------|--------------------------|-------|
| CODE | `runtime/flows/code/` | GENERATE (holistic), ADD (atomic), ... |
| DESIGN | `runtime/flows/design/` | (Planned) → UPDATE THIS |
```

**Change required:**
- If domain was "(Planned)", replace with actual flow names
- If adding to existing domain, add the new flow name to the list

### 2. Update Domain DOMAIN.md

Location: `model/domains/{domain}/DOMAIN.md`

Ensure the **Skill Types** section lists the new type and references the flow:

```markdown
## Skill Types

| Type | Purpose | Flow |
|------|---------|------|
| GENERATE | Create new projects | `runtime/flows/code/GENERATE.md` |
| NEW_TYPE | [Purpose] | `runtime/flows/{domain}/NEW_TYPE.md` |
```

### 3. Verify Discovery Path

Ensure the agent can discover and execute:

1. ✅ DOMAIN.md has discovery guidance for when this skill type applies
2. ✅ At least one skill exists that uses this flow (or is planned)
3. ✅ CONSUMER-PROMPT.md references the flow location

---

## Validation Checklist

Before considering the flow complete:

- [ ] Document follows required structure
- [ ] Execution philosophy is clearly stated
- [ ] Step-by-step flow is documented
- [ ] **Variant Resolution step included** (if flow uses modules)
- [ ] **Determinism rules referenced** (for CODE domain)
- [ ] **Artifact Output Structure defined** ← NEW in v1.2
- [ ] **Flow Execution Output Structure defined** ← NEW in v1.2
- [ ] Error handling is defined
- [ ] **CONSUMER-PROMPT.md updated** ← Don't forget!
- [ ] **DOMAIN.md updated** ← Don't forget!
- [ ] At least one example skill listed

---

## Examples

### Good: CODE/GENERATE

See `runtime/flows/code/GENERATE.md` for a complete example including:
- Clear holistic execution philosophy
- Detailed ASCII flow diagram
- Module resolution table
- Why holistic matters (with code examples)
- Complete traceability requirements

### Good: CODE/ADD

See `runtime/flows/code/ADD.md` for a complete example of atomic execution flow.

---

## Common Mistakes

| Mistake | Impact | Prevention |
|---------|--------|------------|
| Not updating CONSUMER-PROMPT.md | Agent doesn't know flow exists | Use checklist above |
| Missing execution philosophy | Unclear how to execute | Always start with philosophy |
| No ASCII flow diagram | Hard to understand sequence | Include visual representation |
| No module resolution | Agent can't map features to modules | Include resolution table |

---

## Related Documents

- `model/CONSUMER-PROMPT.md` - Must be updated when adding flows
- `model/domains/{domain}/DOMAIN.md` - Must list skill types
- `authoring/SKILL.md` - Skills reference flows
- `authoring/VALIDATOR.md` - Flows define validation requirements

---

**END OF DOCUMENT**
