// ═══════════════════════════════════════════════════════════════════════════════
// Template: Response.java.tpl
// Module: mod-code-015-hexagonal-base-java-spring
// ═══════════════════════════════════════════════════════════════════════════════
// Output: {{basePackagePath}}/application/dto/{{Entity}}Response.java
// Purpose: Response DTO for {{Entity}} (basic, no HATEOAS)
// ═══════════════════════════════════════════════════════════════════════════════
// ⚠️  VARIANT SELECTION:
//     - If mod-019 (HATEOAS) is ACTIVE -> DO NOT USE THIS TEMPLATE
//       Use mod-019's Response-hateoas.java.tpl instead (extends RepresentationModel)
//     - If mod-019 is NOT active -> Use this template (simple record)
// ═══════════════════════════════════════════════════════════════════════════════
// REQUIRED VARIABLES:
//   - {{basePackage}}      : Java base package (e.g., com.bank.customer)
//   - {{basePackagePath}}  : Package as path (e.g., com/bank/customer)
//   - {{Entity}}           : Entity name PascalCase (e.g., Customer)
// ═══════════════════════════════════════════════════════════════════════════════

package {{basePackage}}.application.dto;

import {{basePackage}}.domain.model.*;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Response DTO for {{Entity}}.
 * 
 * Uses record for immutability.
 * NOTE: This is the basic version WITHOUT HATEOAS support.
 * 
 * @generated
 * @module mod-code-015-hexagonal-base-java-spring
 */
public record {{Entity}}Response(
    {{#fields}}
    {{type}} {{fieldName}}{{^last}},{{/last}}
    {{/fields}}
) {
    
    /**
     * Factory method to create response from domain entity.
     */
    public static {{Entity}}Response from({{Entity}} entity) {
        if (entity == null) {
            return null;
        }
        return new {{Entity}}Response(
            {{#fields}}
            entity.get{{FieldName}}(){{^last}},{{/last}}
            {{/fields}}
        );
    }
}
