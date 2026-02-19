# Validation — mod-design-003-api-mapping

## Scripts

| Script | Purpose | Severity |
|--------|---------|----------|
| `api-mapping-check.sh` | Validates api-mapping.yaml structure and tier rules | ERROR |
| `openapi-lint.sh` | Validates OpenAPI spec structure | ERROR |
| `field-mapping-check.sh` | Validates field-mapping.json structure and transformation types | ERROR |

## Usage

```bash
./validation/api-mapping-check.sh <api-mapping.yaml>
./validation/openapi-lint.sh <openapi-spec.yaml>
./validation/field-mapping-check.sh <field-mapping.json>
```

## Validation Rules

### api-mapping-check.sh
| # | Rule | Severity |
|---|------|----------|
| 1 | Valid YAML | ERROR |
| 2 | Required fields present | ERROR |
| 3 | api_tier in valid set | ERROR |
| 4 | api_type in valid set | ERROR |
| 5 | Every aggregate has ≥1 resource | ERROR |
| 6 | Every operation has command_or_query ref | ERROR |
| 7 | HTTP methods valid | ERROR |
| 8 | system_api_dependencies have field_mapping_ref | ERROR |

### openapi-lint.sh
| # | Rule | Severity |
|---|------|----------|
| 1 | Valid YAML | ERROR |
| 2 | openapi version field present | ERROR |
| 3 | info.title present | ERROR |
| 4 | paths non-empty | ERROR |
| 5 | components.schemas non-empty | ERROR |

### field-mapping-check.sh
| # | Rule | Severity |
|---|------|----------|
| 1 | Valid JSON | ERROR |
| 2 | Required fields present | ERROR |
| 3 | entity_mappings non-empty | ERROR |
| 4 | Transformation types valid | ERROR |
| 5 | Direction valid | ERROR |
