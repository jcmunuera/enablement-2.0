# Enablement 2.0 Model

> Meta-model definition: how the system works, standards, and authoring guides

## Purpose

This directory contains the **system definition** for Enablement 2.0:
- Master model document
- Agent context specifications (Consumer and Author roles)
- Asset standards and determinism rules
- Authoring guides
- Domain definitions
- Executive and technical overviews

## Two Interaction Roles

The platform supports two distinct interaction roles:

| Role | Purpose | Prompt Document | Users |
|------|---------|-----------------|-------|
| **CONSUMER** | Use skills to produce SDLC outputs | `CONSUMER-PROMPT.md` | Developers, Solution Architects, Engineering Portal |
| **AUTHOR** | Create/evolve model and knowledge assets | `AUTHOR-PROMPT.md` | C4E Team (platform owners) |

### Consumer Role
Executes existing skills to generate code, designs, reports, etc. The agent follows discovery → skill selection → variant resolution → execution flows.

### Author Role  
Creates new knowledge assets (ADRs, ERIs, Modules, Skills, Flows, etc.) following authoring guides. Must always consult `model/standards/authoring/` before creating any asset. Must ensure coherence between ERIs and Modules.

## Structure

```
model/
├── README.md                          # This file
│
├── ENABLEMENT-MODEL-v1.7.md           # ⭐ Master document (current)
├── CONSUMER-PROMPT.md                 # Consumer agent system prompt (v1.4)
├── AUTHOR-PROMPT.md                   # Author/C4E system prompt
├── ENABLEMENT-EXECUTIVE-BRIEF.md      # Executive summary
├── ENABLEMENT-TECHNICAL-GUIDE.md      # Technical architecture
│
├── standards/
│   ├── ASSET-STANDARDS-v1.4.md        # Structure and naming
│   ├── DETERMINISM-RULES.md           # ⭐ Code generation patterns (NEW)
│   ├── authoring/                     # How to CREATE assets
│   │   ├── README.md                  # Authoring overview
│   │   ├── ADR.md                     # ADR authoring guide
│   │   ├── ERI.md                     # ERI authoring guide (v1.2) ⭐
│   │   ├── MODULE.md                  # Module authoring guide (v1.8) ⭐
│   │   ├── SKILL.md                   # Skill authoring guide (v2.6) ⭐
│   │   ├── FLOW.md                    # Flow authoring guide (v1.1) ⭐
│   │   ├── CAPABILITY.md              # Capability authoring guide
│   │   └── VALIDATOR.md               # Validator authoring guide
│   ├── validation/                    # Validation standards
│   └── traceability/                  # Traceability standards
│
└── domains/                           # Domain definitions
    ├── README.md                      # Domains overview
    ├── code/
    │   ├── DOMAIN.md                  # CODE domain specification
    │   ├── capabilities/              # Domain capabilities
    │   │   ├── resilience.md
    │   │   ├── persistence.md
    │   │   ├── api_architecture.md
    │   │   └── integration.md
    │   └── module-structure.md
    ├── design/
    │   └── DOMAIN.md                  # DESIGN domain (planned)
    ├── qa/
    │   └── DOMAIN.md                  # QA domain (planned)
    └── governance/
        └── DOMAIN.md                  # GOVERNANCE domain (planned)
```

## Key Documents

| Document | Audience | Purpose |
|----------|----------|---------|
| **ENABLEMENT-MODEL-v1.7.md** | All | Complete system specification |
| **CONSUMER-PROMPT.md** | Consumer agents | System prompt for skill execution |
| **AUTHOR-PROMPT.md** | C4E Team | System prompt for authoring sessions |
| **DETERMINISM-RULES.md** | All | Mandatory patterns for code generation |
| **ENABLEMENT-EXECUTIVE-BRIEF.md** | Leadership | Business value, ROI |
| **ENABLEMENT-TECHNICAL-GUIDE.md** | Architects | Technical architecture |
| **standards/ASSET-STANDARDS-v1.4.md** | All | Naming, structure |
| **standards/authoring/*.md** | Authors | How to create assets |

## What's New in v2.4.0 (2025-12-22)

| Change | Description |
|--------|-------------|
| **ENABLEMENT-MODEL v1.7** | New section: Coherence and Determinism. Asset derivation chain formalized. |
| **DETERMINISM-RULES.md** | New document with global mandatory patterns for code generation |
| **ERI.md v1.2** | `implementation_options` structure for multi-option ERIs |
| **MODULE.md v1.8** | `derived_from` now REQUIRED. Variant derivation from ERI. |
| **FLOW.md v1.1** | Variant Resolution Step required |
| **SKILL.md v2.6** | Variant Handling in Module Resolution |
| **CONSUMER-PROMPT.md v1.4** | Variant Selection Behavior, Determinism Rules |

### Key Concepts in v2.4.0

**Coherence:** Modules MUST derive from ERIs. Variants MUST inherit from ERI options.

```
ADR → ERI → Module → Skill
         ↓           ↑
    options → derived_from (MANDATORY)
```

**Determinism:** Global patterns ensure consistent code generation:
- Entity IDs as `record(UUID)`
- DTOs as Java `record`
- Simple enums (no attributes)
- Mappers as `@Component` with `switch`

### Previous (v1.6.1)

| Change | Description |
|--------|-------------|
| **AUTHOR-PROMPT.md** | System prompt for C4E authoring sessions |
| **Interpretive Discovery** | Discovery is semantic interpretation, not rule-based |
| **Holistic Execution** | GENERATE skills consult modules as knowledge |
| **Multi-domain Support** | Framework for handling cross-domain requests |

## Reading Order

### For Executives (15 min)
1. `ENABLEMENT-EXECUTIVE-BRIEF.md`

### For Architects (1-2 hours)
1. `ENABLEMENT-MODEL-v1.7.md`
2. `ENABLEMENT-TECHNICAL-GUIDE.md`
3. `standards/ASSET-STANDARDS-v1.4.md`
4. `standards/DETERMINISM-RULES.md` (**NEW**)

### For Developers / Consumers (2-4 hours)
1. `ENABLEMENT-MODEL-v1.7.md` (sections 1-5, 8-11)
2. `CONSUMER-PROMPT.md` (understand how agents work)
3. `standards/ASSET-STANDARDS-v1.4.md`

### For C4E / Authors (2-4 hours)
1. `ENABLEMENT-MODEL-v1.7.md` (full document, especially §10 Coherence)
2. `AUTHOR-PROMPT.md` (load at start of every authoring session)
3. `standards/authoring/README.md`
4. `standards/authoring/{asset-type}.md` (as needed)
5. `standards/DETERMINISM-RULES.md` (**NEW**)

## Related Directories

| Directory | Content |
|-----------|---------|
| `/knowledge/` | ADRs, ERIs (pure knowledge) |
| `/skills/` | Executable skills |
| `/modules/` | Reusable templates |
| `/runtime/` | Discovery, flows, validators |

## Versioning

Documents include version in filename:
- `ENABLEMENT-MODEL-v1.7.md` = Version 1.7 (current)
- `ASSET-STANDARDS-v1.4.md` = Version 1.4

---

**Last Updated:** 2025-12-22  
**Version:** 5.2
