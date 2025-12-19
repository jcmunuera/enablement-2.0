# Authoring Guide: SKILL

**Version:** 2.4  
**Last Updated:** 2025-12-19  
**Asset Type:** Skill  
**Priority:** CRITICAL

---

## What's New in v2.4

| Change | Description |
|--------|-------------|
| **Hierarchical structure** | Skills now at `skills/{domain}/{layer}/skill-{NNN}-{name}/` |
| **Layer taxonomy** | CODE domain uses SoE/SoI/SoR layers |
| **Simplified naming** | `skill-{NNN}-{name}` (domain/layer implicit in path) |
| **Index registration** | Required registration in `skill-index.yaml` |

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
│  │  - References domain skill-type for execution flow       │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                   │
│                              ▼                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Execution Flow (centralized at domain level)            │    │
│  │  Location: domains/{domain}/flows/{TYPE}.md        │    │
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

Skills are organized hierarchically by domain and layer:

```
skills/
├── code/
│   ├── soe/                    # System of Engagement (frontend)
│   │   └── skill-{NNN}-{name}/
│   ├── soi/                    # System of Integration (microservices)
│   │   └── skill-{NNN}-{name}/
│   └── sor/                    # System of Record (mainframe)
│       └── skill-{NNN}-{name}/
├── design/                     # Flat structure (no layers)
│   └── skill-{NNN}-{name}/
├── qa/
│   └── skill-{NNN}-{name}/
└── governance/
    └── skill-{NNN}-{name}/
```

### Skill Internal Structure

```
skill-{NNN}-{name}/
├── SKILL.md            # Complete specification (required)
├── OVERVIEW.md         # Quick reference for discovery (required) ⭐
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

> **UPDATED in v2.4:** Skills are now organized under `skills/{domain}/{layer}/`.
> For CODE domain, layer is one of: `soe`, `soi`, `sor`.
> Other domains use flat structure (no layer subdirectory).

### Layer Taxonomy (CODE Domain Only)

| Layer | Name | Description | Technologies |
|-------|------|-------------|--------------|
| `soe` | System of Engagement | UI, frontend, digital channels | Angular, React, Vue |
| `soi` | System of Integration | Microservices, APIs, orchestration | Java Spring, Node.js, Quarkus |
| `sor` | System of Record | Core systems, mainframe | COBOL, CICS, DB2, JCL |

## Naming Convention

```
skills/{domain}/{layer}/skill-{NNN}-{name}/
```

- `{domain}`: `code`, `design`, `qa`, `governance`
- `{layer}`: `soe`, `soi`, `sor` (CODE domain only)
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
    - mod-code-001-circuit-breaker-java-resilience4j
  embedded: []                  # DESIGN/QA/GOV domains only

# MODULE REFERENCES (CODE domain)
modules_used:
  - mod-{domain}-{NNN}-...

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

### 2. OVERVIEW.md - Quick Reference (CRITICAL for Discovery)

> **UPDATED in v2.3:** OVERVIEW.md is the PRIMARY document for skill discovery.
> The agent reads this file to determine if a skill matches user intent.
> Write it with discovery in mind.

**OVERVIEW.md Structure:**

```markdown
# skill-{domain}-{NNN}-{type}-{target}

## Overview

**Skill ID:** skill-{domain}-{NNN}-{type}-{target}-{framework}-{library}  
**Type:** {TYPE}  
**Framework:** {framework} (if applicable)  
**Architecture:** {architecture pattern}

---

## Purpose

[One clear paragraph: what this skill does. Be specific about the OUTPUT.]

---

## When to Use

✅ **Use this skill when:**
- [Specific condition 1]
- [Specific condition 2]
- [Specific condition 3]

❌ **Do NOT use when:**
- [Condition where another skill is better]
- [Condition where skill doesn't apply]
- [Edge case to avoid]

---

## Capabilities

| Capability | Description |
|------------|-------------|
| **Feature 1** | What it does |
| **Feature 2** | What it does |

---

## Input Summary

```json
{
  "key": "example",
  ...
}
```

---

## Output Summary

```
{output-structure}/
├── file1
└── file2
```

---

## Dependencies

### Knowledge Dependencies
- **ADR-XXX:** [relevance]
- **ERI-XXX:** [relevance]

### Module Dependencies
- **mod-XXX:** [purpose]

---

## Tags

`tag1` `tag2` `tag3`

---

## Version

**Current:** X.Y.Z  
**Status:** Active  
**Last Updated:** YYYY-MM-DD
```

**Discovery-Critical Sections:**

| Section | Discovery Importance |
|---------|---------------------|
| **Purpose** | PRIMARY - Agent matches user intent against this |
| **When to Use** | HIGH - Explicit conditions for selection |
| **When NOT to Use** | HIGH - Prevents wrong selection |
| **Tags** | MEDIUM - Keyword matching support |
| **Output Summary** | MEDIUM - Verifies output type matches user need |

**Writing Tips for Discovery:**

1. **Purpose:** Write what the skill PRODUCES, not how it works
   - Good: "Generates a complete Spring Boot microservice project"
   - Bad: "Uses templates to create code files"

2. **When to Use:** Be specific about scenarios
   - Good: "Creating a new microservice from scratch"
   - Bad: "When you need code"

3. **When NOT to Use:** Redirect to correct skill
   - Good: "Modifying existing code (use ADD skills)"
   - Bad: "When it doesn't apply"

4. **Tags:** Include synonyms and related terms
   - Good: `generation` `creation` `spring-boot` `java` `microservice`
   - Bad: `skill` `code`

### 3. README.md - External Documentation

User-facing documentation explaining what the skill does and how to use it.

### 4. prompts/ - AI Orchestration

This is where the **prompt engineering** happens.

### 5. Execution Flow Reference (REQUIRED)

**UPDATED in v2.2:** Execution flows are now centralized at domain level, not per-skill.

#### Location

Execution flows are located in:
```
model/domains/{domain}/flows/{TYPE}.md
```

| Skill Type | Flow Location |
|------------|---------------|
| GENERATE | `runtime/flows/code/GENERATE.md` |
| ADD | `runtime/flows/code/ADD.md` |
| REMOVE | `runtime/flows/code/REMOVE.md` |
| REFACTOR | `runtime/flows/code/REFACTOR.md` |
| MIGRATE | `runtime/flows/code/MIGRATE.md` |

#### Purpose

Centralized execution flows ensure:
- **Determinism:** Same input → Same output, every time
- **Consistency:** All skills of same type follow identical flow
- **Maintainability:** Update flow once, applies to all skills
- **Reduced redundancy:** ~12-15 flows vs potentially hundreds of skills

#### Referencing from SKILL.md

Each SKILL.md must include an "Execution Flow" section that references the appropriate skill-type:

```markdown
## Execution Flow

This skill follows the **{TYPE}** execution flow defined at domain level.

**See:** [`model/domains/{domain}/flows/{TYPE}.md`](../../domains/{domain}/flows/{TYPE}.md)
```

#### Skill Type Determines Flow

| Skill Type | Description | Flow Characteristics |
|------------|-------------|---------------------|
| **GENERATE** | Creates new project | Multiple modules, Template Catalog processing, config merging |
| **ADD** | Modifies existing code | Single module typically, targeted changes, existing code analysis |
| **REMOVE** | Removes code/config | Inverse of ADD, cleanup validations |
| **REFACTOR** | Transforms code structure | Analysis, transformation plan, preservation validations |
| **MIGRATE** | Version/framework migration | Assessment, transformation, compatibility checks |

#### Additional Resources

- Generic framework: `runtime/discovery/execution-framework.md`
- Discovery rules: `runtime/discovery/discovery-rules.md`

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

- **mod-{domain}-{NNN}-...:** {what it provides}
- **mod-{domain}-{NNN}:** {what it provides}

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

**From mod-code-015 (Hexagonal Base):**
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
        bash "$KNOWLEDGE_BASE/skills/modules/mod-code-001-circuit-breaker-java-resilience4j/validation/circuit-breaker-check.sh" "$PROJECT_DIR"
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
| Module | mod-{domain}-{NNN}-... | {template source} |

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
| always | mod-{domain}-{NNN}-base-... | Base templates |
| feature.x.enabled | mod-{domain}-{NNN}-feature-... | Feature-specific templates |
| persistence.type = "jpa" | mod-code-016-persistence-jpa-spring | JPA persistence |
| persistence.type = "system_api" | mod-code-017-persistence-systemapi | System API persistence |

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
// Module: mod-code-015-hexagonal-base-java-spring
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

### Structure
- [ ] Skill is in correct location: `skills/{domain}/{layer}/skill-{NNN}-{name}/`
- [ ] SKILL.md is complete with all sections
- [ ] SKILL.md references appropriate execution flow
- [ ] OVERVIEW.md provides quick reference for discovery ⭐
- [ ] README.md has user-facing documentation

### Prompts
- [ ] prompts/system.md has role, context, constraints
- [ ] prompts/user.md has request template
- [ ] prompts/examples/ has at least one example

### Validation
- [ ] validation/validate.sh orchestrates all tiers
- [ ] All referenced modules exist
- [ ] All referenced validators exist

### Content
- [ ] Traceability profile is specified
- [ ] Input schema is defined
- [ ] Output structure is documented
- [ ] **Module Resolution section is complete** (for generation skills)
- [ ] **Every output file traces to a template** (for generation skills)

### Index Registration (REQUIRED) ⭐
- [ ] Added to `runtime/discovery/skill-index.yaml`:
  - [ ] `layers.{layer}.skills`
  - [ ] `domains.{domain}.skills_by_layer.{layer}`
  - [ ] `capabilities.{capability}.skills` (if applicable)
  - [ ] `technologies.{tech}.skills` (if applicable)
  - [ ] `flows.{domain}.{FLOW}.skills`

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

- `model/standards/ASSET-STANDARDS-v1.4.md` - Skill structure specification
- `runtime/discovery/skill-index.yaml` - Skill index for discovery
- `model/standards/traceability/` - Traceability profiles
- `authoring/MODULE.md` - How to create modules
- `authoring/VALIDATOR.md` - How to create validators
- `skills/` - Existing skills

---

**Last Updated:** 2025-11-28
