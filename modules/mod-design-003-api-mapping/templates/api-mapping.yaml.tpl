# API Mapping Template
# Module: mod-design-003-api-mapping (Step 3.1 + 3.2)
#
# Populated from:
# - bounded-context-map.yaml (context, subdomain type → tier)
# - aggregate-definitions.yaml (aggregate, commands, queries → resources, operations)
# - ADR-DESIGN-003 tier mapping rules
# - ADR-DESIGN-003 REST surface mapping rules

version: "1.0"
source_context: "${CONTEXT_ID}"
source_aggregate: "${AGGREGATE_ID}"
analysis_date: "${ANALYSIS_DATE}"
api_type: rest                                   # Default per ADR-DESIGN-003

# ─── Step 3.1: Tier Assignment ───
# Rules:
#   core/supporting subdomain → domain API
#   generic subdomain → system API or external
#   cross-context workflow → composable API
#   channel-specific → experience/BFF API
#   backend integration → system API
api_tier: "${API_TIER}"                          # domain|system|composable|experience
api_name: "${API_NAME}"
api_version: "v1"
base_path: "/api/v1/${RESOURCES_PLURAL}"

# ─── Step 3.2: Resource Mapping (REST) ───
# Rules per ADR-DESIGN-003 REST variant:
#   Aggregate root → /{plural} resource
#   Create* command → POST /{resources}
#   Update* command → PUT /{resources}/{id}
#   Delete* command → DELETE /{resources}/{id}
#   Change*/Process* → POST /{resources}/{id}/{action}
#   Get-by-ID query → GET /{resources}/{id}
#   List query → GET /{resources} (paginated)
#   Search query → GET /{resources}/search
resources:
  - name: "${RESOURCE_NAME}"
    path: "/${RESOURCES_PLURAL}"
    aggregate: "${AGGREGATE_ID}"
    operations:
      # For each command in aggregate-definitions.yaml:
      - method: "${HTTP_METHOD}"
        path: "${ENDPOINT_PATH}"
        command_or_query: "${COMMAND_OR_QUERY_ID}"
        description: "${OPERATION_DESCRIPTION}"
        pagination: false
        idempotent: ${IS_IDEMPOTENT}

# ─── Dependencies ───
system_api_dependencies:
  # Populated when context_relationships contain ACL or conformist
  # to legacy/external systems
  - system_api: "${SYSTEM_API_NAME}"
    purpose: "${SYSTEM_DESCRIPTION}"
    field_mapping_ref: "${FIELD_MAPPING_FILE}"

composable_api_participants: []
