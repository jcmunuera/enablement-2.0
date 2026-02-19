# Traceability Base Model

**Version:** 1.0  
**Last Updated:** 2025-11-27

---

## Purpose

This document defines the **common traceability fields** that ALL skills must capture, regardless of domain or output type. These fields enable:

1. **Auditability:** Who requested what, when, and what decisions were made
2. **Reproducibility:** Ability to understand and recreate the generation
3. **Governance:** Compliance tracking and accountability
4. **Analytics:** Understanding usage patterns and quality metrics

---

## Base Model Schema

Every skill execution MUST capture these fields in its traceability output:

```json
{
  "traceability_version": "1.0",
  
  "generation": {
    "id": "gen-YYYYMMDD-HHMMSS-XXXX",
    "timestamp": "2025-11-27T10:30:00Z",
    "duration_seconds": 45
  },
  
  "skill": {
    "id": "skill-{domain}-{NNN}-{name}",
    "version": "1.0.0",
    "domain": "code|design|qa|gov"
  },
  
  "orchestrator": {
    "model": "claude-sonnet-4-20250514",
    "knowledge_base_version": "5.0"
  },
  
  "request": {
    "raw": "Original user request text",
    "parsed_intent": {
      "action": "generate|add|remove|analyze|transform",
      "target": "What is being acted upon",
      "parameters": {}
    }
  },
  
  "decisions": [
    {
      "id": "decision-001",
      "category": "architecture|technology|configuration|pattern",
      "question": "What decision was made",
      "choice": "The selected option",
      "rationale": "Why this choice was made",
      "alternatives_considered": ["option-a", "option-b"],
      "adr_reference": "adr-XXX (if applicable)"
    }
  ],
  
  "modules_used": [
    {
      "module_id": "mod-XXX-{name}",
      "version": "1.0.0",
      "configuration": {}
    }
  ],
  
  "validators_executed": [
    {
      "validator_id": "val-tier1-generic-project-structure",
      "tier": 1,
      "status": "pass|fail|skip",
      "duration_ms": 150,
      "details": {}
    }
  ],
  
  "status": {
    "overall": "success|partial|failed",
    "errors": [],
    "warnings": []
  }
}
```

---

## Field Definitions

### Generation Block

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | ✅ | Unique identifier: `gen-YYYYMMDD-HHMMSS-XXXX` |
| `timestamp` | ISO-8601 | ✅ | When execution started |
| `duration_seconds` | number | ✅ | Total execution time |

### Skill Block

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | ✅ | Full skill identifier |
| `version` | semver | ✅ | Skill version used |
| `domain` | enum | ✅ | `code`, `design`, `qa`, or `gov` |

### Orchestrator Block

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `model` | string | ✅ | AI model used for orchestration |
| `knowledge_base_version` | string | ✅ | KB version used |

### Request Block

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `raw` | string | ✅ | Original user request verbatim |
| `parsed_intent.action` | enum | ✅ | Primary action type |
| `parsed_intent.target` | string | ✅ | What is being acted upon |
| `parsed_intent.parameters` | object | ⚠️ | Skill-specific parameters |

### Decisions Array

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | ✅ | Unique decision identifier |
| `category` | enum | ✅ | Decision category |
| `question` | string | ✅ | What was decided |
| `choice` | string | ✅ | Selected option |
| `rationale` | string | ✅ | Why this was chosen |
| `alternatives_considered` | array | ⚠️ | Other options evaluated |
| `adr_reference` | string | ⚠️ | Related ADR if applicable |

### Modules Used Array

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `module_id` | string | ✅ | Module identifier |
| `version` | semver | ✅ | Module version |
| `configuration` | object | ⚠️ | Module-specific config |

### Validators Executed Array

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `validator_id` | string | ✅ | Validator identifier |
| `tier` | number | ✅ | Validation tier (1, 2, or 3) |
| `status` | enum | ✅ | `pass`, `fail`, or `skip` |
| `duration_ms` | number | ✅ | Execution time |
| `details` | object | ⚠️ | Additional validation output |

### Status Block

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `overall` | enum | ✅ | `success`, `partial`, or `failed` |
| `errors` | array | ✅ | List of errors (empty if success) |
| `warnings` | array | ✅ | List of warnings |

---

## Extension Points

The base model is extended by **profiles** that add domain-specific fields:

| Profile | Extends With | Used By |
|---------|--------------|---------|
| `code-project` | `artifacts_generated`, `adr_compliance` | skill-code-*-generate-* |
| `code-transformation` | `artifacts_modified`, `before/after` | skill-code-*-add/remove-* |
| `document` | `sections_generated`, `format` | skill-design-*, skill-gov-* |
| `report` | `findings`, `severity_counts` | skill-qa-* |

See `profiles/` directory for profile-specific extensions.

---

## Storage Location

Traceability output is stored in the generated artifact's `.enablement/` directory:

```
{generated-output}/
└── .enablement/
    ├── manifest.json           # ⬅️ Traceability data (this schema)
    ├── execution.log           # Human-readable narrative
    ├── inputs/                 # Preserved input files
    │   └── skill-input.json
    └── validation/             # Validation evidence
        └── results.json
```

---

## Example: Minimal Trace

```json
{
  "traceability_version": "1.0",
  "generation": {
    "id": "gen-20251127-103000-a1b2",
    "timestamp": "2025-11-27T10:30:00Z",
    "duration_seconds": 45
  },
  "skill": {
    "id": "skill-code-020-generate-microservice-java-spring",
    "version": "1.0.0",
    "domain": "code"
  },
  "orchestrator": {
    "model": "claude-sonnet-4-20250514",
    "knowledge_base_version": "5.0"
  },
  "request": {
    "raw": "Create a new microservice for customer management",
    "parsed_intent": {
      "action": "generate",
      "target": "microservice",
      "parameters": {
        "name": "customer-service",
        "features": ["circuit-breaker", "hexagonal"]
      }
    }
  },
  "decisions": [
    {
      "id": "decision-001",
      "category": "architecture",
      "question": "Architecture pattern",
      "choice": "Hexagonal (Ports & Adapters)",
      "rationale": "Standard architecture per ADR-009",
      "adr_reference": "adr-009"
    }
  ],
  "modules_used": [
    { "module_id": "mod-code-015-hexagonal-base-java-spring", "version": "1.0.0" },
    { "module_id": "mod-code-001-circuit-breaker-java-resilience4j", "version": "1.0.0" }
  ],
  "validators_executed": [
    { "validator_id": "val-tier1-generic-project-structure", "tier": 1, "status": "pass", "duration_ms": 150 },
    { "validator_id": "val-tier2-code-java-spring", "tier": 2, "status": "pass", "duration_ms": 5000 }
  ],
  "status": {
    "overall": "success",
    "errors": [],
    "warnings": []
  }
}
```

---

## Related

- `profiles/code-project.md` - Extension for code generation
- `profiles/code-transformation.md` - Extension for code modification
- `profiles/document.md` - Extension for document generation
- `profiles/report.md` - Extension for report generation
- `model/standards/validation/README.md` - Validation system

---

**Last Updated:** 2025-11-27
