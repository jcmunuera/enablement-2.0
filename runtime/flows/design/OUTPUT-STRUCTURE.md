# Design Pipeline Output Structure

## Overview

This document defines the normalized output structure produced by the DESIGN pipeline (phases 0-3) and the Bridge pipeline (phase 4). All tests and comparisons must follow this structure.

## Structure

```
design-output/
│
│  ── Root artifacts (one per project) ──────────────────────
│
├── normalized-requirements.yaml              # Phase 0
│   Normalized functional requirements, features, entities,
│   integrations, assumptions.
│
├── bounded-context-map.yaml                  # Phase 1
│   Strategic DDD: subdomains, bounded contexts, relationships,
│   investment strategies.
│
│  ── Per bounded context (build only) ──────────────────────
│
├── {context-id}/
│   │
│   │  ── DESIGN output (phases 2-3) ───────────────────────
│   │
│   ├── aggregate-definitions.yaml            # Phase 2
│   │   Tactical DDD: aggregates, entities, value objects,
│   │   commands, queries, domain events, invariants.
│   │
│   ├── {aggregate}.feature                   # Phase 3
│   │   BDD scenarios in Gherkin format.
│   │   One file per aggregate (named after aggregate).
│   │
│   ├── scenario-tracing.yaml                 # Phase 3
│   │   Traceability: scenario → requirement → aggregate operation.
│   │
│   │  ── Bridge output (phase 4) ──────────────────────────
│   │
│   ├── openapi-spec.yaml                     # Phase 4b
│   │   OpenAPI 3.0 contract generated from aggregate + binding.
│   │   One per context (all aggregates in context share spec).
│   │
│   ├── manifest.yaml                         # Phase 4c
│   │   Capability manifest: pre-resolved CODE capabilities
│   │   with source annotation (inherent/inferred/stack/manual).
│   │
│   └── prompt.md                             # Phase 4d
│       CODE-ready prompt: service description, domain model,
│       BDD scenarios (full), capabilities, integration context.
│
└── {another-context-id}/
    └── (same structure)
```

## File Manifest per Context

| File | Phase | Producer | Required |
|------|-------|----------|----------|
| `aggregate-definitions.yaml` | 2 | DESIGN | ✅ |
| `{aggregate}.feature` | 3 | DESIGN | ✅ |
| `scenario-tracing.yaml` | 3 | DESIGN | ✅ |
| `openapi-spec.yaml` | 4b | Bridge (contract-gen) | ✅ |
| `manifest.yaml` | 4c | Bridge (capability-inference) | ✅ |
| `prompt.md` | 4d | Bridge (prompt-assembly) | ✅ |

**Total per context: 6 files** (3 DESIGN + 3 Bridge)
**Total root: 2 files** (requirements + context map)

## Validation Checklist

For each test run, verify:

### Phase 0-3 (DESIGN)
- [ ] `normalized-requirements.yaml` passes `requirements-check.sh`
- [ ] `bounded-context-map.yaml` passes `context-map-check.sh`
- [ ] Each context: `aggregate-definitions.yaml` passes `aggregate-check.sh`
- [ ] Each context: `.feature` passes `gherkin-syntax-check.sh`
- [ ] Each context: `scenario-tracing.yaml` passes `tracing-check.sh`
- [ ] Each context: aggregate + tracing passes `coverage-check.sh`

### Phase 4 (Bridge)
- [ ] Each context: `manifest.yaml` passes `manifest-check.sh` (vs capability-index)
- [ ] Each context: `openapi-spec.yaml` has 1 endpoint per command/query in aggregate
- [ ] Each context: `prompt.md` contains full BDD scenarios
- [ ] Each context: `prompt.md` contains all manifest capabilities

## Comparison Protocol

When comparing multiple test runs:

1. **Structural comparison:** Same number of contexts, same context names
2. **Phase 2 comparison:** Same aggregates, same commands/queries per aggregate
3. **Phase 3 comparison:** Scenario count per context, category distribution
4. **Phase 4b comparison:** Same endpoints per context, same error codes
5. **Phase 4c comparison:** Same capabilities per context (source may differ)
6. **Phase 4d comparison:** Prompt token count, BDD scenario count
