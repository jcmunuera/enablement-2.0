// Template: Request.java.tpl
// Output: {{basePackagePath}}/adapter/out/integration/dto/{{ApiName}}Request.java
// Module: mod-code-018-api-integration-rest-java-spring
// Purpose: Request DTO for external API integration

package {{basePackage}}.adapter.out.integration.dto;

/**
 * Request DTO for {{ApiName}} API integration.
 * 
 * NOTE: This is a generic placeholder. In real implementations:
 * - Generate from OpenAPI spec of the external API
 * - Or define fields based on actual API contract
 * 
 * @generated
 * @module mod-code-018-api-integration-rest-java-spring
 */
public record {{ApiName}}Request(
    // TODO: Add fields based on {{ApiName}} API contract
    java.util.Map<String, Object> data
) {
    /**
     * Creates an empty request for testing/mocking.
     */
    public static {{ApiName}}Request empty() {
        return new {{ApiName}}Request(java.util.Map.of());
    }
}
