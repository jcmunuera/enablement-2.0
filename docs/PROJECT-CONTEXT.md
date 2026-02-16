# Enablement 2.0 — Project Context

**Version:** 3.0.13  
**Last Updated:** 2026-02-03  
**Status:** Active Development (E2E Pipeline Validated + Reproducibility Improvements)

---

## Executive Summary

Enablement 2.0 is an AI-powered code generation platform designed to address low framework adoption rates (30-40%) at a multinational financial organization. The platform automates enterprise Java microservice generation while enforcing governance through automated Tech Health Score calculation and budget-linked enforcement mechanisms.

**Key Metrics:**
- Estimated annual savings: ~$5M in developer productivity
- Target audience: 400+ developers across the organization
- Current status: E2E pipeline validated with reproducibility improvements

---

## Architecture Overview

### Core Components

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         ENABLEMENT 2.0 SYSTEM                           │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                 │
│  │  Discovery  │───>│   Context   │───>│    Plan     │                 │
│  │    Agent    │    │    Agent    │    │    Agent    │                 │
│  └─────────────┘    └─────────────┘    └─────────────┘                 │
│         │                  │                  │                         │
│         v                  v                  v                         │
│  ┌─────────────────────────────────────────────────────┐               │
│  │              KNOWLEDGE BASE (KB)                     │               │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐             │               │
│  │  │ Modules │  │Templates│  │Validators│             │               │
│  │  └─────────┘  └─────────┘  └─────────┘             │               │
│  └─────────────────────────────────────────────────────┘               │
│         │                                                               │
│         v                                                               │
│  ┌─────────────────────────────────────────────────────┐               │
│  │           CODEGEN AGENT (Per Phase)                  │               │
│  │  Phase 1: Structural -> Phase 2: Implementation ->   │               │
│  │  Phase 3: Cross-cutting                              │               │
│  └─────────────────────────────────────────────────────┘               │
│         │                                                               │
│         v                                                               │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                 │
│  │  Generated  │───>│  Validation │───>│   Output    │                 │
│  │    Code     │    │  (4 Tiers)  │    │   Package   │                 │
│  └─────────────┘    └─────────────┘    └─────────────┘                 │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Agent Pipeline

| Agent | Input | Output | Purpose |
|-------|-------|--------|---------|
| **Discovery** | User prompt + OpenAPI specs | `discovery-result.json` | Map requirements to capabilities/modules |
| **Context** | Discovery + Specs | `generation-context.json` | Extract all template variables |
| **Plan** | Discovery result | `execution-plan.json` | Determine phase execution order |
| **CodeGen** | Context + Templates | Generated code | Produce code per subphase |
| **Validation** | Generated code | Pass/Fail | Verify compliance (4 tiers) |

### Validation Tiers

| Tier | Scope | Checks |
|------|-------|--------|
| **Tier 0** | Conformance | Template structure, naming |
| **Tier 1** | Universal | Traceability, project structure |
| **Tier 2** | Domain | Code-specific validations |
| **Tier 3** | Module | Per-module specialized checks |

---

## Knowledge Base Structure

```
enablement-2.0-kb/
├── model/                    # Conceptual model
│   ├── ENABLEMENT-MODEL-v3.0.md
│   └── standards/authoring/  # CAPABILITY.md, MODULE.md, etc.
├── modules/                  # Reusable code modules
│   ├── mod-code-001-*/       # Circuit breaker
│   ├── mod-code-015-*/       # Hexagonal base
│   ├── mod-code-017-*/       # SystemAPI persistence
│   └── mod-code-019-*/       # HATEOAS/pagination
├── runtime/                  # Execution components
│   ├── discovery/            # capability-index.yaml
│   ├── flows/                # Generation flows
│   └── validators/           # Validation scripts
├── schemas/                  # JSON schemas
└── docs/                     # Documentation
```

---

## Key Patterns Implemented

### 1. Config Flags Pub/Sub (DEC-035)

Enables cross-module influence without tight coupling:

```yaml
# Publisher (capability-index.yaml)
domain-api:
  publishes_flags:
    hateoas: true
    pagination: true

# Subscriber (MODULE.md)
subscribes_to_flags:
  - flag: hateoas
    affects: [Response.java.tpl]
```

### 2. Phase Catalog (ODEC-018)

Inter-phase coherence for code generation:

```json
{
  "phase": "1.1",
  "classes": {
    "Customer": {
      "package": "com.bank.customer.domain.model",
      "methods": ["create()", "reconstitute()"]
    }
  }
}
```

### 3. Explicit Template Paths (DEC-036)

All templates declare exact output paths:

```java
// Output: {{basePackagePath}}/{{ServiceName}}Application.java
```

### 4. Reproducibility Rules (DEC-039)

Ensures consistent output across runs:
- Trailing newline normalization (post-process)
- Helper method patterns (toUpperCase, toLowerCase)
- ASCII-only comments (no Unicode arrows)

---

## Current Capabilities

### Structural (Phase 1)
- **mod-015**: Hexagonal architecture base (domain, application, adapter layers)
- **mod-019**: HATEOAS + pagination support

### Implementation (Phase 2)
- **mod-017**: SystemAPI persistence (REST client to backend systems)

### Cross-Cutting (Phase 3)
- **mod-001**: Circuit breaker (Resilience4j)
- **mod-002**: Retry patterns
- **mod-003**: Timeout handling

---

## Reproducibility Status

As of 2026-02-03 (3 independent runs, pre-DEC-039):

| Metric | Result |
|--------|--------|
| File structure | 100% reproducible |
| Phase 1 content | 100% identical |
| Phase 2/3 content | Functional with minor variations |
| Compilation | ✅ All pass |
| Tests | ✅ All pass |
| Validation | ✅ All pass |

**Variations addressed by DEC-039:**
- Trailing newlines -> Post-process normalization
- Helper method style -> Explicit prompt rules
- Unicode in comments -> ASCII-only templates + rules

---

## Version History

| Version | Date | Highlights |
|---------|------|------------|
| 3.0.13 | 2026-02-03 | Phase 2 reproducibility improvements (DEC-039) |
| 3.0.12 | 2026-02-03 | E2E validation, manifest fixes |
| 3.0.11 | 2026-02-03 | Config Flags Pub/Sub pattern |
| 3.0.10 | 2026-01-28 | POSIX compatibility fixes |
| 3.0.0 | 2026-01-20 | Model v3.0 release |

---

## References

- [ENABLEMENT-MODEL-v3.0.md](../model/ENABLEMENT-MODEL-v3.0.md) - Complete model specification
- [DECISION-LOG.md](../DECISION-LOG.md) - All architectural decisions (DEC-001 to DEC-039)
- [CHANGELOG.md](../CHANGELOG.md) - Version history
- [capability-index.yaml](../runtime/discovery/capability-index.yaml) - Capability registry
