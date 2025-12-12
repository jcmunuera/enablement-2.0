# Enablement 2.0 Model

This directory contains the **complete model definition** for Enablement 2.0, an SDLC automation platform.

## Document Hierarchy

```
model/
├── README.md                          # This file
├── ENABLEMENT-MODEL-v1.3.md           # Master document - COMPLETE CONCEPTUAL MODEL
│
└── standards/
    ├── ASSET-STANDARDS-v1.3.md        # Structure and naming for ALL asset types
    │
    ├── authoring/                     # How to CREATE assets
    │   ├── README.md                  # Index + common principles
    │   ├── ADR.md                     # ⏳ Pending
    │   ├── ERI.md                     # ⏳ Pending
    │   ├── MODULE.md                  # ⏳ Pending
    │   ├── SKILL.md                   # ⏳ Pending (CRITICAL)
    │   ├── VALIDATOR.md               # ⏳ Pending
    │   ├── CAPABILITY.md              # ⏳ Pending
    │   └── PATTERN.md                 # ⏳ Pending
    │
    ├── validation/                    # Validation SYSTEM (meta-level)
    │   └── README.md                  # 4-tier system architecture
    │
    └── traceability/                  # Traceability MODEL
        ├── README.md                  # System overview
        ├── BASE-MODEL.md              # Common fields for ALL skills
        └── profiles/                  # Output-type specific extensions
            ├── code-project.md        # For generation skills
            ├── code-transformation.md # For add/remove skills
            ├── document.md            # For design/gov skills
            └── report.md              # For qa skills
```

## Master Document

**ENABLEMENT-MODEL-v1.3.md** is the single source of truth for:

- Asset hierarchy (ADR → ERI → Module → Skill → Validator)
- Capability hierarchy (Capability → Feature → Component → Module)
- Skill domains and types (CODE, DESIGN, QA, GOVERNANCE)
- Four-tier validation system
- Traceability model
- Workflow definitions
- Asset creation processes

**Read this first** before creating any asset.

## Asset Types

| Asset | Purpose | Location |
|-------|---------|----------|
| **ADR** | Architectural Decision Record | `knowledge/ADRs/` |
| **ERI** | Enterprise Reference Implementation | `knowledge/ERIs/` |
| **Module** | Reusable code templates | `knowledge/skills/modules/` |
| **Skill** | Executable capability | `knowledge/skills/` |
| **Validator** | Artifact validation | `knowledge/validators/` |
| **Capability** | Feature grouping | `knowledge/capabilities/` |
| **Pattern** | Design patterns | `knowledge/patterns/` |

## Standards Categories

| Category | Purpose | When to Use |
|----------|---------|-------------|
| **ASSET-STANDARDS** | Structure, naming, directory layout | When organizing any asset |
| **authoring/** | Templates, checklists, creation process | When creating new assets |
| **validation/** | System architecture (meta) | Understanding validation system |
| **traceability/** | Model + profiles | When implementing traceability |

## Model vs Knowledge

This directory contains **META-LEVEL** documentation:

| This Directory (model/) | knowledge/ Directory |
|-------------------------|---------------------|
| HOW to create things | THE THINGS created |
| Specifications | Implementations |
| Standards | Assets |

**Example:**
- `model/standards/validation/README.md` = How the validation system works
- `knowledge/validators/` = Actual validator implementations

## For AI Agents

Before creating any asset:

1. Read `ENABLEMENT-MODEL-v1.3.md` for conceptual understanding
2. Read `standards/ASSET-STANDARDS-v1.3.md` for structure
3. Read `standards/authoring/{asset-type}.md` for creation guide
4. Use validators from `knowledge/validators/` after creation
5. Apply traceability from `standards/traceability/`

## For Humans

For manual design/development:

- Consult ADRs for strategic architectural decisions
- Consult ERIs for technology-specific reference implementation
- Follow constraints defined in ERI annexes
- Use authoring guides as checklists

## Versioning

Documents include version in filename:

- `ENABLEMENT-MODEL-v1.3.md` = Version 1.1
- `ASSET-STANDARDS-v1.3.md` = Version 1.2

Internal version in document metadata MUST match filename version.

## Status Legend

- ✅ Active - Complete and usable
- ⏳ Pending - Placeholder, to be completed
- 🔄 Draft - Work in progress

---

**Last Updated:** 2025-11-27  
**Version:** 3.0  
**Maintainer:** Fusion C4E Team
