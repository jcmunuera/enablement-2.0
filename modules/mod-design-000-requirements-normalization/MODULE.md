---
id: mod-design-000-requirements-normalization
name: "Requirements Normalization & Enrichment"
version: "1.0.0"
date: 2026-02-17
status: Active
domain: design

implements:
  capability: requirements-analysis
  feature: normalize-enrich

module_type: policy-driven
eri_reference: none
adr_reference: none
---

# mod-design-000: Requirements Normalization & Enrichment

## Overview

Policy-driven module that transforms unstructured human requirements (natural language, bullet points, mixed-language, incomplete descriptions) into a structured, consistent `normalized-requirements.yaml` artifact suitable for consumption by the DESIGN pipeline.

**Type:** Policy-driven (LLM analyzes and structures within strict constraints)
**Input:** Unstructured requirements in any format (text, bullets, conversation transcript, document)
**Output:** `normalized-requirements.yaml` per schema

---

## Module Structure

```
mod-design-000-requirements-normalization/
├── MODULE.md
├── policies/
│   └── requirements-normalization.md    # Extraction rules, classification, enrichment
├── schemas/
│   └── normalized-requirements.schema.yaml
├── examples/
│   └── customer-onboarding-reference.yaml    # Customer Onboarding reference
└── validation/
    ├── README.md
    └── requirements-check.sh
```

---

## Execution

### Input

Human-provided requirements in any format. May be:
- Free text description
- Bullet point list
- Conversation transcript
- Mixture of languages
- Incomplete or ambiguous

### Process

1. **Load policies** — Inject `policies/requirements-normalization.md`
2. **Load schema** — Include output schema as format reference
3. **Load example** — Include reference as few-shot
4. **Analyze** — LLM extracts, classifies, and structures
5. **Enrich** — LLM identifies implicit requirements, gaps, and assumptions
6. **Validate** — Run `validation/requirements-check.sh`

### Output

File: `normalized-requirements.yaml`
Consumers: mod-design-001-strategic-ddd (primary), all downstream modules

---

## Related

- **Downstream:** mod-design-001-strategic-ddd (consumes output)
- **Downstream:** All DESIGN modules (reference for traceability)
