# Knowledge Base v7.1 - Gap Corrections

**Date:** 2025-12-04  
**Author:** Claude (assisted by JCM)  
**Purpose:** Fix gaps identified during PoC regeneration

---

## Gaps Addressed

| # | Gap | Status | Files Modified |
|---|-----|--------|----------------|
| 1 | Missing Enum.java.tpl template | ✅ Fixed | mod-015/templates/domain/Enum.java.tpl |
| 2 | Timeout: 2 strategies not documented | ✅ Fixed | ERI-010, capability/resilience.md |
| 3 | Timeout: Default strategy not defined | ✅ Fixed | capability/resilience.md |
| 4 | Mapper: Transformations not documented | ✅ Fixed | mod-017/MODULE.md |
| 5 | Template Mapping: Missing Enum | ✅ Fixed | skill-020/SKILL.md |
| 6 | Template Mapping: Missing SystemApiUnavailableException | ✅ Fixed | skill-020/SKILL.md |

---

## Files Created

### 1. Enum.java.tpl
**Path:** `knowledge/skills/modules/mod-015-hexagonal-base-java-spring/templates/domain/Enum.java.tpl`

```java
// Template: Enum.java.tpl
// Output: {{basePackage}}/domain/model/{{EnumName}}.java
// Purpose: Domain enum (pure Java enum, NO framework annotations)
```

---

## Files Modified

### 2. mod-015/MODULE.md
**Change:** Added Enum.java.tpl to template structure listing

### 3. eri-code-010-timeout/ERI.md
**Change:** Added "Alternative Strategy: Client-Level Timeout" section documenting:
- When to use @TimeLimiter vs client-level
- Default recommendation (client_level for new projects)
- Implementation examples for RestClient, RestTemplate, WebClient
- Strategy selection in generation-request.json

### 4. capabilities/resilience.md
**Change:** Updated timeout sub-feature with:
- Strategy options: `client_level` (default), `timelimiter`
- Configuration parameters for each strategy
- Module references for each strategy

### 5. mod-017/MODULE.md
**Change:** Added "Field Transformations (mapping.json)" section documenting:
- Transformation types (uuid_format, case_conversion, enum_to_code, etc.)
- mapping.json structure
- Generated mapper with transformation methods example
- How to provide mapping.json

### 6. skill-020/SKILL.md
**Change:** Updated Template Mapping Reference:
- Added Enum.java.tpl to Domain Layer table
- Added SystemApiUnavailableException.java.tpl to System API table

---

## Impact on PoC Regeneration

After these changes, the PoC regeneration should:

1. **Apply Enum template** → Generate CustomerStatus.java from template
2. **Document timeout strategy** → generation-request.json can specify `strategy: "client_level"`
3. **Apply mapper transformations** → mapping.json drives CustomerSystemApiMapper generation
4. **Complete traceability** → All 24+ files map to specific templates

---

## Validation Required

After regeneration, verify:

1. All generated files have `// Template: X.tpl` header
2. Tier-3 validation passes for ALL modules in `modules.required`:
   - mod-015 (hexagonal)
   - mod-017 (system api)
   - mod-018 (api integration)
   - mod-001 (circuit breaker)
   - mod-002 (retry)

---

## Next Steps

1. Export updated knowledge base to tar
2. Regenerate PoC with updated templates
3. Verify full template traceability
4. Execute all module validations
