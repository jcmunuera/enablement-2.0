# Validation Script Index

**Version:** 1.1  
**Last Updated:** 2026-01-28

This document lists all validation scripts available in the KB, organized by tier and source location.

---

## ⚠️ MANDATORY: Use assemble-validation.sh (DEC-034)

**DO NOT manually copy or generate validation scripts.**

Execute the assembly script instead:

```bash
./runtime/validators/assemble-validation.sh \
    "${PACKAGE_DIR}/validation" \
    "${SERVICE_NAME}" \
    "${STACK}" \
    ${MODULES_USED[@]}
```

The script automatically copies all required scripts from the correct locations.

---

## Tier 0: Conformance Validations

| Script | Source | Notes |
|--------|--------|-------|
| `conformance-check.sh` | GENERATED | Use `template-conformance-check.sh` + module fingerprints |

**Template Location:** `runtime/validators/tier-0-conformance/template-conformance-check.sh`

Tier 0 is the only tier where a script is GENERATED (not copied). It must be created dynamically based on the modules used in the generation, using fingerprints from each module.

---

## Tier 1: Universal Validations

| Script | Source Location |
|--------|-----------------|
| `naming-conventions-check.sh` | `runtime/validators/tier-1-universal/code-projects/naming-conventions/` |
| `project-structure-check.sh` | `runtime/validators/tier-1-universal/code-projects/project-structure/` |
| `traceability-check.sh` | `runtime/validators/tier-1-universal/traceability/` |

These scripts apply to ALL generated projects regardless of stack or modules.

---

## Tier 2: Technology Validations

### Java-Spring Stack

| Script | Source Location |
|--------|-----------------|
| `compile-check.sh` | `runtime/validators/tier-2-technology/code-projects/java-spring/` |
| `syntax-check.sh` | `runtime/validators/tier-2-technology/code-projects/java-spring/` |
| `application-yml-check.sh` | `runtime/validators/tier-2-technology/code-projects/java-spring/` |
| `actuator-check.sh` | `runtime/validators/tier-2-technology/code-projects/java-spring/` (optional) |
| `test-check.sh` | `runtime/validators/tier-2-technology/code-projects/java-spring/` (optional) |

---

## Tier 3: Module-Specific Validations

### Architecture Modules

| Module | Script | Source Location |
|--------|--------|-----------------|
| mod-code-015 (hexagonal-base) | `hexagonal-structure-check.sh` | `modules/mod-code-015-hexagonal-base-java-spring/validation/` |

### Persistence Modules

| Module | Script | Source Location |
|--------|--------|-----------------|
| mod-code-016 (jpa) | `jpa-check.sh` | `modules/mod-code-016-persistence-jpa-java-spring/validation/` |
| mod-code-017 (systemapi) | `systemapi-check.sh` | `modules/mod-code-017-persistence-systemapi/validation/` |

### Integration Modules

| Module | Script | Source Location |
|--------|--------|-----------------|
| mod-code-018 (api-integration-rest) | `integration-check.sh` | `modules/mod-code-018-api-integration-rest-java-spring/validation/` |

### API Exposure Modules

| Module | Script | Source Location |
|--------|--------|-----------------|
| mod-code-019 (api-public-exposure) | `hateoas-check.sh` | `modules/mod-code-019-api-public-exposure-java-spring/validation/` |
| mod-code-019 (api-public-exposure) | `config-check.sh` | `modules/mod-code-019-api-public-exposure-java-spring/validation/` |

### Resilience Modules

| Module | Script | Source Location |
|--------|--------|-----------------|
| mod-code-001 (circuit-breaker) | `circuit-breaker-check.sh` | `modules/mod-code-001-circuit-breaker-java-spring/validation/` |
| mod-code-002 (retry) | `retry-check.sh` | `modules/mod-code-002-retry-java-spring/validation/` |
| mod-code-003 (timeout) | `timeout-check.sh` | `modules/mod-code-003-timeout-java-spring/validation/` |

---

## run-all.sh Template

| File | Source Location | Notes |
|------|-----------------|-------|
| `run-all.sh` | `runtime/validators/run-all.sh.tpl` | Replace `{{SERVICE_NAME}}` and `{{STACK}}` |

The `run-all.sh.tpl` template is POSIX-compatible and works on macOS (bash 3.2+) and Linux.

---

## Collection Process Summary

```
1. Create validation/ directory structure:
   validation/
   ├── scripts/
   │   ├── tier0/
   │   ├── tier1/
   │   ├── tier2/
   │   └── tier3/
   └── reports/

2. GENERATE tier0/conformance-check.sh using template + fingerprints

3. COPY tier1 scripts from runtime/validators/tier-1-universal/

4. COPY tier2 scripts from runtime/validators/tier-2-technology/{stack}/

5. For EACH module used:
   - COPY all *.sh from modules/{module-id}/validation/ to tier3/

6. COPY run-all.sh.tpl → run-all.sh and substitute variables

7. chmod +x all scripts
```

---

*Index generated: 2026-01-28*
