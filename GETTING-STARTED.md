# Getting Started with Enablement 2.0

**Version:** 3.0  
**Last Updated:** 2026-01-20  
**Purpose:** Onboarding guide for different roles

---

## What is Enablement 2.0?

Enablement 2.0 is an AI-powered SDLC automation platform that:

- **Generates code** that follows organizational standards automatically
- **Validates compliance** against Architecture Decision Records (ADRs)
- **Scales knowledge** from reference implementations to 400+ developers
- **Tracks every decision** from strategic architecture to generated code

---

## Choose Your Path

| Role | Time | Goal | Start Here |
|------|------|------|------------|
| [Executive / Manager](#executive-path) | 15 min | Understand value proposition | ↓ |
| [Architect](#architect-path) | 1-2 hours | Understand the model and governance | ↓ |
| [Engineer - Creating Assets](#engineer-creating-assets) | 2-4 hours | Learn to author ADRs, ERIs, Modules, Capabilities | ↓ |
| [Engineer - Using Capabilities](#engineer-using-skills) | 30 min | Generate code using existing Capabilities | ↓ |

---

## Executive Path

**Time:** 15 minutes  
**Goal:** Understand the business value and high-level architecture

### Reading Order

1. **[README.md](README.md)** (5 min)
   - Problem statement: 30-40% framework adoption
   - Solution overview
   - Current inventory

2. **[ENABLEMENT-EXECUTIVE-BRIEF.md](model/ENABLEMENT-EXECUTIVE-BRIEF.md)** (10 min)
   - ROI and value proposition
   - Risk mitigation
   - Adoption strategy

### Key Takeaways

- Every generated artifact traces back to approved architecture decisions
- Capabilities automate repetitive development tasks with guaranteed compliance
- The platform reduces onboarding time and ensures consistency

---

## Architect Path

**Time:** 1-2 hours  
**Goal:** Understand the complete model, governance, and how pieces connect

### Reading Order

1. **[README.md](README.md)** (5 min)
   - Repository structure overview

2. **[model/ENABLEMENT-MODEL-v3.0.md](model/ENABLEMENT-MODEL-v3.0.md)** (30 min)
   - Complete conceptual model
   - Asset hierarchy: ADR → ERI → Module → Capability Feature
   - **Discovery philosophy** (interpretive, not rule-based)
   - **Execution model** (holistic for GENERATE, atomic for ADD)
   - Validation system (4 tiers)

3. **[model/ENABLEMENT-TECHNICAL-GUIDE.md](model/ENABLEMENT-TECHNICAL-GUIDE.md)** (20 min)
   - Technical implementation details
   - How flows execute
   - How validation works

4. **[model/standards/ASSET-STANDARDS-v1.4.md](model/standards/ASSET-STANDARDS-v1.4.md)** (20 min)
   - Naming conventions
   - Directory structures
   - Required metadata

5. **[runtime/discovery/discovery-guidance.md](runtime/discovery/discovery-guidance.md)** (15 min)
   - How prompts are interpreted semantically
   - Domain identification based on output type
   - Skill selection through OVERVIEW.md

### Key Takeaways

- The model separates concerns: Strategic (ADR) → Tactical (ERI) → Operational (Skill)
- Discovery is **interpretive** - the agent understands semantic context, not just keywords
- GENERATE skills work **holistically** - all features generated together, not sequentially
- Validation happens at 4 levels: Universal, Technology, Module, Runtime

### Diagram: How It All Connects

```
┌──────────────────────────────────────────────────────────────────┐
│                     GOVERNANCE FLOW                               │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ADR-004                    ERI-008                  mod-001      │
│  "Use Circuit Breaker"  →   "Resilience4j impl"  →   "Templates" │
│  (Strategic Decision)       (Reference Code)         (Knowledge)  │
│                                                                   │
│                                    ↓                              │
│                                                                   │
│                    capability-index.yaml                          │
│                 resilience.circuit-breaker                        │
│                    (Feature Definition)                           │
│                                                                   │
│                                    ↓                              │
│                                                                   │
│                    ┌─────────────────────┐                        │
│                    │  flow-generate.md   │                        │
│                    │ (Phase Execution)   │                        │
│                    └─────────────────────┘                        │
│                                    ↓                              │
│                                                                   │
│              Generated Code + manifest.json (traceability)        │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

---

## Engineer - Creating Assets

**Time:** 2-4 hours  
**Goal:** Learn to author ADRs, ERIs, Modules, and Capabilities

### Prerequisites

- Complete the [Architect Path](#architect-path) first
- Familiarity with the technology stack (Java/Spring for CODE domain)

### Reading Order

1. **[model/standards/authoring/README.md](model/standards/authoring/README.md)** (10 min)
   - Overview of authoring process
   - Which guide for which asset type

2. **[model/standards/authoring/ADR.md](model/standards/authoring/ADR.md)** (20 min)
   - How to document strategic decisions
   - ADR template and structure

3. **[model/standards/authoring/ERI.md](model/standards/authoring/ERI.md)** (30 min)
   - How to create reference implementations
   - Working code examples with documentation

4. **[model/standards/authoring/MODULE.md](model/standards/authoring/MODULE.md)** (30 min)
   - Module role in code generation
   - Template Catalog structure
   - Variables and placeholders

5. **[model/standards/authoring/CAPABILITY.md](model/standards/authoring/CAPABILITY.md)** (30 min)
   - How to define capability features
   - Feature attributes (keywords, config, input_spec)
   - Implementation mappings to modules

6. **[runtime/flows/code/flow-generate.md](runtime/flows/code/flow-generate.md)** (15 min)
   - Phase-based execution model
   - Modules loaded per phase
   - Validation after generation

### Practice: Creating a New Capability Feature

After completing the reading:

1. Start by examining existing modules:
   - `modules/mod-code-001-circuit-breaker-java-resilience4j/`
   - `modules/mod-code-015-hexagonal-base-java-spring/`

2. Pay special attention to:
   - `MODULE.md` - Complete specification with templates
   - `implements` section in frontmatter

3. Add feature to `runtime/discovery/capability-index.yaml`

### Key Takeaways

- Always create assets in order: ADR → ERI → Module → Capability Feature
- OVERVIEW.md is the key document for skill discovery
- For GENERATE skills, modules are knowledge to consult, not steps to execute
- Tier-3 validation runs for each module consulted

---

## Engineer - Using Capabilities

**Time:** 30 minutes  
**Goal:** Generate code using existing Capabilities

### Reading Order

1. **[README.md](README.md)** (3 min)
   - Quick overview

2. **[runtime/discovery/capability-index.yaml](runtime/discovery/capability-index.yaml)** (5 min)
   - Current inventory of available capabilities and features

3. **Choose a capability and understand its features:**

   **To add Circuit Breaker to existing service:**
   - Feature: `resilience.circuit-breaker`
   - Module: `mod-code-001-circuit-breaker-java-resilience4j`

   **To generate a new Domain API:**
   - Feature: `api-architecture.domain-api`
   - Requires: `architecture.hexagonal-light`

4. **Understand input format:**
   - Review the feature's `input_spec` in capability-index.yaml

### Quick Start: Generate a Domain API

```bash
# 1. Review capability-index.yaml for available features
cat runtime/discovery/capability-index.yaml

# 2. Understand what the feature requires
# Example: domain-api requires hexagonal-light

# 3. Prepare your prompt with required input
# "Generate Domain API for Customer with persistence via System API"

# 4. Execute (via AI agent)
```

### Key Takeaways

- All discovery goes through capability-index.yaml
- Features define keywords, config, input_spec, and implementations
- Generated code includes `.enablement/manifest.json` for traceability

---

## Document Map

```
enablement-2.0/
├── GETTING-STARTED.md              ← YOU ARE HERE
├── README.md                       ← Start here for overview
├── CHANGELOG.md                    ← Version history
│
├── knowledge/                      ← PURE KNOWLEDGE
│   ├── README.md                   ← Knowledge Base overview
│   ├── ADRs/                       ← Strategic decisions
│   │   └── adr-XXX-{topic}/ADR.md
│   └── ERIs/                       ← Reference implementations
│       └── eri-{domain}-XXX-{pattern}/ERI.md
│
├── model/                          ← META-MODEL
│   ├── README.md                   ← Model overview
│   ├── ENABLEMENT-MODEL-v3.0.md    ← ⭐ Master document
│   ├── CONSUMER-PROMPT.md          ← Consumer agent system prompt
│   ├── AUTHOR-PROMPT.md            ← Author/C4E system prompt
│   ├── ENABLEMENT-EXECUTIVE-BRIEF.md  ← For executives
│   ├── ENABLEMENT-TECHNICAL-GUIDE.md  ← For architects
│   │
│   ├── domains/                    ← Domain definitions
│   │   ├── README.md
│   │   ├── code/
│   │   │   ├── DOMAIN.md           ← CODE domain (active)
│   │   │   └── capabilities/       ← Capability documentation
│   │   ├── design/DOMAIN.md        ← DESIGN domain (planned)
│   │   ├── qa/DOMAIN.md            ← QA domain (planned)
│   │   └── governance/DOMAIN.md    ← GOVERNANCE domain (planned)
│   │
│   └── standards/
│       ├── ASSET-STANDARDS-v1.4.md ← Naming & structure
│       ├── authoring/              ← How to CREATE assets
│       │   ├── ADR.md
│       │   ├── ERI.md
│       │   ├── MODULE.md
│       │   ├── CAPABILITY.md       ← ⭐ Feature definitions
│       │   ├── FLOW.md
│       │   └── VALIDATOR.md
│       ├── validation/             ← Validation standards
│       └── traceability/           ← Traceability standards
│
├── modules/                        ← REUSABLE TEMPLATES
│   ├── README.md                   ← Modules inventory
│   └── mod-code-{NNN}-{pattern}/
│       ├── MODULE.md               ← Templates & constraints
│       ├── templates/              ← Code templates
│       └── validation/             ← Tier-3 validators
│
├── runtime/                        ← RUNTIME ORCHESTRATION
│   ├── README.md
│   ├── discovery/
│   │   ├── capability-index.yaml   ← ⭐ Single source of truth
│   │   └── discovery-guidance.md
│   ├── flows/
│   │   └── code/
│   │       ├── flow-generate.md    ← ⭐ Project generation
│   │       └── flow-transform.md   ← Code transformation
│   └── validators/
│       ├── tier-1-universal/
│       └── tier-2-technology/
│
└── docs/
    └── METHODOLOGY.md              ← How we work
```

---

## FAQ

### Q: Where do I start if I just want to generate code?

Go to [Engineer - Using Capabilities](#engineer-using-capabilities) path. You can be productive in 30 minutes.

### Q: I want to add a new pattern (e.g., Bulkhead). What do I need?

Follow the [Engineer - Creating Assets](#engineer-creating-assets) path. You'll need to create:
1. ADR (if new strategic decision)
2. ERI (reference implementation)
3. Module (templates)
4. Capability Feature (in capability-index.yaml)

### Q: What's the difference between ERI and Module?

- **ERI** = Working reference code with documentation. It's a complete, runnable example.
- **Module** = Templates abstracted from ERI. Modules are loaded per phase during generation.

### Q: What is "phase-based execution"?

For flow-generate, features are grouped into phases by nature:
1. **STRUCTURAL**: architecture, api-architecture (project structure)
2. **IMPLEMENTATION**: persistence, integration (adapters)
3. **CROSS-CUTTING**: resilience, etc. (annotations)

Modules are loaded per phase to manage context size and ensure coherent output.

### Q: How does discovery work?

Discovery goes through `capability-index.yaml`. The agent matches user prompt keywords against feature keywords, resolves dependencies, validates compatibility, and determines which modules to load.

### Q: How do I know which validators apply?

See `model/standards/validation/README.md`. The validation tier depends on:
- Tier 1: Always (universal checks)
- Tier 2: Based on detected technology
- Tier 3: Based on modules consulted during generation
- Tier 4: Runtime (CI/CD)

---

## Need Help?

1. Check `knowledge/README.md` for knowledge base structure
2. Check `model/README.md` for model documentation
3. Review existing assets as examples
4. Use the authoring guides in `model/standards/authoring/`
5. Contact the C4E team

---

**Last Updated:** 2026-01-20
