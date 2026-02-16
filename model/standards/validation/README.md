# Validation System Standards

**Version:** 3.0  
**Last Updated:** 2025-11-28

---

## Purpose

This document defines the **meta-model** for the Enablement 2.0 validation system. It describes HOW validation works, not the specific validators (which are assets in `knowledge/validators/`).

---

## Core Principle

> **This is meta-level documentation (HOW the system works).**
> **Actual validators are assets in `knowledge/validators/`.**

---

## The 4-Tier Validation System

Validation is organized in a hierarchical system where each tier applies conditionally:

```
┌─────────────────────────────────────────────────────────────────────┐
│ TIER 1: GENERIC                                                      │
│ Always runs - structural validation applicable to all artifacts      │
│ Examples: project structure, naming conventions                      │
├─────────────────────────────────────────────────────────────────────┤
│ TIER 2: ARTIFACTS                                                    │
│ Conditional - based on artifact type being validated                 │
│   ├── code-projects: java-spring, nodejs, etc.                       │
│   ├── deployments: docker, kubernetes, etc.                          │
│   ├── documents: architecture docs, API specs, etc.                  │
│   └── reports: analysis reports, audit reports, etc.                 │
├─────────────────────────────────────────────────────────────────────┤
│ TIER 3: MODULES                                                      │
│ Conditional - based on features/modules used                         │
│ Embedded within each module (not standalone)                         │
│ Examples: circuit-breaker validation, hexagonal validation           │
├─────────────────────────────────────────────────────────────────────┤
│ TIER 4: RUNTIME (Future)                                             │
│ CI/CD integration - integration tests, contract tests, E2E           │
│ Not yet implemented                                                  │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Validation Flow

```
Skill Execution
      │
      ▼
┌─────────────────┐
│ Generate Output │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│                    VALIDATION ORCHESTRATION                  │
│  (Skill's validate.sh determines which validators to run)   │
└─────────────────────────────────────────────────────────────┘
         │
         ├──► Tier 1: ALWAYS run generic validators
         │
         ├──► Tier 2: Run artifact-specific validators
         │         (based on technology stack / output type)
         │
         └──► Tier 3: Run module validators
                   (for each enabled feature/module)
```

---

## Validator Organization

Validators are organized by **type of artifact** they validate, NOT by domain of the skill:

| Category | Validates | Cross-Domain |
|----------|-----------|--------------|
| `tier-1-universal/` | Basic structure, naming | All domains |
| `tier-2-technology/code-projects/` | Code compilation, tests | CODE, QA |
| `tier-2-technology/deployments/` | Container, K8s configs | CODE, QA, GOV |
| `tier-2-technology/documents/` | Document structure | DESIGN, GOV |
| `tier-2-technology/reports/` | Report format | QA |
| `tier-3-modules/` | Feature-specific | Depends on module |

This enables **cross-domain reuse**: a QA skill analyzing code uses the same validators as a CODE skill generating code.

---

## Validator Asset Type

Validators are a **first-class asset type** in the knowledge base:

```
knowledge/validators/
├── tier-1-universal/
│   └── {validator-name}/
│       ├── VALIDATOR.md          # Metadata, description
│       └── {validator}-check.sh  # Executable script
│
├── tier-2-technology/
│   ├── code-projects/{stack}/
│   ├── deployments/{platform}/
│   ├── documents/{type}/
│   └── reports/{type}/
│
└── tier-3-modules/
    └── README.md                 # Reference to module-embedded validators
```

See `model/standards/authoring/VALIDATOR.md` for how to create validators.

---

## Skill Orchestration by Domain

**CRITICAL:** The validation strategy differs based on skill domain.

### CODE Domain Skills

Orchestrate external validators:

```bash
# Example: CODE domain skill's validate.sh

# 1. Tier 1 Universal: Always (all domains)
run_validator "tier-1-universal/traceability"

# 2. Tier 1 Code: Always (CODE domain only)
run_validator "tier-1-universal/code-projects/project-structure"
run_validator "tier-1-universal/code-projects/naming-conventions"

# 3. Tier 2: Based on technology
if is_java_spring_project; then
    run_validator "tier-2-technology/code-projects/java-spring"
fi
if has_dockerfile; then
    run_validator "tier-2-technology/deployments/docker"
fi

# 4. Tier 3: Based on enabled modules
for module in $(get_enabled_modules); do
    run_module_validator "$module"
done
```

### DESIGN/QA/GOV Domain Skills

Invoke Tier-1 Universal + embedded skill-specific validators:

```bash
# Example: QA domain skill's validate.sh

# 1. Tier 1 Universal: Always (all domains)
run_validator "tier-1-universal/traceability"

# 2. Embedded: Skill-specific (not reusable)
run_embedded "report-structure-check.sh"
run_embedded "findings-format-check.sh"
```

See `model/standards/authoring/SKILL.md` for complete templates.

---

## Relation to Traceability

Validation results are captured in the skill's traceability output:

```json
{
  "validations": {
    "tier_1": {
      "project-structure": { "status": "pass", "duration_ms": 150 },
      "naming-conventions": { "status": "pass", "duration_ms": 200 }
    },
    "tier_2": {
      "java-spring": { "status": "pass", "duration_ms": 5000 },
      "docker": { "status": "pass", "duration_ms": 300 }
    },
    "tier_3": {
      "circuit-breaker": { "status": "pass", "duration_ms": 400 }
    }
  }
}
```

See `model/standards/traceability/` for traceability profiles.

---

## Quick Reference

| I want to... | Go to |
|--------------|-------|
| Understand validation system | This document |
| See available validators | `knowledge/validators/` |
| Create a new validator | `model/standards/authoring/VALIDATOR.md` |
| See how validation is traced | `model/standards/traceability/` |

---

## Related Documents

- `knowledge/validators/` - Validator assets (instances)
- `model/standards/authoring/VALIDATOR.md` - How to create validators
- `model/standards/traceability/` - How validation results are traced
- `model/standards/ASSET-STANDARDS.md` - VALIDATOR asset definition

---

**Last Updated:** 2025-11-28
