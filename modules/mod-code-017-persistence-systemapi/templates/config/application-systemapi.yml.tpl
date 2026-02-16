// ═══════════════════════════════════════════════════════════════════════════════
// Template: application-systemapi.yml.tpl
// Module: mod-code-017-persistence-systemapi
// ═══════════════════════════════════════════════════════════════════════════════
// Output: {{basePackagePath}}/.../application-systemapi.yml
// Purpose: Template for application-systemapi.yml
// ═══════════════════════════════════════════════════════════════════════════════
// REQUIRED VARIABLES: {{Entity}} {{basePackage}} {{serviceName}} {{{SERVICE_NAME}} 
// ═══════════════════════════════════════════════════════════════════════════════
// NOTE (DEC-043): Resilience4j configuration (circuitbreaker, retry, timelimiter)
//       is NOT included here. It is generated exclusively in Phase 3 by the
//       corresponding cross-cutting modules (mod-001, mod-002, mod-003).
//       This template only contains connectivity and logging configuration.
// ═══════════════════════════════════════════════════════════════════════════════

# Template: application-systemapi.yml.tpl
# Output: src/main/resources/application-systemapi.yml
# Purpose: System API connectivity configuration

# System API Configuration
system-api:
  {{serviceName}}:
    base-url: ${{{SERVICE_NAME}}_SYSTEM_API_URL:http://localhost:8081}

# Logging
logging:
  level:
    {{basePackage}}.adapter.systemapi: DEBUG
