# Traceability Profile: Report

**Profile ID:** report  
**Version:** 1.0  
**Last Updated:** 2025-11-27  
**Extends:** BASE-MODEL.md

---

## Purpose

This profile extends the base traceability model for skills that **generate analysis reports**. It captures findings, analyzed artifacts, severity distributions, and actionable recommendations.

## Used By

| Skill Pattern | Example |
|---------------|---------|
| `skill-qa-*-analyze-*` | skill-qa-001-analyze-code-quality |
| `skill-qa-*-review-*` | skill-qa-002-review-architecture |
| `skill-qa-*-audit-*` | skill-qa-003-audit-security |
| `skill-qa-*-assess-*` | skill-qa-004-assess-compliance |

---

## Extended Schema

In addition to BASE-MODEL fields, report traces include:

```json
{
  "profile": "report",
  "profile_version": "1.0",
  
  "report_type": "code-quality|architecture-review|security-audit|compliance-assessment|dependency-analysis",
  
  "output": {
    "format": "markdown|html|json|pdf",
    "filename": "customer-service-architecture-review.md",
    "path": "reports/customer-service-architecture-review.md",
    "size_bytes": 8192
  },
  
  "analyzed_artifacts": [
    {
      "type": "project|file|directory|api|database",
      "path": "/projects/customer-service",
      "scope": "full|partial",
      "files_analyzed": 45,
      "lines_of_code": 12000,
      "analysis_depth": "surface|standard|deep"
    }
  ],
  
  "analysis_criteria": [
    {
      "id": "criteria-001",
      "category": "architecture|code-quality|security|performance|maintainability",
      "name": "Hexagonal Architecture Compliance",
      "source": "adr-009-service-architecture-patterns",
      "weight": 1.0
    }
  ],
  
  "findings_summary": {
    "total_findings": 15,
    "by_severity": {
      "critical": 0,
      "high": 2,
      "medium": 5,
      "low": 6,
      "info": 2
    },
    "by_category": {
      "architecture": 3,
      "code-quality": 7,
      "security": 2,
      "performance": 3
    }
  },
  
  "findings": [
    {
      "id": "finding-001",
      "severity": "high",
      "category": "architecture",
      "title": "Domain logic in adapter layer",
      "description": "Business logic found in REST controller instead of domain service",
      "location": {
        "file": "src/main/java/com/company/adapter/in/CustomerController.java",
        "line_start": 45,
        "line_end": 67
      },
      "evidence": "Method calculateDiscount() contains business rules",
      "adr_violation": "adr-009 Section 3.2",
      "recommendation": "Move calculation logic to CustomerService in domain layer",
      "effort_estimate": "medium",
      "auto_fixable": false
    }
  ],
  
  "scores": {
    "overall": 7.5,
    "max_score": 10,
    "by_category": {
      "architecture": 8.0,
      "code-quality": 7.0,
      "security": 8.5,
      "performance": 6.5
    }
  },
  
  "recommendations": [
    {
      "id": "rec-001",
      "priority": 1,
      "title": "Refactor domain logic out of controllers",
      "description": "Move all business logic to domain services to comply with hexagonal architecture",
      "findings_addressed": ["finding-001", "finding-003"],
      "effort": "medium",
      "impact": "high",
      "suggested_skill": "skill-code-XXX-refactor-to-hexagonal"
    }
  ],
  
  "comparisons": {
    "baseline_available": true,
    "baseline_report_id": "gen-20251120-100000-prev",
    "trend": "improving|stable|degrading",
    "delta": {
      "overall_score": "+0.5",
      "findings_critical": "0",
      "findings_high": "-1"
    }
  },
  
  "tools_used": [
    {
      "tool": "custom-architecture-analyzer",
      "version": "1.0",
      "configuration": {}
    }
  ]
}
```

---

## Field Definitions

### report_type

| Value | Description |
|-------|-------------|
| `code-quality` | Static analysis, code smells, best practices |
| `architecture-review` | Architecture compliance, patterns adherence |
| `security-audit` | Security vulnerabilities, compliance |
| `compliance-assessment` | Regulatory/policy compliance |
| `dependency-analysis` | Dependencies, vulnerabilities, licensing |

### analyzed_artifacts Array

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | enum | ✅ | Artifact type analyzed |
| `path` | string | ✅ | Path to artifact |
| `scope` | enum | ✅ | `full` or `partial` analysis |
| `files_analyzed` | number | ⚠️ | Number of files analyzed |
| `lines_of_code` | number | ⚠️ | Total LOC analyzed |
| `analysis_depth` | enum | ⚠️ | Depth of analysis |

### findings_summary Object

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `total_findings` | number | ✅ | Total findings count |
| `by_severity` | object | ✅ | Count per severity level |
| `by_category` | object | ⚠️ | Count per category |

### findings Array

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | ✅ | Finding identifier |
| `severity` | enum | ✅ | `critical`, `high`, `medium`, `low`, `info` |
| `category` | string | ✅ | Finding category |
| `title` | string | ✅ | Short description |
| `description` | string | ✅ | Detailed description |
| `location` | object | ⚠️ | Where the issue was found |
| `evidence` | string | ✅ | Proof/evidence |
| `adr_violation` | string | ⚠️ | Related ADR if violated |
| `recommendation` | string | ✅ | How to fix |
| `effort_estimate` | enum | ⚠️ | `low`, `medium`, `high` |
| `auto_fixable` | boolean | ⚠️ | Can be auto-fixed |

### recommendations Array

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | ✅ | Recommendation identifier |
| `priority` | number | ✅ | Priority (1 = highest) |
| `title` | string | ✅ | Recommendation title |
| `description` | string | ✅ | Detailed description |
| `findings_addressed` | array | ✅ | Related finding IDs |
| `effort` | enum | ✅ | Estimated effort |
| `impact` | enum | ✅ | Expected impact |
| `suggested_skill` | string | ⚠️ | Skill to automate fix |

### scores Object

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `overall` | number | ✅ | Overall score |
| `max_score` | number | ✅ | Maximum possible score |
| `by_category` | object | ⚠️ | Score per category |

---

## Storage Structure

```
reports/
├── customer-service-architecture-review.md    # Generated report
└── .enablement/
    ├── manifest.json                          # Traceability
    ├── execution.log
    ├── raw-findings.json                      # Detailed findings data
    └── inputs/
        └── skill-input.json
```

---

## Example: Architecture Review Trace

```json
{
  "traceability_version": "1.0",
  "profile": "report",
  "profile_version": "1.0",
  
  "generation": {
    "id": "gen-20251127-170000-r1s2",
    "timestamp": "2025-11-27T17:00:00Z",
    "duration_seconds": 120
  },
  
  "skill": {
    "id": "skill-qa-002-review-architecture",
    "version": "1.0.0",
    "domain": "qa"
  },
  
  "report_type": "architecture-review",
  
  "output": {
    "format": "markdown",
    "filename": "customer-service-review.md",
    "path": "reports/customer-service-review.md"
  },
  
  "analyzed_artifacts": [
    {
      "type": "project",
      "path": "/projects/customer-service",
      "scope": "full",
      "files_analyzed": 45
    }
  ],
  
  "findings_summary": {
    "total_findings": 8,
    "by_severity": {
      "critical": 0,
      "high": 1,
      "medium": 3,
      "low": 4,
      "info": 0
    }
  },
  
  "findings": [
    {
      "id": "finding-001",
      "severity": "high",
      "category": "architecture",
      "title": "Domain logic in adapter",
      "description": "Business logic in REST controller",
      "recommendation": "Move to domain service"
    }
  ],
  
  "scores": {
    "overall": 7.5,
    "max_score": 10
  },
  
  "recommendations": [
    {
      "id": "rec-001",
      "priority": 1,
      "title": "Refactor domain logic",
      "effort": "medium",
      "impact": "high"
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
- `document.md` - For document generation
- `validators/tier-2-technology/reports/` - Report validation

---

**Last Updated:** 2025-11-27
