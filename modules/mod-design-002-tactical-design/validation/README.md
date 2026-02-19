# Validation — mod-design-002-tactical-design

## Scripts

| Script | Purpose | Severity |
|--------|---------|----------|
| `aggregate-check.sh` | Validates aggregate-definitions.yaml structure and rules | ERROR/WARNING |

## Usage

```bash
./validation/aggregate-check.sh <path-to-aggregate-definitions.yaml> [full-tactical|entity-focused]
```

## Validation Rules

| # | Rule | Severity | Check |
|---|------|----------|-------|
| 1 | Valid YAML | ERROR | YAML parser succeeds |
| 2 | Required top-level fields | ERROR | version, bounded_context, context_name, analysis_date present |
| 3 | Single root per aggregate | ERROR | Exactly one is_root=true per aggregate |
| 4 | Entity unique to aggregate | ERROR | No entity ID duplicated across aggregates |
| 5 | VOs have no identity | ERROR | No value_object contains identity key |
| 6 | Command naming | ERROR | PascalCase, imperative verb prefix regex match |
| 7 | Event naming | ERROR | PascalCase, past tense suffix regex match |
| 8 | Command has error cases | ERROR | Non-empty error_cases per command (full-tactical) |
| 9 | Invariant linked | WARNING | Each invariant referenced by ≥1 error case |
| 10 | Context ref present | ERROR | bounded_context field is non-empty |
| 11 | IDs are kebab-case | ERROR | All id fields match ^[a-z][a-z0-9-]*$ |
| 12 | Event triggered_by valid | ERROR | References existing command ID |
| 13 | Command produces_event valid | ERROR | References existing event ID |
| 14 | VO used_by valid | ERROR | References existing entity ID within aggregate |
