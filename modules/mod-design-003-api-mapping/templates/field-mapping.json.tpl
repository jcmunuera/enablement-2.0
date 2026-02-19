{
  "$comment": "Field Mapping Template — Module: mod-design-003-api-mapping (Step 3.4)",
  "$comment2": "Only generated when system_api_dependencies is non-empty in api-mapping.yaml",
  "version": "1.0",
  "domain_api": "${DOMAIN_API_NAME}",
  "system_api": "${SYSTEM_API_NAME}",
  "system_description": "${SYSTEM_DESCRIPTION}",
  "entity_mappings": [
    {
      "domain_entity": "${ENTITY_NAME}",
      "system_entity": "${BACKEND_ENTITY_NAME}",
      "field_mappings": [
        {
          "domain_field": "${DOMAIN_FIELD}",
          "domain_type": "${DOMAIN_TYPE}",
          "system_field": "${SYSTEM_FIELD}",
          "system_type": "${SYSTEM_TYPE}",
          "transformation": "${TRANSFORMATION_TYPE}",
          "direction": "${DIRECTION}",
          "notes": "${NOTES}"
        }
      ]
    }
  ],
  "transformation_types": {
    "direct": "Same value, possibly different field name",
    "uuid-to-string": "UUID to string representation",
    "enum-to-code": "Enum value to legacy code mapping",
    "date-format": "Date format conversion (e.g., ISO to YYYYMMDD)",
    "composite": "Multiple domain fields combine into one system field",
    "lookup": "Value requires external lookup or enrichment",
    "constant": "Fixed value always sent to system"
  }
}
