# Enablement 2.0 Model

> Meta-model definition: how the system works, standards, and authoring guides

## Purpose

This directory contains the **system definition** for Enablement 2.0:
- Master model document
- Agent context specification
- Asset standards
- Authoring guides
- Domain definitions
- Executive and technical overviews

## Structure

```
model/
├── README.md                          # This file
│
├── ENABLEMENT-MODEL-v1.6.md           # ⭐ Master document (current)
├── ENABLEMENT-MODEL-v1.5.md           # Previous version (reference)
├── SYSTEM-PROMPT.md                   # Agent context specification
├── ENABLEMENT-EXECUTIVE-BRIEF.md      # Executive summary
├── ENABLEMENT-TECHNICAL-GUIDE.md      # Technical architecture
│
├── standards/
│   ├── ASSET-STANDARDS-v1.3.md        # Structure and naming
│   ├── authoring/                     # How to CREATE assets
│   │   ├── README.md                  # Authoring overview
│   │   ├── ADR.md                     # ADR authoring guide
│   │   ├── ERI.md                     # ERI authoring guide
│   │   ├── MODULE.md                  # Module authoring guide (v1.7)
│   │   ├── SKILL.md                   # Skill authoring guide (v2.3) ⭐
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
| **SYSTEM-PROMPT.md** | Developers | Agent context and behavior |
| **ENABLEMENT-EXECUTIVE-BRIEF.md** | Leadership | Business value, ROI |
| **ENABLEMENT-TECHNICAL-GUIDE.md** | Architects | Technical architecture |
| **standards/ASSET-STANDARDS-v1.3.md** | Developers | Naming, structure |
| **standards/authoring/*.md** | Developers | How to create assets |

## What's New in v1.6

| Change | Description |
|--------|-------------|
| **Interpretive Discovery** | Discovery is now semantic interpretation, not rule-based |
| **Holistic Execution** | GENERATE skills consult modules as knowledge, generate in one pass |
| **SYSTEM-PROMPT.md** | New document defining agent context |
| **Multi-domain Support** | Framework for handling cross-domain requests |

## Reading Order

### For Executives (15 min)
1. `ENABLEMENT-EXECUTIVE-BRIEF.md`

### For Architects (1-2 hours)
1. `ENABLEMENT-MODEL-v1.6.md`
2. `ENABLEMENT-TECHNICAL-GUIDE.md`
3. `standards/ASSET-STANDARDS-v1.3.md`

### For Developers (2-4 hours)
1. `ENABLEMENT-MODEL-v1.6.md` (sections 1-5, 8-10)
2. `standards/ASSET-STANDARDS-v1.3.md`
3. `standards/authoring/{asset-type}.md`

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
- `ASSET-STANDARDS-v1.3.md` = Version 1.3

---

**Last Updated:** 2025-12-17  
**Version:** 5.0
