# ENABLEMENT-MODEL.md

**Version:** 1.7  
**Date:** 2025-12-22  
**Status:** Active  
**Purpose:** Master document defining the complete Enablement 2.0 model

> **This is the MASTER document.** For detailed operational standards, see:
> - `standards/ASSET-STANDARDS-v1.5.md` - Technical structure for each asset type
> - `standards/DETERMINISM-RULES.md` - Determinism patterns for code generation (**NEW**)
> - `standards/validation/README.md` - Validation system architecture
> - `standards/traceability/README.md` - Traceability model and profiles
> - `CONSUMER-PROMPT.md` - Consumer agent system prompt

---

## Table of Contents

1. [Overview](#1-overview)
2. [Asset Hierarchy](#2-asset-hierarchy)
3. [Domains](#3-domains)
4. [Capability Hierarchy](#4-capability-hierarchy)
5. [Skill Domains and Types](#5-skill-domains-and-types)
6. [Validation System](#6-validation-system)
7. [Traceability](#7-traceability)
8. [Discovery and Orchestration](#8-discovery-and-orchestration)
9. [Execution Model](#9-execution-model) ← Variant Resolution added in v1.7
10. [Coherence and Determinism](#10-coherence-and-determinism) ← **NEW in v1.7**
11. [Multi-Domain Operations](#11-multi-domain-operations)
12. [Knowledge Base Structure](#12-knowledge-base-structure)
13. [Appendices](#13-appendices)

---

## 1. Overview

### 1.1 Purpose

Enablement 2.0 is an SDLC automation platform that enables:

- **For human developers:** Reference documentation (ADRs, ERIs) to design and implement software following organizational standards
- **For automation:** Skills and Modules that automate parts of the SDLC (design, development, QA, governance)

### 1.2 Core Principles

| Principle | Description |
|-----------|-------------|
| **Dual Purpose** | Every asset serves both humans and automation |
| **Traceability** | Every generated output has complete traceability to ADRs, ERIs, Modules |
| **Consistency** | Standardized naming conventions and structures |
| **Validation** | 4-tier system that guarantees compliance |
| **Extensibility** | Model designed for incremental growth |
| **Interpretive Discovery** | Domain and skill identification through semantic interpretation, not rigid rules |
| **Holistic Execution** | GENERATE skills produce complete outputs considering all features together |
| **Coherence** | Modules MUST derive from ERIs; variants MUST inherit from ERI options (**NEW v1.7**) |
| **Determinism** | Code generation follows mandatory patterns ensuring consistency across executions (**NEW v1.7**) |

### 1.3 Conceptual Model

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         ENABLEMENT 2.0                                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  GOVERNANCE LAYER                                                        │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  ADRs ──────> ERIs ──────> Modules ──────> Skills               │    │
│  │  (Strategic)  (Tactical)   (Templates)    (Automated)           │    │
│  │               ↓ options    ↑ derived_from                       │    │
│  │               └────────────┘ (Coherence)                        │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  CAPABILITY LAYER                                                        │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Capabilities ──> Features ──> Components ──> Modules           │    │
│  │  (What)          (Group)      (Abstract)     (Concrete)         │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  DISCOVERY LAYER (Interpretive)                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Prompt ──> Domain Interpretation ──> Skill Selection ──> Plan  │    │
│  │  (Input)    (Semantic Analysis)       (Metadata Match)   (Exec) │    │
│  │  See: runtime/discovery/discovery-guidance.md                   │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  EXECUTION LAYER (By Skill Type) ← Variant Resolution in v1.7           │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  GENERATE: Holistic (modules as knowledge) + Variant Resolution │    │
│  │  ADD: Atomic (specific module application) + Variant Resolution │    │
│  │  ANALYZE: Evaluation (output is report)                         │    │
│  │  See: runtime/flows/{domain}/{type}.md                          │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  DETERMINISM LAYER (Mandatory Patterns) ← NEW in v1.7                   │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Global Rules ──> Module Patterns ──> Consistent Output         │    │
│  │  See: model/standards/DETERMINISM-RULES.md                      │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  VALIDATION LAYER (Sequential, Deterministic)                            │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Tier 1 ──> Tier 2 ──> Tier 3 ──> Tier 4                        │    │
│  │  (Universal) (Technology) (Module) (Runtime)                    │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 1.4 Interpretive vs Deterministic Components

> **Updated in v1.7:** Added Variant Resolution and Determinism phases.

| Phase | Nature | Description |
|-------|--------|-------------|
| **Discovery** | Interpretive | LLM interprets prompt semantically to identify domain and skill |
| **Module Resolution** | Deterministic | Based on features/capabilities in request, rules define which modules apply |
| **Variant Resolution** | Deterministic | If module has variants, resolve which variant to use (**NEW v1.7**) |
| **Execution** | Skill-type dependent | GENERATE is holistic, ADD is atomic |
| **Determinism** | Mandatory | Code generation follows global and module-specific patterns (**NEW v1.7**) |
| **Validation** | Deterministic | Fixed rules, sequential execution, pass/fail criteria |
| **Traceability** | Mandatory | All decisions must be recorded regardless of nature |

---

## 8. Discovery and Orchestration

> **REVISED in v1.6:** Discovery is now interpretive, not rule-based.

### 8.1 Discovery Philosophy

Discovery is the process of identifying WHAT to do based on user input. It is fundamentally **interpretive** - the agent uses semantic understanding to match user intent with platform capabilities.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    DISCOVERY PHILOSOPHY                                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  WHAT DISCOVERY IS:                                                      │
│  • Semantic interpretation of user intent                                │
│  • Matching intent to domain based on SDLC context                       │
│  • Selecting skill based on OVERVIEW.md descriptions                     │
│  • Recognizing ambiguity and asking for clarification                    │
│  • Detecting out-of-scope requests                                       │
│                                                                          │
│  WHAT DISCOVERY IS NOT:                                                  │
│  • Keyword matching with IF/THEN rules                                   │
│  • Deterministic pattern matching                                        │
│  • Hardcoded mappings from words to skills                               │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 8.2 Discovery Process

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     DISCOVERY PROCESS                                     │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  STEP 1: SCOPE VALIDATION                                                │
│  ─────────────────────────────────────────────────────────────────────  │
│  Is this request within SDLC scope?                                      │
│                                                                          │
│  • If YES → Continue to Step 2                                           │
│  • If NO → Inform user this is outside platform scope                    │
│  • If UNCLEAR → Ask for clarification                                    │
│                                                                          │
│  Example OUT OF SCOPE:                                                   │
│  "Genera un poema con rima asonante" → Not SDLC, inform user             │
│                                                                          │
│  ─────────────────────────────────────────────────────────────────────  │
│                                                                          │
│  STEP 2: DOMAIN INTERPRETATION                                           │
│  ─────────────────────────────────────────────────────────────────────  │
│  Which SDLC domain does this belong to?                                  │
│                                                                          │
│  The agent interprets the FULL semantic context:                         │
│  • What is the user trying to accomplish?                                │
│  • What type of output do they expect?                                   │
│  • What SDLC phase does this correspond to?                              │
│                                                                          │
│  Reference: Read model/domains/{domain}/DOMAIN.md for each candidate     │
│                                                                          │
│  Examples:                                                               │
│  • "Genera un microservicio Customer"                                    │
│    → CODE (output is source code, "microservicio" is code artifact)      │
│                                                                          │
│  • "Genera el diagrama de arquitectura técnica"                          │
│    → DESIGN (output is diagram, despite "genera" keyword)                │
│                                                                          │
│  • "Analiza la calidad del código a nivel de resiliencia"                │
│    → QA (action is analysis, output is assessment)                       │
│                                                                          │
│  • "Revisa si cumple con las políticas de seguridad"                     │
│    → GOVERNANCE (action is compliance verification)                      │
│                                                                          │
│  ─────────────────────────────────────────────────────────────────────  │
│                                                                          │
│  STEP 3: SKILL SELECTION                                                 │
│  ─────────────────────────────────────────────────────────────────────  │
│  Which skill within the domain best matches the request?                 │
│                                                                          │
│  Process:                                                                │
│  1. List skills in the identified domain: skills/skill-{domain}-*/       │
│  2. Read OVERVIEW.md of each candidate skill                             │
│  3. Match user intent with skill purpose and "when to use"               │
│  4. Select best match                                                    │
│                                                                          │
│  If multiple skills could apply → Ask user for clarification             │
│  If no skill matches → Inform user capability doesn't exist yet          │
│                                                                          │
│  ─────────────────────────────────────────────────────────────────────  │
│                                                                          │
│  STEP 4: MULTI-DOMAIN DETECTION                                          │
│  ─────────────────────────────────────────────────────────────────────  │
│  Does this request span multiple domains?                                │
│                                                                          │
│  Examples of multi-domain requests:                                      │
│  • "Analiza la calidad y propón mejoras"                                 │
│    → QA (analyze) + DESIGN (propose)                                     │
│                                                                          │
│  • "Analiza y corrige los problemas de resiliencia"                      │
│    → QA (analyze) + CODE (fix)                                           │
│                                                                          │
│  If multi-domain:                                                        │
│  • Decompose into sequential domain operations                           │
│  • Plan execution chain                                                  │
│  • See Section 10: Multi-Domain Operations                               │
│                                                                          │
│  ─────────────────────────────────────────────────────────────────────  │
│                                                                          │
│  STEP 5: EXECUTION PLAN                                                  │
│  ─────────────────────────────────────────────────────────────────────  │
│  Prepare for execution:                                                  │
│                                                                          │
│  • Load SKILL.md for selected skill                                      │
│  • Identify required inputs (what to ask user if missing)                │
│  • Resolve applicable modules based on features                          │
│  • Load corresponding FLOW from runtime/flows/{domain}/{type}.md         │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 8.3 Domain Interpretation Guidelines

The agent interprets domain based on the **complete semantic context**, not individual keywords.

| Signal | Interpretation Guidance |
|--------|------------------------|
| **Output type** | Code → CODE, Diagram → DESIGN, Report → QA, Policy → GOVERNANCE |
| **Action intent** | Create/modify code → CODE, Design/architect → DESIGN, Analyze/audit → QA |
| **Artifact mentioned** | Microservice/API/class → CODE, Architecture/diagram → DESIGN |
| **SDLC phase implied** | Implementation → CODE, Design → DESIGN, Testing/Quality → QA |

**Important:** Keywords like "genera" (generate) do NOT determine domain. The **type of output** determines domain:
- "Genera un microservicio" → CODE (output is code)
- "Genera un diagrama C4" → DESIGN (output is diagram)
- "Genera un reporte de calidad" → QA (output is report)

### 8.4 Handling Ambiguity

When the agent cannot confidently determine domain or skill:

| Situation | Action |
|-----------|--------|
| Domain unclear | Ask user: "¿Tu objetivo es generar código, crear un diseño, analizar calidad, o verificar cumplimiento?" |
| Multiple skills match | Present options: "Puedo ayudarte con X o con Y. ¿Cuál prefieres?" |
| Missing information | Ask for specifics: "Para generar el microservicio, necesito saber qué capacidades requieres (resiliencia, persistencia, etc.)" |
| Out of scope | Inform clearly: "Esta solicitud está fuera del alcance de la plataforma SDLC" |

### 8.5 Discovery Metadata

To facilitate discovery, each asset provides metadata:

| Asset | Metadata for Discovery | Location |
|-------|----------------------|----------|
| Domain | Purpose, output types, skill types, examples | `model/domains/{domain}/DOMAIN.md` |
| Skill | Purpose, when to use, when NOT to use, tags | `skills/{skill}/OVERVIEW.md` |
| Capability | Description, features, components | `model/domains/{domain}/capabilities/{cap}.md` |

---

## 9. Execution Model

> **REVISED in v1.6:** Execution varies by skill type. GENERATE is holistic, not sequential.

### 9.1 Execution Philosophy

Once discovery identifies the skill, execution follows the corresponding flow. The nature of execution depends on the **skill type**.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    EXECUTION BY SKILL TYPE                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  GENERATE (Holistic)                                                     │
│  ─────────────────────────────────────────────────────────────────────  │
│  • Modules are KNOWLEDGE to consult, not steps to execute                │
│  • Agent generates COMPLETE output in one pass                           │
│  • All features/capabilities considered together                         │
│  • Templates are GUIDANCE, not scripts                                   │
│  • Validation is sequential AFTER generation                             │
│                                                                          │
│  ADD (Atomic)                                                            │
│  ─────────────────────────────────────────────────────────────────────  │
│  • Single module applies to existing code                                │
│  • More deterministic transformation                                     │
│  • Module templates applied directly                                     │
│  • Validation after transformation                                       │
│                                                                          │
│  ANALYZE (Evaluation)                                                    │
│  ─────────────────────────────────────────────────────────────────────  │
│  • Input is existing artifact                                            │
│  • Output is report/assessment                                           │
│  • No code generation, only analysis                                     │
│  • Validation checks report completeness                                 │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 9.2 GENERATE Execution (Holistic)

For skills of type GENERATE, the agent produces complete output considering all features together.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                 GENERATE EXECUTION FLOW                                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  PHASE A: PREPARATION                                                    │
│  ─────────────────────────────────────────────────────────────────────  │
│  1. Parse request: Extract all features/capabilities required            │
│  2. Resolve modules: Identify which modules apply (deterministic)        │
│  3. Load knowledge: Read MODULE.md and templates from each               │
│  4. Build context: Combine all variables and constraints                 │
│                                                                          │
│  PHASE B: GENERATION (Holistic)                                          │
│  ─────────────────────────────────────────────────────────────────────  │
│  The agent generates the COMPLETE output in one pass:                    │
│                                                                          │
│  • Considers ALL modules simultaneously                                  │
│  • Uses templates as GUIDANCE for structure and patterns                 │
│  • Applies ALL features together (e.g., circuit-breaker + retry +        │
│    timeout applied to the same code, not iteratively)                    │
│  • Produces complete, coherent output                                    │
│                                                                          │
│  This is NOT:                                                            │
│  ✗ Process module 1, then module 2, then module 3                        │
│  ✗ Generate base, then add feature 1, then add feature 2                 │
│  ✗ Sequential transformation pipeline                                    │
│                                                                          │
│  PHASE C: VALIDATION (Sequential)                                        │
│  ─────────────────────────────────────────────────────────────────────  │
│  After generation, validation IS sequential:                             │
│                                                                          │
│  1. Tier-1 Universal: Traceability, structure                            │
│  2. Tier-2 Technology: Compile, framework-specific                       │
│  3. Tier-3 Module: For EACH module that was consulted:                   │
│     • Run modules/{mod}/validation/{check}.sh                            │
│     • Order doesn't matter, all must pass                                │
│  4. Tier-4 Runtime: (Future) Integration tests                           │
│                                                                          │
│  PHASE D: TRACEABILITY                                                   │
│  ─────────────────────────────────────────────────────────────────────  │
│  Record in manifest:                                                     │
│  • Which modules were consulted                                          │
│  • Which templates were used as guidance                                 │
│  • Which ADRs/ERIs apply                                                 │
│  • Validation results                                                    │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 9.3 Module Role by Skill Type

| Skill Type | Module Role | How Used |
|------------|-------------|----------|
| **GENERATE** | Knowledge source | Consulted for templates, patterns, constraints. Agent synthesizes holistically. |
| **ADD** | Transformation guide | Applied directly to add specific feature to existing code. |
| **REMOVE** | Identification guide | Used to identify what to remove. |
| **REFACTOR** | Pattern reference | Guidance for code transformation. |
| **ANALYZE** | Criteria reference | Defines what to check/measure. |

### 9.4 Module Resolution (Deterministic)

While discovery is interpretive, module resolution IS deterministic based on features:

```
Features in Request          →    Modules to Consult
─────────────────────────────────────────────────────────────────
resilience.circuit_breaker   →    mod-code-001-circuit-breaker
resilience.retry             →    mod-code-002-retry
resilience.timeout           →    mod-code-003-timeout
persistence.type=jpa         →    mod-code-016-persistence-jpa
persistence.type=system_api  →    mod-code-017-persistence-systemapi
integration.rest_clients     →    mod-code-018-api-integration
(always for CODE/GENERATE)   →    mod-code-015-hexagonal-base
```

These rules are defined in each skill's SKILL.md under "Uses Modules".

### 9.5 Validation After Generation

Validation is deterministic and sequential. For GENERATE skills:

1. **Tier-1**: Universal validations (always)
2. **Tier-2**: Technology validations (based on detected stack)
3. **Tier-3**: Module validations - **for each module consulted during generation**:
   - The agent tracks which modules it consulted
   - Each consulted module's validation scripts are executed
   - Order of module validation doesn't matter
   - All must pass

This ensures that even though generation is holistic, validation verifies each module's constraints were respected.

---

## 10. Coherence and Determinism

> **NEW in v1.7:** Establishing formal rules for asset coherence and deterministic code generation.

### 13.1 Asset Derivation Chain

Assets in Enablement 2.0 form a derivation chain where each level inherits from and extends the previous:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    ASSET DERIVATION CHAIN                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ADR (Strategic Decision)                                                │
│    │ "We will use Circuit Breaker pattern for fault tolerance"          │
│    ↓                                                                     │
│  ERI (Reference Implementation)                                          │
│    │ "Here's how to implement Circuit Breaker with Resilience4j"        │
│    │                                                                     │
│    │  └─ implementation_options (if multiple valid approaches)          │
│    │       • option A: default                                          │
│    │       • option B: alternative                                      │
│    │       • option C: deprecated                                       │
│    ↓                                                                     │
│  MODULE (Executable Templates)                                           │
│    │ "Templates for generating Circuit Breaker code"                    │
│    │                                                                     │
│    │  └─ derived_from: eri-xxx (MANDATORY)                              │
│    │  └─ variants (if ERI has implementation_options)                   │
│    │       • Variants MUST correspond to ERI options                    │
│    │       • Module CANNOT invent new variants                          │
│    ↓                                                                     │
│  SKILL (Orchestration)                                                   │
│    │ "Add Circuit Breaker to existing service"                          │
│    │                                                                     │
│    │  └─ Resolves variants at runtime                                   │
│    │  └─ Records selection in manifest                                  │
│    ↓                                                                     │
│  OUTPUT (Generated Code)                                                 │
│      Complete traceability to all ancestors                             │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 13.2 Coherence Rules

**Rule 1: Module-ERI Relationship**

Every Module MUST have a `derived_from` field pointing to its source ERI:

```yaml
# In MODULE.md frontmatter
derived_from: eri-code-008-circuit-breaker-java-resilience4j  # REQUIRED
```

**Rule 2: Variant Inheritance**

If a Module has variants, they MUST derive from ERI's `implementation_options`:

| ERI Defines | Module Inherits |
|-------------|-----------------|
| `implementation_options.options[]` | `variants.alternatives[]` |
| `implementation_options.default` | `variants.default.id` |
| Option `recommended_when` | Variant `recommend_when` |
| Option `status: deprecated` | Variant `deprecated: true` |

**Rule 3: No Invention**

A Module CANNOT offer variants that the ERI does not define as valid options.

### 13.3 Implementation Options Types

ERIs may define implementation options in two ways:

| Type | Description | Module Structure |
|------|-------------|------------------|
| **EQUIVALENT** | Options are functionally interchangeable | Single module with `variants` |
| **DISPARATE** | Options are architecturally different | Separate modules |

**Example EQUIVALENT:** API Integration Client
- Options: RestClient, Feign, RestTemplate
- All produce same result (HTTP client)
- → Single module `mod-018` with variants

**Example DISPARATE:** Persistence
- Options: JPA (local DB), System API (mainframe)
- Architecturally different implementations
- → Two modules: `mod-016` (JPA), `mod-017` (System API)

### 13.4 Variant Resolution

When a module has variants, resolution follows this process:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    VARIANT RESOLUTION PROCESS                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  1. Check if module has variants.enabled = true                          │
│                                                                          │
│  2. If user input specifies variant explicitly:                          │
│     → Use specified variant                                              │
│                                                                          │
│  3. Else if selection_mode = auto-suggest AND conditions match:          │
│     → Ask user: "Based on [condition], would you prefer [alternative]?"  │
│                                                                          │
│  4. Else:                                                                │
│     → Use default variant                                                │
│                                                                          │
│  5. Record selection in manifest:                                        │
│     variant_selections:                                                  │
│       - module: mod-xxx                                                  │
│         variant: selected-id                                             │
│         reason: "user-specified" | "auto-default" | "user-confirmed"     │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 13.5 Determinism Rules

To ensure consistent code generation across executions, the platform enforces mandatory patterns:

**Global Patterns (apply to all CODE modules):**

| Element | Mandatory Pattern | Rationale |
|---------|-------------------|-----------|
| Entity IDs | `record EntityId(UUID value)` | Type safety, immutability |
| DTOs | Java `record` (no Lombok) | Immutability, compile-time safety |
| Enums | Simple (no attributes) | Code mapping delegated to Mapper |
| Mappers | `@Component` with `switch` | Single responsibility, testability |
| Generated code annotations | `@Generated`, `@Module` | Traceability |

**Module-Specific Patterns:**

Each module defines its own determinism section with mandatory and configurable elements:
- See `modules/{mod}/MODULE.md` → `## Determinism` section

**Reference Document:**
- `model/standards/DETERMINISM-RULES.md` - Complete determinism specification

---

## 11. Multi-Domain Operations

> **NEW in v1.6:** Handling requests that span multiple SDLC domains.

### 13.1 Multi-Domain Detection

Some user requests implicitly require multiple domains:

| Request | Domains Involved | Decomposition |
|---------|-----------------|---------------|
| "Analiza la calidad y propón mejoras" | QA → DESIGN | 1. QA/ANALYZE 2. DESIGN/PROPOSE |
| "Analiza y corrige los problemas" | QA → CODE | 1. QA/ANALYZE 2. CODE/ADD or REFACTOR |
| "Diseña e implementa la solución" | DESIGN → CODE | 1. DESIGN/ARCHITECTURE 2. CODE/GENERATE |

### 13.2 Multi-Domain Execution

```
┌─────────────────────────────────────────────────────────────────────────┐
│                 MULTI-DOMAIN EXECUTION                                    │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  APPROACH: Sequential domain execution with context passing              │
│                                                                          │
│  1. DECOMPOSE                                                            │
│     Agent identifies the sequence of domain operations                   │
│                                                                          │
│  2. PLAN                                                                 │
│     Create execution plan: [Domain1/Skill1] → [Domain2/Skill2] → ...    │
│                                                                          │
│  3. EXECUTE WITH CONTEXT                                                 │
│     • Execute first domain/skill                                         │
│     • Pass output as context to next                                     │
│     • Continue chain                                                     │
│                                                                          │
│  4. UNIFIED TRACEABILITY                                                 │
│     Record the complete chain in manifest                                │
│                                                                          │
│  Example: "Analiza y corrige problemas de resiliencia"                   │
│  ─────────────────────────────────────────────────────────────────────  │
│  Plan: [QA/ANALYZE] → [CODE/ADD]                                         │
│                                                                          │
│  Step 1: QA/ANALYZE                                                      │
│  • Input: User's code                                                    │
│  • Output: Analysis report with identified issues                        │
│                                                                          │
│  Step 2: CODE/ADD (with context)                                         │
│  • Input: User's code + Analysis report                                  │
│  • Output: Modified code with resilience patterns                        │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 13.3 Domain Flow Atomicity

Flows within a domain are **atomic** - they do one thing well:

| Domain | Flow | Atomic Action |
|--------|------|---------------|
| CODE | GENERATE | Create new project |
| CODE | ADD | Add one capability |
| QA | ANALYZE | Produce analysis report |
| DESIGN | PROPOSE | Create design proposal |

The **agent** handles orchestration across domains, not the flows themselves. This keeps flows simple and composable.

### 13.4 When to Ask vs When to Proceed

| Situation | Action |
|-----------|--------|
| Clear single domain | Proceed directly |
| Clear multi-domain with obvious sequence | Proceed with planned sequence |
| Ambiguous multi-domain | Ask: "¿Quieres que analice y proponga mejoras, o que analice y las implemente directamente?" |
| Risky multi-domain (e.g., auto-fix code) | Confirm: "Voy a modificar el código directamente. ¿Confirmas?" |

---

## 12. Knowledge Base Structure

> Updated in v1.6 to reflect new structure

```
enablement-2.0/
│
├── knowledge/                    # PURE KNOWLEDGE
│   ├── ADRs/                    # Strategic decisions
│   └── ERIs/                    # Reference implementations
│
├── model/                        # META-MODEL
│   ├── ENABLEMENT-MODEL-v1.6.md # This document
│   ├── CONSUMER-PROMPT.md       # Consumer agent system prompt
│   ├── AUTHOR-PROMPT.md         # Author/C4E system prompt
│   ├── standards/               # Asset standards
│   │   ├── authoring/          # Creation guides
│   │   ├── validation/         # Validation standards
│   │   └── traceability/       # Traceability standards
│   └── domains/                 # Domain definitions
│       ├── code/
│       │   ├── DOMAIN.md       # Semantic description for discovery
│       │   └── capabilities/
│       ├── design/
│       ├── qa/
│       └── governance/
│
├── skills/                       # EXECUTABLE SKILLS
│   ├── skill-code-*/
│   │   ├── OVERVIEW.md         # Discovery metadata (key for selection)
│   │   ├── SKILL.md            # Full specification
│   │   └── validation/
│   └── skill-{domain}-*/
│
├── modules/                      # REUSABLE KNOWLEDGE
│   └── mod-code-*/
│       ├── MODULE.md           # Templates and constraints
│       ├── templates/          # Code templates
│       └── validation/         # Tier-3 validators
│
├── runtime/                      # RUNTIME ORCHESTRATION
│   ├── discovery/
│   │   ├── discovery-guidance.md  # Interpretive guidance (not rules)
│   │   └── execution-framework.md
│   ├── flows/
│   │   └── code/
│   │       ├── GENERATE.md     # Holistic execution
│   │       ├── ADD.md          # Atomic execution
│   │       └── ...
│   └── validators/
│       ├── tier-1-universal/
│       └── tier-2-technology/
│
└── docs/
```

---

## 13. Appendices

### 13.1 Glossary

| Term | Definition |
|------|------------|
| **Discovery** | Interpretive process of identifying domain and skill from user prompt |
| **Holistic Execution** | Generating complete output considering all features together, not iteratively |
| **Module as Knowledge** | Using modules as reference/guidance rather than sequential execution steps |
| **Multi-Domain Operation** | Request that requires skills from multiple SDLC domains |
| **Out of Scope** | Request that doesn't belong to any SDLC domain |

### 13.2 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.7 | 2025-12-22 | Coherence and Determinism section. Variant Resolution in execution. Asset derivation chain formalized. |
| 1.6 | 2025-12-17 | Discovery is now interpretive (not rule-based). GENERATE execution is holistic (modules as knowledge). Added multi-domain operations. Added CONSUMER-PROMPT.md and AUTHOR-PROMPT.md. |
| 1.5 | 2025-12-16 | Repository restructuring: 5 root folders (knowledge, model, skills, modules, runtime). Flows moved to runtime/flows/. |
| 1.4 | 2025-12-12 | Domains as first-class entities. Module naming with domain prefix. |
| 1.3 | 2025-12-01 | Initial GitHub release |

### 13.3 Key Changes in v1.7

**Coherence:**
- Formal derivation chain: ADR → ERI → Module → Skill
- `derived_from` is now MANDATORY for all modules
- Module variants MUST derive from ERI `implementation_options`
- Two types of ERI options: EQUIVALENT (→ variants) and DISPARATE (→ separate modules)

**Determinism:**
- New `DETERMINISM-RULES.md` document with global patterns
- Mandatory patterns: record IDs, record DTOs, simple enums, @Component mappers
- Module-specific determinism sections
- Generated code annotations for traceability

**Execution:**
- STEP 3.5 RESOLVE VARIANTS added to GENERATE and ADD flows
- Variant selection recorded in manifest
- Auto-suggest mode for alternatives based on conditions

### 13.4 Previous Changes (v1.6)

**Discovery:**
- Removed deterministic rules (IF keyword THEN domain)
- Discovery is semantic interpretation by the LLM
- Agent reads DOMAIN.md and OVERVIEW.md to understand options
- Ambiguity triggers clarification, not guessing

**Execution:**
- GENERATE skills are holistic: modules consulted as knowledge, output generated in one pass
- ADD skills remain atomic: specific module transformation
- Validation remains sequential and deterministic
- Tier-3 runs for ALL modules consulted during generation

**Multi-Domain:**
- Agent can decompose requests into domain chains
- Flows are atomic within domain
- Orchestration is agent responsibility

---

**END OF DOCUMENT**

For the complete agent context specification, see `CONSUMER-PROMPT.md`.
