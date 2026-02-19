# OpenAPI Specification Template
# Module: mod-design-003-api-mapping (Step 3.3 — Contract Generation)
#
# Template variables are populated from:
# - api-mapping.yaml (tier, paths, operations)
# - aggregate-definitions.yaml (entities, attributes, value objects, error codes)
#
# Type mapping: Domain → OpenAPI
#   String    → string
#   UUID      → string (format: uuid)
#   Email     → string (format: email)
#   LocalDate → string (format: date)
#   Instant   → string (format: date-time)
#   Long      → integer (format: int64)
#   Integer   → integer (format: int32)
#   Boolean   → boolean
#   Enum      → string (enum: [...])
#   List<T>   → array (items: T)

openapi: "3.0.3"
info:
  title: "${API_NAME}"
  description: "${API_DESCRIPTION}"
  version: "${API_VERSION}"
  contact:
    name: "${OWNER_TEAM}"

servers:
  - url: "${BASE_URL}"
    description: "${ENVIRONMENT}"

paths:
  # ─── For each operation in api-mapping.yaml ───
  ${PATH}:
    ${METHOD}:
      operationId: "${OPERATION_ID}"
      summary: "${DESCRIPTION}"
      tags:
        - "${RESOURCE_NAME}"
      # For POST/PUT: requestBody with schema from command inputs
      # For GET with path param: parameters with {id}
      # For GET collection: parameters with filters + page/size
      # For error responses: match error_cases from aggregate
      responses:
        "200":
          description: "Success"
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/${RESPONSE_SCHEMA}"
        # Error responses per command error_cases
        "${ERROR_STATUS}":
          description: "${ERROR_DESCRIPTION}"
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/ErrorResponse"

components:
  schemas:
    # ─── Entity schema from aggregate root attributes ───
    ${ENTITY_NAME}:
      type: object
      required: [${REQUIRED_FIELDS}]
      properties:
        # For each attribute in entity:
        ${FIELD_NAME}:
          type: "${OPENAPI_TYPE}"
          format: "${OPENAPI_FORMAT}"
          description: "${FIELD_DESCRIPTION}"

    # ─── Value object schemas ───
    ${VO_NAME}:
      type: object
      properties:
        ${VO_FIELD_NAME}:
          type: "${OPENAPI_TYPE}"

    # ─── Request schemas from command inputs ───
    Create${ENTITY_NAME}Request:
      type: object
      required: [${REQUIRED_INPUT_FIELDS}]
      properties:
        ${INPUT_FIELD}:
          type: "${OPENAPI_TYPE}"

    Update${ENTITY_NAME}Request:
      type: object
      properties:
        ${INPUT_FIELD}:
          type: "${OPENAPI_TYPE}"

    # ─── Pagination response wrapper ───
    ${ENTITY_NAME}Page:
      type: object
      properties:
        content:
          type: array
          items:
            $ref: "#/components/schemas/${ENTITY_NAME}"
        page:
          type: integer
        size:
          type: integer
        totalElements:
          type: integer
        totalPages:
          type: integer

    # ─── Standard error response ───
    ErrorResponse:
      type: object
      required: [code, message]
      properties:
        code:
          type: string
          description: "Error code (e.g., DUPLICATE_EMAIL, CUSTOMER_NOT_FOUND)"
        message:
          type: string
          description: "Human-readable error message"
        details:
          type: array
          items:
            type: string
          description: "Additional error details"
