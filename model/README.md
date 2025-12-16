# Enablement 2.0 Model

> Meta-model definition: how the system works, standards, and authoring guides

## Purpose

This directory contains the **system definition** for Enablement 2.0:
- Master model document
- Asset standards
- Authoring guides
- Domain definitions
- Executive and technical overviews

## Structure

```
model/
├── README.md                          # This file
│
├── ENABLEMENT-MODEL-v1.5.md           # ⭐ Master document
├── ENABLEMENT-EXECUTIVE-BRIEF.md      # Executive summary (EN)
├── ENABLEMENT-TECHNICAL-GUIDE.md      # Technical architecture (EN)
├── ENABLEMENT-RESUMEN-EJECUTIVO.md    # Executive summary (ES)
├── ENABLEMENT-GUIA-TECNICA.md         # Technical architecture (ES)
│
├── standards/
│   ├── ASSET-STANDARDS-v1.3.md        # Structure and naming
│   ├── authoring/                     # How to CREATE assets
│   │   ├── ADR.md
│   │   ├── ERI.md
│   │   ├── MODULE.md
│   │   └── SKILL.md
│   ├── validation/                    # Validation standards (doc)
│   └── traceability/                  # Traceability standards (doc)
│
└── domains/                           # Domain definitions
    ├── README.md
    ├── code/
    │   ├── DOMAIN.md                  # CODE domain specification
    │   ├── capabilities/              # Domain capabilities
    │   │   ├── resilience.md
    │   │   ├── persistence.md
    │   │   ├── api_architecture.md
    │   │   └── integration.md
    │   └── module-structure.md
    ├── design/                        # (Planned)
    ├── qa/                            # (Planned)
    └── governance/                    # (Planned)
```

## Key Documents

| Document | Audience | Purpose |
|----------|----------|---------|
| **ENABLEMENT-MODEL-v1.5.md** | All | Complete system specification |
| **ENABLEMENT-EXECUTIVE-BRIEF.md** | Leadership | Business value, ROI |
| **ENABLEMENT-TECHNICAL-GUIDE.md** | Architects | Technical architecture |
| **standards/ASSET-STANDARDS-v1.3.md** | Developers | Naming, structure |
| **standards/authoring/*.md** | Developers | How to create assets |

## Reading Order

### For Executives (15 min)
1. `ENABLEMENT-EXECUTIVE-BRIEF.md`

### For Architects (1-2 hours)
1. `ENABLEMENT-MODEL-v1.5.md`
2. `ENABLEMENT-TECHNICAL-GUIDE.md`
3. `standards/ASSET-STANDARDS-v1.3.md`

### For Developers (2-4 hours)
1. `ENABLEMENT-MODEL-v1.5.md` (sections 1-5)
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
- `ENABLEMENT-MODEL-v1.5.md` = Version 1.5
- `ASSET-STANDARDS-v1.3.md` = Version 1.3

---

**Last Updated:** 2025-12-16  
**Version:** 4.0
