// ═══════════════════════════════════════════════════════════════════════════════
// Template: EntityId.java.tpl
// Module: mod-code-015-hexagonal-base-java-spring
// ═══════════════════════════════════════════════════════════════════════════════
// Output: {{basePackagePath}}/domain/model/{{Entity}}Id.java
// Purpose: Value object for entity ID (type safety)
// ═══════════════════════════════════════════════════════════════════════════════
// REQUIRED VARIABLES (must be in generation-context.json):
//   - {{basePackage}}      : Java base package (e.g., com.bank.customer)
//   - {{basePackagePath}}  : Package as path (e.g., com/bank/customer)
//   - {{Entity}}           : Entity name PascalCase (e.g., Customer)
// ═══════════════════════════════════════════════════════════════════════════════

package {{basePackage}}.domain.model;

import java.util.Objects;
import java.util.UUID;

/**
 * Value object for {{Entity}} identifier.
 * 
 * Provides type safety - prevents passing wrong ID type.
 * Uses UUID for uniqueness and standardization.
 * 
 * @generated {{skillId}} v{{skillVersion}}
 * @module mod-code-015-hexagonal-base-java-spring
 */
public record {{Entity}}Id(UUID value) {
    
    public {{Entity}}Id {
        Objects.requireNonNull(value, "{{Entity}}Id must not be null");
    }
    
    public static {{Entity}}Id generate() {
        return new {{Entity}}Id(UUID.randomUUID());
    }
    
    public static {{Entity}}Id of(String value) {
        return new {{Entity}}Id(UUID.fromString(value));
    }
    
    public static {{Entity}}Id of(UUID value) {
        return new {{Entity}}Id(value);
    }
    
    @Override
    public String toString() {
        return value.toString();
    }
}
