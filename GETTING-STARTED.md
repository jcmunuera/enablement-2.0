# Getting Started with Enablement 2.0

**Version:** 2.0  
**Last Updated:** 2025-12-17  
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
| [Engineer - Creating Assets](#engineer-creating-assets) | 2-4 hours | Learn to author ADRs, ERIs, Modules, Skills | ↓ |
| [Engineer - Using Skills](#engineer-using-skills) | 30 min | Generate code using existing Skills | ↓ |

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
- Skills automate repetitive development tasks with guaranteed compliance
- The platform reduces onboarding time and ensures consistency

---

## Architect Path

**Time:** 1-2 hours  
**Goal:** Understand the complete model, governance, and how pieces connect

### Reading Order

1. **[README.md](README.md)** (5 min)
   - Repository structure overview

2. **[model/ENABLEMENT-MODEL-v1.6.md](model/ENABLEMENT-MODEL-v1.6.md)** (30 min)
   - Complete conceptual model
   - Asset hierarchy: ADR → ERI → Module → Skill
   - **Discovery philosophy** (interpretive, not rule-based)
   - **Execution model** (holistic for GENERATE, atomic for ADD)
   - Validation system (4 tiers)

3. **[model/ENABLEMENT-TECHNICAL-GUIDE.md](model/ENABLEMENT-TECHNICAL-GUIDE.md)** (20 min)
   - Technical implementation details
   - How Skills execute
   - How validation works

4. **[model/standards/ASSET-STANDARDS-v1.3.md](model/standards/ASSET-STANDARDS-v1.3.md)** (20 min)
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
│                          skill-code-001                           │
│                   "Add Circuit Breaker to Service"                │
│                     (Automated Execution)                         │
│                                                                   │
│                                    ↓                              │
│                                                                   │
│                    ┌─────────────────────┐                        │
│                    │   GENERATE.md       │                        │
│                    │ (Holistic Execution)│                        │
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
**Goal:** Learn to author ADRs, ERIs, Modules, and Skills

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
   - Module role by skill type (knowledge for GENERATE, transformation for ADD)
   - Template Catalog structure
   - Variables and placeholders

5. **[model/standards/authoring/SKILL.md](model/standards/authoring/SKILL.md)** (45 min)
   - **OVERVIEW.md is critical for discovery** - how to write it
   - Skill specification structure
   - Execution flow reference
   - Validation orchestration

6. **[runtime/flows/code/GENERATE.md](runtime/flows/code/GENERATE.md)** (15 min)
   - Holistic execution model
   - Modules as knowledge, not steps
   - Validation after generation

### Practice: Creating a New Skill

After completing the reading:

1. Start by examining existing skills:
   - `skills/skill-code-001-add-circuit-breaker-java-resilience4j/`
   - `skills/skill-code-020-generate-microservice-java-spring/`

2. Pay special attention to:
   - `SKILL.md` - Complete specification
   - `OVERVIEW.md` - Discovery metadata (critical!)

3. Use the validation checklist in `authoring/SKILL.md` before submitting

### Key Takeaways

- Always create assets in order: ADR → ERI → Module → Skill
- OVERVIEW.md is the key document for skill discovery
- For GENERATE skills, modules are knowledge to consult, not steps to execute
- Tier-3 validation runs for each module consulted

---

## Engineer - Using Skills

**Time:** 30 minutes  
**Goal:** Generate code using existing Skills

### Reading Order

1. **[README.md](README.md)** (3 min)
   - Quick overview

2. **[skills/README.md](skills/README.md)** (5 min)
   - Current inventory of available skills

3. **Choose a Skill and read its documentation:**

   **To add Circuit Breaker to existing service:**
   - `skills/skill-code-001-add-circuit-breaker-java-resilience4j/OVERVIEW.md`

   **To generate a new microservice:**
   - `skills/skill-code-020-generate-microservice-java-spring/OVERVIEW.md`

4. **Understand input format:**
   - Review the skill's `SKILL.md` for input schema

### Quick Start: Generate a Microservice

```bash
# 1. Navigate to the skill
cd skills/skill-code-020-generate-microservice-java-spring

# 2. Read the OVERVIEW (quick reference)
cat OVERVIEW.md

# 3. Review full specification
cat SKILL.md

# 4. Create your generation request following the schema

# 5. Execute (via your AI integration)
```

### Key Takeaways

- Each Skill has OVERVIEW.md for quick reference, SKILL.md for full details
- Input schemas define what parameters you need
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
│   ├── ENABLEMENT-MODEL-v1.6.md    ← ⭐ Master document
│   ├── CONSUMER-PROMPT.md          ← Consumer agent system prompt
│   ├── AUTHOR-PROMPT.md            ← Author/C4E system prompt
│   ├── ENABLEMENT-EXECUTIVE-BRIEF.md  ← For executives
│   ├── ENABLEMENT-TECHNICAL-GUIDE.md  ← For architects
│   │
│   ├── domains/                    ← Domain definitions
│   │   ├── README.md
│   │   ├── code/DOMAIN.md          ← CODE domain (active)
│   │   ├── design/DOMAIN.md        ← DESIGN domain (planned)
│   │   ├── qa/DOMAIN.md            ← QA domain (planned)
│   │   └── governance/DOMAIN.md    ← GOVERNANCE domain (planned)
│   │
│   └── standards/
│       ├── ASSET-STANDARDS-v1.3.md ← Naming & structure
│       ├── authoring/              ← How to CREATE assets
│       │   ├── ADR.md
│       │   ├── ERI.md
│       │   ├── MODULE.md
│       │   ├── SKILL.md            ← ⭐ Critical for skills
│       │   └── VALIDATOR.md
│       ├── validation/             ← Validation standards
│       └── traceability/           ← Traceability standards
│
├── skills/                         ← EXECUTABLE SKILLS
│   ├── README.md                   ← Skills inventory
│   └── skill-{domain}-{NNN}-{type}-{target}/
│       ├── OVERVIEW.md             ← ⭐ Discovery metadata
│       ├── SKILL.md                ← Full specification
│       └── validation/
│
├── modules/                        ← REUSABLE KNOWLEDGE
│   ├── README.md                   ← Modules inventory
│   └── mod-{domain}-{NNN}-{pattern}/
│       ├── MODULE.md               ← Templates & constraints
│       ├── templates/              ← Code templates
│       └── validation/             ← Tier-3 validators
│
├── runtime/                        ← RUNTIME ORCHESTRATION
│   ├── README.md
│   ├── discovery/
│   │   ├── discovery-guidance.md   ← ⭐ Interpretive discovery
│   │   └── execution-framework.md
│   ├── flows/
│   │   └── code/
│   │       ├── GENERATE.md         ← ⭐ Holistic execution
│   │       ├── ADD.md
│   │       └── ...
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

Go to [Engineer - Using Skills](#engineer-using-skills) path. You can be productive in 30 minutes.

### Q: I want to add a new pattern (e.g., Bulkhead). What do I need?

Follow the [Engineer - Creating Assets](#engineer-creating-assets) path. You'll need to create:
1. ADR (if new strategic decision)
2. ERI (reference implementation)
3. Module (templates)
4. Skill (automation)

### Q: What's the difference between ERI and Module?

- **ERI** = Working reference code with documentation. It's a complete, runnable example.
- **Module** = Templates abstracted from ERI. For GENERATE skills, modules are knowledge to consult. For ADD skills, they're more directly applied.

### Q: What is "holistic execution"?

For GENERATE skills, the agent doesn't process modules one by one. Instead, it consults ALL applicable modules as knowledge and generates the complete output in one pass, considering all features together. This produces more coherent code.

### Q: How does discovery work?

Discovery is **interpretive**, not rule-based. The agent reads DOMAIN.md files and skill OVERVIEW.md files to understand what each skill does. It matches user intent semantically based on **output type** (code, diagram, report) and **action** (generate, analyze, design).

### Q: How do I know which validators apply to my skill?

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

**Last Updated:** 2025-12-17
