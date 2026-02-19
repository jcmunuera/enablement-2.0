// ═══════════════════════════════════════════════════════════════════════════════
// Template: EntityModelAssembler.java.tpl
// Module: mod-code-019-api-public-exposure-java-spring
// ═══════════════════════════════════════════════════════════════════════════════
// Output: {{basePackagePath}}/adapter/in/rest/assembler/{{entityName}}ModelAssembler.java
// Purpose: Converts {{entityName}} to HATEOAS-enabled responses per ADR-001
// ═══════════════════════════════════════════════════════════════════════════════
// REQUIRED VARIABLES (must be in generation-context.json):
//   - {{basePackage}}      : Java base package (e.g., com.bank.customer)
//   - {{basePackagePath}}  : Package as path (e.g., com/bank/customer)
//   - {{entityName}}       : Entity name PascalCase (e.g., Customer)
//   - {{entityNameLower}}  : Entity name camelCase (e.g., customer)
// ═══════════════════════════════════════════════════════════════════════════════

package {{basePackage}}.adapter.in.rest.assembler;

import {{basePackage}}.adapter.in.rest.{{entityName}}Controller;
import {{basePackage}}.application.dto.{{entityName}}Response;
import {{basePackage}}.domain.model.{{entityName}};
import org.springframework.hateoas.server.mvc.RepresentationModelAssemblerSupport;
import org.springframework.stereotype.Component;

import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.*;

/**
 * Assembler that converts {{entityName}} domain entities to {{entityName}}Response DTOs
 * with HATEOAS links per ADR-001.
 * 
 * @generated
 * @module mod-code-019-api-public-exposure-java-spring
 * @capability api-architecture.domain-api
 */
@Component
public class {{entityName}}ModelAssembler 
        extends RepresentationModelAssemblerSupport<{{entityName}}, {{entityName}}Response> {
    
    public {{entityName}}ModelAssembler() {
        super({{entityName}}Controller.class, {{entityName}}Response.class);
    }
    
    @Override
    public {{entityName}}Response toModel({{entityName}} entity) {
        {{entityName}}Response response = {{entityName}}Response.fromDomain(entity);
        
        // Self link
        response.add(linkTo(methodOn({{entityName}}Controller.class)
            .getById(entity.getId().toString()))
            .withSelfRel());
        
        // Collection link
        response.add(linkTo(methodOn({{entityName}}Controller.class)
            .getAll())
            .withRel("{{entityNameLower}}s"));
        
        return response;
    }
}
