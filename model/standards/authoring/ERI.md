# Authoring Guide: ERI (Enterprise Reference Implementation)

**Version:** 1.3  
**Last Updated:** 2026-01-22  
**Asset Type:** ERI  
**Model Version:** 3.0.1

---

## What's New in v1.3

| Change | Description |
|--------|-------------|
| **Skills Eliminated** | References to skills removed; modules are discovered via capabilities |
| **automated_by Removed** | ERIs no longer reference skills; modules implement features directly |

## What's New in v1.2

| Change | Description |
|--------|-------------|
| **Implementation Options** | Formal structure for defining valid options with default and selection criteria |
| **Variant Derivation** | Clear rules for how modules derive variants from ERI options |

---

## Overview

ERIs are **complete, production-ready reference implementations** of patterns defined in ADRs for specific technology stacks. They serve as starting points for code generation and validation targets for compliance checking.

## When to Create an ERI

Create an ERI when:

- An ADR needs a concrete implementation for a specific technology
- A new technology stack requires standardized patterns
- A reference implementation is needed for developer guidance
- Automation (modules) need a template to generate from

Do NOT create an ERI for:

- Strategic decisions (use ADR instead)
- Partial or incomplete implementations
- Technology choices not yet approved in an ADR

---

## Handling Multiple Implementation Options

When an ADR defines a pattern that has **multiple implementation options** (e.g., different persistence strategies, different integration clients), follow these guidelines:

### Principle: ONE ERI, Multiple Options

**Always create a SINGLE unified ERI** that documents all options together. This provides:
- Complete picture in one document
- Clear decision criteria for choosing between options
- Side-by-side comparison
- Single source of truth for the pattern

### Implementation Options Structure (v1.2)

> **NEW in v1.2:** ERIs with multiple options MUST use this formal structure.

ERIs define the **space of valid implementation options**. Modules derived from the ERI can ONLY offer variants that correspond to options defined here.

```markdown
## Implementation Options

> This section defines all valid implementation approaches for this pattern.
> Modules derived from this ERI MUST only implement options defined here.

### Recommended Default: {Option Name}

**Why Default:** [Rationale for why this is the recommended choice for most cases]

### Option A: {Option Name} ⭐ DEFAULT

**Description:** [What this option is]

**Recommended When:**
- [Condition 1]
- [Condition 2]

**Trade-offs:**
- ✅ [Advantage 1]
- ✅ [Advantage 2]
- ⚠️ [Consideration or limitation]

**Reference Implementation:**
```{language}
[Complete, production-ready code]
```

### Option B: {Option Name}

**Description:** [What this option is]

**Recommended When:**
- [Condition 1 - these become recommend_when in module]
- [Condition 2]

**Trade-offs:**
- ✅ [Advantage 1]
- ⚠️ [Consideration]

**Reference Implementation:**
```{language}
[Complete, production-ready code]
```

### Option C: {Option Name} ⚠️ DEPRECATED (if applicable)

**Description:** [What this option is]

**Status:** Deprecated - Use [Option A] for new implementations

**Recommended When:**
- Legacy compatibility required
- [Other specific condition]

**Deprecation Reason:** [Why this is deprecated and what to use instead]

**Reference Implementation:**
```{language}
[Code for legacy support]
```
```

### Option Metadata Table

Every multi-option ERI SHOULD include a summary table:

```markdown
### Options Summary

| Option | Status | Recommended When | Deprecated? |
|--------|--------|------------------|-------------|
| RestClient | ⭐ DEFAULT | New projects, Spring Boot 3.2+ | No |
| OpenFeign | Alternative | Existing Feign patterns, declarative preference | No |
| RestTemplate | Alternative | Legacy compatibility only | Yes (v1.2) |
```

### Derivation to Modules

The relationship between ERI options and Module variants:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    ERI → MODULE DERIVATION                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ERI defines:                         MODULE inherits:                       │
│  ─────────────                        ────────────────                       │
│  • Valid options                  →   • Variants (ONLY from ERI options)     │
│  • Default recommendation         →   • default.id                           │
│  • "Recommended When" conditions  →   • recommend_when conditions            │
│  • Deprecated status              →   • deprecated: true                     │
│  • Reference code                 →   • Template content                     │
│                                                                              │
│  RULE: A module CANNOT offer a variant that is not an option in the ERI     │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Validation Rule

> **CRITICAL:** When reviewing a Module, verify that every variant corresponds to an option defined in the source ERI. Modules CANNOT invent new variants.

### Examples

| Pattern | ERI Options | Module Variants |
|---------|-------------|-----------------|
| REST Client | RestClient (default), Feign, RestTemplate | restclient (default), feign, resttemplate |
| Timeout | Client-level (default), Annotation-based | client-timeout (default), annotation-async |
| Persistence | JPA, System API | N/A - Functionally disparate → 2 separate modules |

### Naming for Multi-Option ERIs

Use a **generic pattern name** that encompasses all options:

- ✅ `eri-code-012-persistence-patterns-java-spring` (covers JPA + System API)
- ✅ `eri-code-013-api-integration-rest-java-spring` (covers all REST clients)
- ❌ `eri-code-012-jpa-persistence-java-spring` (too specific if System API is also covered)

### Relationship to MODULEs

The decision of how many MODULEs to derive from a multi-option ERI depends on **functional equivalence**:

| Equivalence | ERI Structure | Module Structure |
|-------------|---------------|------------------|
| **Functionally Equivalent** | One ERI with multiple options | One Module with variants |
| **Functionally Disparate** | One ERI with multiple options | Multiple separate Modules |

See `authoring/MODULE.md` for the MODULE desglose criteria.

---

## Directory Structure

```
knowledge/ERIs/
└── eri-{domain}-XXX-{pattern}-{framework}-{library}/
    └── ERI.md           # Main document (required)
```

## Naming Convention

```
eri-{domain}-XXX-{pattern}-{framework}-{library}
```

- `{domain}`: Primary domain (`code`, `design`, `qa`, `gov`)
- `XXX`: 3-digit sequential number within domain
- `{pattern}`: Pattern being implemented (kebab-case)
- `{framework}`: Technology framework (java, nodejs, python, etc.)
- `{library}`: Specific library if applicable

**Examples:**
- `eri-code-001-hexagonal-light-java-spring`
- `eri-code-008-circuit-breaker-java-resilience4j`
- `eri-code-020-circuit-breaker-nodejs-opossum`

---

## Required YAML Front Matter

```yaml
---
id: eri-{domain}-XXX-{pattern}-{framework}-{library}
title: "ERI-{DOMAIN}-XXX: {Title}"
sidebar_label: "{Short Label}"
version: X.Y
date: YYYY-MM-DD
updated: YYYY-MM-DD
status: Draft|Active|Deprecated
author: {Author/Team}
domain: code|design|qa|gov
pattern: {pattern-name}
framework: {java|nodejs|python|etc}
library: {library-name}
library_version: X.Y.Z
java_version: "17|21"      # If Java
implements:
  - adr-XXX-{topic}
tags:
  - {tag1}
  - {tag2}
related:
  - eri-{domain}-XXX-...
derived_modules:                    # Modules that derive from this ERI
  - mod-{domain}-XXX-...
cross_domain_usage: {domain}    # Optional: qa, design, gov
---
```

---

## Required Sections

### Template

```markdown
# ERI-{DOMAIN}-XXX: {Title}

## Overview

[What this ERI provides. What problem it solves. When to use it.]

**Implements:** [ADR reference]  
**Status:** [Draft|Active|Deprecated]

---

## Technology Stack

| Component | Technology | Version |
|-----------|------------|---------|
| **Language** | {language} | {version} |
| **Framework** | {framework} | {version} |
| **Library** | {library} | {version} |

---

## Project Structure

[Directory layout for projects following this ERI]

```
{project-name}/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/company/{service}/
│   │   │       ├── domain/
│   │   │       ├── application/
│   │   │       └── infrastructure/
│   │   └── resources/
│   └── test/
├── pom.xml
└── Dockerfile
```

---

## Code Reference

[Complete, compilable code examples for each key component]

### {Component 1}

```{language}
// File: {path/to/file}
// Purpose: {what this code does}

{complete, production-ready code}
```

### {Component 2}

```{language}
{complete, production-ready code}
```

---

## Configuration

[Required configuration with explanations]

### {config-file}

```yaml
# {explanation of each section}
{complete configuration}
```

---

## Testing

[How to test implementations of this ERI]

### Unit Test Example

```{language}
{test code}
```

---

## Dependencies

### Required Dependencies

```xml
<!-- pom.xml -->
<dependencies>
    {required dependencies}
</dependencies>
```

### Optional Dependencies

```xml
<!-- For enhanced features -->
{optional dependencies}
```

---

## Compliance Checklist

Requirements that implementations MUST satisfy:

- [ ] {Requirement 1 - ERROR if not met}
- [ ] {Requirement 2 - ERROR if not met}
- [ ] {Requirement 3 - WARNING if not met}

---

## Related Documentation

- **ADR:** [adr-XXX-{topic}](../../ADRs/adr-XXX-{topic}/) - Strategic decision
- **Module:** [mod-XXX-...](../../../modules/mod-XXX-.../) - Derived module
- **Capability:** See `runtime/discovery/capability-index.yaml` for feature definition

---

## Changelog

| Date | Version | Change | Author |
|------|---------|--------|--------|
| {date} | 1.0 | Initial version | {author} |
```

---

## Section Guidelines

### Overview

- Explain what the ERI provides in 2-3 sentences
- State which ADR it implements
- Clarify when to use (and when not to)

### Code Reference

- Code MUST be complete and compilable
- Include ALL necessary imports
- Add comments explaining non-obvious code
- Use realistic naming (not "foo/bar")
- Follow the organization's coding standards

### Configuration

- Show complete, working configuration
- Explain each section/property
- Include sensible defaults
- Document environment-specific overrides

### Compliance Checklist

- List MUST have requirements (ERROR level)
- List SHOULD have requirements (WARNING level)
- Each item must be verifiable
- These become validation rules for modules

---

## Validation Checklist

Before marking an ERI as "Active":

- [ ] Implements at least one ADR
- [ ] Code examples are complete and compilable
- [ ] All dependencies are specified with versions
- [ ] Configuration is complete and documented
- [ ] Compliance checklist is defined
- [ ] At least one module references this ERI
- [ ] Test examples are provided
- [ ] Technology versions are specified

---

## Relationships

```
ADR
 │
 │ implements (N:1)
 │ Multiple ERIs can implement one ADR
 │
 ▼
ERI
 │
 │ derived_to (1:N)
 │ One ERI typically has one Module, complex ERIs may have multiple
 │
 ▼
Module
 │
 │ implements (N:1)
 │ Modules implement capability features via capability-index.yaml
 │
 ▼
Capability.Feature
```

### Required Relationships

| Relationship | Requirement |
|--------------|-------------|
| `implements` | MUST reference at least one ADR |
| `derived_modules` | SHOULD have at least one module that derives from this ERI |

### Optional Relationships

| Relationship | When to Use |
|--------------|-------------|
| `related` | For related ERIs in the same pattern family |
| `cross_domain_usage` | When used by modules in other domains (e.g., QA validation) |

---

## Cross-Domain Usage

ERIs have a primary domain but may be used by other domains:

```yaml
cross_domain_usage: qa
```

This allows QA modules to validate code against the same ERI that CODE modules use to generate it.

---

## Examples

### Good ERI Naming

- ✅ `eri-code-001-hexagonal-light-java-spring` (pattern + technology)
- ✅ `eri-code-008-circuit-breaker-java-resilience4j` (specific implementation)
- ❌ `eri-code-001-architecture` (too vague)
- ❌ `eri-001-java-spring` (missing pattern)

### Good Code Reference

- ✅ Complete class with imports, annotations, methods
- ✅ Realistic naming (`CustomerService`, not `MyService`)
- ✅ Production-ready (error handling, logging)
- ❌ Snippets without context
- ❌ Pseudo-code or incomplete examples

---

## Machine-Readable Annex (MANDATORY)

Every ERI **MUST** include a machine-readable annex at the end of the document. This annex defines constraints that automation (Modules) must respect when implementing the ERI.

### Purpose

The annex serves as:
- **Source of truth** for deriving MODULE validators
- **Contract** that Modules must satisfy
- **AI-interpretable** specification for automated code generation
- **Compliance checklist** in structured format

### Required Location

The annex MUST be the **last section** of the ERI, after "Changelog":

```markdown
## Changelog
...

---

## Annex: Implementation Constraints

> This annex defines rules that MUST be respected when creating Modules
> based on this ERI. Compliance is mandatory.

```yaml
eri_constraints:
  ...
```
```

### Annex Schema

```yaml
eri_constraints:
  id: eri-{domain}-XXX-{pattern}-constraints
  version: "1.0"
  eri_reference: eri-{domain}-XXX-...
  adr_reference: adr-XXX-...
  
  # Implementation options (v1.2) - REQUIRED if ERI has multiple options
  implementation_options:
    default: option-id           # Which option is the default
    options:
      - id: option-id            # Unique identifier (becomes variant id in module)
        name: "Human Name"
        status: default|alternative|deprecated
        recommended_when:        # Conditions that suggest this option
          - "Condition 1"
          - "Condition 2"
        deprecated_reason: "..."  # Only if status: deprecated
        
  # Structural rules (code organization, annotations, layers)
  structural_constraints:
    - id: unique-identifier
      rule: "Human-readable description of the rule"
      validation: "How to verify (grep command, AST check, etc.)"
      severity: ERROR|WARNING
      layer: domain|application|adapter|infrastructure  # Optional
      applies_to: [option-id]    # Optional: limit to specific options
      
  # Configuration rules (application.yml, properties)
  configuration_constraints:
    - id: unique-identifier
      rule: "Human-readable description"
      validation: "How to verify"
      severity: ERROR|WARNING
      applies_to: [option-id]    # Optional: limit to specific options
      
  # Required and optional dependencies
  dependency_constraints:
    required:
      - groupId: org.example
        artifactId: example-lib
        minVersion: "1.0.0"
        reason: "Why this dependency is needed"
        applies_to: [option-id]  # Optional: limit to specific options
    optional:
      - groupId: org.example
        artifactId: optional-lib
        reason: "When this would be useful"
        
  # Testing requirements
  testing_constraints:
    - id: unique-identifier
      rule: "Testing requirement"
      validation: "How to verify"
      severity: ERROR|WARNING
```

### Severity Levels

| Level | Meaning | Validation Behavior |
|-------|---------|---------------------|
| **ERROR** | MUST be satisfied | Validation fails if violated |
| **WARNING** | SHOULD be satisfied | Validation warns but passes |

### Example Annex (Single Option ERI)

```yaml
eri_constraints:
  id: eri-code-001-hexagonal-constraints
  version: "1.0"
  eri_reference: eri-code-001-hexagonal-light-java-spring
  adr_reference: adr-009-service-architecture-patterns
  
  structural_constraints:
    - id: domain-no-framework-annotations
      rule: "Domain layer classes MUST NOT have framework annotations (@Service, @Repository, @Entity)"
      validation: "grep -r '@Service\|@Repository\|@Entity\|@Component' src/*/domain/ returns empty"
      severity: ERROR
      layer: domain
      
    - id: service-in-application-layer
      rule: "@Service annotation MUST be in application layer only"
      validation: "grep -r '@Service' src/*/domain/ returns empty"
      severity: ERROR
      layer: application
      
  configuration_constraints:
    - id: actuator-health-enabled
      rule: "Actuator health endpoint SHOULD be enabled"
      validation: "application.yml contains management.endpoints.web.exposure.include with 'health'"
      severity: WARNING
      
  dependency_constraints:
    required:
      - groupId: org.springframework.boot
        artifactId: spring-boot-starter-web
        reason: "REST API support"
      - groupId: org.mapstruct
        artifactId: mapstruct
        minVersion: "1.5.0"
        reason: "DTO/Entity mapping"
        
  testing_constraints:
    - id: domain-tests-no-spring
      rule: "Domain layer unit tests MUST run without Spring context"
      validation: "Domain test classes do not use @SpringBootTest"
      severity: ERROR
```

### Example Annex (Multi-Option ERI)

```yaml
eri_constraints:
  id: eri-code-013-api-integration-constraints
  version: "1.0"
  eri_reference: eri-code-013-api-integration-rest-java-spring
  adr_reference: adr-012-integration-patterns
  
  # Implementation options - defines valid variants for derived modules
  implementation_options:
    default: restclient
    options:
      - id: restclient
        name: "RestClient (Spring 6.1+)"
        status: default
        recommended_when:
          - "New projects on Spring Boot 3.2+"
          - "Team prefers fluent API style"
          
      - id: feign
        name: "OpenFeign"
        status: alternative
        recommended_when:
          - "Existing codebase uses Feign extensively"
          - "Team prefers declarative interface style"
          
      - id: resttemplate
        name: "RestTemplate"
        status: deprecated
        recommended_when:
          - "Legacy compatibility required"
        deprecated_reason: "RestClient is the modern replacement. Use only for legacy."
  
  structural_constraints:
    - id: client-in-adapter-layer
      rule: "REST clients MUST be in adapter/out layer"
      validation: "Client classes are in adapter/out/integration/"
      severity: ERROR
      
    - id: feign-interface-naming
      rule: "Feign clients MUST end with 'Client' suffix"
      validation: "grep -r '@FeignClient' | grep 'interface.*Client'"
      severity: ERROR
      applies_to: [feign]  # Only applies to Feign option
      
  dependency_constraints:
    required:
      - groupId: org.springframework.boot
        artifactId: spring-boot-starter-web
        reason: "REST support"
      - groupId: org.springframework.cloud
        artifactId: spring-cloud-starter-openfeign
        reason: "Feign client support"
        applies_to: [feign]  # Only required for Feign option
```

### Relationship to MODULE Validators

The constraints in the ERI annex are the **source** from which MODULE validators are derived:

```
ERI Annex (eri_constraints)
    │
    │ derived to
    ▼
MODULE Validator (tier-3-module)
    │
    │ executed by
    ▼
Flow Validation (flow-generate / flow-transform)
```

When creating a MODULE from an ERI:
1. Read the ERI's `eri_constraints`
2. Implement each constraint as a check in the MODULE's validator script
3. Reference the original constraint ID for traceability

---

## Related

- `model/standards/ASSET-STANDARDS-v1.4.md` - ERI structure specification
- `authoring/ADR.md` - How to create ADRs that ERIs implement
- `authoring/MODULE.md` - How to create Modules from ERIs
- `authoring/CAPABILITY.md` - How modules implement capability features
- `knowledge/ERIs/` - Existing ERIs

---

**Last Updated:** 2026-01-22
