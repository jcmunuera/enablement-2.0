# Authoring Standards

**Version:** 2.2  
**Last Updated:** 2025-12-18

---

## Purpose

This directory contains **authoring guides** for creating assets in the Enablement 2.0 knowledge base. Each guide provides:

- Complete templates with all required sections
- Field specifications and valid values
- Checklists for completeness validation
- Examples of well-formed assets
- Relationship requirements (what other assets must exist/be referenced)

---

## What's New in v2.2

> **Key changes:**

| Guide | Change |
|-------|--------|
| **FLOW.md** | **NEW** - Authoring guide for execution flows with mandatory CONSUMER-PROMPT.md update checklist |
| **README.md** | Added FLOW.md to index and quick reference |

### Previous (v2.1)

| Guide | Change |
|-------|--------|
| **SKILL.md** | OVERVIEW.md now marked as CRITICAL for discovery. Detailed guidance on writing for semantic interpretation. |
| **MODULE.md** | Clarified module role by skill type: knowledge source for GENERATE (holistic), transformation guide for ADD (atomic). |

---

## Authoring Guides Index

### Core Asset Types

| Asset Type | Guide | Version | Description |
|------------|-------|---------|-------------|
| ADR | [ADR.md](./ADR.md) | 1.0 | Architecture Decision Records |
| ERI | [ERI.md](./ERI.md) | 1.0 | Enterprise Reference Implementations |
| Module | [MODULE.md](./MODULE.md) | **1.7** | Reusable code templates |
| Skill | [SKILL.md](./SKILL.md) | **2.3** | Automation skills (**CRITICAL**) |
| Validator | [VALIDATOR.md](./VALIDATOR.md) | 1.0 | Artifact validation components |
| **Flow** | [FLOW.md](./FLOW.md) | **1.0** | Execution flows by skill type (**NEW**) |

### Complementary Asset Types

| Asset Type | Guide | Version | Description |
|------------|-------|---------|-------------|
| Capability | [CAPABILITY.md](./CAPABILITY.md) | 1.0 | Feature groupings |

---

## Asset Creation Order

Assets should be created in this order to ensure dependencies exist:

```
1. ADR (Strategic Decision)
   ↓
2. ERI (Reference Implementation)
   ↓
3. Module (Reusable Template)
   ↓
4. Validator (Quality Checks)      ← Can be created alongside Module
   ↓
5. Skill (Automation)
```

---

## Common Principles

### 1. Self-Contained Documentation

Each asset MUST be understandable without external context. An AI agent reading only the asset should understand:
- What it is
- Why it exists
- How to use it
- What it relates to

### 2. Explicit Relationships

All relationships to other assets MUST be explicitly documented:

| Relationship | From | To | Example |
|--------------|------|-----|---------|
| `implements` | ERI | ADR | ERI implements ADR decisions |
| `source_eri` | Module | ERI | Module derives from ERI |
| `uses` | Skill | Module | Skill uses Module templates |
| `validates` | Validator | Artifact | Validator checks artifact |
| `orchestrates` | Skill | Validator | Skill runs validators |

### 3. Machine-Readable Metadata

Assets MUST include YAML front matter for tooling:

```yaml
---
id: {type}-{id}
version: {semver}
status: draft|active|deprecated
created: {ISO date}
updated: {ISO date}
# Asset-specific fields...
---
```

### 4. Incremental Creation

Assets can be created incrementally across sessions. Each authoring guide specifies:
- **Minimum viable asset:** Required fields for a valid draft
- **Complete asset:** All fields for production use
- **Validation checklist:** How to verify completeness

---

## Quick Reference: What to Read

| I want to... | Read this |
|--------------|-----------|
| Document a strategic decision | [ADR.md](./ADR.md) |
| Create a reference implementation | [ERI.md](./ERI.md) |
| Build reusable templates | [MODULE.md](./MODULE.md) |
| Create automated capability | [SKILL.md](./SKILL.md) |
| Add validation for new technology | [VALIDATOR.md](./VALIDATOR.md) |
| **Define how a skill type executes** | [FLOW.md](./FLOW.md) |

---

## Usage

### For AI Agents

When creating a new asset:

1. Read the appropriate authoring guide (e.g., `SKILL.md` for skills)
2. Identify required relationships (ADRs, ERIs, etc.)
3. Create minimum viable asset first
4. Complete remaining sections
5. Run validation checklist
6. Update related assets if needed

### For Humans

When reviewing or extending assets:

1. Use authoring guides as reference for expected structure
2. Use checklists to verify completeness
3. Follow templates for consistency

---

## Critical: Discovery and Execution

### SKILL.md and Discovery

The **SKILL.md** guide is particularly important because:

1. **OVERVIEW.md is the key to discovery** - The agent reads OVERVIEW.md to match user intent with skill purpose
2. **Writing for semantic interpretation** - Skills must be written so the LLM can interpret them correctly
3. **When to Use / When NOT to Use** - These sections directly affect skill selection

**Read SKILL.md carefully before creating any skill.**

### MODULE.md and Execution

The **MODULE.md** guide clarifies:

1. **Modules as knowledge for GENERATE** - Templates are guidance, not scripts
2. **Modules as transformation for ADD** - More deterministic application
3. **Tier-3 validation** - Runs AFTER generation to verify compliance

**Understand module role before creating templates.**

### FLOW.md and CONSUMER-PROMPT Updates

The **FLOW.md** guide is critical for maintaining consistency:

1. **Execution flows define HOW skills execute** - Each skill type needs a documented flow
2. **CONSUMER-PROMPT.md must be updated** - When adding a new flow, the agent context must reflect it
3. **Post-creation checklist** - FLOW.md includes mandatory steps to update related documents

**⚠️ Creating a flow without updating CONSUMER-PROMPT.md will break the agent's ability to discover and execute the new skill type.**

---

## Related Documents

- [../../ENABLEMENT-MODEL-v1.6.md](../../ENABLEMENT-MODEL-v1.6.md) - Master model document
- [../../CONSUMER-PROMPT.md](../../CONSUMER-PROMPT.md) - Consumer agent system prompt
- [../../AUTHOR-PROMPT.md](../../AUTHOR-PROMPT.md) - Author system prompt
- [../ASSET-STANDARDS-v1.4.md](../ASSET-STANDARDS-v1.4.md) - Naming conventions and directory structure
- [../validation/](../validation/) - Validation system architecture
- [../traceability/](../traceability/) - Traceability model and profiles

---

**Last Updated:** 2025-12-17
