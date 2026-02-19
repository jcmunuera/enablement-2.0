// ═══════════════════════════════════════════════════════════════════════════════
// Template: application-retry.yml.tpl
// Module: mod-code-002-retry-java-resilience4j
// ═══════════════════════════════════════════════════════════════════════════════
// Output: Applied to existing adapter/service class
// Purpose: Resilience pattern template
// ═══════════════════════════════════════════════════════════════════════════════
// REQUIRED VARIABLES: {{BusinessException}} {{basePackage}} {{maxAttempts}} {{retryName}} {{waitDuration}} 
// ═══════════════════════════════════════════════════════════════════════════════

# Template: application-retry.yml.tpl
# Output: src/main/resources/application.yml (merge)
# Purpose: Resilience4j retry configuration

resilience4j:
  retry:
    configs:
      default:
        maxAttempts: 3
        waitDuration: 500ms
        enableExponentialBackoff: true
        exponentialBackoffMultiplier: 2
        retryExceptions:
          - java.net.ConnectException
          - java.net.SocketTimeoutException
          - org.springframework.web.client.ResourceAccessException
          - java.io.IOException
        ignoreExceptions:
          - {{basePackage}}.domain.exception.{{BusinessException}}
    
    instances:
      {{retryName}}:
        baseConfig: default
        maxAttempts: {{maxAttempts}}
        waitDuration: {{waitDuration}}ms

management:
  endpoints:
    web:
      exposure:
        include: health,metrics,retries,retryevents
  health:
    retries:
      enabled: true
