// ═══════════════════════════════════════════════════════════════════════════════
// Template: basic-retry.java.tpl
// Module: mod-code-002-retry-java-resilience4j
// ═══════════════════════════════════════════════════════════════════════════════
// Output: Applied to existing service class
// Purpose: Basic retry pattern without fallback
// ═══════════════════════════════════════════════════════════════════════════════
// REQUIRED VARIABLES: {{ParamType}} {{ReturnType}} {{clientMethod}} {{methodName}} {{paramName}} {{retryName}} 
// ═══════════════════════════════════════════════════════════════════════════════

import io.github.resilience4j.retry.annotation.Retry;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Retry(name = "{{retryName}}")
public {{ReturnType}} {{methodName}}({{ParamType}} {{paramName}}) {
    log.debug("Calling external service: {}", {{paramName}});
    return client.{{clientMethod}}({{paramName}});
}
