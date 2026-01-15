# Enablement 2.0

> AI-powered platform for full SDLC automation with governance

## Overview

Enablement 2.0 is a **multi-domain platform** that combines a structured Knowledge Base with AI capabilities to automate the entire Software Development Lifecycle (SDLC) following organizational standards.

### What Enablement 2.0 Covers

| Domain | Scope | Status |
|--------|-------|--------|
| **CODE** | Microservices, APIs, persistence, resilience patterns | Active |
| **DESIGN** | Architecture diagrams, C4 models, documentation | Planned |
| **QA** | Test generation, coverage analysis, quality gates | Planned |
| **GOVERNANCE** | Compliance validation, audit trails, policy enforcement | Planned |

### Problem Statement

- Low adoption of development frameworks (~30-40%)
- Inconsistent implementations across teams
- Productivity cost from pattern reinvention (~$5M annually)
- Difficulty maintaining governance across the SDLC
- Manual compliance validation and audit processes

### Solution

A **capability-based Knowledge Base** that feeds specialized AI agents to:
- Generate code, designs, and tests compliant with standards (ADRs)
- Apply reference patterns (ERIs) consistently across domains
- Automate validation and compliance checks
- Enforce governance throughout the entire SDLC
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
│   ├── ENABLEMENT-MODEL-v2.0.md   # Master document
│   ├── CONSUMER-PROMPT.md         # Consumer agent system prompt
│   ├── AUTHOR-PROMPT.md           # Author/C4E system prompt
│   ├── standards/                 # Asset standards and authoring guides
│   └── domains/                   # Domain definitions with capabilities
│       └── {domain}/capabilities/ # Domain-specific capabilities
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

## Model v2.0 - Capability-Based Architecture

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
│  CAPABILITY LAYER (what can be done) ← NEW in v2.0                  │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  Domain ──> Capability ──> Feature                           │    │
│  │  (CODE)     (resilience)   (circuit-breaker)                 │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                              ▼                                       │
│  EXECUTION LAYER (what to do)                                        │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  Skills ─────────────────> Output                            │    │
│  │  (implement capabilities)  (Generated Artifacts)             │    │
│  │       │                                                       │    │
│  │       └──> Modules (templates for skills)                    │    │
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

### Key Concepts in Model v2.0

**Capabilities:** Domain-specific abilities that skills implement.

```yaml
# Example: CODE domain capabilities
resilience:
  features: [circuit-breaker, retry, timeout, rate-limiter]
persistence:
  features: [jpa, systemapi]
api-exposure:
  features: [rest-hateoas]
```

**Skill Types:**
- `CREATION` - Generate complete artifacts from scratch
- `TRANSFORMATION` - Add/modify capabilities to existing code
- `ANALYSIS` - Analyze without modification
- `VALIDATION` - Verify compliance

### Current Inventory (v2.5.0)

| Asset Type | Count | Location |
|------------|-------|----------|
| **Domains** | 4 | model/domains/ (CODE active, others planned) |
| **Capabilities** | 8 | model/domains/code/capabilities/ |
| **ADRs** | 6 | knowledge/ADRs/ |
| **ERIs** | 9 | knowledge/ERIs/ |
| **Modules** | 10 | modules/ |
| **Skills** | 5 | skills/ |
| **Flows** | 10 | runtime/flows/code/ |

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

# View capabilities
ls model/domains/code/capabilities/

# View available skills
ls skills/

# View available modules
ls modules/

# View runtime (flows, validators)
ls runtime/
```

### Understand the Model

1. Start with: `model/ENABLEMENT-MODEL-v2.0.md`
2. Then: `model/standards/ASSET-STANDARDS-v1.4.md`
3. To create assets: `model/standards/authoring/`

---

## Execution Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│  1. INPUT: User prompt                                               │
│                                                                      │
│  2. DISCOVERY: Interpret domain, capability, and skill (semantic)   │
│     └── runtime/discovery/discovery-guidance.md                     │
│                                                                      │
│  3. LOAD: Skill specification + capabilities                         │
│     └── skills/{skill}/SKILL.md + model/domains/{domain}/caps/      │
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
│  7. OUTPUT: Generated artifacts + traceability manifest             │
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

### Current Phase: Model v2.0 (v2.x)
- [x] Multi-domain SDLC architecture
- [x] Capability-based skill organization
- [x] Resilience patterns (Circuit Breaker, Retry, Timeout, Rate Limiter)
- [x] Persistence patterns (JPA, System API)
- [x] API patterns (HATEOAS, REST Client)
- [x] Coherence and Determinism rules
- [x] Code Generation PoC validated

### Next Phases
- [ ] Observability patterns (metrics, tracing, logging)
- [ ] Event-driven patterns (Kafka, async)
- [ ] Testing patterns (unit, integration, contract)
- [ ] DESIGN domain activation
- [ ] QA domain activation
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

**Version:** 2.5.0  
**Model:** v2.0  
**Last Updated:** 2025-01-15
