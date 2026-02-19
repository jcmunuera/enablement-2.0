# Validation — mod-design-004-bdd-scenarios

## Scripts

| Script | Purpose | Severity |
|--------|---------|----------|
| `gherkin-syntax-check.sh` | Validates .feature file is valid Gherkin | ERROR |
| `coverage-check.sh` | Validates every command/invariant/query has scenario coverage | ERROR |
| `tracing-check.sh` | Validates scenario-tracing.yaml completeness and correctness | ERROR/WARNING |

## Usage

```bash
./validation/gherkin-syntax-check.sh <feature-file>
./validation/coverage-check.sh <aggregate-definitions.yaml> <scenario-tracing.yaml>
./validation/tracing-check.sh <feature-file> <scenario-tracing.yaml>
```

## Validation Rules

### gherkin-syntax-check.sh
| # | Rule | Severity |
|---|------|----------|
| 1 | Feature keyword present | ERROR |
| 2 | Every Scenario has Given/When/Then | ERROR |
| 3 | Single When per Scenario | ERROR |
| 4 | No HTTP codes in content | ERROR |
| 5 | No JSON references in content | ERROR |

### coverage-check.sh
| # | Rule | Severity |
|---|------|----------|
| 1 | Every command has ≥1 happy-path scenario | ERROR |
| 2 | Every command has ≥1 validation/error scenario | ERROR |
| 3 | Every query has ≥1 happy-path scenario | ERROR |
| 4 | Every invariant has ≥1 violation scenario | ERROR |
| 5 | All capabilities traced | WARNING |

### tracing-check.sh
| # | Rule | Severity |
|---|------|----------|
| 1 | Valid YAML | ERROR |
| 2 | Every scenario in .feature has tracing entry | ERROR |
| 3 | Every tracing entry references scenario in .feature | ERROR |
| 4 | Category is from valid set | ERROR |
| 5 | tests_invariant present when category=invariant | ERROR |
| 6 | expected_error present for error scenarios | ERROR |
| 7 | IDs are kebab-case and unique | ERROR |
