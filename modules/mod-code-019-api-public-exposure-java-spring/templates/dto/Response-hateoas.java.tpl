// ═══════════════════════════════════════════════════════════════════════════════
// Template: Response-hateoas.java.tpl
// Module: mod-code-019-api-public-exposure-java-spring
// ═══════════════════════════════════════════════════════════════════════════════
// Output: {{basePackagePath}}/application/dto/{{Entity}}Response.java
// Purpose: Response DTO for {{Entity}} WITH HATEOAS support
// ═══════════════════════════════════════════════════════════════════════════════
// ⚠️  VARIANT SELECTION:
//     - This template MUST be used when mod-019 (HATEOAS) is active
//     - It generates a CLASS that extends RepresentationModel (required for HATEOAS)
//     - DO NOT use mod-015's Response.java.tpl when this module is active
//     - The ModelAssembler requires Response to extend RepresentationModel
// ═══════════════════════════════════════════════════════════════════════════════
// REQUIRED VARIABLES:
//   - {{basePackage}}      : Java base package (e.g., com.bank.customer)
//   - {{basePackagePath}}  : Package as path (e.g., com/bank/customer)
//   - {{Entity}}           : Entity name PascalCase (e.g., Customer)
//   - {{entity}}           : Entity name camelCase (e.g., customer)
//   - {{entityPlural}}     : Entity name plural (e.g., customers)
// ═══════════════════════════════════════════════════════════════════════════════

package {{basePackage}}.application.dto;

import {{basePackage}}.domain.model.*;
import org.springframework.hateoas.RepresentationModel;
import org.springframework.hateoas.server.core.Relation;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Response DTO for {{Entity}} with HATEOAS hypermedia links.
 * 
 * IMPORTANT: Uses CLASS (not record) because HATEOAS requires extending RepresentationModel.
 * This enables the .add(Link) method used by ModelAssembler.
 * 
 * @generated
 * @module mod-code-019-api-public-exposure-java-spring
 */
@Relation(collectionRelation = "{{entityPlural}}", itemRelation = "{{entity}}")
public class {{Entity}}Response extends RepresentationModel<{{Entity}}Response> {
    
    {{#fields}}
    private {{type}} {{fieldName}};
    {{/fields}}
    
    /**
     * Default constructor for serialization.
     */
    public {{Entity}}Response() {}
    
    /**
     * All-args constructor.
     */
    public {{Entity}}Response({{#fields}}{{type}} {{fieldName}}{{^last}}, {{/last}}{{/fields}}) {
        {{#fields}}
        this.{{fieldName}} = {{fieldName}};
        {{/fields}}
    }
    
    /**
     * Factory method to create response from domain entity.
     */
    public static {{Entity}}Response from({{Entity}} entity) {
        if (entity == null) {
            return null;
        }
        {{Entity}}Response response = new {{Entity}}Response();
        {{#fields}}
        response.{{fieldName}} = entity.get{{FieldName}}();
        {{/fields}}
        return response;
    }
    
    /**
     * Alias for from() - used by some assemblers.
     */
    public static {{Entity}}Response fromDomain({{Entity}} entity) {
        return from(entity);
    }
    
    // ========== Getters ==========
    
    {{#fields}}
    public {{type}} get{{FieldName}}() {
        return {{fieldName}};
    }
    
    {{/fields}}
    
    // ========== Setters ==========
    
    {{#fields}}
    public void set{{FieldName}}({{type}} {{fieldName}}) {
        this.{{fieldName}} = {{fieldName}};
    }
    
    {{/fields}}
}
