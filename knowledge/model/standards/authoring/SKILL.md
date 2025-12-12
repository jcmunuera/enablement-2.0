# Authoring Guide: SKILL

**Version:** 2.1  
**Last Updated:** 2025-12-12  
**Asset Type:** Skill  
**Priority:** CRITICAL

---

## Overview

Skills are **automated executable capabilities** that leverage the knowledge base to perform tasks. They are the primary interface between AI orchestration and the accumulated knowledge in ADRs, ERIs, and Modules.

**This is the most critical authoring guide** because Skills are what transform static knowledge into executable automation.

---

## Skill Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         SKILL                                    │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  SKILL.md - Complete specification                       │    │
│  │  - What it does, inputs, outputs, constraints            │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                   │
│                              ▼                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  EXECUTION-FLOW.md - Deterministic execution steps       │    │
│  │  - Step-by-step process, module resolution, validation   │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                   │
│                              ▼                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  prompts/ - AI orchestration instructions                │    │
│  │  - system.md: Role, context, constraints                 │    │
│  │  - user.md: Request template                             │    │
│  │  - examples/: Few-shot examples                          │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                   │
│                              ▼                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  validation/ - Quality assurance                         │    │
│  │  - validate.sh: Orchestrates Tier 1, 2, 3 validators    │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

---

## When to Create a Skill

Create a Skill when:

- A repeatable automation task is needed
- Modules exist that can be composed for the task
- The task has clear inputs, outputs, and validation criteria
- Multiple users/projects would benefit from automation

Do NOT create a Skill for:

- One-off tasks
- Tasks without clear success criteria
- Tasks that can't be validated automatically

---

## Directory Structure

```
knowledge/skills/
└── skill-{domain}-{NNN}-{type}-{target}-{framework}-{library}/
    ├── SKILL.md            # Complete specification (required)
    ├── EXECUTION-FLOW.md   # Deterministic execution steps (required) ← NEW
    ├── OVERVIEW.md         # Quick reference (required)
    ├── README.md           # External-facing documentation (required)
    ├── prompts/            # AI prompts (required)
    │   ├── system.md       # System prompt
    │   ├── user.md         # User prompt template
    │   └── examples/       # Few-shot examples
    │       └── *.md
    └── validation/         # Validation orchestration (required)
        ├── README.md
        └── validate.sh     # Main orchestrator
```

> **NEW in v2.1:** Every skill MUST have an `EXECUTION-FLOW.md` that defines the deterministic 
> step-by-step execution process. See [orchestration/execution-framework.md](../../../orchestration/execution-framework.md) 
> for the generic framework that all skills follow.

## Naming Convention

```
skill-{domain}-{NNN}-{type}-{target}-{framework}-{library}
```

- `{domain}`: `code`, `design`, `qa`, `gov`
- `{NNN}`: 3-digit number (unique within domain)
- `{type}`: Action type (see below)
- `{target}`: What is acted upon
- `{framework}`: Technology (if applicable)
- `{library}`: Specific library (if applicable)

### Skill Types by Domain

| Domain | Types | Examples |
|--------|-------|----------|
| **CODE** | generate, add, remove, refactor, migrate, update | skill-code-020-generate-microservice-java-spring |
| **DESIGN** | generate, create, transform, document | skill-design-001-generate-hld |
| **QA** | analyze, validate, audit, review, assess | skill-qa-001-analyze-code-quality |
| **GOV** | document, verify, enforce, report | skill-gov-001-document-api |

---

## Required Files

### 1. SKILL.md - Complete Specification

This is the **master document** that fully specifies the skill.

```yaml
---
id: skill-{domain}-{NNN}-{type}-{target}-{framework}-{library}
title: "Skill: {Title}"
version: X.Y.Z
date: YYYY-MM-DD
updated: YYYY-MM-DD
status: Draft|Active|Deprecated
domain: code|design|qa|gov
type: generate|add|remove|analyze|...
target: microservice|circuit-breaker|hld|...
framework: java|nodejs|python|...    # For CODE domain
library: spring|resilience4j|...     # For CODE domain

# OUTPUT SPECIFICATION (required)
output:
  type: code-project|document|report
  technology: java-spring|nodejs-express|...  # For CODE domain only
  format: markdown|html|pdf|...               # For DESIGN/QA/GOV domains

# VALIDATION SPECIFICATION (required)
# See "Validation Orchestration by Domain" section for rules
validation:
  tier1_universal:
    - traceability              # ALWAYS included (all domains)
  tier1_code:                   # CODE domain only
    - project-structure
    - naming-conventions
  tier2:                        # CODE domain only
    - code-projects/java-spring
    - deployments/docker
  tier3:                        # CODE domain only (modules used)
    - mod-001-circuit-breaker-java-resilience4j
  embedded: []                  # DESIGN/QA/GOV domains only

# MODULE REFERENCES (CODE domain)
modules_used:
  - mod-XXX-...

# GOVERNANCE REFERENCES
adr_compliance:
  - adr-XXX-...
eri_reference:
  - eri-{domain}-XXX-...
traceability_profile: code-project|code-transformation|document|report
tags:
  - {tag1}
---
```

### 2. OVERVIEW.md - Quick Reference

```markdown
# skill-{domain}-{NNN}-{type}-{target}

**Domain:** {domain}  
**Type:** {type}  
**Version:** X.Y.Z

## Purpose

[One paragraph: what this skill does]

## Input

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `serviceName` | string | ✅ | Name of the service |

## Output

[What is generated/produced]

## Modules Used

- mod-XXX-... ({purpose})

## Validators

- Tier 1: project-structure, naming-conventions
- Tier 2: java-spring, docker
- Tier 3: {module-specific}

## Quick Start

```bash
# Example invocation
{example command or API call}
```
```

### 3. README.md - External Documentation

User-facing documentation explaining what the skill does and how to use it.

### 4. prompts/ - AI Orchestration

This is where the **prompt engineering** happens.

### 5. EXECUTION-FLOW.md - Deterministic Execution (REQUIRED)

**NEW in v2.1:** Every skill MUST have an `EXECUTION-FLOW.md` that defines the deterministic, 
step-by-step execution process. This ensures reproducibility and traceability.

See the [orchestration/execution-framework.md](../../../orchestration/execution-framework.md) for the generic framework.

#### Purpose

The EXECUTION-FLOW.md ensures:
- **Determinism:** Same input → Same output, every time
- **Traceability:** Every decision is documented and auditable
- **Reproducibility:** Any agent can execute the skill identically
- **Debugging:** Clear steps make it easy to identify issues

#### Required Sections

```markdown
# Execution Flow: skill-{domain}-{NNN}-{name}

**Skill Type:** {GENERATE|ADD|REMOVE|ANALYZE|...}  
**Version:** X.Y  
**Last Updated:** YYYY-MM-DD

---

## Overview

[Brief description of what this execution flow does]

---

## Prerequisites

[What must exist before execution begins]

| Input | Source | Required | Description |
|-------|--------|----------|-------------|
| `input-file.json` | User | ✅ | Configuration |

---

## Execution Steps

### Step 1: Validate Input

```
ACTION: [What is done]
INPUT:  [What is consumed]
OUTPUT: [What is produced]

RULES:
1. [Specific rule]
2. [Specific rule]
```

### Step 2: [Next Step]

[Continue for all steps...]

---

## Error Handling

| Error | Action |
|-------|--------|
| [Error type] | [How to handle] |

---

## Outputs Summary

| Output | Path | Purpose |
|--------|------|---------|
| [Output name] | [Path] | [Why it exists] |
```

#### Skill Type Determines Structure

| Skill Type | Key Differences |
|------------|-----------------|
| **GENERATE** | Creates new project, multiple modules, Template Catalog processing |
| **ADD** | Modifies existing code, single module typically, targeted changes |
| **REMOVE** | Removes code/config, inverse of ADD |
| **ANALYZE** | Reads code, produces report, no modifications |
| **VALIDATE** | Runs checks, produces validation report |

#### Example: GENERATE Skill Flow

For skills that generate new projects (like `skill-code-020`):

1. **Validate Input** - Check generation-request.json
2. **Resolve Modules** - Determine which modules based on features
3. **Build Variable Context** - Extract all template variables
4. **Process Each Module** - For each module, process its Template Catalog
5. **Merge Configuration Files** - Combine application.yml, pom.xml
6. **Generate Manifest** - Create traceability manifest.json
7. **Run Validations** - Execute Tier 1, 2, 3 validators
8. **Generate Execution Audit** - Create execution-audit.json

#### Example: ADD Skill Flow

For skills that add features to existing code (like `skill-code-001`):

1. **Validate Input** - Check transformation-request.json
2. **Resolve Module** - Single module (fixed)
3. **Locate Target** - Find file to modify
4. **Select Template** - Based on pattern variant
5. **Build Variable Context** - Extract variables
6. **Generate Code Modifications** - Prepare changes
7. **Apply Modifications** - Modify files
8. **Run Validations** - Execute validators
9. **Generate Execution Audit** - Create audit

#### Reference

- Generic framework: `knowledge/orchestration/execution-framework.md`
- Discovery rules: `knowledge/orchestration/discovery-rules.md`
- Audit schema: `knowledge/orchestration/audit-schema.json`

---

## Prompt Engineering

### prompts/system.md

The system prompt establishes:
- Role and expertise
- Context from knowledge base
- Constraints and rules
- Output format requirements

```markdown
# System Prompt: skill-{domain}-{NNN}-{type}-{target}

## Role

You are an expert {role description} with deep knowledge of:
- {domain expertise 1}
- {domain expertise 2}
- {domain expertise 3}

## Context

You have access to the following knowledge:

### ADR Compliance
{Summarize relevant ADR decisions - NOT full content, just key constraints}

- **ADR-XXX:** {key decision and constraint}
- **ADR-YYY:** {key decision and constraint}

### Reference Implementation
{Summarize the ERI - key patterns, not full code}

- Architecture: {pattern}
- Key components: {list}
- Constraints: {list}

### Modules Available
{List modules and their purpose}

- **mod-XXX:** {what it provides}
- **mod-YYY:** {what it provides}

## Constraints

You MUST:
1. {Constraint derived from ADR}
2. {Constraint derived from ERI}
3. {Constraint for output format}

You MUST NOT:
1. {Anti-pattern from ADR}
2. {Common mistake to avoid}

## Output Format

{Specify exact output format expected}

## Validation

Generated output will be validated by:
- Tier 1: {validators}
- Tier 2: {validators}
- Tier 3: {validators}
```

### prompts/user.md

Template for user requests with placeholders:

```markdown
# User Prompt Template

## Request

{{user_request}}

## Parameters

- **Service Name:** {{serviceName}}
- **Package:** {{packageName}}
- **Features:** {{features}}

## Additional Context

{{additional_context}}
```

### prompts/examples/

Few-shot examples showing expected input/output pairs:

```markdown
# Example: {scenario}

## Input

{example input}

## Expected Output

{example output}

## Explanation

{why this output is correct}
```

---

## Prompt Derivation from Knowledge Base

**This is the critical innovation of Enablement 2.0.**

### The Derivation Process

```
┌─────────────────────────────────────────────────────────────────┐
│                    KNOWLEDGE BASE                                │
│  ┌───────────┐    ┌───────────┐    ┌───────────┐               │
│  │    ADR    │    │    ERI    │    │  Module   │               │
│  │ Strategic │    │ Reference │    │ Templates │               │
│  │ Decisions │    │   Code    │    │ + Valid.  │               │
│  └─────┬─────┘    └─────┬─────┘    └─────┬─────┘               │
│        │                │                │                      │
│        ▼                ▼                ▼                      │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                 PROMPT DERIVATION                        │   │
│  │                                                          │   │
│  │  ADR → Constraints (MUST/MUST NOT)                       │   │
│  │  ERI → Patterns + Structure + Examples                   │   │
│  │  Module → Specific implementations to use                │   │
│  │                                                          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│                              ▼                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    SKILL PROMPTS                         │   │
│  │  system.md + user.md + examples/                         │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### What to Extract from Each Source

| Source | Extract | Use In Prompt |
|--------|---------|---------------|
| **ADR** | Decision statements, rationale | Constraints section |
| **ADR** | Consequences (positive/negative) | Warnings, trade-offs |
| **ERI** | Architecture pattern | Context section |
| **ERI** | Key code patterns | Examples section |
| **ERI** | Compliance checklist | Validation references |
| **Module** | Template variables | Input parameters |
| **Module** | Validation scripts | Validation section |

### Example Derivation

**From ADR-009 (Service Architecture):**
```
Decision: "Services MUST use Hexagonal Architecture"
  ↓
Constraint: "You MUST structure code with domain, application, infrastructure layers"
```

**From ERI-001 (Hexagonal Java Spring):**
```
Code Pattern: Domain layer has no Spring dependencies
  ↓
Constraint: "Domain classes MUST NOT import org.springframework.*"
```

**From mod-015 (Hexagonal Base):**
```
Templates: Application.java.hbs, domain/Entity.hbs
  ↓
Context: "Use the hexagonal-base module templates"
```

---

## Validation Orchestration by Domain

**CRITICAL**: The validation strategy differs fundamentally based on skill domain.

### Decision Matrix

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    VALIDATION ORCHESTRATION BY DOMAIN                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  CORE PRINCIPLE: Every Skill has at least one Module.                       │
│  Validation logic lives in the Module, Skill only orchestrates.             │
│                                                                              │
│  SKILL DOMAIN: CODE                                                         │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  validate.sh ORCHESTRATES external validators:                        │  │
│  │                                                                        │  │
│  │  ✅ Tier-1 Universal    → validators/tier-1-universal/traceability/   │  │
│  │  ✅ Tier-1 Code         → validators/tier-1-universal/code-projects/  │  │
│  │  ✅ Tier-2 Technology   → validators/tier-2-technology/{category}/    │  │
│  │  ✅ Tier-3 Module       → modules/{mod}/validation/                   │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│  SKILL DOMAIN: DESIGN, QA, GOV                                              │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  validate.sh ORCHESTRATES validators:                                 │  │
│  │                                                                        │  │
│  │  ✅ Tier-1 Universal    → validators/tier-1-universal/traceability/   │  │
│  │  ✅ Tier-3 Module       → modules/{mod}/validation/                   │  │
│  │                                                                        │  │
│  │  ⚪ Tier-1 Domain       → Future: validators/tier-1-universal/{dom}/  │  │
│  │  ⚪ Tier-2 Technology   → Future: if tech-specific patterns emerge    │  │
│  │                                                                        │  │
│  │  Note: Even for DESIGN/QA/GOV, each Skill has an associated Module    │  │
│  │  (may be 1:1 relationship). Validation lives in the Module.           │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Summary Table

| Domain | Tier-1 Universal | Tier-1 Domain | Tier-2 Technology | Tier-3 Module |
|--------|------------------|---------------|-------------------|---------------|
| **CODE** | ✅ traceability | ✅ code-projects | ✅ java-spring, etc | ✅ from modules |
| **DESIGN** | ✅ traceability | ⚪ (future) | ⚪ (future) | ✅ from modules |
| **QA** | ✅ traceability | ⚪ (future) | ⚪ (future) | ✅ from modules |
| **GOV** | ✅ traceability | ⚪ (future) | ⚪ (future) | ✅ from modules |

**Key Change:** Every Skill has at least one Module. Validation logic is ALWAYS in the Module.

---

## validate.sh Templates

### For CODE Domain Skills

```bash
#!/bin/bash
# validate.sh - CODE domain skill
# Orchestrates external validators (Tier 1, 2, 3)

set -e

PROJECT_DIR="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KNOWLEDGE_BASE="$SCRIPT_DIR/../../.."
VALIDATORS="$KNOWLEDGE_BASE/validators"

TOTAL_ERRORS=0

echo "═══════════════════════════════════════════════════════════"
echo "TIER 1: UNIVERSAL (Traceability)"
echo "═══════════════════════════════════════════════════════════"

bash "$VALIDATORS/tier-1-universal/traceability/traceability-check.sh" "$PROJECT_DIR"
TOTAL_ERRORS=$((TOTAL_ERRORS + $?))

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "TIER 1: CODE PROJECTS (Structure)"
echo "═══════════════════════════════════════════════════════════"

for validator in project-structure naming-conventions; do
    bash "$VALIDATORS/tier-1-universal/code-projects/$validator/$validator-check.sh" "$PROJECT_DIR"
    TOTAL_ERRORS=$((TOTAL_ERRORS + $?))
done

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "TIER 2: ARTIFACT VALIDATION"
echo "═══════════════════════════════════════════════════════════"

# Java-Spring (conditional)
if [[ -f "$PROJECT_DIR/pom.xml" ]]; then
    for script in "$VALIDATORS/tier-2-technology/code-projects/java-spring/"*-check.sh; do
        bash "$script" "$PROJECT_DIR"
        TOTAL_ERRORS=$((TOTAL_ERRORS + $?))
    done
fi

# Docker (conditional)
if [[ -f "$PROJECT_DIR/Dockerfile" ]]; then
    bash "$VALIDATORS/tier-2-technology/deployments/docker/dockerfile-check.sh" "$PROJECT_DIR"
    TOTAL_ERRORS=$((TOTAL_ERRORS + $?))
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "TIER 3: MODULE VALIDATION"
echo "═══════════════════════════════════════════════════════════"

# Module-specific validation (conditional on features)
INPUT_JSON="$PROJECT_DIR/.enablement/inputs/skill-input.json"

if [[ -f "$INPUT_JSON" ]]; then
    # Circuit breaker validation
    if jq -e '.features | contains(["circuit-breaker"])' "$INPUT_JSON" > /dev/null 2>&1; then
        bash "$KNOWLEDGE_BASE/skills/modules/mod-001-circuit-breaker-java-resilience4j/validation/circuit-breaker-check.sh" "$PROJECT_DIR"
        TOTAL_ERRORS=$((TOTAL_ERRORS + $?))
    fi
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "VALIDATION COMPLETE"
echo "═══════════════════════════════════════════════════════════"

if [[ $TOTAL_ERRORS -eq 0 ]]; then
    echo "✅ All validations passed"
    exit 0
else
    echo "❌ $TOTAL_ERRORS validation(s) failed"
    exit 1
fi
```

### For DESIGN, QA, GOV Domain Skills

```bash
#!/bin/bash
# validate.sh - Non-CODE domain skill (DESIGN, QA, GOV)
# Orchestrates Tier-1 Universal + Tier-3 Module validators

set -e

OUTPUT_DIR="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KNOWLEDGE_BASE="$SCRIPT_DIR/../../.."
VALIDATORS="$KNOWLEDGE_BASE/validators"
MODULES="$KNOWLEDGE_BASE/skills/modules"

TOTAL_ERRORS=0

echo "═══════════════════════════════════════════════════════════"
echo "TIER 1: UNIVERSAL (Traceability)"
echo "═══════════════════════════════════════════════════════════"

# Universal validator applies to ALL domains
bash "$VALIDATORS/tier-1-universal/traceability/traceability-check.sh" "$OUTPUT_DIR"
TOTAL_ERRORS=$((TOTAL_ERRORS + $?))

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "TIER 3: MODULE VALIDATION"
echo "═══════════════════════════════════════════════════════════"

# Module validators - validation logic lives in the module
# Even for DESIGN/QA/GOV, each Skill has at least one associated Module

bash "$MODULES/mod-qa-001-coverage-report/validation/report-structure-check.sh" "$OUTPUT_DIR"
TOTAL_ERRORS=$((TOTAL_ERRORS + $?))

bash "$MODULES/mod-qa-001-coverage-report/validation/findings-format-check.sh" "$OUTPUT_DIR"
TOTAL_ERRORS=$((TOTAL_ERRORS + $?))

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "VALIDATION COMPLETE"
echo "═══════════════════════════════════════════════════════════"

if [[ $TOTAL_ERRORS -eq 0 ]]; then
    echo "✅ All validations passed"
    exit 0
else
    echo "❌ $TOTAL_ERRORS validation(s) failed"
    exit 1
fi
```

### Module Structure for Non-CODE Domains

For DESIGN/QA/GOV skills, create a corresponding module:

```
skills/modules/
└── mod-qa-001-coverage-report/     # Module for QA coverage skill
    ├── MODULE.md                   # Module specification
    ├── templates/                  # Report templates
    │   └── report-template.md
    └── validation/                 # Tier-3 validators
        ├── README.md
        ├── report-structure-check.sh    # Validates report sections
        └── findings-format-check.sh     # Validates findings format
```

Example module validator:

```bash
#!/bin/bash
# report-structure-check.sh - Embedded validator for QA reports

OUTPUT_DIR="${1:-.}"
ERRORS=0

pass() { echo -e "✅ PASS: $1"; }
fail() { echo -e "❌ FAIL: $1"; ERRORS=$((ERRORS + 1)); }

# Check report file exists
if [[ -f "$OUTPUT_DIR/report.md" ]]; then
    pass "report.md exists"
else
    fail "report.md not found"
fi

# Check required sections
for section in "Summary" "Findings" "Recommendations"; do
    if grep -q "## $section" "$OUTPUT_DIR/report.md"; then
        pass "Section '$section' present"
    else
        fail "Section '$section' missing"
    fi
done

exit $ERRORS
```

---

## Traceability Integration

Skills MUST produce traceability output following the appropriate profile:

| Skill Type | Traceability Profile |
|------------|---------------------|
| generate-* | `code-project` |
| add-*, remove-*, refactor-* | `code-transformation` |
| design-*, document-* | `document` |
| analyze-*, review-*, audit-* | `report` |

See `model/standards/traceability/profiles/` for profile specifications.

---

## Complete SKILL.md Template

```markdown
# Skill: {Title}

**Skill ID:** skill-{domain}-{NNN}-{type}-{target}-{framework}-{library}  
**Domain:** {domain}  
**Type:** {type}  
**Version:** X.Y.Z  
**Status:** Active

---

## Overview

[What this skill does, when to use it, what it produces]

## Knowledge Dependencies

| Type | Asset | Purpose |
|------|-------|---------|
| ADR | adr-XXX-... | {constraint source} |
| ERI | eri-{domain}-XXX-... | {reference implementation} |
| Module | mod-XXX-... | {template source} |

---

## Input Specification

### Required Parameters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `serviceName` | string | Service name (PascalCase) | `CustomerService` |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `features` | array | [] | Features to enable |

### Input Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["serviceName", "packageName"],
  "properties": {
    "serviceName": { "type": "string", "pattern": "^[A-Z][a-zA-Z0-9]*$" },
    "packageName": { "type": "string", "pattern": "^[a-z][a-z0-9]*(\\.[a-z][a-z0-9]*)*$" },
    "features": { "type": "array", "items": { "type": "string" } }
  }
}
```

---

## Output Specification

### Generated Artifacts

| Artifact | Path | Description |
|----------|------|-------------|
| Project structure | `{serviceName}/` | Complete project |
| Main class | `src/main/java/.../Application.java` | Entry point |

### Traceability Output

Profile: `{code-project|code-transformation|document|report}`

Location: `{output}/.enablement/manifest.json`

---

## Module Resolution (REQUIRED for generation skills)

This section defines **which modules to use** based on conditions in the input.
Each module contains its own **Template Catalog** - Skills do NOT duplicate template mappings.

### Module Selection Rules

| Condition | Module | Purpose |
|-----------|--------|---------|
| always | mod-XXX-base-... | Base templates |
| feature.x.enabled | mod-XXX-feature-... | Feature-specific templates |
| persistence.type = "jpa" | mod-016-persistence-jpa-spring | JPA persistence |
| persistence.type = "system_api" | mod-017-persistence-systemapi | System API persistence |

### Generation Workflow

```
1. Parse input (generation-request.json)
2. Resolve required modules using rules above
3. For each module:
   a. Read MODULE.md → Template Catalog section
   b. For each template in catalog:
      - Read .tpl file from module's templates/ directory
      - Substitute {{variables}} with values from input
      - Generate output file at specified path
      - Add traceability header
4. Merge configuration files (application.yml, pom.xml)
5. Generate manifest.json with complete traceability
```

### Traceability Header (Required)

Every generated file MUST include a traceability header:

```java
// =============================================================================
// GENERATED CODE - DO NOT EDIT
// Template: Entity.java.tpl
// Module: mod-015-hexagonal-base-java-spring
// Generated by: skill-code-020-generate-microservice-java-spring
// =============================================================================
```

> **IMPORTANT:** Template-to-output mapping lives in each MODULE's Template Catalog,
> NOT in the SKILL. This ensures single source of truth and easier maintenance.

---

## Execution Steps

1. **Parse Input:** Validate input against schema
2. **Load Modules:** Initialize required modules
3. **Generate:** Execute templates with parameters
4. **Validate:** Run Tier 1, 2, 3 validators
5. **Trace:** Generate traceability manifest

---

## Validation

### Validators Used

| Tier | Validator | Condition |
|------|-----------|-----------|
| 1 | project-structure | Always |
| 1 | naming-conventions | Always |
| 2 | java-spring | If Java project |
| 2 | docker | If Dockerfile present |
| 3 | {module-validator} | If feature enabled |

---

## Success Metrics

| Metric | Target |
|--------|--------|
| Compilation | 100% success |
| Tests | All pass |
| Validation | 0 errors |

---

## Error Handling

| Error | Cause | Recovery |
|-------|-------|----------|
| Invalid input | Schema validation failed | Return error with details |
| Template error | Missing variable | Return error with variable name |
| Validation failed | Constraint violated | Return validation report |

---

## Related Skills

| Skill | Relationship |
|-------|--------------|
| skill-{domain}-XXX-... | {how they relate} |

---

## Changelog

| Date | Version | Change | Author |
|------|---------|--------|--------|
| {date} | 1.0.0 | Initial version | {author} |
```

---

## Validation Checklist

Before marking a Skill as "Active":

- [ ] SKILL.md is complete with all sections
- [ ] **EXECUTION-FLOW.md defines deterministic execution steps** ← NEW
- [ ] OVERVIEW.md provides quick reference
- [ ] README.md has user-facing documentation
- [ ] prompts/system.md has role, context, constraints
- [ ] prompts/user.md has request template
- [ ] prompts/examples/ has at least one example
- [ ] validation/validate.sh orchestrates all tiers
- [ ] All referenced modules exist
- [ ] All referenced validators exist
- [ ] Traceability profile is specified
- [ ] Input schema is defined
- [ ] Output structure is documented
- [ ] **Module Resolution section is complete** (for generation skills)
- [ ] **Every output file traces to a template** (for generation skills)

---

## Relationships

```
ADR ─────────────────────────────────────────────────────
  │ compliance
  ▼
Skill ──────────────────────────────────────────────────
  │                    │                    │
  │ uses              │ orchestrates       │ produces
  ▼                    ▼                    ▼
Module              Validator           Traceability
(templates)         (Tier 1,2,3)        (manifest.json)
```

---

## Related

- `model/standards/ASSET-STANDARDS-v1.3.md` - Skill structure specification
- `model/standards/traceability/` - Traceability profiles
- `authoring/MODULE.md` - How to create modules
- `authoring/VALIDATOR.md` - How to create validators
- `knowledge/skills/` - Existing skills

---

**Last Updated:** 2025-11-28
