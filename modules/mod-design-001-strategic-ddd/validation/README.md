# Validation — mod-design-001-strategic-ddd

## Scripts

| Script | Purpose | Severity |
|--------|---------|----------|
| `context-map-check.sh` | Validates bounded-context-map.yaml structure and rules | ERROR/WARNING |

## Usage

```bash
./validation/context-map-check.sh <path-to-bounded-context-map.yaml> [option]
```

**Options:**
- `full-strategic` (default) — Full validation including UL term count
- `lightweight` — Relaxed validation (no UL minimum, no subdomain section required)

## Validation Rules

| # | Rule | Severity | Check |
|---|------|----------|-------|
| 1 | Valid YAML | ERROR | YAML parser succeeds |
| 2 | Required top-level fields | ERROR | version, domain, description, analysis_date, source_requirements present |
| 3 | Context IDs unique | ERROR | No duplicate context IDs across all subdomains |
| 4 | At least 1 capability per context | ERROR | Non-empty capabilities array |
| 5 | At least 3 UL terms per context | ERROR | ubiquitous_language.length >= 3 (full-strategic only) |
| 6 | Subdomain type valid | ERROR | type in [core, supporting, generic] |
| 7 | Relationship type valid | ERROR | type in [customer-supplier, conformist, acl, partnership, shared-kernel, open-host, published-language] |
| 8 | Relationship refs valid | ERROR | upstream and downstream exist as context IDs |
| 9 | Integration pattern valid | ERROR | integration_pattern in [sync-api, async-event, shared-db] |
| 10 | No duplicate capabilities | WARNING | No capability string in multiple contexts |
| 11 | IDs are kebab-case | ERROR | All id fields match ^[a-z][a-z0-9-]*$ |
| 12 | No god contexts | WARNING | No context with >5 capabilities |
