// ═══════════════════════════════════════════════════════════════════════════════
// Template: Enum.java.tpl
// Module: mod-code-015-hexagonal-base-java-spring
// ═══════════════════════════════════════════════════════════════════════════════
// Output: {{basePackage}}/domain/model/{{EnumName}}.java
// Purpose: Domain enum (pure Java enum, NO framework annotations)
// ═══════════════════════════════════════════════════════════════════════════════
// REQUIRED VARIABLES: {{EnumName}} {{^last}} {{basePackage}} {{skillId}} {{skillVersion}} {{value}} 
// ═══════════════════════════════════════════════════════════════════════════════

package {{basePackage}}.domain.model;

/**
 * {{EnumName}} domain enumeration.
 * 
 * This is a pure domain enum with NO external system concerns.
 * Mapping to/from external codes (mainframe, API) is handled
 * in the appropriate Mapper class.
 * 
 * @generated {{skillId}} v{{skillVersion}}
 * @module mod-code-015-hexagonal-base-java-spring
 */
public enum {{EnumName}} {
{{#enumValues}}
    {{value}}{{^last}},{{/last}}{{#last}}{{/last}}
{{/enumValues}}
}
