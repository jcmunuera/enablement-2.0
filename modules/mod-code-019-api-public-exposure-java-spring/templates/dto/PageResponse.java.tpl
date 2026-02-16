// ═══════════════════════════════════════════════════════════════════════════════
// Template: PageResponse.java.tpl
// Module: mod-code-019-api-public-exposure-java-spring
// ═══════════════════════════════════════════════════════════════════════════════
// Output: {{basePackagePath}}/adapter/in/rest/dto/PageResponse.java
// Purpose: Standard pagination response per ADR-001
// ═══════════════════════════════════════════════════════════════════════════════
// REQUIRED VARIABLES: {{basePackagePath}} {{basePackage}} 
// ═══════════════════════════════════════════════════════════════════════════════

package {{basePackage}}.adapter.in.rest.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import org.springframework.hateoas.Links;

import java.util.List;

/**
 * Standard page response structure following ADR-001 pagination standards.
 * 
 * @param <T> Type of content items
 */
public record PageResponse<T>(
    List<T> content,
    PageMetadata page,
    @JsonProperty("_links") Links links
) {
    
    public record PageMetadata(
        int number,
        int size,
        long totalElements,
        int totalPages
    ) {}
    
    /**
     * Factory method to create PageResponse from Spring Page.
     */
    public static <T> PageResponse<T> of(
            List<T> content,
            int number,
            int size,
            long totalElements,
            int totalPages,
            Links links) {
        return new PageResponse<>(
            content,
            new PageMetadata(number, size, totalElements, totalPages),
            links
        );
    }
}
