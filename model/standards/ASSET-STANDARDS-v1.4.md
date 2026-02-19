# ASSET-STANDARDS.md

**Version:** 1.4  
**Date:** 2025-12-19  
**Status:** Active  
**Purpose:** Define mandatory structure and content for all Enablement 2.0 knowledge base assets  
**Master Document:** See `ENABLEMENT-MODEL-v2.0.md` for complete conceptual model

---

## What's New in v1.4

| Change | Description |
|--------|-------------|
| **Skill structure** | Skills now organized by domain and layer: `skills/{domain}/{layer}/` |
| **Layer taxonomy** | CODE domain uses SoE/SoI/SoR layers |
| **Skill naming** | Simplified: `skill-{NNN}-{name}` (domain/layer implicit in path) |
| **Skill index** | New `runtime/discovery/skill-index.yaml` for efficient discovery |

---

## Overview

This document defines the **mandatory standards** for creating and maintaining assets in the Enablement 2.0 knowledge base. All contributors (human or AI) MUST follow these standards to ensure consistency, discoverability, and quality.

### Asset Types

| Type | Purpose | Location |
|------|---------|----------|
| **ADR** | Architectural Decision Record | `/knowledge/ADRs/adr-XXX-{topic}/` |
| **ERI** | Enterprise Reference Implementation | `/knowledge/ERIs/eri-{domain}-XXX-{pattern}-{framework}-{library}/` |
| **Module** | Reusable content templates | `/modules/mod-{domain}-{NNN}-{pattern}-{framework}-{library}/` |
| **Skill** | Executable capability | `/skills/{domain}/{layer}/skill-{NNN}-{name}/` |
| **Capability** | High-level technical objective grouping | `/model/domains/{domain}/capabilities/{capability}.md` |
| **Validator** | Artifact validation components | `/runtime/validators/tier-{N}-{category}/{name}/` |

---

## 1. ADR Standard

### Naming Convention

```
adr-XXX-{topic}/
└── ADR.md
```

- `XXX`: 3-digit sequential number (001, 002, ...)
- `{topic}`: kebab-case descriptive name
- Example: `adr-001-api-design-standards/`

### Required YAML Front Matter

```yaml
---
id: adr-XXX-{topic}
title: "ADR-XXX: {Title}"
sidebar_label: {Short Label}
version: {X.Y}
date: {YYYY-MM-DD}           # Creation date
updated: {YYYY-MM-DD}        # Last update date
status: {Draft|Proposed|Accepted|Deprecated|Superseded}
author: {Author/Team}
framework: agnostic          # or specific framework if applicable
tags:
  - {tag1}
  - {tag2}
related:
  - {related-adr-id}
  - {related-eri-id}
supersedes: {adr-id}         # Optional: if this replaces another ADR
superseded_by: {adr-id}      # Optional: if deprecated
---
```

### Required Sections

````markdown
# ADR-XXX: {Title}

**Status:** {status}
**Date:** {date}
**Updated:** {updated}
**Deciders:** {team/people}

---

## Context
[Problem statement, business context, why decision is needed]

## Decision
[The decision made, with clear statement]

## Rationale
[Why this decision was chosen over alternatives]

## Consequences

### Positive
- [benefit 1]
- [benefit 2]

### Negative
- [drawback 1]
- [drawback 2]

### Mitigations
[How to address negative consequences]

## Implementation
[Reference to ERIs, Skills, or other implementation guidance]

## Validation
[Success criteria, compliance checks]

## References
[Related ADRs, external resources]

## Changelog
### vX.Y (YYYY-MM-DD)
- [changes]
````

### Quality Checklist

- [ ] YAML front matter complete
- [ ] Framework-agnostic (implementation details in ERIs)
- [ ] Clear decision statement
- [ ] Rationale explains "why"
- [ ] Consequences are balanced (positive AND negative)
- [ ] References to implementing ERIs/Skills
- [ ] Changelog maintained

---

## 2. ERI Standard

### Naming Convention

```
eri-{domain}-XXX-{pattern}-{framework}-{library}/
└── ERI.md
```

- `{domain}`: Primary domain (`code`, `design`, `qa`, `gov`)
- `XXX`: 3-digit sequential number within domain
- `{pattern}`: Pattern implemented (kebab-case)
- `{framework}`: Technology framework (java, nodejs, python, etc.)
- `{library}`: Specific library if applicable
- Example: `eri-code-001-hexagonal-light-java-spring/`

### Required YAML Front Matter

```yaml
---
id: eri-{domain}-XXX-{full-name}
title: "ERI-{DOMAIN}-XXX: {Title}"
sidebar_label: {Short Label}
version: {X.Y}
date: {YYYY-MM-DD}
updated: {YYYY-MM-DD}
status: {Draft|Active|Deprecated}
author: {Author/Team}
domain: {code|design|qa|gov}      # Primary domain
pattern: {pattern-name}
framework: {java|nodejs|python|etc}
library: {library-name}
library_version: {X.Y.Z}
java_version: "{17|21}"      # If Java
implements:
  - {adr-id}                 # ADR(s) this implements
tags:
  - {tag1}
  - {tag2}
related:
  - {related-eri-id}
automated_by:
  - {skill-id}               # Skills that use this ERI
cross_domain_usage:          # Optional: secondary domain usage
  - {domain}: "{usage description}"
---
```

### Required Sections

````markdown
# ERI-{DOMAIN}-XXX: {Title}

## Overview
[Purpose, what this ERI provides, when to use it]

## Technology Stack
| Component | Technology | Version |
|-----------|------------|---------|
| Language  | {lang}     | {ver}   |
| Framework | {fw}       | {ver}   |
| ...       | ...        | ...     |

## Project Structure
[Directory tree showing complete structure]

## Code Reference
[REAL, WORKING CODE for each component]

### {Component 1}
```{language}
// Complete, copy-paste ready code
```

### {Component 2}
```{language}
// Complete, copy-paste ready code
```

## Configuration
[Configuration files with explanations]

## Testing
[Test examples - unit and integration]

## Dependencies
[pom.xml, package.json, requirements.txt excerpt]

## Compliance Checklist
[Verification rules for this ERI]

## Related Documentation
[Links to ADRs, Skills, Modules]

## Changelog
### vX.Y (YYYY-MM-DD)
- [changes]

---

## Annex: Implementation Constraints (MANDATORY)

> Machine-readable constraints for automation. See authoring/ERI.md for full schema.

```yaml
eri_constraints:
  id: eri-{domain}-XXX-{pattern}-constraints
  version: "1.0"
  eri_reference: eri-{domain}-XXX-...
  adr_reference: adr-XXX-...
  
  structural_constraints:
    - id: ...
      rule: "..."
      validation: "..."
      severity: ERROR|WARNING
      
  configuration_constraints:
    - id: ...
      
  dependency_constraints:
    required:
      - groupId: ...
        artifactId: ...
        
  testing_constraints:
    - id: ...
```
````

### Quality Checklist

- [ ] YAML front matter complete
- [ ] Technology stack table present
- [ ] Complete project structure
- [ ] **REAL, WORKING CODE** (not pseudocode)
- [ ] Code is copy-paste ready
- [ ] Configuration examples included
- [ ] Test examples included
- [ ] Dependencies specified with versions
- [ ] Compliance checklist defined
- [ ] References implementing ADR(s)
- [ ] **Machine-readable annex included** ← MANDATORY

---

## 3. Module Standard

### Naming Convention

```
mod-XXX-{pattern}-{framework}-{library}/
├── OVERVIEW.md                          # Brief description (optional)
├── MODULE.md                            # Full documentation (required)
└── validation/                          # Validation scripts (required)
    ├── README.md                        # How to run validations
    └── {feature}-check.sh               # Validation script
```

- `XXX`: 3-digit sequential number
- Module as directory (not single file)
- Example: `mod-code-001-circuit-breaker-java-resilience4j/`

### Required Structure

````markdown
# MOD-XXX: {Pattern Name} - {Framework/Library}

**Module ID:** mod-XXX-{full-name}
**Version:** {X.Y}
**Date:** {YYYY-MM-DD}
**Source ERI:** {eri-id}
**Framework:** {framework}
**Library:** {library} {version}
**Used by:** {skill-ids}

---

## Purpose
[What this module provides, when to use it]

## Template Variables

### {Category 1} Variables
| Variable | Description | Example |
|----------|-------------|---------|
| `{{var1}}` | ... | ... |
| `{{var2}}` | ... | ... |

### {Category 2} Variables
| Variable | Description | Example |
|----------|-------------|---------|
| `{{var3}}` | ... | ... |

## Templates

### Template 1: {Name}

**Use case:** [When to use this template]

#### Code
```{language}
// Template with {{variables}}
```

#### Configuration
```yaml
# Associated configuration template
```

### Template 2: {Name}
[Same structure as Template 1]

## Best Practices
- [Practice 1]
- [Practice 2]

## Common Pitfalls
- [Pitfall 1]: [How to avoid]
- [Pitfall 2]: [How to avoid]

## Usage Notes
[Additional guidance for using these templates]

## Related
- **Source ERI:** {eri-id}
- **Used by Skills:** {skill-ids}
- **Complements:** {other-mod-ids}

---

**Module Version:** {X.Y}
**Last Updated:** {YYYY-MM-DD}
````

### Quality Checklist

- [ ] Header metadata complete (ID, Version, Source ERI, etc.)
- [ ] Purpose section explains when to use
- [ ] Template Variables table with ALL variables
- [ ] Templates with REAL code ({{variables}} syntax)
- [ ] Best Practices section
- [ ] Common Pitfalls section
- [ ] Usage Notes section
- [ ] Related section with links
- [ ] Consistent with other modules
- [ ] **validation/ directory exists with scripts**

### Module Validation Requirements

Each module MUST include a `validation/` directory with:

1. **README.md** - Documents what the validation checks and how to run it
2. **{feature}-check.sh** - Validation script for the feature/pattern this module implements

**Example:** `mod-code-001-circuit-breaker.../validation/circuit-breaker-check.sh`

The validation script MUST:
- Be executable (`chmod +x`)
- Accept SERVICE_DIR as first argument
- Return exit code 0 (pass) or 1 (fail)
- Output format: `✅ PASS:` / `❌ FAIL:` / `⚠️ WARN:`
- Be self-contained (no external dependencies beyond bash/grep/find)

See `knowledge/validators/README.md` for complete requirements.

---

## 3.5 Validation Hierarchy

Enablement 2.0 uses a **tiered validation system** with **domain-specific orchestration**.

### Validation by Domain

The validation strategy differs based on skill domain:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    VALIDATION ORCHESTRATION BY DOMAIN                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  CODE DOMAIN                          │  DESIGN / QA / GOV DOMAINS          │
│  ─────────────────                    │  ──────────────────────────          │
│  validate.sh ORCHESTRATES:            │  validate.sh INVOKES:               │
│                                        │                                      │
│  ✅ Tier-1 Universal (traceability)   │  ✅ Tier-1 Universal (traceability) │
│  ✅ Tier-1 Code (structure, naming)   │  ✅ Embedded (skill-specific)        │
│  ✅ Tier-2 (tech stack)               │                                      │
│  ✅ Tier-3 (modules)                  │  ❌ Tier-1 Code (not applicable)    │
│                                        │  ❌ Tier-2 (not applicable)         │
│                                        │  ❌ Tier-3 (not applicable)         │
│                                        │                                      │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Rationale:** Code artifacts have predictable, standardized structures that benefit from shared validators. Documents and reports have skill-specific formats requiring embedded validation.

### Tier 1: Universal (All Domains)

**Location:** `knowledge/validators/tier-1-universal/traceability/`  
**Purpose:** Validate traceability metadata exists in ALL outputs  
**Execution:** ALWAYS (all domains)

| Validator | Description |
|-----------|-------------|
| `traceability-check.sh` | Validates `.enablement/manifest.json` exists and is valid |

### Tier 1: Code Projects (CODE Domain Only)

**Location:** `knowledge/validators/tier-1-universal/code-projects/`  
**Purpose:** Validate code project structure and conventions  
**Execution:** CODE domain only

| Validator | Description |
|-----------|-------------|
| `project-structure-check.sh` | Validates src/main/java, src/test/java, pom.xml |
| `naming-conventions-check.sh` | Validates PascalCase, lowercase packages |

### Tier 2: Technology Validations (CODE Domain Only)

**Location:** `knowledge/validators/tier-2-technology/{category}/{stack}/`  
**Purpose:** Validate technology-specific aspects  
**Execution:** CODE domain, conditional on artifact type

| Category | Stacks | Examples |
|----------|--------|----------|
| `code-projects/` | java-spring, nodejs-*, python-* | compile-check.sh, test-check.sh |
| `deployments/` | docker, kubernetes | dockerfile-check.sh |

### Tier 3: Module Validations (CODE Domain Only)

**Location:** `knowledge/skills/modules/{module}/validation/`  
**Purpose:** Validate feature/pattern implementation (ERI constraints)  
**Execution:** CODE domain, conditional on modules used

| Module | Validates |
|--------|-----------|
| `mod-code-001-circuit-breaker-*` | Circuit breaker configuration |
| `mod-code-015-hexagonal-base-*` | Hexagonal architecture structure |

### Embedded Validations (DESIGN/QA/GOV Domains)

**Location:** `knowledge/skills/{skill}/validation/`  
**Purpose:** Skill-specific output format validation  
**Execution:** Non-CODE domains

Since documents and reports have skill-specific formats, their validation is **not reusable** and lives within each skill.

### Tier 4: Runtime Validations (Future)

**Location:** CI/CD pipeline  
**Purpose:** Execution verification  
**Status:** ⏳ PENDING IMPLEMENTATION

### Summary Table

| Tier | Location | Applies To | Execution |
|------|----------|------------|-----------|
| 1 Universal | `tier-1-universal/traceability/` | All domains | ALWAYS |
| 1 Code | `tier-1-universal/code-projects/` | CODE only | ALWAYS for CODE |
| 2 | `tier-2-technology/` | CODE only | Conditional |
| 3 | `modules/{mod}/validation/` | CODE only | Conditional |
| Embedded | `skills/{skill}/validation/` | DESIGN/QA/GOV | ALWAYS for non-CODE |
| 4 | CI/CD | All | Future |

**See `knowledge/validators/README.md` for complete details.**  
**See `model/standards/authoring/SKILL.md` for validation orchestration templates.**

---

## 4. Skill Standard

### Directory Structure

Skills are organized hierarchically by domain and layer:

```
skills/
├── README.md                    # Skills overview and layer explanation
├── code/
│   ├── README.md               # CODE domain skills, explains SoE/SoI/SoR
│   ├── soe/                    # System of Engagement (frontend)
│   │   └── skill-{NNN}-{name}/
│   ├── soi/                    # System of Integration (microservices)
│   │   └── skill-{NNN}-{name}/
│   └── sor/                    # System of Record (mainframe)
│       └── skill-{NNN}-{name}/
├── design/                     # DESIGN domain (flat for now)
│   └── skill-{NNN}-{name}/
├── qa/                         # QA domain (flat for now)
│   └── skill-{NNN}-{name}/
└── governance/                 # GOVERNANCE domain (flat for now)
    └── skill-{NNN}-{name}/
```

### Layer Taxonomy (CODE Domain)

| Layer | Name | Description |
|-------|------|-------------|
| `soe` | System of Engagement | UI, digital channels, frontend (Angular, React, Vue) |
| `soi` | System of Integration | Microservices, APIs, orchestration (Java Spring, Node.js) |
| `sor` | System of Record | Core systems, mainframe (COBOL, CICS, DB2) |

### Naming Convention

```
skills/{domain}/{layer}/skill-{NNN}-{name}/
├── OVERVIEW.md          # Discovery document (required)
├── SKILL.md             # Full specification (required)
├── README.md            # Quick start guide (required)
├── prompts/             # LLM prompts (required)
│   ├── SPEC.md          # Prompt specification - SINGLE SOURCE OF TRUTH (required)
│   ├── claude.txt       # Claude-optimized prompt (required)
│   └── gemini.txt       # Gemini-optimized prompt (required)
├── examples/            # Working examples (required) - SEE TYPE-SPECIFIC STRUCTURE
│   ├── README.md        # Examples index (required)
│   └── {example-name}/  # Each example as directory
└── validation/          # Validation scripts (required)
    ├── README.md        # Validation rules documentation
    └── validate.sh      # Main validation orchestrator (required)
```

**Naming Convention Details:**

| Component | Description | Values |
|-----------|-------------|--------|
| `{domain}` | Skill domain (directory level 1) | `code`, `design`, `qa`, `governance` |
| `{layer}` | Architectural layer (directory level 2, CODE only) | `soe`, `soi`, `sor` |
| `{NNN}` | Sequential number within domain | `001`-`999` |
| `{name}` | Descriptive name (kebab-case) | `circuit-breaker-java-resilience4j`, `microservice-java-spring` |

**Examples:**
- `skills/code/soi/skill-001-circuit-breaker-java-resilience4j/`
- `skills/code/soi/skill-020-microservice-java-spring/`
- `skills/code/soe/skill-040-microfrontend-angular/`
- `skills/code/sor/skill-050-cobol-cics-program/`
- `skills/design/skill-001-c4-diagram/`
- `skills/qa/skill-001-code-quality-analysis/`

### Skill Index Registration (REQUIRED)

When creating a new skill, you MUST register it in `runtime/discovery/skill-index.yaml`:

1. Add to `layers.{layer}.skills` list
2. Add to `domains.{domain}.skills_by_layer.{layer}` list
3. Add to `capabilities.{capability}.skills` if applicable
4. Add to `technologies.{tech}.skills` if applicable
5. Add to `flows.{domain}.{FLOW}.skills` based on execution flow

**Example registration for a new SOI skill:**

```yaml
# In skill-index.yaml

layers:
  soi:
    skills:
      - skill-001-circuit-breaker-java-resilience4j
      - skill-NEW-your-new-skill           # Add here

domains:
  code:
    skills_by_layer:
      soi:
        - skill-001-circuit-breaker-java-resilience4j
        - skill-NEW-your-new-skill         # Add here

capabilities:
  resilience:                              # If applicable
    skills:
      - skill-NEW-your-new-skill           # Add here

technologies:
  java-spring:                             # If applicable
    skills:
      - skill-NEW-your-new-skill           # Add here

flows:
  code:
    ADD:                                   # Based on flow type
      skills:
        - skill-NEW-your-new-skill         # Add here
```

### Type-Specific Example Structure

**TRANSFORMATION Skills (e.g., skill-code-001-add-*):**
```
examples/
├── README.md
└── {example-name}/
    ├── before/              # Original code BEFORE transformation
    │   └── {File}.java
    ├── after/               # Code AFTER transformation applied
    │   └── {File}.java
    └── application.yml      # Additional config if needed
```

**CREATION Skills (e.g., skill-code-020-generate-*):**
```
examples/
├── README.md
└── {example-name}/
    ├── README.md            # Example description
    ├── input.json           # Input configuration for generation
    └── template/            # Generated code output (full project)
        ├── pom.xml
        └── src/
            ├── main/java/...
            └── test/java/...
```

### Skill Validation Requirements

Skills MUST orchestrate validations from the three-tier system:

#### validation/validate.sh Structure

```bash
#!/bin/bash
# Skill validation orchestrator (CODE domain)

SERVICE_DIR=$1
BASE_PACKAGE_PATH=$2
INPUT_JSON=${3:-".enablement/inputs/skill-input.json"}
VALIDATORS="../../../../validators"

# 1. UNIVERSAL VALIDATION (always - all domains)
bash "$VALIDATORS/tier-1-universal/traceability/traceability-check.sh" "$SERVICE_DIR"

# 2. CODE PROJECT VALIDATIONS (CODE domain only)
bash "$VALIDATORS/tier-1-universal/code-projects/project-structure/project-structure-check.sh" "$SERVICE_DIR"
bash "$VALIDATORS/tier-1-universal/code-projects/naming-conventions/naming-conventions-check.sh" "$SERVICE_DIR"

# 3. ARTIFACT VALIDATIONS (conditional on technology)
if [ -f "$SERVICE_DIR/pom.xml" ]; then
    for script in "$VALIDATORS/tier-2-technology/code-projects/java-spring/"*-check.sh; do
        bash "$script" "$SERVICE_DIR"
    done
fi

if [ -f "$SERVICE_DIR/Dockerfile" ]; then
    bash "$VALIDATORS/tier-2-technology/deployments/docker/dockerfile-check.sh" "$SERVICE_DIR"
fi

# 4. MODULE VALIDATIONS (conditional on features)
source ../../modules/mod-code-015-hexagonal.../validation/hexagonal-structure-check.sh "$SERVICE_DIR" "$BASE_PACKAGE_PATH"

if feature_enabled "circuit_breaker" "$INPUT_JSON"; then
    source ../../modules/mod-code-001-circuit-breaker.../validation/circuit-breaker-check.sh "$SERVICE_DIR"
fi
```

#### Validation Execution Order

**For CODE domain skills**, execute in this order:
1. **Universal** - Traceability (`.enablement/manifest.json`)
2. **Code Projects** - Structure, naming conventions
3. **Artifacts** - Technology-specific (Java/Spring, Docker)
4. **Module** - Feature-specific (Circuit Breaker, Hexagonal, etc.)
5. **Runtime** - CI/CD tests (future)

**For DESIGN/QA/GOV domain skills**, execute:
1. **Universal** - Traceability (`.enablement/manifest.json`)
2. **Embedded** - Skill-specific validators in `validation/`

#### Generated Project Requirements

Skills MUST copy validation scripts to generated projects:

```
{generated-project}/.enablement/validation/
├── README.md
├── validate-all.sh
├── tier-1-universal/
│   └── {scripts from knowledge/validators/tier-1-universal/}
├── tier-2-technology/
│   └── {scripts from knowledge/validators/tier-2-technology/}
└── tier-3-modules/
    └── {scripts from modules/{module}/validation/}
```

**See `knowledge/validators/README.md` for complete requirements.**

---

### OVERVIEW.md (Required)

```markdown
# skill-{domain}-{NNN}-{name}

## Overview

**Skill ID:** skill-{domain}-{NNN}-{full-name}
**Type:** {TRANSFORMATION|CREATION}
**Domain:** {CODE|DESIGN|QA|GOVERNANCE}
**Framework:** {framework}
**Library:** {library}

---

## Purpose
[1-2 sentences on what this skill does]

## When to Use
✅ **Use when:** [scenarios]
❌ **Do NOT use when:** [anti-patterns]

## Capabilities
[Bullet list of what this skill can do]

## Input Summary
[Brief input description with example]

## Output Summary
[Brief output description with structure]

## Dependencies

### Knowledge Dependencies
- **ADRs:** {list}
- **ERIs:** {list}

### Module Dependencies
- {mod-ids}

## Tags
`{tag1}` `{tag2}` `{tag3}`

## Version
**Current:** {X.Y.Z}
**Status:** {Draft|Active|Deprecated}
**Last Updated:** {YYYY-MM-DD}
```

### SKILL.md (Required)

```markdown
---
skill_id: skill-{domain}-{NNN}-{full-name}
skill_name: {Human Readable Name}
skill_type: {transformation|creation}
skill_domain: {code|design|qa|gov}
complexity: {low|medium|high}
priority: {low|medium|high}
version: {X.Y.Z}
date: {YYYY-MM-DD}
author: {Author/Team}
status: {draft|active|deprecated}
modules_used:                    # REQUIRED: At least one module
  - mod-XXX-{name}               # Every skill MUST have at least one module
  - mod-YYY-{name}               # Optional additional modules
tags:
  - {tag1}
  - {tag2}
---

# Skill: {Name}

## Overview
### Purpose
### Scope
### Architecture

## Knowledge Dependencies
### Implements ADRs
### References ERIs
### Uses Modules

## Input Specification
### Schema (JSON Schema format)
### Example Input
### Validation Rules

## Output Specification
### Generated Structure
### File Descriptions
### Example Output

## Execution Steps
### Step 1: {name}
### Step 2: {name}
[...]

## Validation
### Input Validation
### Output Validation
### Compliance Checks

## Success Metrics
[Table of metrics and thresholds]

## Error Handling
[Common errors and recovery]

## Related Skills
### Complements
### Builds Toward

## Changelog
### Version X.Y.Z (YYYY-MM-DD)
- [changes]
```

### README.md (Required)

```markdown
# skill-{domain}-{NNN}-{name}

> {One-line description}

## Quick Start

### 1. {First step}
### 2. {Second step}
### 3. {Third step}

## Input
[Minimal example]

## Output
[Expected result]

## Features
[Table of features/options]

## Documentation
- [SKILL.md](./SKILL.md) - Full specification
- [OVERVIEW.md](./OVERVIEW.md) - Discovery summary
- [examples/](./examples/) - Working examples
- [prompts/](./prompts/) - LLM prompts

## Related
[Links to ADRs, ERIs, other skills]
```

### prompts/SPEC.md (Required) - Single Source of Truth

```markdown
# SPEC.md - LLM Prompt Specification

## Skill: skill-{domain}-{NNN}-{name}

## Purpose
[What this skill does]

## Architecture Constraints
[Key rules the LLM must follow]

## Code Quality Standards
[Coding standards to apply]

## Output Format
[How LLM should structure output]

## Validation Rules
[Rules for validating generated code]

## Error Recovery
[How to handle common errors]
```

### prompts/claude.txt (Required)

```
[Claude-optimized prompt derived from SPEC.md]
[Uses Claude's strengths: detailed reasoning, code quality]
[Ready to use - paste directly into Claude]
```

### prompts/gemini.txt (Required)

```
[Gemini-optimized prompt derived from SPEC.md]
[Uses Gemini's strengths: concise instructions]
[Ready to use - paste directly into Gemini]
```

**Note:** SPEC.md is the neutral, framework-agnostic specification. claude.txt and gemini.txt are derived, LLM-specific implementations of SPEC.md.

### examples/ Requirements

**Each example MUST include:**

```
examples/
├── README.md                    # Index of all examples
├── example-01-{name}/
│   ├── README.md                # Example description
│   ├── input.json               # Actual input file
│   ├── before/                  # (TRANSFORMATION only) Code before
│   │   └── {files}
│   └── expected/                # Expected output
│       └── {files or structure}
├── example-02-{name}/
│   └── ...
```

**examples/README.md must include:**
- Table of all examples with descriptions
- When to use each example
- Expected outcomes

### validation/ Requirements

**Must include:**

```
validation/
├── README.md                    # Validation rules documentation
├── validate.sh                  # Main validation entry point
└── checks/
    ├── input_validation.sh      # Validate input format
    ├── structure_check.sh       # Validate output structure
    ├── compilation_check.sh     # Verify code compiles
    └── compliance_check.py      # ADR/ERI compliance
```

**validate.sh must:**
- Accept input/output paths as arguments
- Return exit code 0 on success, non-zero on failure
- Output structured validation report

### Quality Checklist

- [ ] OVERVIEW.md present and complete
- [ ] SKILL.md present with YAML front matter
- [ ] README.md present with quick start
- [ ] prompts/SPEC.md present with complete prompts
- [ ] prompts/system.txt present with actual prompt
- [ ] examples/ has at least 1 complete example
- [ ] Each example has input.json and expected output
- [ ] validation/validate.sh present and executable
- [ ] At least one validation check script present
- [ ] All referenced ADRs/ERIs/Modules exist

---

## 5. Capability Standard

### Naming Convention

```
capabilities/{capability_name}.md
```

- Single markdown file
- Lowercase with underscores
- Example: `capabilities/resilience.md`

### Required Structure

````markdown
# Capability: {Capability Name}

**Capability ID:** {capability_name}
**Version:** {X.Y}
**Date:** {YYYY-MM-DD}
**Based on:** {ADR-ids}

---

## Overview
[What this capability provides - high-level technical objective]

## Features

Features are functional groupings within this capability.

### {feature_1}

[Description]

#### Components

| Component | Description | Module |
|-----------|-------------|--------|
| {component_1} | ... | mod-XXX-... |
| {component_2} | ... | mod-XXX-... |

```json
{
  "capabilities": {
    "{capability_name}": {
      "{feature_1}": {
        "{component_1}": {
          "enabled": true,
          "option": "value"
        }
      }
    }
  }
}
```

**Options:**
| Option | Values | Default | Description |
|--------|--------|---------|-------------|
| ... | ... | ... | ... |

**Generates:**
- [what this enables]

### {feature_2}
[Same structure]

## Dependencies
| ADR | Relationship |
|-----|--------------|
| ... | ... |

## Modules
| Feature | Component | Module | Status |
|---------|-----------|--------|--------|
| ... | ... | ... | ... |

## Skills Using This Capability
| Skill | Usage |
|-------|-------|
| ... | ... |

## Recommended Combinations
[Common capability combinations with examples]

## Configuration Reference
[Default configurations]

## Validation Rules
[Rules for valid capability configuration]

## Example Full Configuration
```json
{
  // Complete example
}
```

## Changelog
### vX.Y (YYYY-MM-DD)
- [changes]
````

### Quality Checklist

- [ ] Header metadata complete
- [ ] Overview explains purpose
- [ ] All features and components documented
- [ ] JSON config example for each feature
- [ ] Options table for each component
- [ ] Module mapping defined
- [ ] Skills using capability listed
- [ ] Validation rules defined
- [ ] Complete example configuration

---

## 6. Pattern Standard

### Naming Convention

```
patterns/ptr-XXX-{pattern}/
├── DOCUMENTATION.md
└── diagrams/
    └── {diagram}.png
```

### Required Structure

````markdown
# Pattern: {Pattern Name}

**Pattern ID:** ptr-XXX-{pattern}
**Category:** {Resilience|Data|Integration|etc}
**Version:** {X.Y}

---

## Overview
[What this pattern solves]

## Problem
[The problem this pattern addresses]

## Solution
[How the pattern solves it]

## Structure
[Diagram or component description]

## Implementation
[Link to ERIs implementing this pattern]

## When to Use
[Appropriate scenarios]

## When NOT to Use
[Anti-patterns]

## Related Patterns
[Complementary or alternative patterns]

## References
[External resources]
````

---

## 7. Validator Standard

Validators are reusable components that verify the correctness of generated artifacts. The validation strategy **differs by skill domain** - see section 3.5.

### Organization

```
validators/
├── tier-1-universal/
│   ├── traceability/            # UNIVERSAL - All domains
│   │   ├── VALIDATOR.md
│   │   └── traceability-check.sh
│   │
│   └── code-projects/           # CODE domain only
│       ├── project-structure/
│       │   ├── VALIDATOR.md
│       │   └── project-structure-check.sh
│       └── naming-conventions/
│           ├── VALIDATOR.md
│           └── naming-conventions-check.sh
│
├── tier-2-technology/            # CODE domain only - by artifact type
│   ├── code-projects/{stack}/
│   └── deployments/{platform}/
│
└── tier-3-modules/              # CODE domain only - embedded in modules
    └── README.md                # Reference only
```

### Naming Convention

| Tier | Pattern | Example | Applies To |
|------|---------|---------|------------|
| Tier 1 Universal | `tier-1-universal/traceability/` | `traceability-check.sh` | All domains |
| Tier 1 Code | `tier-1-universal/code-projects/{name}/` | `project-structure-check.sh` | CODE only |
| Tier 2 | `tier-2-technology/{category}/{target}/` | `code-projects/java-spring/` | CODE only |
| Tier 3 | Embedded in module | `modules/mod-code-001-.../validation/` | CODE only |
| Embedded | `skills/{skill}/validation/` | `report-check.sh` | DESIGN/QA/GOV |

### Required VALIDATOR.md Structure

```yaml
---
validator_id: val-{tier}-{category}-{name}
tier: 1|2|3
category: generic|code-projects|deployments|documents|reports
target: project-structure|java-spring|docker|...
version: 1.0.0
cross_domain_usage:
  - code: "Primary usage"
  - qa: "Secondary usage"
---
```

````markdown
# Validator: {Name}

## Purpose
[What this validator checks]

## Checks
| Script | Description |
|--------|-------------|
| check-1.sh | [what it validates] |

## Usage
```bash
./{name}-check.sh <target-directory>
```

## Exit Codes
- 0: All checks passed
- 1: One or more checks failed

## Dependencies
[Required tools]

## Related
- ADR: [related ADR]
- ERI: [related ERI]
````

### Cross-Domain Usage

Tier-2 validators are organized by **artifact type**, enabling cross-domain reuse for CODE skills:

| Validator | Validates | Used by |
|-----------|-----------|---------|
| `java-spring` | Java code compiles, tests pass | CODE skills, QA skills (input validation) |
| `docker` | Dockerfile is valid | CODE skills |

**Note:** DESIGN/QA/GOV skills use **embedded validators** specific to their output format, not shared Tier-2 validators.

### Validation Orchestration Examples

**CODE domain skill:**

```bash
# Tier 1: Universal (all domains)
run_validator "tier-1-universal/traceability"

# Tier 1: Code Projects (CODE domain)
run_validator "tier-1-universal/code-projects/project-structure"
run_validator "tier-1-universal/code-projects/naming-conventions"

# Tier 2: Based on stack (CODE domain)
if is_java_spring; then
    run_validator "tier-2-technology/code-projects/java-spring"
fi

# Tier 3: Based on enabled features (CODE domain)
if feature_enabled "circuit_breaker"; then
    run_module_validator "mod-code-001-circuit-breaker"
fi
```

**QA domain skill:**

```bash
# Tier 1: Universal (all domains)
run_validator "tier-1-universal/traceability"

# Embedded: Skill-specific (non-CODE domains)
run_embedded_validator "report-structure-check.sh"
run_embedded_validator "findings-format-check.sh"
```

---

## 8. General Standards

### File Naming

| Type | Convention | Example |
|------|------------|---------|
| Directories | kebab-case | `eri-code-001-hexagonal-light-java-spring` |
| Markdown files | UPPERCASE or kebab-case | `ADR.md`, `ERI.md`, `MODULE.md`, `README.md` |
| Code files | Language convention | `PaymentService.java` |
| Config files | lowercase | `application.yml` |
| Scripts | lowercase with extension | `validate.sh` |

### Markdown Standards

1. **Use ATX-style headers** (`#`, `##`, `###`)
2. **One blank line** before headers
3. **Code blocks** with language specifier
4. **Tables** for structured data
5. **Links** use relative paths within knowledge base

### Version Numbering

- **Major (X.0.0):** Breaking changes, incompatible with previous
- **Minor (0.X.0):** New features, backward compatible
- **Patch (0.0.X):** Bug fixes, corrections

### Changelog Format

```markdown
## Changelog

### vX.Y.Z (YYYY-MM-DD)
- Added: [new feature]
- Changed: [modification]
- Fixed: [bug fix]
- Removed: [deprecated item]
```

### Cross-References

Always use full IDs:
- ADRs: `adr-001-api-design-standards`
- ERIs: `eri-code-001-hexagonal-light-java-spring`
- Modules: `mod-code-001-circuit-breaker-java-resilience4j`
- Skills: `skill-code-001-add-circuit-breaker-java-resilience4j`
- Capabilities: `resilience`

---

## 9. Review Checklist

Before committing any asset, verify:

### All Assets
- [ ] Naming convention followed
- [ ] YAML front matter complete (where applicable)
- [ ] Version and date present
- [ ] Changelog entry added
- [ ] Cross-references use full IDs
- [ ] No placeholder content ("TODO", "TBD", empty sections)

### ADRs
- [ ] Framework-agnostic
- [ ] Clear decision statement
- [ ] Implementation references ERIs/Skills

### ERIs
- [ ] Real, working code
- [ ] All code is copy-paste ready
- [ ] Tests included
- [ ] Implements referenced ADR(s)

### Modules
- [ ] All template variables documented
- [ ] Best Practices section
- [ ] Common Pitfalls section
- [ ] Source ERI referenced

### Skills
- [ ] All 3 required .md files present
- [ ] prompts/ has SPEC.md AND system.txt
- [ ] examples/ has at least 1 working example with input.json
- [ ] validation/ has validate.sh script
- [ ] No empty directories

### Capabilities
- [ ] All features and components have config examples
- [ ] Module mapping complete
- [ ] Validation rules defined

---

## 10. Related Model Documents

This document is part of Enablement 2.0 model framework:

### Master Document

- **ENABLEMENT-MODEL-v2.0.md** - Complete conceptual model
  - Asset hierarchy and relationships
  - Capability hierarchy (Capability → Feature → Component → Module)
  - Skill domains and types
  - Four-tier validation system
  - Workflow definitions

### Companion Standards

- **validators/README.md** - Complete validation system documentation
  - Three-tier validation hierarchy (Generic / Artifacts / Module)
  - Validator structure and naming
  - Cross-domain usage patterns

- **traceability/README.md** - Traceability requirements for code generation
  - BASE-MODEL.md (common fields)
  - Output-type profiles (code-project, code-transformation, document, report)
  - Reproducibility standards

- **authoring/*.md** - Asset creation guides
  - Templates and examples for each asset type
  - Checklists for completeness validation

### How These Documents Work Together

```
ENABLEMENT-MODEL-v2.0.md (Master)
    ↓
Defines: Conceptual model, asset hierarchy, capability hierarchy, 
         skill domains, validation system, workflows
    ↓
    ├── ASSET-STANDARDS-v1.4.md (this doc)
    │       ↓
    │   Defines: Detailed structure of ADRs, ERIs, Modules, 
    │            Skills, Validators, Capabilities, Patterns
    │
    ├── authoring/*.md
    │       ↓
    │   Defines: How to create each asset type (templates, examples)
    │
    ├── validation/README.md + knowledge/validators/
    │       ↓
    │   Defines: How validation system works and validator instances
    │
    └── traceability/BASE-MODEL.md + profiles/
            ↓
        Defines: How to document generation and validation
```

---

## 11. Enforcement

### Automated Checks

```bash
#!/bin/bash
# validate-asset.sh

ASSET_PATH=$1
ASSET_TYPE=$2

case $ASSET_TYPE in
  adr)
    # Check YAML front matter
    # Check required sections
    ;;
  eri)
    # Check code blocks exist
    # Check technology stack table
    ;;
  module)
    # Check template variables table
    # Check best practices section
    ;;
  skill)
    # Check all required files exist
    # Check examples have input.json
    # Check validation scripts exist
    ;;
  capability)
    # Check features and components documented
    # Check module mapping
    ;;
esac
```

### Manual Review

All new assets require review against this standard before merge.

---

## 12. Migration Guide

### Existing Assets

1. **Audit** current assets against standards
2. **Prioritize** by usage frequency
3. **Migrate** incrementally
4. **Validate** after each migration

### Priority Order

1. Skills (most visible to users)
2. Modules (used by skills)
3. ERIs (reference implementations)
4. ADRs (decisions)
5. Capabilities (configuration)
6. Patterns (documentation)

---

**Document Version:** 1.1  
**Last Updated:** 2025-11-26  
**Maintainer:** Fusion C4E Team
