# Enablement 2.0

> AI-powered platform for full SDLC automation with governance

**Version:** 3.0  
**Last Updated:** 2026-01-20

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
├── knowledge/              # KNOWLEDGE BASE
│   ├── ADRs/              # Architecture Decision Records (strategic)
│   └── ERIs/              # Enterprise Reference Implementations (tactical)
│
├── model/                  # META-MODEL
│   ├── ENABLEMENT-MODEL-v3.0.md   # Master document
│   ├── CONSUMER-PROMPT.md         # Consumer agent system prompt
│   ├── AUTHOR-PROMPT.md           # Author/C4E system prompt
│   ├── standards/                 # Asset standards and authoring guides
│   └── domains/                   # Domain definitions
│       └── code/capabilities/     # Capability documentation
│
├── modules/                # MODULES (reusable templates)
│   └── mod-code-{NNN}-...
│
├── runtime/                # RUNTIME
│   ├── discovery/         # capability-index.yaml + discovery guidance
│   ├── flows/             # Execution flows (generate, transform)
│   └── validators/        # Tier-1 and Tier-2 validators
│
└── docs/                   # Project documentation
```

---

## Model v3.0 - Capability-Based Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           ENABLEMENT 2.0 v3.0                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  KNOWLEDGE LAYER                                                            │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  ADRs ──────────> ERIs                                               │   │
│  │  (Strategic)      (Tactical Reference)                               │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                              │                                              │
│                              ▼                                              │
│  CAPABILITY LAYER                                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Capability ──> Feature ──> Implementation ──> Module                │   │
│  │  (resilience)   (circuit-breaker)  (java-spring)   (mod-001)        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                              │                                              │
│                              ▼                                              │
│  EXECUTION LAYER                                                            │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Discovery ──> Flow Selection ──> Phase Planning ──> Generation     │   │
│  │  (keywords)    (generate/transform)  (structural→impl→cross-cut)    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Key Concepts

| Concept | Description |
|---------|-------------|
| **Capability** | Conceptual grouping (architecture, resilience, persistence) |
| **Feature** | Specific option within capability (circuit-breaker, retry) |
| **Implementation** | Stack-specific realization (java-spring, nodejs) |
| **Module** | Templates and rules for code generation |
| **Flow** | Execution pattern (generate, transform) |

---

## Discovery Flow

All discovery goes through `capability-index.yaml`:

```
prompt → keywords → features → implementations → modules
                      ↓
                 resolve dependencies
                      ↓
                 select flow (generate/transform)
                      ↓
                 phase planning → execution
```

---

## Current Capabilities (CODE Domain)

| Capability | Type | Features |
|------------|------|----------|
| **architecture** | Structural | hexagonal-light |
| **api-architecture** | Compositional | domain-api, system-api, experience-api, composable-api |
| **integration** | Compositional | api-rest |
| **persistence** | Compositional | jpa, systemapi |
| **resilience** | Compositional | circuit-breaker, retry, timeout, rate-limiter |
| **distributed-transactions** | Compositional | saga-compensation |

---

## Modules (java-spring)

| Module | Capability | Feature |
|--------|------------|---------|
| mod-code-001 | resilience | circuit-breaker |
| mod-code-002 | resilience | retry |
| mod-code-003 | resilience | timeout |
| mod-code-004 | resilience | rate-limiter |
| mod-code-015 | architecture | hexagonal-light |
| mod-code-016 | persistence | jpa |
| mod-code-017 | persistence | systemapi |
| mod-code-018 | integration | api-rest |
| mod-code-019 | api-architecture | domain-api |
| mod-code-020 | distributed-transactions | saga-compensation |

---

## Getting Started

### For Consumers (Developers)

1. Read [CONSUMER-PROMPT.md](model/CONSUMER-PROMPT.md) for the agent system prompt
2. Understand capabilities in [capability-index.yaml](runtime/discovery/capability-index.yaml)
3. Use natural language to request code generation

**Example:**
```
"Generate a Domain API for Customer management with 
persistence via System API and circuit breaker protection"
```

### For Authors (C4E Team)

1. Read [AUTHOR-PROMPT.md](model/AUTHOR-PROMPT.md)
2. Follow [Authoring Standards](model/standards/authoring/README.md)
3. Create ADRs → ERIs → Modules → Capability features

---

## Documentation

| Document | Purpose |
|----------|---------|
| [ENABLEMENT-MODEL-v3.0.md](model/ENABLEMENT-MODEL-v3.0.md) | Core model definition |
| [Discovery Guidance](runtime/discovery/discovery-guidance.md) | How discovery works |
| [Flow: Generate](runtime/flows/code/flow-generate.md) | Project generation flow |
| [Flow: Transform](runtime/flows/code/flow-transform.md) | Code transformation flow |

---

## What's New in v3.0

| Change | Description |
|--------|-------------|
| **Skills Eliminated** | Logic moved to enriched Features |
| **Single Discovery Path** | All through capability-index.yaml |
| **Multi-Implementation** | Features support multiple stacks/patterns |
| **Stack Detection** | Automatic detection from existing code |
| **Two Generic Flows** | flow-generate and flow-transform |

---

## Related

- [Getting Started](GETTING-STARTED.md)
- [Changelog](CHANGELOG.md)
- [Methodology](docs/METHODOLOGY.md)

---

**Last Updated:** 2026-01-20
