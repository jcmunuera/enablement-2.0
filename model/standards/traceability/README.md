# Traceability Standards

**Version:** 3.0  
**Last Updated:** 2025-11-27

---

## Purpose

This directory defines the **traceability model** for Enablement 2.0. Traceability ensures that:

1. **Skill executions** are auditable (what was requested, what decisions were made)
2. **Outputs** can be traced back to their inputs and configuration
3. **Quality** can be measured and compared over time
4. **Compliance** with ADRs and standards can be verified

---

## Architecture: Base Model + Profiles

Traceability follows a **layered architecture**:

```
┌─────────────────────────────────────────────────────────────────┐
│                      BASE-MODEL.md                               │
│     Common fields ALL skills must capture (mandatory)            │
│     - generation metadata (id, timestamp, duration)              │
│     - skill info (id, version, domain)                          │
│     - request (raw, parsed intent)                              │
│     - decisions made                                             │
│     - modules used                                               │
│     - validators executed                                        │
│     - status                                                     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ EXTENDED BY
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                         PROFILES                                 │
│     Domain-specific extensions based on OUTPUT TYPE              │
├─────────────────┬─────────────────┬────────────────┬────────────┤
│  code-project   │code-transform   │   document     │   report   │
│                 │                 │                │            │
│ artifacts_      │ artifacts_      │ sections       │ findings   │
│ generated       │ modified        │ diagrams       │ scores     │
│ adr_compliance  │ before/after    │ sources        │ recommend  │
│ dependencies    │ rollback_info   │ template       │ trends     │
└─────────────────┴─────────────────┴────────────────┴────────────┘
```

---

## Directory Structure

```
traceability/
├── README.md              # This file (overview)
├── BASE-MODEL.md          # Common fields for ALL skills
└── profiles/              # Output-type specific extensions
    ├── code-project.md    # For skill-code-*-generate-*
    ├── code-transformation.md # For skill-code-*-add/remove-*
    ├── document.md        # For skill-design-*, skill-gov-*
    └── report.md          # For skill-qa-*
```

---

## Profile Selection

Skills select their traceability profile based on **output type**, not domain:

| Skill Pattern | Output Type | Profile |
|---------------|-------------|---------|
| `skill-code-*-generate-*` | New code project | `code-project` |
| `skill-code-*-add-*` | Modified project | `code-transformation` |
| `skill-code-*-remove-*` | Modified project | `code-transformation` |
| `skill-design-*-generate-*` | Document | `document` |
| `skill-design-*-create-*` | Document | `document` |
| `skill-gov-*-generate-*` | Document | `document` |
| `skill-qa-*-analyze-*` | Report | `report` |
| `skill-qa-*-review-*` | Report | `report` |

---

## Key Traceability Questions

Every trace answers:

| Question | Field(s) |
|----------|----------|
| **What** was created? | `profile`, `artifacts_*`, output fields |
| **When**? | `generation.timestamp`, `generation.duration_seconds` |
| **Who/What** created it? | `skill.id`, `orchestrator.model` |
| **Why** was it created? | `request.raw`, `request.parsed_intent` |
| **What decisions** were made? | `decisions[]` with rationale |
| **What modules** were used? | `modules_used[]` |
| **How was it validated?** | `validators_executed[]` |
| **Was it successful?** | `status.overall`, `status.errors` |

---

## Storage Location

Traceability is stored in `.enablement/manifest.json` within the output:

### Code Projects
```
{generated-project}/
└── .enablement/
    ├── manifest.json           # Traceability (BASE + profile)
    ├── execution.log           # Human-readable narrative
    ├── inputs/                 # Preserved inputs
    └── validation/             # Validation evidence
```

### Documents
```
docs/
└── .enablement/
    └── {document-name}-manifest.json
```

### Reports
```
reports/
└── .enablement/
    └── {report-name}-manifest.json
```

---

## Quick Reference

| I want to... | Read this |
|--------------|-----------|
| Understand common trace fields | [BASE-MODEL.md](./BASE-MODEL.md) |
| Trace code generation | [profiles/code-project.md](./profiles/code-project.md) |
| Trace code modification | [profiles/code-transformation.md](./profiles/code-transformation.md) |
| Trace document generation | [profiles/document.md](./profiles/document.md) |
| Trace report generation | [profiles/report.md](./profiles/report.md) |

---

## Relation to Validation

Traceability captures **validation results** but is separate from validation itself:

- **Validation** (in `model/standards/validation/`) = HOW to validate
- **Validators** (in `knowledge/validators/`) = WHAT validates
- **Traceability** (this directory) = RECORDING what was validated and results

The `validators_executed[]` field in traceability links to validators in `knowledge/validators/`.

---

## Related Documents

- `model/standards/validation/README.md` - Validation system
- `knowledge/validators/` - Validator assets
- `model/standards/authoring/SKILL.md` - How skills implement traceability
- `model/standards/ASSET-STANDARDS.md` - Asset definitions

---

**Last Updated:** 2025-11-27
