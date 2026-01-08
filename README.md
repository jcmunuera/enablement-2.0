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
│   ├── CONSUMER-PROMPT.md         # Consumer agent system prompt
│   ├── AUTHOR-PROMPT.md           # Author/C4E system prompt
│   ├── standards/                 # Asset standards and authoring guides
│   └── domains/                   # Domain definitions (CODE, DESIGN, QA, GOV)
│
├── skills/                 # SKILLS (executable units for agents)
│   ├── code/              # CODE domain skills
│   │   ├── soe/          # System of Engagement (frontend)
│   │   ├── soi/          # System of Integration (microservices)
│   │   └── sor/          # System of Record (mainframe)
│   ├── design/            # DESIGN domain skills
│   ├── qa/                # QA domain skills
│   └── governance/        # GOVERNANCE domain skills
│
├── modules/                # MODULES (reusable templates, CODE domain)
│   └── mod-code-{NNN}-...
│
├── runtime/                # RUNTIME (orchestration and execution)
│   ├── discovery/         # Interpretive discovery + skill-index.yaml
│   ├── flows/             # Execution flows by domain/type
│   └── validators/        # Tier-1 and Tier-2 validators
│
└── docs/                   # Project documentation
```

> **Note:** Proofs of concept (PoCs) are maintained in a separate workspace directory outside this repository to keep generated outputs separate from the versioned model.

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

## Agent Entry Point

> **For AI Agents:** If you are an AI agent interacting with this Knowledge Base, follow this section.

### Step 1: Identify Your Role

| Role | Description | Typical Triggers |
|------|-------------|------------------|
| **CONSUMER** | Execute skills to produce SDLC outputs | "Generate a microservice", "Create an API", "Add circuit breaker" |
| **AUTHOR** | Create or modify Knowledge Base assets | "Create a new ERI", "Add a module", "Define a new skill" |

> **Note:** Your role is typically specified in the prompt you receive. If not specified, infer from context: requests for code/design/analysis → CONSUMER; requests to extend the KB → AUTHOR.

### Step 2: Load Role-Specific Context

| Role | Action |
|------|--------|
| **CONSUMER** | Read `model/CONSUMER-PROMPT.md` and follow its instructions |
| **AUTHOR** | Read `model/AUTHOR-PROMPT.md` and follow its instructions |

### Step 3: Execute

The role-specific prompt will guide you through:

| Role | Process |
|------|---------|
| **CONSUMER** | Discovery → Skill Selection → Module Resolution → Execution → Validation |
| **AUTHOR** | Standards Review → Asset Creation → Coherence Validation → Registration |

### Additional Context

If provided with an `ENTERPRISE-CONTEXT.md` file, read it **before** the role-specific prompt. It contains organizational vocabulary and conventions that inform interpretation.

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
2. Then: `model/standards/ASSET-STANDARDS-v1.4.md`
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
- [x] Code Generation PoC validated

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

**Version:** 2.3.0  
**Last Updated:** 2026-01-08
