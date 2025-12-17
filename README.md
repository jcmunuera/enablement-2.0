# Enablement 2.0

> AI-powered SDLC platform for automated code generation with governance

## Overview

Enablement 2.0 is a platform that combines a structured Knowledge Base with AI capabilities to automate code generation following organizational standards.

### Problem Statement

- Low adoption of development frameworks (~30-40%)
- Inconsistent implementations across teams
- Productivity cost from pattern reinvention
- Difficulty maintaining governance in generated code

### Solution

A machine-readable Knowledge Base that feeds specialized AI agents to:
- Generate code compliant with standards (ADRs)
- Apply reference patterns (ERIs)
- Automatically validate generated code
- Scale knowledge to 400+ developers

---

## Repository Structure

```
enablement-2.0/
│
├── knowledge/              # KNOWLEDGE BASE (context for humans & agents)
│   ├── ADRs/              # Architecture Decision Records (strategic)
│   └── ERIs/              # Enterprise Reference Implementations (tactical)
│
├── model/                  # META-MODEL (defines the Enablement system)
│   ├── ENABLEMENT-MODEL-v1.6.md   # Master document
│   ├── SYSTEM-PROMPT.md           # Agent context specification
│   ├── standards/                 # Asset standards and authoring guides
│   └── domains/                   # Domain definitions (CODE, DESIGN, QA, GOV)
│
├── skills/                 # SKILLS (executable units for agents)
│   └── skill-{domain}-{NNN}-...
│
├── modules/                # MODULES (reusable templates, CODE domain)
│   └── mod-code-{NNN}-...
│
├── runtime/                # RUNTIME (orchestration and execution)
│   ├── discovery/         # Interpretive discovery guidance
│   ├── flows/             # Execution flows by domain/type
│   └── validators/        # Tier-1 and Tier-2 validators
│
├── docs/                   # Project documentation
└── poc/                    # Proofs of concept
```

---

## Conceptual Model

```
┌─────────────────────────────────────────────────────────────────────┐
│                         ENABLEMENT 2.0                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  KNOWLEDGE LAYER (what to know)                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  ADRs ──────────> ERIs                                       │    │
│  │  (Strategic)      (Tactical Reference)                       │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                              ▼                                       │
│  EXECUTION LAYER (what to do)                                        │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  Skills ──────────> Modules ──────────> Output              │    │
│  │  (Executable)       (Knowledge)         (Generated Code)    │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                              ▼                                       │
│  RUNTIME LAYER (how to execute)                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  Discovery ──> Flow ──> Validation                           │    │
│  │  (Interpretive) (Holistic/Atomic)  (Sequential)              │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Current Inventory (v2.2.0)

| Asset Type | Count | Location |
|------------|-------|----------|
| **Domains** | 4 | model/domains/ (CODE active, others planned) |
| **ADRs** | 5 | knowledge/ADRs/ |
| **ERIs** | 7 | knowledge/ERIs/ |
| **Modules** | 8 | modules/ |
| **Skills** | 2 | skills/ |
| **Flows** | 5 | runtime/flows/code/ |

---

## Quick Start

**New here?** Start with [GETTING-STARTED.md](GETTING-STARTED.md) which provides onboarding paths for:
- Executives (15 min)
- Architects (1-2 hours)
- Engineers creating assets (2-4 hours)
- Engineers using skills (30 min)

### Explore the Repository

```bash
# View knowledge (ADRs, ERIs)
ls knowledge/

# View model and domains
ls model/domains/

# View available skills
ls skills/

# View available modules
ls modules/

# View runtime (flows, validators)
ls runtime/
```

### Understand the Model

1. Start with: `model/ENABLEMENT-MODEL-v1.6.md`
2. Then: `model/standards/ASSET-STANDARDS-v1.3.md`
3. To create assets: `model/standards/authoring/`

---

## Execution Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│  1. INPUT: User prompt                                               │
│                                                                      │
│  2. DISCOVERY: Interpret domain and skill (semantic)                │
│     └── runtime/discovery/discovery-guidance.md                     │
│                                                                      │
│  3. LOAD: Skill specification + OVERVIEW.md                         │
│     └── skills/{skill}/SKILL.md, OVERVIEW.md                        │
│                                                                      │
│  4. FLOW: Get execution approach for skill type                     │
│     └── runtime/flows/{domain}/{TYPE}.md                            │
│                                                                      │
│  5. EXECUTE: Consult modules, generate output (holistic for GEN)    │
│     └── modules/{mod}/MODULE.md, templates/                         │
│                                                                      │
│  6. VALIDATE: Run validators (sequential)                           │
│     └── runtime/validators/ + modules/{mod}/validation/             │
│                                                                      │
│  7. OUTPUT: Generated code + traceability manifest                  │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Versioning

We use [Semantic Versioning](https://semver.org/):

```
MAJOR.MINOR.PATCH

MAJOR - Structural changes, complete new capability
MINOR - New ERIs, MODULEs, SKILLs
PATCH - Fixes, documentation improvements
```

See [CHANGELOG.md](CHANGELOG.md) for version history.

---

## Methodology

See [docs/METHODOLOGY.md](docs/METHODOLOGY.md) for details on:
- Branching strategy
- Commit conventions
- AI workflow
- Session documentation

---

## Roadmap

### Current Phase: Foundation (v2.x)
- [x] Structured Knowledge Base
- [x] Resilience patterns (Circuit Breaker, Retry, Timeout, Rate Limiter)
- [x] Persistence patterns (JPA, System API)
- [x] Clear separation: knowledge / model / skills / runtime
- [x] Interpretive discovery model (v1.6)
- [x] Holistic execution for GENERATE skills
- [ ] Complete Code Generation PoC

### Next Phases
- [ ] Observability patterns
- [ ] Event-driven patterns
- [ ] Testing patterns
- [ ] MCP Server integration

---

## Contributing

This is an internal project of the Center for Enablement (C4E).

To contribute:
1. Review `docs/METHODOLOGY.md`
2. Follow standards in `model/standards/authoring/`
3. Validate changes before committing

---

## License

Internal project - All rights reserved.

---

**Version:** 2.2.0  
**Last Updated:** 2025-12-17
