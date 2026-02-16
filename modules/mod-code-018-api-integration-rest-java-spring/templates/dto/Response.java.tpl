// Template: Response.java.tpl
// Output: {{basePackagePath}}/adapter/out/integration/dto/{{ApiName}}Response.java
// Module: mod-code-018-api-integration-rest-java-spring
// Purpose: Response DTO for external API integration

package {{basePackage}}.adapter.out.integration.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

/**
 * Response DTO for {{ApiName}} API integration.
 * 
 * NOTE: This is a generic placeholder. In real implementations:
 * - Generate from OpenAPI spec of the external API
 * - Or define fields based on actual API contract
 * 
 * @generated
 * @module mod-code-018-api-integration-rest-java-spring
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public record {{ApiName}}Response(
    String id,
    // TODO: Add fields based on {{ApiName}} API contract
    java.util.Map<String, Object> data
) {
    /**
     * Creates an empty response for testing/mocking.
     */
    public static {{ApiName}}Response empty() {
        return new {{ApiName}}Response(null, java.util.Map.of());
    }
}
