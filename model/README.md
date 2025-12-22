# Enablement 2.0 Model

> Meta-model definition: how the system works, standards, and authoring guides

## Purpose

This directory contains the **system definition** for Enablement 2.0:
- Master model document
- Agent context specifications (Consumer and Author roles)
- Asset standards
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
Executes existing skills to generate code, designs, reports, etc. The agent follows discovery → skill selection → execution flows.

### Author Role  
Creates new knowledge assets (ADRs, ERIs, Modules, Skills, Flows, etc.) following authoring guides. Must always consult `model/standards/authoring/` before creating any asset.

## Structure

```
model/
├── README.md                          # This file
│
├── ENABLEMENT-MODEL-v1.6.md           # ⭐ Master document (current)
├── ENABLEMENT-MODEL-v1.5.md           # Previous version (reference)
├── CONSUMER-PROMPT.md                 # Consumer agent system prompt
├── AUTHOR-PROMPT.md                   # ⭐ Author/C4E system prompt (NEW)
├── ENABLEMENT-EXECUTIVE-BRIEF.md      # Executive summary
├── ENABLEMENT-TECHNICAL-GUIDE.md      # Technical architecture
│
├── standards/
│   ├── ASSET-STANDARDS-v1.4.md        # Structure and naming
│   ├── authoring/                     # How to CREATE assets
│   │   ├── README.md                  # Authoring overview
│   │   ├── ADR.md                     # ADR authoring guide
│   │   ├── ERI.md                     # ERI authoring guide
│   │   ├── MODULE.md                  # Module authoring guide (v1.7)
│   │   ├── SKILL.md                   # Skill authoring guide (v2.3) ⭐
│   │   ├── FLOW.md                    # Flow authoring guide (v1.0) ⭐
│   │   ├── CAPABILITY.md              # Capability authoring guide
│   │   └── VALIDATOR.md               # Validator authoring guide
│   ├── validation/                    # Validation standards
│   └── traceability/                  # Traceability standards
│
└── domains/                           # Domain definitions
    ├── README.md                      # Domains overview
    ├── code/
    │   ├── DOMAIN.md                  # CODE domain specification (v1.1)
    │   ├── capabilities/              # Domain capabilities
    │   │   ├── resilience.md
    │   │   ├── persistence.md
    │   │   ├── api_architecture.md
    │   │   └── integration.md
    │   └── module-structure.md
    ├── design/
    │   └── DOMAIN.md                  # DESIGN domain (v1.1, planned)
    ├── qa/
    │   └── DOMAIN.md                  # QA domain (v1.1, planned)
    └── governance/
        └── DOMAIN.md                  # GOVERNANCE domain (v1.1, planned)
```

## Key Documents

| Document | Audience | Purpose |
|----------|----------|---------|
| **ENABLEMENT-MODEL-v1.6.md** | All | Complete system specification |
| **CONSUMER-PROMPT.md** | Consumer agents | System prompt for skill execution |
| **AUTHOR-PROMPT.md** | C4E Team | System prompt for authoring sessions |
| **ENABLEMENT-EXECUTIVE-BRIEF.md** | Leadership | Business value, ROI |
| **ENABLEMENT-TECHNICAL-GUIDE.md** | Architects | Technical architecture |
| **standards/ASSET-STANDARDS-v1.4.md** | All | Naming, structure |
| **standards/authoring/*.md** | Authors | How to create assets |

## What's New in v1.6.1

| Change | Description |
|--------|-------------|
| **AUTHOR-PROMPT.md** | New system prompt for C4E authoring sessions |
| **CONSUMER-PROMPT.md** | Renamed from SYSTEM-PROMPT.md, refactored |
| **FLOW.md authoring guide** | How to create execution flows |
| **Two-role model** | Clear separation of Consumer vs Author prompts |

### Previous (v1.6)

| Change | Description |
|--------|-------------|
| **Interpretive Discovery** | Discovery is now semantic interpretation, not rule-based |
| **Holistic Execution** | GENERATE skills consult modules as knowledge, generate in one pass |
| **CONSUMER-PROMPT.md** | Agent context specification (renamed from SYSTEM-PROMPT.md in v1.6.1) |
| **Multi-domain Support** | Framework for handling cross-domain requests |

## Reading Order

### For Executives (15 min)
1. `ENABLEMENT-EXECUTIVE-BRIEF.md`

### For Architects (1-2 hours)
1. `ENABLEMENT-MODEL-v1.6.md`
2. `ENABLEMENT-TECHNICAL-GUIDE.md`
3. `standards/ASSET-STANDARDS-v1.4.md`

### For Developers / Consumers (2-4 hours)
1. `ENABLEMENT-MODEL-v1.6.md` (sections 1-5, 8-10)
2. `CONSUMER-PROMPT.md` (understand how agents work)
3. `standards/ASSET-STANDARDS-v1.4.md`

### For C4E / Authors (2-4 hours)
1. `ENABLEMENT-MODEL-v1.6.md` (full document)
2. `AUTHOR-PROMPT.md` ⭐ (load at start of every authoring session)
3. `standards/authoring/README.md`
4. `standards/authoring/{asset-type}.md` (as needed)

## Related Directories

| Directory | Content |
|-----------|---------|
| `/knowledge/` | ADRs, ERIs (pure knowledge) |
| `/skills/` | Executable skills |
| `/modules/` | Reusable templates |
| `/runtime/` | Discovery, flows, validators |

## Versioning

Documents include version in filename:
- `ENABLEMENT-MODEL-v1.6.md` = Version 1.6 (current)
- `ASSET-STANDARDS-v1.4.md` = Version 1.3

---

**Last Updated:** 2025-12-18  
**Version:** 5.1
