# ENABLEMENT-MODEL.md

**Version:** 1.3  
**Date:** 2025-12-12  
**Status:** Active  
**Purpose:** Master document defining the complete Enablement 2.0 model

> **This is the MASTER document.** For detailed operational standards, see:
> - `standards/ASSET-STANDARDS-v1.3.md` - Technical structure for each asset type
> - `standards/validation/README.md` - Validation system architecture
> - `standards/traceability/README.md` - Traceability model and profiles

---

## Table of Contents

1. [Overview](#1-overview)
2. [Asset Hierarchy](#2-asset-hierarchy)
3. [Capability Hierarchy](#3-capability-hierarchy)
4. [Skill Domains and Types](#4-skill-domains-and-types)
5. [Validation System](#5-validation-system)
6. [Traceability](#6-traceability)
7. [Orchestration Layer](#7-orchestration-layer) ← NEW
8. [Workflows](#8-workflows)
9. [Asset Creation](#9-asset-creation)
10. [Knowledge Base Structure](#10-knowledge-base-structure)
11. [Appendices](#11-appendices)

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
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  CAPABILITY LAYER                                                        │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Capabilities ──> Features ──> Components ──> Modules           │    │
│  │  (What)          (Group)      (Abstract)     (Concrete)         │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  ORCHESTRATION LAYER (NEW)                                               │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Discovery ──> Skill Selection ──> Execution Flow ──> Audit     │    │
│  │  (Rules)       (Matching)         (Deterministic)    (Trace)    │    │
│  │  See: knowledge/orchestration/                                   │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  EXECUTION LAYER (Swarms)                                                │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  DESIGN ─────> CODE ─────> QA ─────> GOVERNANCE                 │    │
│  │  (Architect)   (Implement) (Validate) (Comply)                  │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  VALIDATION LAYER                                                        │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Tier 1 ──> Tier 2 ──> Tier 3 ──> Tier 4                        │    │
│  │  (Universal) (Technology) (Module) (Runtime)                    │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 1.4 Asset Creation Flow

**ADRs and ERIs are the entry points** for the Enablement system. All automation (Modules and Skills) derives from these foundational documents.

```
┌─────────────────────────────────────────────────────────────────────┐
│                    ASSET CREATION FLOW                               │
│                    (Sequential, not parallel)                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  STEP 1: ADR (Entry Point - Strategic)                               │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  Human architects define strategic decisions                 │    │
│  │  Framework-agnostic principles and patterns                  │    │
│  │  Example: "Services MUST implement circuit breaker pattern"  │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                              ▼                                       │
│  STEP 2: ERI (Entry Point - Tactical)                                │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  Human engineers define reference implementation             │    │
│  │  Technology-specific, with machine-readable constraints      │    │
│  │  Example: "Use Resilience4j with these configurations..."    │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                              ▼                                       │
│  STEP 3: Module (Derived - Template)                                 │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  Created FROM ERI constraints and examples                   │    │
│  │  Contains code templates + validation scripts                │    │
│  │  MUST be created BEFORE Skills that use it                   │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                              ▼                                       │
│  STEP 4: Skill (Derived - Automation)                                │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  Created AFTER Modules it will use                           │    │
│  │  Orchestrates modules and validations                        │    │
│  │  Generates code with full traceability                       │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Key Rules:**
1. **ADRs/ERIs are INPUT** - Created by humans, consumed by automation
2. **Modules before Skills** - A Skill cannot exist without its Modules
3. **SKILL-MODULE relationship is MANDATORY** - Every Skill has at least one Module
4. **Traceability is mandatory** - Every Skill traces back to ADR through ERI and Module

---

## 2. Asset Hierarchy

### 2.1 Asset Definitions

| Asset | Level | Purpose | Audience |
|-------|-------|---------|----------|
| **ADR** | Strategic | Framework-agnostic architectural decisions | Humans + AI |
| **ERI** | Tactical | Opinionated reference implementation for specific technology | Humans + AI |
| **Module** | Template | Reusable content templates with integrated validations | AI (Skills) |
| **Skill** | Operational | Automated executable capability | AI (Orchestrator) |
| **Validator** | Quality | Reusable artifact validation components | AI (Skills) |

### 2.2 Multi-Domain Applicability

The asset model applies to ALL domains, not just CODE. Here are concrete examples:

| Asset | CODE | DESIGN | QA | GOV |
|-------|------|--------|-----|-----|
| **ADR** | Technical decisions (hexagonal, circuit-breaker) | Methodological decisions (C4, ADR-as-practice) | Quality decisions (min coverage, SAST mandatory) | Compliance decisions (retention, audit trails) |
| **ERI** | Implementation in Java/Spring | Implementation in PlantUML/Mermaid | Implementation in SonarQube/OWASP | Implementation in audit tools |
| **Module** | Reusable code templates | Document templates | Report templates | Evidence templates |
| **Skill** | Orchestrates code generation/transformation | Orchestrates design/documentation | Orchestrates analysis/audit | Orchestrates reporting/verification |
| **Capability** | Technical feature grouping (resilience, observability) | Methodology grouping (architecture-documentation) | Check grouping (security-analysis) | Compliance grouping (audit-trail) |

**Domain-Specific Examples:**

| Domain | ADR | ERI | Module | Skill |
|--------|-----|-----|--------|-------|
| **CODE** | ADR-004: Circuit Breaker Pattern | eri-code-008-circuit-breaker-java-resilience4j | mod-001-circuit-breaker-java-resilience4j | skill-code-001-add-circuit-breaker-java-resilience4j |
| **DESIGN** | ADR-012: C4 for Architecture Docs | eri-design-001-c4-plantuml | mod-design-001-c4-plantuml | skill-design-001-generate-c4-diagrams |
| **QA** | ADR-015: Minimum Coverage Policy | eri-qa-001-coverage-jacoco | mod-qa-001-coverage-report | skill-qa-001-analyze-code-coverage |
| **GOV** | ADR-020: Audit Trail Requirements | eri-gov-001-audit-enablement | mod-gov-001-compliance-report | skill-gov-001-generate-compliance-report |

### 2.3 Asset Relationships

```
ADR (1) ────────────────────────────────────────────────────────────────
  │                                                                      
  │ implements (1:N)                                                     
  │ One ADR can have multiple ERIs for different technologies           
  │                                                                      
  ▼                                                                      
ERI (N) ────────────────────────────────────────────────────────────────
  │                                                                      
  │ abstracts to (1:N)                                                   
  │ One ERI can have multiple Modules (normal: 1:1, complex: 1:N)        
  │                                                                      
  ▼                                                                      
Module (N) ─────────────────────────────────────────────────────────────
  │                                                                      
  │ used by (N:N)                                                        
  │ One Skill can use multiple Modules                                   
  │ One Module can be used by multiple Skills                            
  │                                                                      
  ▼                                                                      
Skill (N) ──────────────────────────────────────────────────────────────
  │
  │ orchestrates (N:N)
  │ Skills run Validators to verify outputs
  │
  ▼
Validator (N) ──────────────────────────────────────────────────────────
```

### 2.4 Relationship Examples

```
ADR-004: Resilience Patterns (Framework Agnostic)
├── ERI-008: Circuit Breaker with Resilience4j (Java/Spring)
│   └── mod-001-circuit-breaker-java-resilience4j
│       ├── skill-code-001-add-circuit-breaker-java-resilience4j
│       └── skill-code-020-generate-microservice-java-spring (uses this module)
│
├── ERI-009: Retry with Resilience4j (Java/Spring)
│   └── mod-002-retry-java-resilience4j
│       └── skill-code-002-add-retry-java-resilience4j
│
└── ERI-010: Circuit Breaker with Opossum (NodeJS)
    └── mod-020-circuit-breaker-nodejs-opossum
        └── skill-code-040-add-circuit-breaker-nodejs-opossum

ADR-009: Service Architecture Patterns (Framework Agnostic)
└── ERI-001: Hexagonal Light with Spring (Java/Spring)
    └── mod-015-hexagonal-base-java-spring
        └── skill-code-020-generate-microservice-java-spring (uses this module)
```

### 2.4 ADR: Architectural Decision Record

**Purpose:** Document strategic architectural decisions, framework-agnostic.

**Characteristics:**
- Framework-agnostic (does not mention specific technologies)
- Defines "what" and "why", not "how"
- Serves as reference for humans and as constraint for automation
- Can have multiple ERIs that implement it

**Structure:**

```
adr-XXX-{topic}/
└── ADR.md
```

**Required Sections:**
- Context
- Decision
- Rationale
- Consequences (Positive, Negative, Mitigations)
- Implementation Guidelines
- Compliance Criteria

### 2.5 ERI: Enterprise Reference Implementation

**Purpose:** Opinionated reference implementation for a specific technology.

**Characteristics:**
- Framework-specific (Java/Spring, NodeJS, etc.)
- Defines the concrete "how"
- Includes functional example code
- Serves both humans AND for generating Modules/Skills
- **MUST include machine-readable annex with constraints**

**Structure:**

```
eri-{domain}-XXX-{pattern}-{framework}-{library}/
└── ERI.md
```

**Required Sections:**
- Overview
- Implementation Details
- Code Examples
- Configuration
- Testing Guidelines
- **Annex: Implementation Constraints (YAML)** ← MANDATORY

**Machine-Readable Annex Example:**

The ERI document must include an annex section at the end with the following structure:

> **Annex: Implementation Constraints**
>
> This annex defines rules that MUST be respected when creating Modules or Skills
> based on this ERI. Compliance is mandatory.

```yaml
eri_constraints:
  id: eri-code-008-circuit-breaker-resilience4j
  version: 1.0
  adr_reference: adr-004
  
  structural_constraints:
    - id: annotation-placement
      rule: "@CircuitBreaker annotation MUST be in application layer only"
      validation: "grep -r '@CircuitBreaker' domain/ returns empty"
      severity: ERROR
      
    - id: fallback-required
      rule: "Every @CircuitBreaker MUST define fallbackMethod"
      validation: "all @CircuitBreaker annotations include fallbackMethod"
      severity: ERROR
      
    - id: fallback-signature
      rule: "Fallback method MUST have Throwable as last parameter"
      validation: "fallback methods signature includes Throwable parameter"
      severity: ERROR
      
  configuration_constraints:
    - id: actuator-metrics
      rule: "Circuit breaker metrics MUST be exposed via actuator"
      validation: "application.yml includes circuitbreakers in management.endpoints"
      severity: WARNING
      
    - id: failure-rate-threshold
      rule: "Failure rate threshold SHOULD be between 25-75%"
      validation: "failureRateThreshold >= 25 AND <= 75"
      severity: WARNING
      
  dependency_constraints:
    required:
      - groupId: io.github.resilience4j
        artifactId: resilience4j-spring-boot3
        minVersion: "2.0.0"
      - groupId: org.springframework.boot
        artifactId: spring-boot-starter-aop
        reason: "Required for @CircuitBreaker annotation processing"
        
  testing_constraints:
    - id: unit-test-coverage
      rule: "Circuit breaker behavior MUST have unit tests"
      validation: "test class exists for service with @CircuitBreaker"
      severity: WARNING
```

### 2.6 Module

**Purpose:** Reusable code template with integrated validations.

**Characteristics:**
- Derives from an ERI (general rule, exceptions documented)
- Contains code templates with variables
- Includes pattern/feature-specific validations
- Used by Skills to generate code

**Structure:**

```
mod-XXX-{pattern}-{framework}-{library}/
├── MODULE.md
└── validation/
    ├── README.md
    └── {feature}-check.sh
```

**MODULE.md Content:**
- Template Variables
- Code Templates (with {{variables}})
- Usage Instructions
- Validation Reference

### 2.7 Skill

**Purpose:** Automated capability that executes a specific SDLC action.

**Characteristics:**
- Belongs to a Domain (DESIGN, CODE, QA, GOVERNANCE)
- Has a specific Type within the domain
- Uses one or more Modules
- **ONLY ORCHESTRATES validations, does not define them**
- Generates outputs with complete traceability

**Structure:**

```
skill-XXX-{action}-{target}-{framework}-{library}/
├── SKILL.md
├── OVERVIEW.md
├── README.md
└── validation/
    ├── README.md
    └── validate.sh      # Only orchestrates the 4 tiers
```

---

## 3. Capability Hierarchy

### 3.1 Level Definitions

```
CAPABILITY (High level - What I want to achieve)
└── FEATURE (Functional grouping - How I group it)
    └── COMPONENT (Abstraction - What pattern/technique)
        └── MODULE(s) (Concrete implementation - 1:N)
```

| Level | Definition | Example |
|-------|------------|---------|
| **Capability** | High-level business/technical objective | Resilience, Persistence, Security |
| **Feature** | Functional grouping within capability | Fault Tolerance, Recovery, Data Access |
| **Component** | Specific pattern or technique (abstract) | Circuit Breaker, Saga, JPA Repository |
| **Module** | Concrete implementation of component | mod-001-circuit-breaker-java-resilience4j |

### 3.2 Cardinality

```
Capability (1) ──> Feature (N)
Feature (1) ──> Component (N)
Component (1) ──> Module (1..N)  # Normally 1:1, but can be 1:N for complex patterns
```

### 3.3 Complete Example

```yaml
capability: Resilience
  description: "Patterns to build fault-tolerant systems"
  
  features:
    - name: Fault Tolerance
      description: "Prevent cascade failures"
      components:
        - name: Circuit Breaker
          modules: [mod-001-circuit-breaker-java-resilience4j]
          combinable: true
          dependencies: []
          
        - name: Retry
          modules: [mod-002-retry-java-resilience4j]
          combinable: true
          dependencies: [circuit-breaker]  # Recommended
          
        - name: Bulkhead
          modules: [mod-004-bulkhead-java-resilience4j]
          combinable: true
          dependencies: []
          
        - name: Timeout
          modules: [mod-005-timeout-java-resilience4j]
          combinable: true
          dependencies: []
          
    - name: Recovery
      description: "Graceful degradation and recovery"
      components:
        - name: Fallback
          modules: [mod-006-fallback-java-resilience4j]
          combinable: true
          dependencies: [circuit-breaker]  # Required
          
        - name: Saga
          modules: 
            - mod-003-saga-orchestrator-java-spring
            - mod-007-saga-participant-java-spring
          combinable: false  # Alternative pattern
          dependencies: []
          note: "Requires both modules together"

capability: Persistence
  description: "Data storage and access patterns"
  
  features:
    - name: Data Access
      description: "Patterns for accessing data"
      components:
        - name: JPA Repository
          modules: [mod-010-jpa-repository-java-spring]
          combinable: false  # Alternative
          alternatives: [sor-api-client]
          
        - name: SoR API Client
          modules: [mod-011-sor-client-java-spring]
          combinable: false  # Alternative
          alternatives: [jpa-repository]
          
    - name: Caching
      description: "Caching strategies"
      components:
        - name: Redis Cache
          modules: [mod-012-redis-cache-java-spring]
          combinable: true
          
        - name: In-Memory Cache
          modules: [mod-013-inmemory-cache-java-spring]
          combinable: true
```

### 3.4 Combinable vs Alternative

| Type | Description | Example |
|------|-------------|---------|
| **Combinable: true** | Can be used together with other components | Circuit Breaker + Retry + Timeout |
| **Combinable: false** | Exclusive alternative, choose one | JPA Repository XOR SoR API Client |

### 3.5 Dependencies

| Type | Description | Example |
|------|-------------|---------|
| **Required** | MUST be present | Fallback requires Circuit Breaker |
| **Recommended** | SHOULD be present | Retry recommended with Circuit Breaker |
| **None** | No dependencies | Bulkhead |

---

## 4. Skill Domains and Types

### 4.1 Skill Domains (Aligned with Swarms)

Skill Domains correspond to SDLC phases and align with platform Swarms:

```
┌─────────────────────────────────────────────────────────────────────┐
│                        SKILL DOMAINS                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────────┐  │
│  │  DESIGN  │───>│   CODE   │───>│    QA    │───>│  GOVERNANCE  │  │
│  │  Swarm   │    │  Swarm   │    │  Swarm   │    │    Swarm     │  │
│  └──────────┘    └──────────┘    └──────────┘    └──────────────┘  │
│       │              │               │                  │           │
│       ▼              ▼               ▼                  ▼           │
│  Architecture    Generate        Analyze          Documentation    │
│  Transform       Add             Validate         Compliance       │
│  Documentation   Remove          Audit            Policy           │
│                  Refactor                                          │
│                  Migrate                                           │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 4.2 DESIGN Domain

**Purpose:** Architectural design and system transformation.

| Type | Purpose | Input | Output |
|------|---------|-------|--------|
| **ARCHITECTURE** | Design new architecture (greenfield) | Requirements, constraints | Architecture design, diagrams |
| **TRANSFORM** | Transform existing architecture (brownfield) | Existing code + target architecture | Transformation plan, work items |
| **DOCUMENTATION** | Generate design documentation | Code/requirements | ADR drafts, diagrams |

**Examples:**

```
DESIGN/ARCHITECTURE:
├── skill-design-001-architecture-microservice
├── skill-design-002-architecture-api-contract
└── skill-design-003-architecture-data-model

DESIGN/TRANSFORM:
├── skill-design-040-transform-monolith-to-microservices
├── skill-design-041-transform-layered-to-hexagonal
└── skill-design-042-transform-sync-to-event-driven

DESIGN/DOCUMENTATION:
├── skill-design-080-documentation-adr-draft
├── skill-design-081-documentation-architecture-diagram
└── skill-design-082-documentation-sequence-diagram
```

**TRANSFORM vs ARCHITECTURE:**

| Aspect | ARCHITECTURE | TRANSFORM |
|--------|--------------|-----------|
| Input | Requirements (greenfield) | Existing code (brownfield) |
| Analysis | Requirements analysis | Code analysis + requirements |
| Output | New architecture design | Transformation plan |
| Scope | Single domain | Multi-domain (may require CODE skills) |

### 4.3 CODE Domain

**Purpose:** Code generation, modification, and migration.

| Type | Purpose | Input | Output |
|------|---------|-------|--------|
| **GENERATE** | Create new code from scratch | Requirements JSON | New project/code |
| **ADD** | Add specific feature (directed) | Existing code + feature | Modified code |
| **REMOVE** | Remove feature/code | Existing code + target | Modified code |
| **REFACTOR** | Improve without changing behavior | Existing code | Improved code |
| **MIGRATE** | Transform version/framework (technical) | Existing code + target version | Migrated code |

**Examples:**

```
CODE/GENERATE:
├── skill-code-020-generate-microservice-java-spring
├── skill-code-021-generate-rest-api-java-spring
├── skill-code-022-generate-event-consumer-java-kafka
└── skill-code-023-generate-library-java-maven

CODE/ADD:
├── skill-code-001-add-circuit-breaker-java-resilience4j
├── skill-code-002-add-retry-java-resilience4j
├── skill-code-003-add-caching-java-redis
└── skill-code-004-add-logging-java-slf4j

CODE/REMOVE:
├── skill-code-040-remove-deprecated-endpoints
├── skill-code-041-remove-unused-dependencies

CODE/REFACTOR:
├── skill-code-060-refactor-extract-service
├── skill-code-061-refactor-apply-clean-code
└── skill-code-062-refactor-optimize-queries

CODE/MIGRATE:
├── skill-code-080-migrate-spring-boot-2-to-3
├── skill-code-081-migrate-junit4-to-5
├── skill-code-082-migrate-java-8-to-17
└── skill-code-083-migrate-javax-to-jakarta
```

### 4.4 QA Domain

**Purpose:** Code analysis, validation, and audit.

| Type | Purpose | Input | Output |
|------|---------|-------|--------|
| **ANALYZE** | Analyze code to detect issues | Existing code | Analysis report |
| **VALIDATE** | Verify compliance with standards | Existing code + standards | Validation report |
| **AUDIT** | Generate audit reports | Existing code | Audit report |

**Examples:**

```
QA/ANALYZE:
├── skill-qa-001-analyze-architecture-compliance
├── skill-qa-002-analyze-security-vulnerabilities
├── skill-qa-003-analyze-performance-bottlenecks
└── skill-qa-004-analyze-code-quality

QA/VALIDATE:
├── skill-qa-040-validate-adr-compliance
├── skill-qa-041-validate-coding-standards
├── skill-qa-042-validate-api-contract
└── skill-qa-043-validate-test-coverage

QA/AUDIT:
├── skill-qa-080-audit-dependencies
├── skill-qa-081-audit-technical-debt
├── skill-qa-082-audit-security-posture
└── skill-qa-083-audit-license-compliance
```

### 4.5 GOVERNANCE Domain

**Purpose:** Documentation, compliance, and policies.

| Type | Purpose | Input | Output |
|------|---------|-------|--------|
| **DOCUMENTATION** | Generate documentation | Code/data | Documentation |
| **COMPLIANCE** | Verify and apply policies | Code + policies | Compliance report |
| **POLICY** | Manage policies | Policy definitions | Applied policies |

**Examples:**

```
GOVERNANCE/DOCUMENTATION:
├── skill-gov-001-documentation-api
├── skill-gov-002-documentation-changelog
├── skill-gov-003-documentation-release-notes
└── skill-gov-004-documentation-runbook

GOVERNANCE/COMPLIANCE:
├── skill-gov-040-compliance-license
├── skill-gov-041-compliance-security-policies
└── skill-gov-042-compliance-data-governance

GOVERNANCE/POLICY:
├── skill-gov-080-policy-branch-protection
├── skill-gov-081-policy-code-owners
└── skill-gov-082-policy-pr-enforcement
```

### 4.6 Skill Naming Convention

```
skill-{domain}-{NNN}-{type}-{target}-{framework}-{library}

Where:
- {domain}: Skill domain (lowercase)
  - code    → CODE domain skills
  - design  → DESIGN domain skills
  - qa      → QA domain skills
  - gov     → GOVERNANCE domain skills
  
- {NNN}: Sequential number WITHIN the domain (001-999)
  - Each domain has its own counter starting at 001
  - No risk of overlap between domains
  
- {type}: Skill type (generate, add, remove, analyze, etc.)
- {target}: What is generated/modified (microservice, circuit-breaker, etc.)
- {framework}: Main framework (java-spring, nodejs-express, etc.)
- {library}: Specific library if applicable (resilience4j, opossum, etc.)
```

**Examples:**

```
CODE Domain:
├── skill-code-001-add-circuit-breaker-java-resilience4j
├── skill-code-002-add-retry-java-resilience4j
├── skill-code-020-generate-microservice-java-spring
├── skill-code-030-remove-deprecated-endpoints
├── skill-code-040-refactor-extract-service
└── skill-code-050-migrate-spring-boot-2-to-3

DESIGN Domain:
├── skill-design-001-architecture-microservice
├── skill-design-010-transform-monolith-to-microservices
└── skill-design-020-generate-adr-draft

QA Domain:
├── skill-qa-001-analyze-architecture-compliance
├── skill-qa-010-validate-adr-compliance
└── skill-qa-020-audit-dependencies

GOVERNANCE Domain:
├── skill-gov-001-documentation-api
├── skill-gov-040-compliance-license
└── skill-gov-080-policy-branch-protection
```

**Note:** Module naming remains unchanged (`mod-XXX-{pattern}-{framework}-{library}`) as modules are domain-neutral and can be used by skills from any domain.

---

## 5. Validation System

### 5.1 4 Tier Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                    VALIDATION SYSTEM (4 Tiers)                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Tier 1: UNIVERSAL                                                   │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  Universal checks that apply to ALL outputs, ALL domains     │    │
│  │  Examples: Traceability metadata, .enablement/manifest.json  │    │
│  │  Location: validators/tier-1-universal/                      │    │
│  │  Execution: ALWAYS                                           │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                              ▼                                       │
│  Tier 2: TECHNOLOGY                                                  │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  Technology-specific checks                                  │    │
│  │  Examples: pom.xml valid, package.json valid, Dockerfile ok  │    │
│  │  Location: validators/tier-2-technology/{category}/          │    │
│  │  Execution: CONDITIONAL (if technology detected)             │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                              ▼                                       │
│  Tier 3: MODULE                                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  Content/feature-specific checks from modules                │    │
│  │  Examples: C4 structure ok, report format valid, CB config   │    │
│  │  Location: skills/modules/{module}/validation/               │    │
│  │  Execution: ALWAYS (every skill has at least one module)     │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                              ▼                                       │
│  Tier 4: RUNTIME (Future)                                            │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  Execution verification in CI/CD                             │    │
│  │  Examples: Integration tests pass, contract tests pass       │    │
│  │  Location: CI/CD pipeline                                    │    │
│  │  Execution: IN CI/CD ENVIRONMENT                             │    │
│  │  Status: ⏳ PENDING IMPLEMENTATION                           │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 5.2 Tier 1: Universal

**Purpose:** Universal validations that apply to ALL outputs, ALL domains.

**Location:** `knowledge/validators/tier-1-universal/`

**Execution:** ALWAYS

**Checks:**

| Check | Script | Description |
|-------|--------|-------------|
| Traceability | traceability-check.sh | .enablement/ exists, manifest.json valid |

**Additional for CODE domain:**

| Check | Script | Description |
|-------|--------|-------------|
| Project structure | project-structure-check.sh | src/main/java, src/test/java exist |
| Naming conventions | naming-conventions-check.sh | PascalCase classes, lowercase packages |

**Script Example:**

```bash
#!/bin/bash
# traceability/traceability-check.sh

PROJECT_DIR="$1"
ERRORS=0

if [[ ! -d "$PROJECT_DIR/.enablement" ]]; then
    echo "❌ ERROR: .enablement/ directory not found"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ PASS: .enablement/ exists"
fi

if [[ ! -f "$PROJECT_DIR/.enablement/manifest.json" ]]; then
    echo "❌ ERROR: manifest.json not found"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ PASS: manifest.json exists"
fi

exit $ERRORS
```

### 5.3 Tier 2: Technology

**Purpose:** Technology/framework-specific validations.

**Location:** `knowledge/validators/tier-2-technology/{category}/{stack}/`

**Execution:** CONDITIONAL (if technology is present)

**Supported Stacks:**

| Stack | Detection | Scripts |
|-------|-----------|---------|
| java-maven | pom.xml exists | compile-check.sh, test-check.sh |
| java-gradle | build.gradle exists | compile-check.sh, test-check.sh |
| spring-boot | spring-boot-starter in pom.xml | actuator-check.sh, application-yml-check.sh |
| nodejs-npm | package.json exists | npm-check.sh, lint-check.sh |
| docker | Dockerfile exists | dockerfile-check.sh |
| kubernetes | k8s/ directory exists | manifest-check.sh |

**Detection Example in Skill:**

```bash
# Detect and execute technology validations
if [[ -f "$PROJECT_DIR/pom.xml" ]]; then
    run_validation "java-maven" "$PROJECT_DIR"
    
    if grep -q "spring-boot-starter" "$PROJECT_DIR/pom.xml"; then
        run_validation "spring-boot" "$PROJECT_DIR"
    fi
fi

if [[ -f "$PROJECT_DIR/Dockerfile" ]]; then
    run_validation "docker" "$PROJECT_DIR"
fi
```

### 5.4 Tier 3: Module

**Purpose:** Content/feature-specific validations from modules.

**Location:** `knowledge/skills/modules/{module}/validation/`

**Execution:** ALWAYS (every Skill has at least one Module)

**Module Responsibility:**

Each Module is responsible for validating that ITS content is correctly generated according to the ERI it derives from. This applies to ALL domains:

| Domain | Module Example | Validates |
|--------|---------------|-----------|
| CODE | mod-001-circuit-breaker | @CircuitBreaker correct, fallback exists |
| CODE | mod-015-hexagonal | Layer separation, Spring-free domain |
| DESIGN | mod-design-001-c4-plantuml | C4 diagram structure, syntax |
| QA | mod-qa-001-coverage-report | Report format, metrics present |
| GOV | mod-gov-001-compliance-report | Compliance sections, evidence |

**Relationship with ERI Constraints:**

Module validation scripts MUST implement the constraints defined in the ERI annex:

```
ERI Constraint                    →    Module Validation Script
─────────────────────────────────────────────────────────────────
annotation-placement (ERROR)      →    Check @CircuitBreaker not in domain/
fallback-required (ERROR)         →    Check all @CircuitBreaker have fallback
actuator-metrics (WARNING)        →    Check application.yml config
```

### 5.5 Tier 4: Runtime (Future)

**Purpose:** Verify behavior at execution time.

**Status:** ⏳ PENDING IMPLEMENTATION

**Requirements:**
- CI/CD environment with application execution capability
- Configured integration tests
- Configured contract tests

**Future Scope:**

| Check | Description |
|-------|-------------|
| Integration tests | Tests that verify integration between components |
| Contract tests | Tests that verify API contracts |
| Smoke tests | Basic functionality tests |
| Performance baseline | Base performance metrics |

**Placeholder in Skills:**

```bash
# Tier 4: Runtime (future)
# TODO: Implement when CI/CD integration available
echo "⏭️  SKIP: Tier 4 Runtime - Not yet implemented"
# run_runtime_tests "$PROJECT_DIR"
```

### 5.6 Skill as Orchestrator

**Fundamental Principle:** Skills DO NOT define validations, they ONLY orchestrate them.

**validate.sh Structure in Skill:**

```bash
#!/bin/bash
# skill-XXX/validation/validate.sh
# Main validation orchestrator for skill-XXX
# This script orchestrates the three validation tiers.
# It does NOT define validations, only calls existing scripts.

set -e

PROJECT_DIR="$1"
PACKAGE_PATH="$2"  # Optional, for module validations

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KNOWLEDGE_BASE="$SCRIPT_DIR/../../../.."

TOTAL_ERRORS=0
TOTAL_WARNINGS=0

# ═══════════════════════════════════════════════════════════════════
# TIER 1 UNIVERSAL: TRACEABILITY (Always executed - all domains)
# ═══════════════════════════════════════════════════════════════════
echo "═══════════════════════════════════════════════════════════"
echo "TIER 1 UNIVERSAL: TRACEABILITY"
echo "═══════════════════════════════════════════════════════════"

bash "$KNOWLEDGE_BASE/validators/tier-1-universal/traceability/traceability-check.sh" "$PROJECT_DIR"
TOTAL_ERRORS=$((TOTAL_ERRORS + $?))

# ═══════════════════════════════════════════════════════════════════
# TIER 1 CODE: STRUCTURAL (Always executed - CODE domain only)
# ═══════════════════════════════════════════════════════════════════
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "TIER 1 CODE: STRUCTURAL VALIDATION"
echo "═══════════════════════════════════════════════════════════"

bash "$KNOWLEDGE_BASE/validators/tier-1-universal/code-projects/project-structure/project-structure-check.sh" "$PROJECT_DIR"
TOTAL_ERRORS=$((TOTAL_ERRORS + $?))

bash "$KNOWLEDGE_BASE/validators/tier-1-universal/code-projects/naming-conventions/naming-conventions-check.sh" "$PROJECT_DIR"
TOTAL_ERRORS=$((TOTAL_ERRORS + $?))

# ═══════════════════════════════════════════════════════════════════
# TIER 2: TECHNOLOGY (Conditional on detected technology)
# ═══════════════════════════════════════════════════════════════════
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "TIER 2: TECHNOLOGY VALIDATION"
echo "═══════════════════════════════════════════════════════════"

# Java/Spring
if [[ -f "$PROJECT_DIR/pom.xml" ]]; then
    echo "Detected: Java/Maven project"
    for script in "$KNOWLEDGE_BASE/validators/tier-2-technology/code-projects/java-spring/"*-check.sh; do
        bash "$script" "$PROJECT_DIR"
        TOTAL_ERRORS=$((TOTAL_ERRORS + $?))
    done
fi

# Docker
if [[ -f "$PROJECT_DIR/Dockerfile" ]]; then
    echo "Detected: Docker project"
    bash "$KNOWLEDGE_BASE/validators/tier-2-technology/deployments/docker/dockerfile-check.sh" "$PROJECT_DIR"
    TOTAL_ERRORS=$((TOTAL_ERRORS + $?))
fi

# ═══════════════════════════════════════════════════════════════════
# TIER 3: MODULE (Conditional on features/modules used)
# ═══════════════════════════════════════════════════════════════════
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "TIER 3: MODULE VALIDATION"
echo "═══════════════════════════════════════════════════════════"

# Hexagonal Architecture (always for this skill)
bash "$KNOWLEDGE_BASE/skills/modules/mod-015-hexagonal-base-java-spring/validation/hexagonal-structure-check.sh" \
    "$PROJECT_DIR" "$PACKAGE_PATH"
TOTAL_ERRORS=$((TOTAL_ERRORS + $?))

# Circuit Breaker (if feature enabled)
if [[ "$FEATURE_CIRCUIT_BREAKER" == "true" ]] || grep -rq "@CircuitBreaker" "$PROJECT_DIR/src" 2>/dev/null; then
    echo "Detected: Circuit Breaker feature"
    bash "$KNOWLEDGE_BASE/skills/modules/mod-001-circuit-breaker-java-resilience4j/validation/circuit-breaker-check.sh" \
        "$PROJECT_DIR"
    TOTAL_ERRORS=$((TOTAL_ERRORS + $?))
fi

# ═══════════════════════════════════════════════════════════════════
# TIER 4: RUNTIME (Future - Not yet implemented)
# ═══════════════════════════════════════════════════════════════════
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "TIER 4: RUNTIME VALIDATION"
echo "═══════════════════════════════════════════════════════════"
echo "⏭️  SKIP: Tier 4 Runtime - Not yet implemented"

# ═══════════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════════
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "VALIDATION SUMMARY"
echo "═══════════════════════════════════════════════════════════"
echo "Total Errors: $TOTAL_ERRORS"
echo "Total Warnings: $TOTAL_WARNINGS"

if [[ $TOTAL_ERRORS -gt 0 ]]; then
    echo "❌ VALIDATION FAILED"
    exit 1
else
    echo "✅ VALIDATION PASSED"
    exit 0
fi
```

### 5.7 ADR/ERI Compliance Validation

**Important Clarification:** The 4-tier validation system validates **technical correctness**. ADR/ERI **compliance** is a separate concern handled by **QA Domain Skills**.

```
┌─────────────────────────────────────────────────────────────────────┐
│              VALIDATION vs COMPLIANCE                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  4-TIER VALIDATION (During Generation)                               │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  Tier 1: Infrastructure  → Files exist, structure correct    │    │
│  │  Tier 2: Stack           → Technology config valid           │    │
│  │  Tier 3: Module          → ERI constraints respected         │    │
│  │  Tier 4: Runtime         → Tests pass (future)               │    │
│  │                                                               │    │
│  │  Focus: TECHNICAL CORRECTNESS                                │    │
│  │  When: During skill execution                                │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  QA DOMAIN SKILLS (Post-Generation or On-Demand)                     │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  skill-qa-001-analyze-architecture-compliance                │    │
│  │  skill-qa-010-validate-adr-compliance                        │    │
│  │  skill-qa-011-validate-eri-compliance                        │    │
│  │                                                               │    │
│  │  Focus: ARCHITECTURAL COMPLIANCE                             │    │
│  │  When: After generation, during code review, on-demand       │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Why validate compliance if code is generated from ADR/ERI?**

1. **AI is non-deterministic** - LLMs can make mistakes even with correct input
2. **Code evolves** - Manual changes after generation may break compliance
3. **Safety net** - Double-checking ensures governance requirements are met
4. **Audit trail** - Compliance validation provides evidence for auditors

**What each validates:**

| Validation Type | What it checks | Example |
|-----------------|----------------|---------|
| **Tier 3 (Module)** | ERI technical constraints | `@CircuitBreaker` annotation is in application layer |
| **QA/ADR Compliance** | ADR architectural principles | Service implements resilience pattern as mandated |
| **QA/ERI Compliance** | ERI implementation guidelines | Fallback method follows ERI recommended signature |

---

## 6. Traceability

### 6.1 Traceability Levels

All code generated by Skills MUST include traceability at 4 levels:

| Level | Format | Purpose | Audience |
|-------|--------|---------|----------|
| 1. Machine-readable | manifest.json | Parseable by tools | Automation |
| 2. Human narrative | execution.log | Readable history | Developers |
| 3. Evidence | validation-evidence.md | Verifiable proofs | Auditors |
| 4. Reproducibility | validation/ scripts | Re-execution | Everyone |

### 6.2 .enablement/ Structure

Every generated project includes:

```
{project}/
└── .enablement/
    ├── manifest.json              # Level 1: Machine-readable
    ├── execution.log              # Level 2: Human narrative
    ├── validation-evidence.md     # Level 3: Evidence
    ├── validate-all.sh            # Level 4: Reproducibility
    ├── inputs/
    │   └── skill-input.json       # Original input
    └── validation/
        ├── infrastructure/        # Tier 1 scripts (copied)
        ├── stacks/                # Tier 2 scripts (copied)
        └── modules/               # Tier 3 scripts (copied)
```

### 6.3 manifest.json

```json
{
  "generation_id": "gen-20251126-091234",
  "timestamp": "2025-11-26T09:12:34Z",
  "orchestrator": "claude-sonnet-4",
  "knowledge_base_version": "3.0",
  
  "user_request": {
    "raw": "Generate Customer microservice with circuit breaker",
    "parsed_intent": {
      "action": "generate",
      "entity": "Customer",
      "features": ["circuit_breaker", "hexagonal_architecture"]
    }
  },
  
  "skill_execution": {
    "skill_id": "skill-code-020-generate-microservice-java-spring",
    "skill_type": "CODE/GENERATE",
    "domain": "CODE",
    "modules_used": [
      {
        "module_id": "mod-015-hexagonal-base-java-spring",
        "eri_reference": "eri-code-001-hexagonal-light-java-spring",
        "adr_reference": "adr-009-service-architecture-patterns"
      },
      {
        "module_id": "mod-001-circuit-breaker-java-resilience4j",
        "eri_reference": "eri-code-008-circuit-breaker-java-resilience4j",
        "adr_reference": "adr-004-resilience-patterns"
      }
    ]
  },
  
  "validation_results": {
    "tier1_infrastructure": {
      "status": "PASSED",
      "checks": 4,
      "passed": 4,
      "warnings": 0,
      "errors": 0
    },
    "tier2_stack": {
      "status": "PASSED",
      "stacks_validated": ["java-maven", "spring-boot", "docker"],
      "checks": 15,
      "passed": 14,
      "warnings": 1,
      "errors": 0
    },
    "tier3_module": {
      "status": "PASSED",
      "modules_validated": ["hexagonal", "circuit-breaker"],
      "checks": 22,
      "passed": 21,
      "warnings": 1,
      "errors": 0
    },
    "tier4_runtime": {
      "status": "SKIPPED",
      "reason": "Not yet implemented"
    }
  },
  
  "adr_compliance": [
    {
      "adr_id": "adr-009",
      "title": "Service Architecture Patterns",
      "status": "COMPLIANT",
      "evidence": ["Domain Spring-free: ✓", "JPA in adapter: ✓"]
    },
    {
      "adr_id": "adr-004",
      "title": "Resilience Patterns",
      "status": "COMPLIANT",
      "evidence": ["Circuit Breaker implemented: ✓", "Fallback defined: ✓"]
    }
  ],
  
  "files_generated": {
    "total": 45,
    "by_type": {
      "java": 32,
      "yaml": 5,
      "xml": 3,
      "dockerfile": 1,
      "markdown": 4
    }
  }
}
```

---

## 7. Orchestration Layer

The Orchestration Layer defines **how skills are discovered, selected, and executed**. It sits between user requests and skill execution, ensuring deterministic and traceable behavior.

### 7.1 Purpose

The Orchestration Layer ensures:

| Goal | Description |
|------|-------------|
| **Determinism** | Same input → Same output, every time |
| **Discoverability** | User prompts map to appropriate skills |
| **Traceability** | Every execution step is auditable |
| **Reproducibility** | Any agent can execute skills identically |

### 7.2 Components

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     ORCHESTRATION LAYER                                  │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────────────┐     ┌──────────────────┐     ┌─────────────────┐  │
│  │  Discovery Rules  │ ──> │  Skill Selection │ ──> │ Execution Flow │  │
│  │  (Prompt → Skill) │     │  (Match & Rank)  │     │ (Step-by-step) │  │
│  └──────────────────┘     └──────────────────┘     └─────────────────┘  │
│                                                              │           │
│                                                              ▼           │
│                                                     ┌─────────────────┐  │
│                                                     │   Audit Trail   │  │
│                                                     │ (execution-audit)│  │
│                                                     └─────────────────┘  │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 7.3 Key Files

| File | Purpose |
|------|---------|
| `orchestration/discovery-rules.md` | Maps user intents to skills |
| `orchestration/execution-framework.md` | Generic execution flow for all skills |
| `orchestration/prompt-template.md` | Standard input format |
| `orchestration/audit-schema.json` | Schema for execution audits |

### 7.4 Execution Flow Per Skill

Every Skill MUST have an `EXECUTION-FLOW.md` that specializes the generic framework:

```
Generic Framework (orchestration/execution-framework.md)
                    │
                    ▼
    ┌───────────────────────────────┐
    │   SKILL's EXECUTION-FLOW.md   │
    │                               │
    │   Step 1: Validate Input      │
    │   Step 2: Resolve Modules     │
    │   Step 3: Build Context       │
    │   Step 4: Process Templates   │
    │   Step 5: Merge Configs       │
    │   Step 6: Run Validations     │
    │   Step 7: Generate Audit      │
    └───────────────────────────────┘
```

### 7.5 Module Resolution

Skills resolve which modules to use based on input:

```
Input: generation-request.json
  │
  ├── features.resilience.circuitBreaker: true  ──> mod-001-circuit-breaker
  ├── features.resilience.retry: true           ──> mod-002-retry
  ├── features.persistence.type: "jpa"          ──> mod-016-persistence-jpa
  └── (always)                                  ──> mod-015-hexagonal-base
```

Each resolved module contributes its Template Catalog to the generation.

### 7.6 Template Catalog Processing

Modules own their templates. The skill processes each module's Template Catalog:

```
Module: mod-001-circuit-breaker
  │
  └── Template Catalog:
        ├── CircuitBreakerConfig.java.tpl  ──> src/.../config/CircuitBreakerConfig.java
        ├── circuit-breaker.yml.tpl        ──> (merge into) application.yml
        └── pom-dependencies.xml.tpl       ──> (merge into) pom.xml
```

> **Reference:** See `knowledge/model/standards/authoring/SKILL.md` for complete EXECUTION-FLOW.md specification.

---

## 8. Workflows

### 7.1 Simple Workflow: CODE/ADD

```
┌─────────────────────────────────────────────────────────────────────┐
│                    WORKFLOW: CODE/ADD                                │
│                    Example: Add Circuit Breaker                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  INPUT                                                               │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  - Existing code (Java/Spring service)                       │    │
│  │  - Feature request: "add circuit breaker to external calls"  │    │
│  │  - Config: { failure_rate: 50, timeout: 5s }                 │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                              ▼                                       │
│  SKILL EXECUTION                                                     │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  skill-code-001-add-circuit-breaker-java-resilience4j        │    │
│  │                                                               │    │
│  │  1. Load Module: mod-001-circuit-breaker                      │    │
│  │  2. Analyze existing code                                     │    │
│  │  3. Apply templates from module                               │    │
│  │  4. Modify configuration                                      │    │
│  │  5. Run validations (Tier 1 → 2 → 3)                         │    │
│  │  6. Generate traceability                                     │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                              ▼                                       │
│  OUTPUT                                                              │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  - Modified code with @CircuitBreaker annotations            │    │
│  │  - Updated application.yml with configuration                │    │
│  │  - Updated pom.xml with dependencies                         │    │
│  │  - .enablement/ with traceability                            │    │
│  │  - Validation report (100% passed)                           │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 7.2 Complex Workflow: ENHANCE (Multi-domain)

```
┌─────────────────────────────────────────────────────────────────────┐
│                    WORKFLOW: ENHANCE                                 │
│                    (Multi-domain orchestration)                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  INPUT                                                               │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  - Existing codebase                                         │    │
│  │  - Enhancement goal: "improve resilience"                    │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                              ▼                                       │
│  PHASE 1: ANALYSIS (QA Domain)                                       │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  skill-qa-001-analyze-architecture-compliance                │    │
│  │  skill-qa-002-analyze-resilience-patterns                    │    │
│  │                                                               │    │
│  │  Output: Analysis Report                                      │    │
│  │  - Missing: Circuit Breaker on external calls                │    │
│  │  - Missing: Retry on database operations                     │    │
│  │  - Found: Deprecated error handling pattern                  │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                              ▼                                       │
│  PHASE 2: RECOMMENDATIONS                                            │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  Generated recommendations:                                   │    │
│  │  1. ADD circuit-breaker → skill-code-001                     │    │
│  │  2. ADD retry → skill-code-002                               │    │
│  │  3. REFACTOR error-handling → skill-code-060                 │    │
│  │                                                               │    │
│  │  Human/AI Review: APPROVE                                     │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                              ▼                                       │
│  PHASE 3: EXECUTION (CODE Domain)                                    │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  Sequential execution:                                        │    │
│  │                                                               │    │
│  │  1. skill-code-001-add-circuit-breaker → Modified code v1    │    │
│  │  2. skill-code-002-add-retry → Modified code v2              │    │
│  │  3. skill-code-060-refactor-error-handling → Modified code v3│    │
│  │                                                               │    │
│  │  Each skill runs full validation (Tier 1-3)                  │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                              ▼                                       │
│  PHASE 4: FINAL VALIDATION (QA Domain)                               │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  skill-qa-040-validate-adr-compliance                        │    │
│  │                                                               │    │
│  │  Final validation of entire codebase                         │    │
│  │  Output: Compliance Report (100% ADR compliant)              │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                              ▼                                       │
│  OUTPUT                                                              │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  - Enhanced codebase with all improvements                   │    │
│  │  - Detailed change log                                       │    │
│  │  - Full traceability for each change                         │    │
│  │  - Compliance report                                         │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 7.3 Workflow: DESIGN/TRANSFORM

```
┌─────────────────────────────────────────────────────────────────────┐
│                    WORKFLOW: DESIGN/TRANSFORM                        │
│                    Example: Monolith to Microservices                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  INPUT                                                               │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  - Existing monolith codebase                                │    │
│  │  - Target: Microservices architecture                        │    │
│  │  - Constraints: Must maintain existing APIs                  │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                              ▼                                       │
│  PHASE 1: ANALYSIS (DESIGN Domain)                                   │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  skill-design-040-transform-analyze-monolith                 │    │
│  │                                                               │    │
│  │  - Identify bounded contexts                                 │    │
│  │  - Map dependencies                                          │    │
│  │  - Identify shared data                                      │    │
│  │                                                               │    │
│  │  Output: Domain analysis report                              │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                              ▼                                       │
│  PHASE 2: ARCHITECTURE DESIGN (DESIGN Domain)                        │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  skill-design-001-architecture-microservice                  │    │
│  │                                                               │    │
│  │  - Define service boundaries                                 │    │
│  │  - Design communication patterns                             │    │
│  │  - Plan data separation                                      │    │
│  │                                                               │    │
│  │  Output: Architecture design + ADR drafts                    │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                              ▼                                       │
│  PHASE 3: TRANSFORMATION PLAN                                        │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  Generated work items:                                        │    │
│  │                                                               │    │
│  │  Stage 1: Extract shared library                             │    │
│  │    → CODE/REFACTOR: skill-code-060                           │    │
│  │                                                               │    │
│  │  Stage 2: Create Customer microservice                       │    │
│  │    → CODE/GENERATE: skill-code-020                           │    │
│  │    → CODE/MIGRATE: skill-code-080 (move customer code)       │    │
│  │                                                               │    │
│  │  Stage 3: Create Order microservice                          │    │
│  │    → CODE/GENERATE: skill-code-020                           │    │
│  │    → CODE/MIGRATE: skill-code-080 (move order code)          │    │
│  │                                                               │    │
│  │  Stage 4: Create API Gateway                                 │    │
│  │    → CODE/GENERATE: skill-code-024                           │    │
│  │                                                               │    │
│  │  Human Review: APPROVE / MODIFY                              │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                              ▼                                       │
│  PHASE 4: EXECUTION (CODE Domain - Multiple skills)                  │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  Execute transformation plan stage by stage                  │    │
│  │  Each stage validates before proceeding                      │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                              ▼                                       │
│  OUTPUT                                                              │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  - Multiple microservices                                    │    │
│  │  - API Gateway                                               │    │
│  │  - Transformation documentation                              │    │
│  │  - Full traceability                                         │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 7.4 Workflow: CODE/GENERATION with CAPABILITIES

```
┌─────────────────────────────────────────────────────────────────────┐
│                    WORKFLOW: CODE/GENERATION                         │
│                    Example: Generate Microservice with Capabilities  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  INPUT                                                               │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  - Entity: "Customer"                                        │    │
│  │  - Capabilities: ["resilience", "observability"]             │    │
│  │  - Technology: java-spring                                   │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                              ▼                                       │
│  PHASE 1: CAPABILITY EXPANSION                                       │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  Load capability definitions:                                │    │
│  │                                                               │    │
│  │  CAPABILITY: resilience                                      │    │
│  │  ├── FEATURE: circuit-breaker                                │    │
│  │  │   └── COMPONENT: circuit-breaker-basic                    │    │
│  │  │       └── MODULE: mod-001-circuit-breaker-java-resilience4j│   │
│  │  ├── FEATURE: retry                                          │    │
│  │  │   └── COMPONENT: retry-exponential                        │    │
│  │  │       └── MODULE: mod-002-retry-java-resilience4j         │    │
│  │  └── FEATURE: timeout                                        │    │
│  │      └── COMPONENT: timeout-basic                            │    │
│  │          └── MODULE: mod-003-timeout-java-resilience4j       │    │
│  │                                                               │    │
│  │  CAPABILITY: observability                                   │    │
│  │  ├── FEATURE: health-checks                                  │    │
│  │  │   └── COMPONENT: actuator-health                          │    │
│  │  │       └── MODULE: mod-010-health-java-actuator            │    │
│  │  └── FEATURE: metrics                                        │    │
│  │      └── COMPONENT: micrometer-prometheus                    │    │
│  │          └── MODULE: mod-011-metrics-java-micrometer         │    │
│  │                                                               │    │
│  │  Modules to use: [mod-001, mod-002, mod-003, mod-010, mod-011]│   │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                              ▼                                       │
│  PHASE 2: SKILL EXECUTION                                            │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  skill-code-020-generate-microservice-java-spring            │    │
│  │                                                               │    │
│  │  1. Load base structure (mod-015-hexagonal-base-java-spring) │    │
│  │  2. Apply each capability module:                            │    │
│  │     - mod-001: Add @CircuitBreaker annotations               │    │
│  │     - mod-002: Add @Retry configurations                     │    │
│  │     - mod-003: Add @TimeLimiter configs                      │    │
│  │     - mod-010: Configure actuator health endpoints           │    │
│  │     - mod-011: Add Micrometer metrics                        │    │
│  │  3. Generate unified configuration                           │    │
│  │  4. Create .enablement/ with full traceability               │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                              ▼                                       │
│  PHASE 3: VALIDATION                                                 │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  Tier 1 Universal: traceability                              │    │
│  │  Tier 1 Code: project-structure, naming-conventions          │    │
│  │  Tier 2 Technology: java-spring, docker                      │    │
│  │  Tier 3 Module: (from each module used)                      │    │
│  │     - mod-001: circuit-breaker-check.sh                      │    │
│  │     - mod-002: retry-check.sh                                │    │
│  │     - mod-003: timeout-check.sh                              │    │
│  │     - mod-010: health-check.sh                               │    │
│  │     - mod-011: metrics-check.sh                              │    │
│  │     - mod-015: hexagonal-check.sh                            │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                              ▼                                       │
│  OUTPUT                                                              │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  customer-service/                                           │    │
│  │  ├── src/main/java/.../                                      │    │
│  │  │   ├── domain/          (Spring-free)                      │    │
│  │  │   ├── application/     (use cases)                        │    │
│  │  │   └── infrastructure/  (adapters + resilience)            │    │
│  │  ├── src/main/resources/                                     │    │
│  │  │   └── application.yml  (all configs unified)              │    │
│  │  ├── Dockerfile                                              │    │
│  │  └── .enablement/                                            │    │
│  │      ├── manifest.json    (full capability traceability)     │    │
│  │      └── validation/      (all tier scripts)                 │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 9. Asset Creation

**IMPORTANT: Creation Order**

Assets MUST be created in this order:

```
1. ADR  ──►  2. ERI  ──►  3. Module  ──►  4. Skill
   │            │             │              │
   │            │             │              └─ Uses Module(s)
   │            │             └─ Derives from ERI
   │            └─ Implements ADR
   └─ Entry point (strategic decision)
```

- **ADR before ERI:** ERI implements an ADR
- **ERI before Module:** Module derives from ERI constraints
- **Module before Skill:** Skill uses one or more Modules

### 8.1 Decision Tree: What Asset to Create?

```
START
  │
  ├─ Is it a strategic architectural decision (framework-agnostic)?
  │   │
  │   YES → Create ADR
  │   │
  │   NO ──┐
  │        │
  │        ├─ Is it a reference implementation for a specific technology?
  │        │   │
  │        │   YES → Create ERI (referencing ADR)
  │        │   │
  │        │   NO ──┐
  │        │        │
  │        │        ├─ Is it reusable template code for Skills?
  │        │        │   │
  │        │        │   YES → Create Module (referencing ERI)
  │        │        │   │
  │        │        │   NO ──┐
  │        │        │        │
  │        │        │        ├─ Is it an executable automated capability?
  │        │        │        │   │
  │        │        │        │   YES → Create Skill (using Module(s))
  │        │        │        │   │
  │        │        │        │   NO ──┐
  │        │        │        │        │
  │        │        │        │        └─ Review model, probably
  │        │        │        │           one of the above
  │        │        │        │
  │        │        │        │
END
```

### 8.2 Process: Create an ADR

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CREATE ADR                                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. VERIFY                                                           │
│     □ No similar ADR exists (search in knowledge/ADRs/)              │
│     □ It is a strategic framework-agnostic decision                  │
│     □ It has organizational impact                                   │
│                                                                      │
│  2. CREATE STRUCTURE                                                 │
│     mkdir knowledge/ADRs/adr-XXX-{topic}/                            │
│     touch knowledge/ADRs/adr-XXX-{topic}/ADR.md                      │
│                                                                      │
│  3. COMPLETE SECTIONS                                                │
│     □ YAML front matter (id, title, version, date, status)          │
│     □ Context                                                        │
│     □ Decision                                                       │
│     □ Rationale                                                      │
│     □ Consequences (Positive, Negative, Mitigations)                │
│     □ Implementation Guidelines                                      │
│     □ Compliance Criteria                                           │
│                                                                      │
│  4. VERIFY WITH CHECKLIST                                            │
│     □ Is framework-agnostic (no specific technologies mentioned)    │
│     □ Decision is clear and actionable                              │
│     □ Compliance criteria are verifiable                            │
│     □ Related ADRs are referenced                                   │
│                                                                      │
│  5. REVIEW AND COMMIT                                                │
│     □ Peer review                                                    │
│     □ Commit with message: "feat(adr): add ADR-XXX {title}"         │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 8.3 Process: Create an ERI

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CREATE ERI                                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. VERIFY                                                           │
│     □ ADR it implements exists                                       │
│     □ No similar ERI exists for this technology                      │
│     □ Technology is approved in the organization                    │
│                                                                      │
│  2. CREATE STRUCTURE                                                 │
│     mkdir knowledge/ERIs/eri-{domain}-XXX-{pattern}-{framework}-{library}/   │
│     touch knowledge/ERIs/eri-{domain}-XXX-.../ERI.md                         │
│                                                                      │
│  3. COMPLETE SECTIONS                                                │
│     □ YAML front matter (including adr_reference)                   │
│     □ Overview                                                       │
│     □ Implementation Details                                         │
│     □ Code Examples (functional, tested)                            │
│     □ Configuration                                                  │
│     □ Testing Guidelines                                             │
│     □ **ANNEX: Implementation Constraints (YAML)** ← MANDATORY      │
│                                                                      │
│  4. DEFINE CONSTRAINTS IN ANNEX                                      │
│     □ structural_constraints (ERROR severity)                        │
│     □ configuration_constraints (WARNING severity)                   │
│     □ dependency_constraints (required, optional)                    │
│     □ testing_constraints                                            │
│                                                                      │
│  5. VERIFY WITH CHECKLIST                                            │
│     □ Example code compiles and works                               │
│     □ Constraints are automatically verifiable                      │
│     □ References correct ADR                                         │
│     □ Machine-readable annex is present and complete                │
│                                                                      │
│  6. REVIEW AND COMMIT                                                │
│     □ Peer review                                                    │
│     □ Commit with message: "feat(eri): add ERI-XXX {title}"         │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 8.4 Process: Create a Module

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CREATE MODULE                                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. VERIFY                                                           │
│     □ ERI it derives from exists (documented exceptions)            │
│     □ No similar Module exists                                       │
│     □ Is reusable by multiple Skills                                │
│                                                                      │
│  2. CREATE STRUCTURE                                                 │
│     mkdir knowledge/skills/modules/mod-XXX-{pattern}-{fw}-{lib}/    │
│     mkdir knowledge/skills/modules/mod-XXX-.../validation/          │
│     touch knowledge/skills/modules/mod-XXX-.../MODULE.md            │
│     touch knowledge/skills/modules/mod-XXX-.../validation/README.md │
│     touch knowledge/skills/modules/mod-XXX-.../{feature}-check.sh   │
│                                                                      │
│  3. COMPLETE MODULE.md                                               │
│     □ YAML front matter (eri_reference, adr_reference)              │
│     □ Overview                                                       │
│     □ Template Variables (complete table)                           │
│     □ Templates (code with {{variables}})                           │
│     □ Usage Instructions                                             │
│     □ Validation Reference                                           │
│                                                                      │
│  4. CREATE VALIDATION SCRIPT                                         │
│     □ Implement ERI constraints as checks                           │
│     □ Severity: ERROR for structural, WARNING for config            │
│     □ Clear output: ✅ PASS / ❌ ERROR / ⚠️ WARNING                 │
│     □ Exit code: 0 = pass, >0 = error count                         │
│                                                                      │
│  5. CREATE validation/README.md                                      │
│     □ What it validates                                              │
│     □ How to execute                                                 │
│     □ Reference to ERI constraints                                  │
│                                                                      │
│  6. VERIFY WITH CHECKLIST                                            │
│     □ Templates have all variables documented                       │
│     □ Validation script implements all ERI constraints              │
│     □ Script is executable (chmod +x)                               │
│     □ Validation README is complete                                 │
│                                                                      │
│  7. REVIEW AND COMMIT                                                │
│     □ Peer review                                                    │
│     □ Commit: "feat(module): add mod-XXX {name}"                    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 8.5 Process: Create a Skill

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CREATE SKILL                                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. VERIFY                                                           │
│     □ Required Module(s) exist                                      │
│     □ No similar Skill exists                                        │
│     □ Domain and Type identified                                     │
│                                                                      │
│  2. CREATE STRUCTURE                                                 │
│     mkdir knowledge/skills/skill-XXX-{type}-{target}-{fw}-{lib}/    │
│     mkdir knowledge/skills/skill-XXX-.../validation/                │
│     touch knowledge/skills/skill-XXX-.../SKILL.md                   │
│     touch knowledge/skills/skill-XXX-.../OVERVIEW.md                │
│     touch knowledge/skills/skill-XXX-.../README.md                  │
│     touch knowledge/skills/skill-XXX-.../validation/validate.sh     │
│     touch knowledge/skills/skill-XXX-.../validation/README.md       │
│                                                                      │
│  3. COMPLETE SKILL.md                                                │
│     □ YAML front matter (domain, type, modules_used)                │
│     □ Overview                                                       │
│     □ Input Contract (JSON schema)                                  │
│     □ Output Contract (JSON schema)                                 │
│     □ Execution Flow                                                 │
│     □ Modules Used (with references)                                │
│     □ Validation Reference                                           │
│                                                                      │
│  4. CREATE validate.sh (ORCHESTRATION ONLY)                         │
│     □ Tier 1: Infrastructure (call existing scripts)                │
│     □ Tier 2: Stack (detect and call existing scripts)              │
│     □ Tier 3: Module (call scripts from used modules)               │
│     □ Tier 4: Placeholder for runtime                               │
│     □ Summary with totals                                            │
│     □ DO NOT DEFINE own validations                                 │
│                                                                      │
│  5. VERIFY WITH CHECKLIST                                            │
│     □ validate.sh ONLY orchestrates, does not define validations    │
│     □ All used modules are referenced                               │
│     □ Input/Output contracts are complete                           │
│     □ Domain and Type are correct per taxonomy                      │
│                                                                      │
│  6. REVIEW AND COMMIT                                                │
│     □ Peer review                                                    │
│     □ Commit: "feat(skill): add skill-XXX {name}"                   │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 8.6 Process: Create a Capability

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CREATE CAPABILITY                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. VERIFY                                                           │
│     □ No similar Capability exists                                   │
│     □ Groups multiple related features                               │
│     □ At least 2 features identified                                 │
│                                                                      │
│  2. CREATE FILE                                                      │
│     touch knowledge/capabilities/{capability-name}.md               │
│                                                                      │
│  3. COMPLETE STRUCTURE                                               │
│     □ YAML front matter (id, name, description, domain)             │
│     □ Overview (what this capability provides)                      │
│     □ Features (list with descriptions)                             │
│     □ Components per feature (with module mappings)                 │
│     □ Default configuration                                          │
│     □ Example usage                                                  │
│                                                                      │
│  4. DEFINE FEATURE-COMPONENT-MODULE HIERARCHY                        │
│                                                                      │
│     features:                                                        │
│       - name: circuit-breaker                                        │
│         description: Prevent cascade failures                        │
│         components:                                                  │
│           - id: circuit-breaker-basic                               │
│             module: mod-001-circuit-breaker-java-resilience4j       │
│           - id: circuit-breaker-advanced                            │
│             module: mod-002-circuit-breaker-advanced-java           │
│                                                                      │
│  5. VERIFY WITH CHECKLIST                                            │
│     □ Each feature has at least one component                       │
│     □ Each component maps to existing module                        │
│     □ All referenced modules exist                                  │
│     □ Default configuration is sensible                             │
│                                                                      │
│  6. UPDATE capabilities/README.md                                    │
│     □ Add entry to capability index                                 │
│                                                                      │
│  7. REVIEW AND COMMIT                                                │
│     □ Peer review                                                    │
│     □ Commit: "feat(capability): add {name} capability"             │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 8.7 Process: Create a Validator (Tier-1/Tier-2)

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CREATE VALIDATOR (Tier-1 or Tier-2)               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  NOTE: Tier-3 validators are created with their Modules.            │
│        This process is for shared Tier-1 and Tier-2 validators.     │
│                                                                      │
│  1. DETERMINE TIER                                                   │
│     □ Tier-1 Universal: Applies to all outputs, all domains         │
│     □ Tier-1 Domain: Applies to all outputs of a specific domain   │
│     □ Tier-2 Technology: Applies to specific tech stack             │
│                                                                      │
│  2. CREATE STRUCTURE                                                 │
│                                                                      │
│     For Tier-1 Universal:                                            │
│     mkdir validators/tier-1-universal/{validator-name}/             │
│                                                                      │
│     For Tier-1 Domain (e.g., code-projects):                        │
│     mkdir validators/tier-1-universal/{domain}/{validator-name}/    │
│                                                                      │
│     For Tier-2 Technology:                                           │
│     mkdir validators/tier-2-technology/{category}/{stack}/          │
│                                                                      │
│  3. CREATE FILES                                                     │
│     touch {validator-dir}/VALIDATOR.md                              │
│     touch {validator-dir}/{name}-check.sh                           │
│                                                                      │
│  4. COMPLETE VALIDATOR.md                                            │
│     □ YAML front matter (id, name, tier, applies_to)                │
│     □ Purpose                                                        │
│     □ Checks performed (table)                                       │
│     □ Usage instructions                                             │
│                                                                      │
│  5. CREATE CHECK SCRIPT                                              │
│     □ Standard output functions (pass, fail, warn, skip)            │
│     □ Accept target directory as $1                                 │
│     □ Clear messages for each check                                 │
│     □ Exit with error count                                         │
│                                                                      │
│  6. SCRIPT TEMPLATE                                                  │
│     #!/bin/bash                                                      │
│     TARGET_DIR="${1:-.}"                                             │
│     ERRORS=0                                                         │
│                                                                      │
│     pass() { echo -e "✅ PASS: $1"; }                                │
│     fail() { echo -e "❌ FAIL: $1"; ERRORS=$((ERRORS + 1)); }       │
│     warn() { echo -e "⚠️  WARN: $1"; }                               │
│                                                                      │
│     # Checks here...                                                 │
│                                                                      │
│     exit $ERRORS                                                     │
│                                                                      │
│  7. VERIFY WITH CHECKLIST                                            │
│     □ Script is executable (chmod +x)                               │
│     □ Works with test project                                       │
│     □ Clear pass/fail output                                        │
│     □ Correct exit codes                                            │
│                                                                      │
│  8. UPDATE validators/README.md                                      │
│     □ Add to directory structure                                    │
│     □ Add to tier description table                                 │
│                                                                      │
│  9. REVIEW AND COMMIT                                                │
│     □ Peer review                                                    │
│     □ Commit: "feat(validator): add {name} validator (tier-N)"      │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 8.8 General Quality Checklist

```
┌─────────────────────────────────────────────────────────────────────┐
│                    QUALITY CHECKLIST                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  STRUCTURE                                                           │
│  □ Correct naming convention                                         │
│  □ Main file has correct name (ADR.md, ERI.md, etc.)                │
│  □ YAML front matter complete and valid                             │
│  □ All required sections present                                    │
│                                                                      │
│  TRACEABILITY                                                        │
│  □ References to related assets (ADR→ERI→Module→Skill)              │
│  □ Correct version number                                            │
│  □ Updated date                                                      │
│  □ Correct status (Draft/Proposed/Accepted/Deprecated)              │
│                                                                      │
│  CONTENT                                                             │
│  □ Example code works                                                │
│  □ Templates have documented variables                               │
│  □ Constraints are verifiable                                        │
│  □ Documentation is clear for humans                                │
│                                                                      │
│  VALIDATION                                                          │
│  □ Validation scripts are executable                                │
│  □ Scripts implement ERI constraints                                │
│  □ Output is clear (PASS/WARNING/ERROR)                             │
│  □ Exit codes are correct                                            │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 10. Knowledge Base Structure

### 9.1 Complete Structure

```
knowledge/
├── README.md                                    # Overview and navigation (v4.0)
│
├── model/                                       # Enablement Model definition
│   ├── README.md                               # Model overview
│   ├── ENABLEMENT-MODEL-v1.3.md               # ⭐ This document (master)
│   └── standards/                              # Operational standards
│       ├── ASSET-STANDARDS-v1.3.md            # Technical asset structure
│       ├── authoring/                          # Asset creation guides
│       ├── validation/                         # Validation standards by domain
│       └── traceability/                       # Traceability standards by domain
│
├── capabilities/                                # Capability catalog
│   ├── README.md                               # Index of all capabilities
│   ├── resilience.md                           # Capability: Resilience
│   ├── api_architecture.md                     # Capability: API Architecture
│   └── ...                                     # Other capabilities
│
├── validation/                                  # Validation system
│   ├── README.md                               # System overview
│   ├── tier-1-universal/                       # Tier 1: Universal
│   │   ├── traceability/                       # All domains
│   │   │   ├── VALIDATOR.md
│   │   │   └── traceability-check.sh
│   │   └── code-projects/                      # CODE domain
│   │       ├── project-structure/
│   │       │   ├── VALIDATOR.md
│   │       │   └── project-structure-check.sh
│   │       └── naming-conventions/
│   │           ├── VALIDATOR.md
│   │           └── naming-conventions-check.sh
│   ├── tier-2-technology/                      # Tier 2: By technology
│   │   ├── code-projects/
│   │   │   └── java-spring/
│   │   │       ├── VALIDATOR.md
│   │   │       ├── compile-check.sh
│   │   │       ├── test-check.sh
│   │   │       ├── actuator-check.sh
│   │   │       └── application-yml-check.sh
│   │   └── deployments/
│   │       └── docker/
│   │           ├── VALIDATOR.md
│   │           └── dockerfile-check.sh
│   └── tier-3-module/                          # Tier 3: Reference only
│       └── README.md                           # Points to modules/
│
├── ADRs/                                        # Architectural Decision Records
│   ├── adr-001-api-design-standards/
│   │   └── ADR.md
│   ├── adr-004-resilience-patterns/
│   │   └── ADR.md
│   └── adr-009-service-architecture-patterns/
│       └── ADR.md
│
├── ERIs/                                        # Enterprise Reference Implementations
│   ├── eri-code-001-hexagonal-light-java-spring/
│   │   └── ERI.md                              # Includes constraints annex
│   └── eri-code-008-circuit-breaker-java-resilience4j/
│       └── ERI.md                              # Includes constraints annex
│
├── patterns/                                    # Standard pattern documentation
│   ├── README.md                               # Pattern index
│   ├── saga.md                                 # Saga Pattern
│   ├── cqrs.md                                 # CQRS Pattern
│   └── event-sourcing.md                       # Event Sourcing Pattern
│
└── skills/
    │
    ├── modules/                                # Tier 3: Modules with validation
    │   ├── mod-001-circuit-breaker-java-resilience4j/
    │   │   ├── MODULE.md
    │   │   └── validation/
    │   │       ├── README.md
    │   │       └── circuit-breaker-check.sh
    │   └── mod-015-hexagonal-base-java-spring/
    │       ├── MODULE.md
    │       └── validation/
    │           ├── README.md
    │           └── hexagonal-structure-check.sh
    │
    ├── skill-code-001-add-circuit-breaker-java-resilience4j/
    │   ├── SKILL.md
    │   ├── OVERVIEW.md
    │   ├── README.md
    │   └── validation/
    │       ├── README.md
    │       └── validate.sh                     # Only orchestrates
    │
    └── skill-code-020-generate-microservice-java-spring/
        ├── SKILL.md
        ├── OVERVIEW.md
        ├── README.md
        └── validation/
            ├── README.md
            └── validate.sh                     # Only orchestrates
```

### 9.2 Naming Conventions

| Asset | Pattern | Example |
|-------|---------|---------|
| ADR | `adr-XXX-{topic}/ADR.md` | `adr-004-resilience-patterns/ADR.md` |
| ERI | `eri-{domain}-XXX-{pattern}-{framework}-{library}/ERI.md` | `eri-code-008-circuit-breaker-java-resilience4j/ERI.md` |
| Module | `mod-XXX-{pattern}-{framework}-{library}/MODULE.md` | `mod-001-circuit-breaker-java-resilience4j/MODULE.md` |
| Skill | `skill-{domain}-{NNN}-{type}-{target}-{fw}-{lib}/SKILL.md` | `skill-code-001-add-circuit-breaker-java-resilience4j/SKILL.md` |
| Capability | `{capability}.md` | `resilience.md` |

### 9.3 Skill Numbering by Domain

With the new naming convention (`skill-{domain}-{NNN}-*`), each domain has its own independent counter:

| Domain | Prefix | Number Range | Types |
|--------|--------|--------------|-------|
| **CODE** | `skill-code-` | 001-999 | add, generate, remove, refactor, migrate |
| **DESIGN** | `skill-design-` | 001-999 | architecture, transform, documentation |
| **QA** | `skill-qa-` | 001-999 | analyze, validate, audit |
| **GOVERNANCE** | `skill-gov-` | 001-999 | documentation, compliance, policy |

**Recommended numbering within each domain:**

| Domain | Range | Type |
|--------|-------|------|
| CODE | 001-019 | ADD |
| CODE | 020-039 | GENERATE |
| CODE | 040-059 | REMOVE |
| CODE | 060-079 | REFACTOR |
| CODE | 080-199 | MIGRATE |
| DESIGN | 001-039 | ARCHITECTURE |
| DESIGN | 040-079 | TRANSFORM |
| DESIGN | 080-199 | DOCUMENTATION |
| QA | 001-039 | ANALYZE |
| QA | 040-079 | VALIDATE |
| QA | 080-199 | AUDIT |
| GOV | 001-039 | DOCUMENTATION |
| GOV | 040-079 | COMPLIANCE |
| GOV | 080-199 | POLICY |

**Note:** These are recommended ranges within each domain. Since domains are now explicit in the name, there's no risk of number collision between domains.

---

## 11. Appendices

### 10.1 Glossary

| Term | Definition |
|------|------------|
| **ADR** | Architectural Decision Record - Strategic architectural decision |
| **ERI** | Enterprise Reference Implementation - Opinionated reference implementation |
| **Module** | Reusable code template with validations |
| **Skill** | Automated executable capability |
| **Capability** | High-level technical objective (Resilience, Security, etc.) |
| **Feature** | Functional grouping within capability |
| **Component** | Specific pattern or technique within feature |
| **Swarm** | Group of agents specialized in a domain |
| **Domain** | SDLC phase (DESIGN, CODE, QA, GOVERNANCE) |
| **Tier** | Validation level (1: Universal, 2: Technology, 3: Module, 4: Runtime) |

### 10.2 Cross References

| If you need... | Consult... |
|----------------|------------|
| Detailed asset structure | `model/standards/ASSET-STANDARDS-v1.3.md` |
| Validation standards | `model/standards/validation/README.md` |
| Traceability standards | `model/standards/traceability/README.md` |
| Asset authoring guides | `model/standards/authoring/` |
| Capability catalog | `capabilities/README.md` |
| Skill index by domain | `skills/README.md` |
| Generated code examples | `customer-service-gen1` (example project) |

### 10.3 Change History

| Version | Date | Changes |
|---------|------|---------|
| 1.2 | 2025-11-28 | Multi-domain consistency: SKILL-MODULE mandatory, "code"→"content", Tier nomenclature (Universal/Technology/Module/Runtime), added CODE/GENERATION workflow with CAPABILITIES, added CAPABILITY and VALIDATOR creation processes, multi-domain applicability examples |
| 1.1 | 2025-11-27 | Validation system refinement, traceability model |
| 1.0 | 2025-11-26 | Initial version of complete model |

---

## Usage Notes

### For AI Agents

**Before creating any asset:**
1. Read this document completely (ENABLEMENT-MODEL-v1.3.md)
2. Consult `model/standards/ASSET-STANDARDS-v1.3.md` for technical structure
3. Follow the process defined in section 8
4. Verify with checklists before delivering

**Consistency Reminders:**
- ADRs and ERIs are INPUT - do not generate them without human review
- Modules MUST be created BEFORE Skills that use them
- Skills ONLY orchestrate validations, they do not define them
- ERIs MUST include machine-readable constraint annex
- Modules MUST implement ERI constraints as validation scripts
- Traceability is MANDATORY in all generated output

### For Humans

**For manual design/development:**
- Consult ADRs for strategic architectural decisions
- Consult ERIs for technology-specific reference implementation
- Follow constraints defined in ERI annexes

**For creating new ADRs/ERIs:**
- ADRs: Framework-agnostic, strategic decisions only
- ERIs: Include machine-readable constraints annex (YAML)
- Both require peer review before publishing

### For Both AI and Humans

**To extend the knowledge base:**
- Follow creation processes in section 8
- Verify with quality checklists
- Maintain traceability chain: ADR → ERI → Module → Skill
- Create Module before Skill
- Run validations after any change

**Asset creation order:**
1. ADR (if new strategic decision needed)
2. ERI (if new technology implementation needed)
3. Module (derived from ERI)
4. Skill (using one or more Modules)

---

**END OF DOCUMENT**

For questions about this model, consult with the architecture team or open an issue in the repository.
