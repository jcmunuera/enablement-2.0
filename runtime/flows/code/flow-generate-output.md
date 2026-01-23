# Flow Generate - Output Specification

## Version: 1.1
## Last Updated: 2026-01-23
## Applies to: `flow-generate`

---

## Overview

This document specifies the complete structure of a code generation package produced by `flow-generate`. Every generation run MUST produce a package following this specification to ensure:

1. **Reproducibility** - Same inputs produce same outputs
2. **Traceability** - Full audit trail of decisions
3. **Validation** - Automated quality checks
4. **Portability** - Package can be moved/shared

> **Note:** This specification is for `flow-generate` (new project creation). Other flows like `flow-transform` will have their own output specifications.

---

## Package Structure

```
gen_{service-name}_{YYYYMMDD_HHMMSS}/
│
├── input/                              # [MANDATORY] Original inputs
│   ├── prompt.txt                      # User prompt (verbatim)
│   ├── prompt-metadata.json            # Parsed prompt metadata
│   ├── domain-api-spec.yaml            # Domain API OpenAPI spec (if provided)
│   ├── system-api-*.yaml               # System API specs (if provided)
│   └── mapping.json                    # Domain-to-System mappings (if provided)
│
├── output/                             # [MANDATORY] Generated artifacts
│   └── {service-name}/                 # Main project directory
│       ├── pom.xml
│       ├── src/main/java/...
│       ├── src/main/resources/...
│       ├── src/test/java/...           # Unit tests
│       └── .enablement/                # [MANDATORY] Generation metadata
│           └── manifest.json
│
├── trace/                              # [MANDATORY] Generation trace
│   ├── discovery-trace.json            # Discovery phase results
│   ├── generation-trace.json           # Generation phase results  
│   ├── modules-used.json               # Modules and their contributions
│   ├── decisions-log.jsonl             # Decision log (JSON Lines format)
│   └── context-snapshots/              # [OPTIONAL] Phase context snapshots
│
└── validation/                         # [MANDATORY] Validation suite
    ├── run-all.sh                      # Master validation script
    ├── scripts/
    │   ├── tier1/                      # Universal validations
    │   │   ├── naming-conventions-check.sh
    │   │   ├── project-structure-check.sh
    │   │   └── traceability-check.sh
    │   ├── tier2/                      # Technology validations
    │   │   ├── compile-check.sh
    │   │   ├── syntax-check.sh
    │   │   ├── application-yml-check.sh
    │   │   ├── actuator-check.sh
    │   │   └── test-check.sh
    │   └── tier3/                      # Module-specific validations
    │       └── *.sh                    # One per module used
    ├── reports/
    │   └── validation-results.json
    └── compare-determinism.sh          # [OPTIONAL] For determinism testing
```

---

## Directory Specifications

### `/input` - Original Inputs

**Purpose:** Preserve all inputs for reproducibility.

| File | Required | Description |
|------|----------|-------------|
| `prompt.txt` | Yes | User's original prompt, verbatim |
| `prompt-metadata.json` | Yes | Parsed metadata from prompt |
| `domain-api-spec.yaml` | If provided | OpenAPI spec for Domain API |
| `system-api-*.yaml` | If provided | OpenAPI specs for backend System APIs |
| `mapping.json` | If provided | Domain-to-System field mappings |

**prompt-metadata.json schema:**
```json
{
  "service_name": "string",
  "base_package": "string", 
  "entities": ["string"],
  "features_requested": ["string"],
  "constraints": ["string"],
  "parsed_at": "ISO-8601"
}
```

---

### `/output` - Generated Artifacts

**Purpose:** The actual generated project.

#### `.enablement/manifest.json`

Every generated project MUST include `.enablement/manifest.json`:

```json
{
  "generation": {
    "id": "UUID v4",
    "timestamp": "ISO-8601",
    "run_id": "YYYYMMDD_HHMMSS"
  },
  "enablement": {
    "version": "3.0.x",
    "domain": "code",
    "flow": "flow-generate"
  },
  "discovery": {
    "stack": "java-spring",
    "capabilities": [
      "architecture.hexagonal-light",
      "api-architecture.domain-api",
      "persistence.systemapi",
      "resilience.circuit-breaker"
    ],
    "features": [
      "hexagonal-light",
      "domain-api",
      "systemapi",
      "circuit-breaker"
    ]
  },
  "modules": [
    {
      "id": "mod-code-015-hexagonal-base-java-spring",
      "version": "1.0.0",
      "capability": "architecture.hexagonal-light",
      "phase": 1
    }
  ],
  "status": {
    "overall": "SUCCESS | PARTIAL | FAILED",
    "compilation": "PASS | FAIL",
    "tier1": "PASS | FAIL",
    "tier2": "PASS | FAIL", 
    "tier3": "PASS | FAIL | PASS_WITH_WARNINGS"
  },
  "metrics": {
    "files_generated": 25,
    "lines_of_code": 1500,
    "test_files": 3
  }
}
```

---

### `/trace` - Generation Trace

**Purpose:** Full audit trail for debugging and analysis.

#### `discovery-trace.json`

```json
{
  "$schema": "enablement/schemas/discovery-trace.schema.json",
  "version": "1.0",
  "timestamp": "ISO-8601",
  
  "prompt_analysis": {
    "raw_prompt": "string",
    "detected_intent": "generate | transform | refactor",
    "entities_identified": ["Customer", "Account"],
    "features_mentioned": ["hexagonal", "resilience"]
  },
  
  "capability_resolution": {
    "rules_applied": [
      {
        "rule": "DC-001",
        "condition": "domain_api_spec_provided",
        "result": "api-architecture.domain-api"
      }
    ],
    "capabilities_detected": [
      "architecture.hexagonal-light",
      "api-architecture.domain-api"
    ]
  },
  
  "module_resolution": {
    "stack": "java-spring",
    "modules_selected": [
      {
        "capability": "architecture.hexagonal-light",
        "module": "mod-code-015-hexagonal-base-java-spring",
        "reason": "Default for java-spring stack"
      }
    ]
  },
  
  "config_derivation": {
    "hateoas": true,
    "pagination": false,
    "compensation_available": true
  }
}
```

#### `generation-trace.json`

```json
{
  "$schema": "enablement/schemas/generation-trace.schema.json", 
  "version": "1.0",
  "run_id": "20260123_100255",
  
  "phases": [
    {
      "phase": 1,
      "name": "STRUCTURAL",
      "modules": ["mod-015", "mod-019"],
      "started_at": "ISO-8601",
      "completed_at": "ISO-8601",
      "files_generated": [
        "pom.xml",
        "src/main/java/.../Customer.java"
      ],
      "compilation_result": "PASS",
      "errors": [],
      "warnings": []
    }
  ],
  
  "summary": {
    "total_phases": 3,
    "total_files": 25,
    "total_duration_ms": 15000
  }
}
```

#### `modules-used.json`

```json
{
  "$schema": "enablement/schemas/modules-used.schema.json",
  "version": "1.0",
  
  "modules": [
    {
      "id": "mod-code-015-hexagonal-base-java-spring",
      "version": "1.0.0",
      "capability": "architecture.hexagonal-light",
      "phase": 1,
      "files_generated": [
        {
          "path": "src/main/java/.../domain/model/Customer.java",
          "template": "domain-entity.java.template",
          "checksum": "sha256:..."
        }
      ],
      "files_modified": [],
      "tests_generated": [
        "src/test/java/.../domain/model/CustomerTest.java"
      ]
    }
  ]
}
```

#### `decisions-log.jsonl`

JSON Lines format - one decision per line:

```jsonl
{"timestamp":"2026-01-23T10:02:55.001Z","decision":"SELECT_PERSISTENCE","input":"System API spec provided","output":"persistence.systemapi","rule":"DC-003"}
{"timestamp":"2026-01-23T10:02:55.002Z","decision":"SKIP_JPA","input":"No database schema","output":"Skip mod-016","rule":"DC-004"}
{"timestamp":"2026-01-23T10:02:56.100Z","decision":"GENERATE_FILE","phase":1,"file":"Customer.java","module":"mod-015"}
```

---

### `/validation` - Validation Suite

**Purpose:** Automated quality assurance.

#### `run-all.sh`

Master script that executes all validations:
- Must be POSIX-compatible (works with `sh` on Mac)
- Executes all tier1, tier2, tier3 scripts
- Generates `reports/validation-results.json`
- Returns exit code 0 (all pass) or 1 (failures)

#### Tier Structure

| Tier | Scope | Validations |
|------|-------|-------------|
| Tier 1 | Universal | Naming, structure, traceability |
| Tier 2 | Technology | Compilation, syntax, config |
| Tier 3 | Module | Per-module specific checks |

#### Script Sources

| Tier | Source Location |
|------|-----------------|
| Tier 1 | `runtime/validators/tier-1-universal/` |
| Tier 2 | `runtime/validators/tier-2-technology/{stack}/` |
| Tier 3 | `modules/{module-id}/validation/` |

---

## Naming Conventions

### Package Name

Format: `gen_{service-name}_{YYYYMMDD_HHMMSS}`

Examples:
- `gen_customer-api_20260123_100255`
- `gen_account-service_20260123_143022`

### Run ID

Format: `YYYYMMDD_HHMMSS`

Used in:
- Package name suffix
- `manifest.json` → `generation.run_id`
- `generation-trace.json` → `run_id`

### Generation ID

Format: UUID v4

Used in:
- `manifest.json` → `generation.id`
- Cross-referencing between systems

---

## Required vs Optional

| Element | Required | Notes |
|---------|----------|-------|
| `/input/prompt.txt` | Yes | Always preserve original prompt |
| `/input/prompt-metadata.json` | Yes | Parsed prompt |
| `/input/*.yaml` | If provided | API specs |
| `/output/{project}/` | Yes | Main deliverable |
| `/output/{project}/.enablement/manifest.json` | Yes | Generation metadata |
| `/trace/discovery-trace.json` | Yes | Discovery audit |
| `/trace/generation-trace.json` | Yes | Generation audit |
| `/trace/modules-used.json` | Yes | Module tracking |
| `/trace/decisions-log.jsonl` | Yes | Decision audit |
| `/trace/context-snapshots/` | No | Debug only |
| `/validation/run-all.sh` | Yes | Master validator |
| `/validation/scripts/tier*/` | Yes | Validation scripts |
| `/validation/reports/` | Yes | Results |

---

## File Formats

| Extension | Format | Used For |
|-----------|--------|----------|
| `.json` | JSON | Structured data, configs |
| `.jsonl` | JSON Lines | Append-only logs |
| `.yaml` | YAML | OpenAPI specs |
| `.sh` | Shell | Validation scripts (POSIX) |
| `.txt` | Plain text | Prompts, notes |
| `.md` | Markdown | Documentation |

---

## Related Documents

- [Generation Orchestrator](./GENERATION-ORCHESTRATOR.md) - Execution flow
- [Flow: Generate](./code/flow-generate.md) - Generation phases
- [Validation Tiers](../validators/README.md) - Validation system
