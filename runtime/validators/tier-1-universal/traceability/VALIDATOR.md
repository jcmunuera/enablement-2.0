# Validator: Traceability

**Validator ID:** val-tier1-traceability  
**Tier:** 1  
**Category:** universal  
**Version:** 1.0.0  
**Applies To:** ALL outputs (all domains, all output types)

---

## Purpose

Validates that every generated output includes proper traceability metadata in the `.enablement/manifest.json` file. This is the **only truly universal validator** that applies to ALL skills regardless of domain or output type.

---

## Checks

| Check | Description | Severity |
|-------|-------------|----------|
| Directory exists | `.enablement/` directory present | FAIL |
| Manifest exists | `manifest.json` file present | FAIL |
| Valid JSON | Manifest is valid JSON | FAIL |
| Required fields | Contains `generation`, `skill`, `status` | FAIL |
| Generation ID | `generation.id` is valid UUID | WARN |
| Timestamp | `generation.timestamp` is valid ISO-8601 | WARN |
| Skill reference | `skill.id` matches skill naming convention | WARN |

---

## Usage

```bash
./traceability-check.sh <output-directory>
```

### Arguments

- `output-directory`: Path to the generated output (default: current directory)

### Exit Codes

- `0`: All checks passed
- `1`: One or more checks failed

---

## Required Manifest Structure

Minimum required fields:

```json
{
  "generation": {
    "id": "uuid",
    "timestamp": "ISO-8601"
  },
  "skill": {
    "id": "skill-{domain}-{NNN}-...",
    "version": "X.Y.Z",
    "domain": "{code|design|qa|gov}"
  },
  "status": {
    "overall": "SUCCESS|PARTIAL|FAILED"
  }
}
```

See `model/standards/traceability/BASE-MODEL.md` for complete specification.

---

## Why Universal?

This validator is domain-agnostic because:

1. **Auditability**: Every output must be traceable to its origin
2. **Reproducibility**: Must know what skill/version generated it
3. **Governance**: Compliance requires knowing provenance

Whether the output is code, a document, or a report - traceability is mandatory.

---

## Related

- `model/standards/traceability/BASE-MODEL.md` - Traceability specification
- `model/standards/authoring/SKILL.md` - Skill validation requirements
