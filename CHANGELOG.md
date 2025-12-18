# Changelog

All notable changes to Enablement 2.0 will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

### [2.2.0] - Planned
- Code Generation PoC results
- Complete stub flows (REMOVE, REFACTOR, MIGRATE)

### [3.0.0] - Future
- MCP Server integration
- Multi-agent architecture
