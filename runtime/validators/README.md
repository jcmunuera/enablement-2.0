# Validators

**Version:** 3.0  
**Last Updated:** 2025-11-28  
**Asset Type:** VALIDATOR

---

## Overview

Validators are reusable components that verify the correctness of generated content. The validation system is organized in **tiers** that apply progressively based on the output characteristics:

| Tier | Name | Scope | Location |
|------|------|-------|----------|
| 0 | **Conformance** | Generation process validation | `validators/tier-0-conformance/` |
| 1 | **Universal** | All domains, all outputs | `validators/tier-1-universal/` |
| 2 | **Technology** | Specific tech stacks | `validators/tier-2-technology/` |
| 3 | **Module** | Feature-specific constraints | `modules/{mod}/validation/` |
| 4 | **Runtime** | Execution verification | (future) |

---

## Core Principle: Tiered Validation

The validation system uses a tiered approach where each tier validates different aspects of the generated output. Validations are executed in order:

1. **Tier-0 Conformance** - Validates the generation process followed templates correctly (DEC-027)
2. **Tier-1 Universal** - Validates structure, naming, traceability
3. **Tier-2 Technology** - Validates compilation, syntax for specific tech stack
4. **Tier-3 Module** - Validates feature-specific constraints from modules

This pattern applies to **ALL domains** (CODE, DESIGN, QA, GOV).

---

## Validation Matrix by Domain

| Domain | Tier-1 Universal | Tier-1 Domain | Tier-2 Technology | Tier-3 Module |
|--------|------------------|---------------|-------------------|---------------|
| **CODE** | ✅ traceability | ✅ code-projects | ✅ java-spring, docker, etc | ✅ from modules |
| **DESIGN** | ✅ traceability | ⚪ (future) | ⚪ (future) | ✅ from modules |
| **QA** | ✅ traceability | ⚪ (future) | ⚪ (future) | ✅ from modules |
| **GOV** | ✅ traceability | ⚪ (future) | ⚪ (future) | ✅ from modules |

**Note:** ⚪ indicates validators that may be added when shared patterns emerge for that domain.

---

## Directory Structure

```
validators/
├── README.md                              # This file
│
├── tier-1-universal/                      # Universal validators
│   ├── traceability/                      # ✅ ALL domains, ALL outputs
│   │   ├── VALIDATOR.md
│   │   └── traceability-check.sh          # Validates .enablement/manifest.json
│   │
│   └── code-projects/                     # CODE domain only
│       ├── project-structure/
│       │   ├── VALIDATOR.md
│       │   └── project-structure-check.sh
│       └── naming-conventions/
│           ├── VALIDATOR.md
│           └── naming-conventions-check.sh
│
├── tier-2-technology/                     # Technology-specific validators
│   ├── code-projects/
│   │   └── java-spring/
│   │       ├── VALIDATOR.md
│   │       ├── compile-check.sh
│   │       ├── test-check.sh
│   │       ├── actuator-check.sh
│   │       └── application-yml-check.sh
│   └── deployments/
│       └── docker/
│           ├── VALIDATOR.md
│           └── dockerfile-check.sh
│
└── tier-3-module/                         # Reference to module validators
    └── README.md                          # Points to modules/{mod}/validation/
```

---

## Tier Definitions

### Tier-0 Conformance: Generation Process Validation

**Applies to:** ALL generated code  
**Location:** `validators/tier-0-conformance/`  
**Purpose:** Ensure generated code follows templates correctly (DEC-024/DEC-025)

This tier validates that the generation process produced code that conforms to the expected templates. It checks:
- **Fingerprints:** Unique patterns that MUST appear if templates were followed
- **Anti-improvisation:** Detects known incorrect patterns (e.g., wrong class inheritance)
- **Naming conventions:** Verifies correct naming from templates

**Scripts:**
- `template-conformance-check.sh` - Validates template conformance for all modules

**When it fails:** The generated code was "improvised" instead of following templates strictly. This indicates a DEC-024/DEC-025 violation.

---

### Tier-1 Universal: Traceability

**Applies to:** ALL outputs from ALL domains  
**Location:** `validators/tier-1-universal/traceability/`  
**Purpose:** Ensure every output has proper provenance metadata

This is the **only truly universal validator**. It validates:
- `.enablement/` directory exists
- `manifest.json` is valid and contains required fields
- Traceability data is complete (generation, skill, status)

### Tier-1 Domain: Structural

**Applies to:** Specific domain outputs  
**Location:** `validators/tier-1-universal/{domain}/`  
**Purpose:** Domain-wide structural standards

Currently implemented for CODE domain:

| Validator | Description |
|-----------|-------------|
| `code-projects/project-structure/` | Validates src/main/java, src/test/java, pom.xml |
| `code-projects/naming-conventions/` | Validates PascalCase classes, lowercase packages |

Other domains (DESIGN, QA, GOV) can add domain-wide validators here when patterns emerge.

### Tier-2 Technology

**Applies to:** Outputs using specific technology stacks  
**Location:** `validators/tier-2-technology/`  
**Purpose:** Technology-specific validation

| Category | Stacks | Description |
|----------|--------|-------------|
| `code-projects/` | java-spring, nodejs-*, python-* | Compilation, tests, configs |
| `deployments/` | docker, kubernetes | Container/orchestration validation |

### Tier-3 Module

**Applies to:** ALL skills (every skill has at least one module)  
**Location:** Embedded in each module at `modules/{mod}/validation/`  
**Purpose:** Feature-specific and content-specific validation

Every MODULE contains its own validation logic. This ensures:
- Validation is co-located with the content templates
- Feature constraints are verified at generation time
- Domain-specific formats are validated by the responsible module

See `validators/tier-3-module/README.md` for reference.

---

## Validation Script Standard

All validators follow this output format:

```bash
#!/bin/bash
# {name}-check.sh

TARGET_DIR="${1:-.}"
ERRORS=0

# Output functions
pass() { echo -e "✅ PASS: $1"; }
fail() { echo -e "❌ FAIL: $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo -e "⚠️  WARN: $1"; }
skip() { echo -e "⏭️  SKIP: $1"; }

# Checks...

exit $ERRORS
```

---

## Usage Examples

### CODE Skill: validate.sh

```bash
#!/bin/bash
# skill-code-020-generate-microservice-java-spring/validation/validate.sh

PROJECT_DIR="${1:-.}"
VALIDATORS="../../../../validators"
MODULES="../../../modules"

TOTAL_ERRORS=0

# Tier-1 Universal (ALL domains)
bash "$VALIDATORS/tier-1-universal/traceability/traceability-check.sh" "$PROJECT_DIR"
TOTAL_ERRORS=$((TOTAL_ERRORS + $?))

# Tier-1 Domain: CODE (code-projects structural)
for script in "$VALIDATORS/tier-1-universal/code-projects/"*/*-check.sh; do
    bash "$script" "$PROJECT_DIR"
    TOTAL_ERRORS=$((TOTAL_ERRORS + $?))
done

# Tier-2 Technology (based on tech stack)
for script in "$VALIDATORS/tier-2-technology/code-projects/java-spring/"*-check.sh; do
    bash "$script" "$PROJECT_DIR"
    TOTAL_ERRORS=$((TOTAL_ERRORS + $?))
done

# Tier-2 Deployment
bash "$VALIDATORS/tier-2-technology/deployments/docker/dockerfile-check.sh" "$PROJECT_DIR"
TOTAL_ERRORS=$((TOTAL_ERRORS + $?))

# Tier-3 Module (from associated modules)
bash "$MODULES/mod-code-015-hexagonal-base-java-spring/validation/hexagonal-check.sh" "$PROJECT_DIR"
TOTAL_ERRORS=$((TOTAL_ERRORS + $?))

# Tier-3 Module (conditional based on features)
if [ -f "$PROJECT_DIR/src/main/java/"**/CircuitBreakerConfig.java ]; then
    bash "$MODULES/mod-code-001-circuit-breaker-java-resilience4j/validation/circuit-breaker-check.sh" "$PROJECT_DIR"
    TOTAL_ERRORS=$((TOTAL_ERRORS + $?))
fi

exit $TOTAL_ERRORS
```

### DESIGN Skill: validate.sh

```bash
#!/bin/bash
# skill-design-001-generate-c4-diagrams/validation/validate.sh

OUTPUT_DIR="${1:-.}"
VALIDATORS="../../../../validators"
MODULES="../../../modules"

TOTAL_ERRORS=0

# Tier-1 Universal (ALL domains)
bash "$VALIDATORS/tier-1-universal/traceability/traceability-check.sh" "$OUTPUT_DIR"
TOTAL_ERRORS=$((TOTAL_ERRORS + $?))

# Tier-3 Module (from associated module)
bash "$MODULES/mod-design-001-c4-plantuml/validation/c4-structure-check.sh" "$OUTPUT_DIR"
TOTAL_ERRORS=$((TOTAL_ERRORS + $?))

bash "$MODULES/mod-design-001-c4-plantuml/validation/diagram-syntax-check.sh" "$OUTPUT_DIR"
TOTAL_ERRORS=$((TOTAL_ERRORS + $?))

exit $TOTAL_ERRORS
```

### QA Skill: validate.sh

```bash
#!/bin/bash
# skill-qa-001-analyze-code-coverage/validation/validate.sh

OUTPUT_DIR="${1:-.}"
VALIDATORS="../../../../validators"
MODULES="../../../modules"

TOTAL_ERRORS=0

# Tier-1 Universal (ALL domains)
bash "$VALIDATORS/tier-1-universal/traceability/traceability-check.sh" "$OUTPUT_DIR"
TOTAL_ERRORS=$((TOTAL_ERRORS + $?))

# Tier-3 Module (from associated module)
bash "$MODULES/mod-qa-001-coverage-report/validation/report-structure-check.sh" "$OUTPUT_DIR"
TOTAL_ERRORS=$((TOTAL_ERRORS + $?))

bash "$MODULES/mod-qa-001-coverage-report/validation/metrics-format-check.sh" "$OUTPUT_DIR"
TOTAL_ERRORS=$((TOTAL_ERRORS + $?))

exit $TOTAL_ERRORS
```

---

## Adding New Validators

### Tier-1: New Domain Structural Checks

1. Create directory: `validators/tier-1-universal/{domain}/`
2. Add VALIDATOR.md and {name}-check.sh
3. Document in this README

### Tier-2: New Technology Stack

1. Identify category: `code-projects/`, `deployments/`, etc.
2. Create directory: `validators/tier-2-technology/{category}/{stack}/`
3. Add VALIDATOR.md and check scripts
4. Update SKILL authoring guide if needed

### Tier-3: Module Validators

Validators for modules live **inside the module**:
```
modules/{mod}/validation/
├── README.md
├── {feature}-check.sh
└── ...
```

See `model/standards/authoring/VALIDATOR.md` for complete authoring guide.

---

## Validation Runner: run-all.sh

### Template Location

`runtime/validators/run-all.sh.tpl`

### Purpose

The `run-all.sh` script is generated for each output package to orchestrate validation execution. It:
- Iterates through all tier directories (tier1, tier2, tier3)
- Executes each validation script
- Captures results and generates a JSON report
- Returns appropriate exit code

### CRITICAL Requirements

**DO NOT use `set -e`** - This causes the script to exit on the first validation failure, preventing subsequent validations from running.

**Capture exit codes BEFORE conditionals:**
```bash
# CORRECT - capture exit code immediately
output=$("$script" "$PROJECT_DIR" 2>&1)
exit_code=$?

if [[ $exit_code -eq 0 ]]; then
    # handle pass
fi

# WRONG - exit code is lost after the conditional
if "$script" "$PROJECT_DIR"; then
    # ...
else
    exit_code=$?  # BUG: $? is now 1 from the 'if' itself
fi
```

### Template Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `{{SERVICE_NAME}}` | Name of the generated service | `customer-api` |
| `{{STACK}}` | Technology stack | `java-spring` |

### Tier-3 Scripts: ALL Modules Required

**CRITICAL:** When copying Tier-3 validation scripts, you MUST include scripts from ALL modules used in the generation, including:

- **Phase 1 modules** (structural): e.g., `mod-015`, `mod-019`
- **Phase 2 modules** (implementation): e.g., `mod-017`, `mod-018`
- **Phase 3+ modules** (cross-cutting): e.g., `mod-001`, `mod-002`, `mod-003`

Failure to include all modules results in incomplete validation coverage.

### Module Validation Script Reference

| Module | Script(s) | Phase |
|--------|-----------|-------|
| mod-code-015-hexagonal-base | `hexagonal-structure-check.sh` | 1 |
| mod-code-017-persistence-systemapi | `systemapi-check.sh`, `config-check.sh` | 2 |
| mod-code-019-api-public-exposure | `hateoas-check.sh`, `pagination-check.sh` | 1 |
| mod-code-001-circuit-breaker | `circuit-breaker-check.sh` | 3 |
| mod-code-002-retry | `retry-check.sh` | 3 |
| mod-code-003-timeout | `timeout-check.sh` | 3 |

---

## Related Documentation

- `model/standards/authoring/SKILL.md` - Validation orchestration patterns
- `model/standards/authoring/MODULE.md` - Module validation requirements
- `model/standards/authoring/VALIDATOR.md` - How to create validators
- `model/standards/traceability/BASE-MODEL.md` - Required manifest fields
