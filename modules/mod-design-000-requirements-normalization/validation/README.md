# Validation — mod-design-000-requirements-normalization

## Scripts

| Script | Purpose |
|--------|---------|
| `requirements-check.sh` | Validates structure AND gap detection rules |

## Usage

```bash
./validation/requirements-check.sh <normalized-requirements.yaml>
```

## Structural Validation Rules

| # | Rule | Severity |
|---|------|----------|
| 1 | Valid YAML | ERROR |
| 2 | Required top-level fields present | ERROR |
| 3 | At least 1 actor | ERROR |
| 4 | At least 1 feature group | ERROR |
| 5 | At least 1 feature per group | ERROR |
| 6 | Feature type valid (query/command/composite) | ERROR |
| 7 | Feature criticality valid | ERROR |
| 8 | Command features have ≥1 business rule | ERROR |
| 9 | Command features have ≥1 error scenario | ERROR |
| 10 | At least 1 data entity per feature | ERROR |
| 11 | Entity classification valid | ERROR |
| 12 | Actor refs valid | ERROR |
| 13 | All IDs kebab-case | ERROR |
| 14 | List features have pagination block | WARNING |
| 15 | Feature group order sequential | WARNING |
| 16 | Assumptions present | WARNING |

## Gap Detection Rules (downstream readiness)

These rules verify that enough information has been gathered for downstream DESIGN phases (Strategic DDD, Tactical DDD, BDD) to produce correct output.

| Rule | What it checks | Required by | Severity |
|------|---------------|-------------|----------|
| G1 | Every reference entity has a known integration source | Phase 1: relationship type | WARNING |
| G2 | Stateful entities have state machine defined | Phase 2: invariants, commands | ERROR |
| G3 | Business criticality/differentiation info exists | Phase 1: subdomain classification | WARNING |
| G4 | Integrations have access method info | Phase 1: build vs buy | WARNING |
| G5 | Cross-system commands have sync/async clarity | Phase 1+2: patterns, events | WARNING |
| G6 | Terminal states explicitly confirmed | Phase 2: irreversibility invariants | WARNING |

## Interpreting Results

- **0 warnings**: Output is complete for downstream consumption
- **Structural warnings only** (pagination, order): Minor, proceed with caution
- **Gap warnings (G1-G6)**: Downstream phases may produce incorrect output. Consider enriching before proceeding.
- **Gap errors (G2)**: MUST be resolved before proceeding — stateful entities without state machines will produce broken tactical design.
