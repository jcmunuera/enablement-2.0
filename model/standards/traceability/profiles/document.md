# Traceability Profile: Document

**Profile ID:** document  
**Version:** 1.0  
**Last Updated:** 2025-11-27  
**Extends:** BASE-MODEL.md

---

## Purpose

This profile extends the base traceability model for skills that **generate documents**. It captures document structure, sections generated, diagrams included, and sources referenced.

## Used By

| Skill Pattern | Example |
|---------------|---------|
| `skill-design-*-generate-*` | skill-design-001-generate-hld |
| `skill-design-*-create-*` | skill-design-002-create-api-spec |
| `skill-gov-*-generate-*` | skill-gov-001-generate-runbook |
| `skill-gov-*-document-*` | skill-gov-002-document-api |

---

## Extended Schema

In addition to BASE-MODEL fields, document traces include:

```json
{
  "profile": "document",
  "profile_version": "1.0",
  
  "document_type": "hld|lld|api-spec|runbook|adr|technical-spec",
  
  "output": {
    "format": "markdown|html|pdf|openapi|asyncapi",
    "filename": "customer-service-hld.md",
    "path": "docs/architecture/customer-service-hld.md",
    "size_bytes": 15360,
    "checksum": "sha256:abc123..."
  },
  
  "structure": {
    "total_sections": 8,
    "total_words": 2500,
    "sections": [
      {
        "id": "section-1",
        "title": "Executive Summary",
        "level": 1,
        "word_count": 150,
        "generated_from": "user-request + context"
      },
      {
        "id": "section-2",
        "title": "Architecture Overview",
        "level": 1,
        "word_count": 500,
        "subsections": ["2.1", "2.2", "2.3"],
        "generated_from": "adr-009 + eri-code-001"
      }
    ]
  },
  
  "diagrams_included": [
    {
      "id": "diagram-1",
      "type": "architecture|sequence|class|component|deployment",
      "title": "High-Level Architecture",
      "format": "mermaid|plantuml|draw.io",
      "location": "embedded|external",
      "source": "Generated from code analysis"
    }
  ],
  
  "sources_referenced": [
    {
      "type": "adr|eri|module|skill|code|external",
      "id": "adr-009-service-architecture-patterns",
      "sections_used": ["Decision", "Rationale"],
      "citation_count": 3
    },
    {
      "type": "code",
      "id": "customer-service",
      "path": "src/main/java/com/company/",
      "analysis_type": "structure|api|dependencies"
    }
  ],
  
  "template_used": {
    "template_id": "hld-template-v1",
    "customizations_applied": [
      "Added security section",
      "Removed legacy integration section"
    ]
  },
  
  "compliance": {
    "standards_followed": ["IEEE-1471", "C4-Model"],
    "review_status": "draft|pending-review|approved",
    "approvers": []
  },
  
  "cross_references": {
    "links_to": [
      {
        "document": "customer-service-lld.md",
        "relationship": "details"
      }
    ],
    "linked_from": []
  }
}
```

---

## Field Definitions

### document_type

| Value | Description |
|-------|-------------|
| `hld` | High-Level Design document |
| `lld` | Low-Level Design / Detailed Design |
| `api-spec` | API specification (OpenAPI, AsyncAPI) |
| `runbook` | Operational runbook |
| `adr` | Architecture Decision Record |
| `technical-spec` | Technical specification |

### output Object

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `format` | enum | ✅ | Output format |
| `filename` | string | ✅ | Generated filename |
| `path` | string | ✅ | Full path to document |
| `size_bytes` | number | ⚠️ | Document size |
| `checksum` | string | ⚠️ | SHA-256 hash |

### structure Object

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `total_sections` | number | ✅ | Number of top-level sections |
| `total_words` | number | ⚠️ | Approximate word count |
| `sections` | array | ✅ | Section details |

### sections Array

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | ✅ | Section identifier |
| `title` | string | ✅ | Section title |
| `level` | number | ✅ | Heading level (1, 2, 3...) |
| `word_count` | number | ⚠️ | Words in section |
| `subsections` | array | ⚠️ | Child section IDs |
| `generated_from` | string | ⚠️ | Source of content |

### diagrams_included Array

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | ✅ | Diagram identifier |
| `type` | enum | ✅ | Diagram type |
| `title` | string | ✅ | Diagram title |
| `format` | enum | ✅ | Diagram format |
| `location` | enum | ✅ | `embedded` or `external` |
| `source` | string | ⚠️ | How diagram was created |

### sources_referenced Array

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | enum | ✅ | Source type |
| `id` | string | ✅ | Source identifier |
| `sections_used` | array | ⚠️ | Which parts were referenced |
| `citation_count` | number | ⚠️ | Times cited |

---

## Storage Structure

For standalone documents:
```
docs/
├── architecture/
│   ├── customer-service-hld.md    # Generated document
│   └── .enablement/
│       ├── manifest.json          # Traceability
│       ├── execution.log
│       └── inputs/
│           └── skill-input.json
```

For documents within a project:
```
{project}/
├── docs/
│   └── architecture/
│       └── HLD.md
└── .enablement/
    └── documents/
        └── hld-manifest.json      # Document-specific trace
```

---

## Example: HLD Generation Trace

```json
{
  "traceability_version": "1.0",
  "profile": "document",
  "profile_version": "1.0",
  
  "generation": {
    "id": "gen-20251127-160000-d1e2",
    "timestamp": "2025-11-27T16:00:00Z",
    "duration_seconds": 30
  },
  
  "skill": {
    "id": "skill-design-001-generate-hld",
    "version": "1.0.0",
    "domain": "design"
  },
  
  "document_type": "hld",
  
  "output": {
    "format": "markdown",
    "filename": "customer-service-hld.md",
    "path": "docs/architecture/customer-service-hld.md"
  },
  
  "structure": {
    "total_sections": 6,
    "sections": [
      { "id": "1", "title": "Overview", "level": 1 },
      { "id": "2", "title": "Architecture", "level": 1 },
      { "id": "3", "title": "Components", "level": 1 },
      { "id": "4", "title": "Data Flow", "level": 1 },
      { "id": "5", "title": "Security", "level": 1 },
      { "id": "6", "title": "Deployment", "level": 1 }
    ]
  },
  
  "diagrams_included": [
    {
      "id": "arch-diagram",
      "type": "component",
      "title": "Component Diagram",
      "format": "mermaid",
      "location": "embedded"
    }
  ],
  
  "sources_referenced": [
    {
      "type": "adr",
      "id": "adr-009",
      "citation_count": 5
    },
    {
      "type": "code",
      "id": "customer-service",
      "analysis_type": "structure"
    }
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

- `BASE-MODEL.md` - Base traceability schema
- `report.md` - For analysis/audit reports
- `validators/tier-2-technology/documents/` - Document validation

---

**Last Updated:** 2025-11-27
