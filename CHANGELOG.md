# Changelog

All notable changes to Enablement 2.0 will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.4.1] - 2025-12-22

### 📚 Documentation Update

Updated supporting documentation to reflect v2.4.0 changes.

#### Changed

**Master Documents**
- `ENABLEMENT-MODEL-v1.6.md` → `ENABLEMENT-MODEL-v1.7.md`
  - New §10: Coherence and Determinism
  - Asset derivation chain formalized
  - Variant Resolution process documented
  - Coherence and Determinism added to Core Principles

**Support Documents**
- `model/README.md` v5.1 → v5.2: Updated versions, added DETERMINISM-RULES
- `model/standards/authoring/README.md` v2.2 → v2.3: Coherence rules, updated versions
- `model/AUTHOR-PROMPT.md` v1.0 → v1.1: Added coherence rules, determinism patterns
- `_sidebar.md`: Added Determinism Rules link, updated to v1.7

---

## [2.4.0] - 2025-12-22

### 🎯 Determinism & Model Coherence

Major update ensuring deterministic code generation and full model coherence between ERIs and Modules.

#### Added

**New Documents**
- `model/standards/DETERMINISM-RULES.md` - Global mandatory patterns for consistent code generation

**Implementation Options in ERIs**
- ERI-010 (Timeout): `client-timeout` (default), `annotation-async`
- ERI-012 (Persistence): `jpa`, `systemapi` (DISPARATE → separate modules)
- ERI-013 (API Integration): `restclient` (default), `feign`, `resttemplate` (deprecated)

**Module Variants**
- mod-code-003: `client-timeout` (default), `annotation-async`
- mod-code-018: `restclient` (default), `feign`, `resttemplate`

#### Changed

**Authoring Guides**
- `ERI.md` v1.1 → v1.2: Formal `implementation_options` structure with default and `recommended_when`
- `MODULE.md` v1.7 → v1.8: `derived_from` now REQUIRED, variant derivation from ERI
- `FLOW.md` v1.0 → v1.1: Required Variant Resolution Step for flows using modules
- `SKILL.md` v2.5 → v2.6: Variant Handling in Module Resolution section

**Execution Flows**
- `GENERATE.md` v2.0 → v2.1: Added STEP 3.5 RESOLVE VARIANTS
- `ADD.md` v1.0 → v1.1: Added STEP 3.5 RESOLVE VARIANT

**Consumer Behavior**
- `CONSUMER-PROMPT.md` v1.3 → v1.4: Variant Selection Behavior, Determinism Rules

**Modules (added YAML frontmatter with `derived_from`)**
- mod-code-001 → eri-code-008 (circuit-breaker)
- mod-code-015 → eri-code-001 (hexagonal-base)
- mod-code-019 → eri-code-014 (api-public-exposure)
- mod-code-020 → eri-code-015 (compensation)

**Module Templates Updated**
- mod-code-003: New `client/` templates for client-level timeout
- mod-code-015: `EntityId` now `record(UUID)`, simplified enums, Response variants
- mod-code-017: DTOs as `record`, code mapping in Mapper
- mod-code-018: Formalized variant structure in frontmatter

**Skills**
- skill-020 v1.2.0 → v1.3.0: Resilience annotations now mandatory (not just comments)
- skill-021 v2.0.0 → v2.1.0: mod-020 compensation is opt-in (`features.compensation.enabled`)

**Discovery**
- `skill-index.yaml` v2.0 → v2.1: Input validation rules, formalized discovery process

#### Coherence Rules Established

```
ADR (decision)
  ↓
ERI (reference implementation)
  • Defines implementation_options (if multiple)
  • Sets default and recommended_when
  • Indicates EQUIVALENT (→ 1 module with variants) or DISPARATE (→ N modules)
  ↓
MODULE (executable templates)
  • MUST have derived_from (REQUIRED)
  • Inherits variants from ERI (cannot invent new ones)
  • Formalizes for runtime
  ↓
SKILL (orchestration)
  • Resolves variants at execution time
```

#### Determinism Patterns

| Element | Pattern | Rationale |
|---------|---------|-----------|
| Entity IDs | `record(UUID)` | Type safety, immutability |
| DTOs | `record` | Immutability, no Lombok |
| Enums | Simple (no attributes) | Code mapping in Mapper |
| Mappers | `@Component` with switch | Single responsibility |
| Annotations | `@generated`, `@module` | Traceability |

---

## [2.3.0] - 2025-12-19

### 🚀 Scalable Discovery

Major restructuring for scalable skill discovery supporting 200+ skills.

#### Added

**New Files**
- `runtime/discovery/skill-index.yaml` - Pre-computed index for efficient skill discovery
- `skills/code/README.md` - CODE domain skills overview with layer explanation
- `model/standards/ASSET-STANDARDS-v1.4.md` - Updated asset standards

**Layer Taxonomy (CODE Domain)**

| Layer | Name | Technologies |
|-------|------|--------------|
| `soe` | System of Engagement | Angular, React, Vue |
| `soi` | System of Integration | Java Spring, Node.js |
| `sor` | System of Record | COBOL, CICS, DB2 |

#### Changed

**Skill Structure**
- Skills now organized: `skills/{domain}/{layer}/skill-{NNN}-{name}/`
- Naming simplified: domain and layer implicit in path
- Existing skills migrated to `skills/code/soi/`

**Updated Documents**
- `discovery-guidance.md` v3.0 - Layer-based discovery process
- `CONSUMER-PROMPT.md` v1.3 - Layer identification step added
- `authoring/SKILL.md` v2.4 - Hierarchical structure, index registration

**Migrated Skills**

| Before | After |
|--------|-------|
| `skills/skill-code-001-add-circuit-breaker-*` | `skills/code/soi/skill-001-circuit-breaker-*` |
| `skills/skill-code-020-generate-microservice-*` | `skills/code/soi/skill-020-microservice-*` |

#### Discovery Optimization

```
Before: Agent reads ALL skill OVERVIEW.md files (O(n))
After:  Agent queries skill-index.yaml by layer, then reads filtered candidates only
```

With 200 skills across 3 layers, this reduces candidates from 200 to ~60-70 per layer.

---

## [2.2.1] - 2025-12-18

### 🎭 Two-Role Model

Formalized separation of Consumer and Author interaction roles.

#### Added

**New Documents**
- `model/AUTHOR-PROMPT.md` - System prompt for C4E authoring sessions
- `model/standards/authoring/FLOW.md` - Authoring guide for execution flows

#### Changed

**Renamed**
- `model/SYSTEM-PROMPT.md` → `model/CONSUMER-PROMPT.md` (consistent nomenclature)

**Updated**
- `model/README.md` v5.1 - Documents two-role model
- `model/standards/authoring/README.md` v2.2 - Added FLOW.md
- `_sidebar.md` - Updated navigation with new prompts
- All references to SYSTEM-PROMPT.md updated

#### Two Roles

| Role | Prompt | Purpose |
|------|--------|---------|
| CONSUMER | `CONSUMER-PROMPT.md` | Use skills to produce SDLC outputs |
| AUTHOR | `AUTHOR-PROMPT.md` | Create/evolve model and knowledge assets |

---

## [2.2.0] - 2025-12-17

### 🧠 Model Philosophy Revision

Major revision of discovery and execution philosophy.

#### Added

**New Documents**
- `model/CONSUMER-PROMPT.md` - Consumer agent system prompt (was SYSTEM-PROMPT.md)
- `runtime/discovery/discovery-guidance.md` - Interpretive discovery guidance

#### Changed

**Discovery Philosophy**
- Discovery is now INTERPRETIVE, not rule-based
- Domain identification based on semantic analysis, not keywords
- Skill selection through OVERVIEW.md matching, not IF/THEN rules
- Added multi-domain operation support
- Added out-of-scope detection

**Execution Model**
- GENERATE skills now use HOLISTIC execution
- Modules are KNOWLEDGE to consult, not steps to execute
- All features generated together in one pass
- Validation remains sequential (Tier-1, Tier-2, Tier-3 per module)
- Clear distinction: GENERATE (holistic) vs ADD (atomic)

**Updated Documents**
- ENABLEMENT-MODEL v1.5 → v1.6 (major philosophy changes)
- GENERATE.md v1.0 → v2.0 (holistic execution)
- discovery-rules.md → discovery-guidance.md (interpretive)

#### Key Concepts in v1.6

| Concept | v1.5 | v1.6 |
|---------|------|------|
| Discovery | Rule-based (IF keyword THEN domain) | Interpretive (semantic analysis) |
| Module execution | Sequential (process each in order) | Holistic (consult all, generate once) |
| Multi-domain | Not addressed | Explicit support with decomposition |
| Out-of-scope | Not addressed | Explicit detection and handling |

---

## [2.1.0] - 2025-12-16

### 🏗️ Major Restructuring

Complete repository reorganization for clarity and coherence.

#### Changed

**New Repository Structure**
```
enablement-2.0/
├── knowledge/      # Pure knowledge (ADRs, ERIs only)
├── model/          # Meta-model (standards, domains, authoring)
├── skills/         # Executable skills
├── modules/        # Reusable templates
└── runtime/        # Discovery, flows, validators
```

**Key Moves**
| Before | After |
|--------|-------|
| `knowledge/model/` | `model/` |
| `knowledge/skills/` | `skills/` |
| `knowledge/skills/modules/` | `modules/` |
| `knowledge/validators/` | `runtime/validators/` |
| `knowledge/orchestration/` | `runtime/discovery/` |
| `knowledge/domains/.../skill-types/` | `runtime/flows/` |

**Model Updates**
- ENABLEMENT-MODEL upgraded to v1.5
- Clear separation of concerns documented
- Execution flow diagram added

#### Removed
- `knowledge/patterns/` - Not actively used
- `knowledge/concerns/` - Simplified for now
- `skills/*/README.md` - Redundant with SKILL.md + OVERVIEW.md

#### Technical Details

| Metric | Value |
|--------|-------|
| ERIs | 7 |
| Modules | 8 |
| ADRs | 5 |
| Skills | 2 |
| Flows | 5 (GENERATE, ADD, REMOVE, REFACTOR, MIGRATE) |

---

## [2.0.0] - 2025-12-12

### 🎯 Domain Model Formalization

#### Added
- Domain model v2.0 (CODE, DESIGN, QA, GOVERNANCE)
- Module naming with domain prefix: `mod-code-XXX-...`
- Skill-types centralized in domains
- Capabilities moved to domain level

#### Changed
- All modules renamed: `mod-001` → `mod-code-001`
- 100+ references updated
- ENABLEMENT-MODEL v1.3 → v1.4

---

## [1.0.0] - 2025-12-01

### 🎉 Initial Release

First version of the Knowledge Base on GitHub. Corresponds to internal version v7.0.

#### Added

**Resilience Patterns (Complete)**
- ERI-CODE-008: Circuit Breaker (Resilience4j)
- ERI-CODE-009: Retry Pattern (Resilience4j)
- ERI-CODE-010: Timeout Pattern (Resilience4j)
- ERI-CODE-011: Rate Limiter (Resilience4j)
- mod-code-001 through mod-code-004: Templates for each pattern
- ADR-004: Resilience Patterns decision record

**Persistence Patterns (New)**
- ERI-CODE-012: Persistence Patterns (JPA + System API unified)
- mod-code-016: JPA persistence template
- mod-code-017: System API persistence template
- ADR-011: Persistence Patterns decision record

**API Integration**
- ERI-CODE-013: REST API Integration
- mod-code-018: REST integration template
- ADR-012: API Integration Patterns

**Hexagonal Architecture**
- ERI-CODE-001: Hexagonal Light (Java/Spring)
- mod-code-015: Hexagonal base template
- ADR-009: Service Architecture Patterns

**Skills**
- skill-code-001: Add Circuit Breaker to existing service
- skill-code-020: Generate Microservice

**Model & Standards**
- ENABLEMENT-MODEL v1.2
- ASSET-STANDARDS v1.3
- Authoring guides
- 4-tier validation system

---

## Version History (Pre-GitHub)

| Internal | Description | Date |
|----------|-------------|------|
| v7.0 | Resilience complete + Persistence patterns | 2025-12-01 |
| v6.0 | ERI machine-readable annex mandatory | 2025-11-28 |
| v5.0 | Validator restructure, domain prefixes | 2025-11-27 |

---

## Upcoming

### [2.5.0] - Planned
- PoC v3.2 validation with determinism rules
- Complete stub flows (REMOVE, REFACTOR, MIGRATE)

### [3.0.0] - Future
- MCP Server integration
- Multi-agent architecture
