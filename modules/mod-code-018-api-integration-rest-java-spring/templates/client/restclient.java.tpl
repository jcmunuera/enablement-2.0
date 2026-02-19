// ═══════════════════════════════════════════════════════════════════════════════
// Template: restclient.java.tpl
// Module: mod-code-018-api-integration-rest-java-spring
// Variant: restclient (DEFAULT)
// ═══════════════════════════════════════════════════════════════════════════════
// Output: {{basePackagePath}}/adapter/out/integration/{{ApiName}}Client.java
// Purpose: RestClient implementation for REST API integration (Spring 3.2+)
// ═══════════════════════════════════════════════════════════════════════════════
// REQUIRED VARIABLES (must be in generation-context.json):
//   - {{basePackage}}      : Java base package (e.g., com.bank.customer)
//   - {{basePackagePath}}  : Package as path (e.g., com/bank/customer)
//   - {{ApiName}}          : API name PascalCase (e.g., Parties)
//   - {{apiName}}          : API name camelCase (e.g., parties)
//   - {{resourcePath}}     : Base resource path (e.g., /parties)
//   - {{serviceName}}      : Service name for X-Source-System header
// ═══════════════════════════════════════════════════════════════════════════════

package {{basePackage}}.adapter.out.integration;

import {{basePackage}}.adapter.out.integration.dto.{{ApiName}}Response;
import {{basePackage}}.adapter.out.integration.dto.{{ApiName}}Request;
import {{basePackage}}.adapter.out.integration.exception.IntegrationException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.util.List;

/**
 * REST client for {{ApiName}} System API.
 * Uses Spring RestClient (Spring 6.1+ / Boot 3.2+).
 * 
 * @generated
 * @module mod-code-018-api-integration-rest-java-spring
 * @variant restclient
 * @capability integration.api-rest
 */
@Component
public class {{ApiName}}SystemApiClient {
    
    private static final Logger log = LoggerFactory.getLogger({{ApiName}}SystemApiClient.class);
    
    private final RestClient restClient;
    
    public {{ApiName}}SystemApiClient(
            RestClient.Builder restClientBuilder,
            @Value("${integration.{{apiName}}-api.base-url}") String baseUrl) {
        this.restClient = restClientBuilder
            .baseUrl(baseUrl)
            .defaultStatusHandler(
                status -> status.is4xxClientError() || status.is5xxServerError(),
                (request, response) -> {
                    throw new IntegrationException(
                        "{{ApiName}} API error: " + response.getStatusCode(),
                        response.getStatusCode().value()
                    );
                }
            )
            .build();
    }
    
    public {{ApiName}}Response getById(String id) {
        log.debug("{{ApiName}}: GET {{resourcePath}}/{}", id);
        
        return restClient.get()
            .uri("{{resourcePath}}/{id}", id)
            .headers(this::addCorrelationHeaders)
            .retrieve()
            .body({{ApiName}}Response.class);
    }
    
    public List<{{ApiName}}Response> getAll() {
        log.debug("{{ApiName}}: GET {{resourcePath}}");
        
        return restClient.get()
            .uri("{{resourcePath}}")
            .headers(this::addCorrelationHeaders)
            .retrieve()
            .body(new ParameterizedTypeReference<>() {});
    }
    
    public {{ApiName}}Response create({{ApiName}}Request request) {
        log.debug("{{ApiName}}: POST {{resourcePath}}");
        
        return restClient.post()
            .uri("{{resourcePath}}")
            .headers(this::addCorrelationHeaders)
            .contentType(MediaType.APPLICATION_JSON)
            .body(request)
            .retrieve()
            .body({{ApiName}}Response.class);
    }
    
    public {{ApiName}}Response update(String id, {{ApiName}}Request request) {
        log.debug("{{ApiName}}: PUT {{resourcePath}}/{}", id);
        
        return restClient.put()
            .uri("{{resourcePath}}/{id}", id)
            .headers(this::addCorrelationHeaders)
            .contentType(MediaType.APPLICATION_JSON)
            .body(request)
            .retrieve()
            .body({{ApiName}}Response.class);
    }
    
    public void delete(String id) {
        log.debug("{{ApiName}}: DELETE {{resourcePath}}/{}", id);
        
        restClient.delete()
            .uri("{{resourcePath}}/{id}", id)
            .headers(this::addCorrelationHeaders)
            .retrieve()
            .toBodilessEntity();
    }
    
    /**
     * Adds correlation headers for distributed tracing.
     * MANDATORY for all outbound requests per ERI-CODE-013.
     */
    private void addCorrelationHeaders(org.springframework.http.HttpHeaders headers) {
        String correlationId = MDC.get("correlationId");
        if (correlationId != null) {
            headers.set("X-Correlation-ID", correlationId);
        }
        headers.set("X-Source-System", "{{serviceName}}");
    }
}
