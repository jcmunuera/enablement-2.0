// ═══════════════════════════════════════════════════════════════════════════════
// Template: application-circuitbreaker.yml.tpl
// Module: mod-code-001-circuit-breaker-java-resilience4j
// ═══════════════════════════════════════════════════════════════════════════════
// Output: Applied to existing adapter/service class
// Purpose: Resilience pattern template
// ═══════════════════════════════════════════════════════════════════════════════
// REQUIRED VARIABLES: {{circuitBreakerName}} {{failureRateThreshold}} {{minimumNumberOfCalls}} {{slidingWindowSize}} {{waitDurationInOpenState}} 
// ═══════════════════════════════════════════════════════════════════════════════

# Template: application-circuitbreaker.yml.tpl
# Output: src/main/resources/application.yml (merge)
# Purpose: Resilience4j circuit breaker configuration

resilience4j:
  circuitbreaker:
    instances:
      {{circuitBreakerName}}:
        failure-rate-threshold: {{failureRateThreshold}}
        wait-duration-in-open-state: {{waitDurationInOpenState}}s
        sliding-window-size: {{slidingWindowSize}}
        minimum-number-of-calls: {{minimumNumberOfCalls}}
        permitted-number-of-calls-in-half-open-state: 10
        automatic-transition-from-open-to-half-open-enabled: true
        sliding-window-type: COUNT_BASED
        register-health-indicator: true
        event-consumer-buffer-size: 10
