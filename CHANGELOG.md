# Changelog

## [3.0.10-014] - 2026-01-28

### Added (Validation Assembly Automation)

DEC-034: Created `assemble-validation.sh` script to automate validation script collection.

#### Problem Solved
DEC-033's WARNING was not effective - agents continued improvising validation scripts despite explicit instructions to copy from KB.

#### Solution
- **NEW:** `runtime/validators/assemble-validation.sh` - executable script that agents MUST run
- Script automatically copies scripts from correct KB locations based on modules used
- Eliminates human error and improvisation

#### Additional Cleanup
- **CONSOLIDATED:** Merged `runtime/validation/` into `runtime/validators/`
- **MOVED:** `package-structure-check.sh` to `tier-0-conformance/`
- **DELETED:** `runtime/validation/` (was duplicate/confusing)

#### Files Changed
- `runtime/validators/assemble-validation.sh` (NEW)
- `runtime/validators/tier-0-conformance/package-structure-check.sh` (MOVED)
- `runtime/flows/code/GENERATION-ORCHESTRATOR.md` (v1.3 → v1.4)
- `runtime/validation/` (DELETED)

---

## [3.0.10-013] - 2026-01-28

### Fixed (Validation Script Management)

Addresses issue discovered during new-chat PoC test where validation scripts were improvised instead of copied from KB.

#### DEC-033: Validation Script Management (No Improvisation)
- **Phase 6 WARNING**: Added prominent warning at start of Phase 6 in GENERATION-ORCHESTRATOR.md
- **Explicit instructions**: Scripts MUST be copied from KB, NOT generated
- **Script location reference**: Clear table mapping tiers to source locations
- **Module mapping**: Table showing which scripts to copy per module

#### Files Modified
- `runtime/flows/code/GENERATION-ORCHESTRATOR.md` (v1.2 → v1.3)
  - Added ⚠️ CRITICAL WARNING section at top of Phase 6
  - Updated Key Changes to include DEC-033

#### Root Cause
GENERATION-ORCHESTRATOR.md Phase 6 had instructions to "copy" scripts but:
1. No prominent warning about NOT generating
2. Instructions buried in pseudocode
3. New chat agents missed the implicit requirement

---

## [3.0.10-012] - 2026-01-27

### Added (Human Approval Checkpoint)

New orchestration pattern documented in GENERATION-ORCHESTRATOR.md:

#### DEC-032: Human Approval Checkpoint Pattern
- **Phase 2.7**: Mandatory approval checkpoint between CONTEXT_RESOLUTION and GENERATION
- **Artifact**: `trace/execution-plan.md` generated for human review
- **Protocol**: Explicit "approved" response required to proceed
- **Benefits**: Anti-compaction, early validation, auditability, determinism

#### Files Modified
- `runtime/flows/code/GENERATION-ORCHESTRATOR.md` (v1.1 → v1.2)
  - Updated orchestration flow diagram
  - Added Phase 2.7: HUMAN APPROVAL CHECKPOINT section
  - Documented approval protocol and integration points

---

## [3.0.10-011] - 2026-01-27

### Fixed (Post PoC Validation)

Based on customer-api Golden Master PoC execution, the following fixes were applied:

#### CRITICAL - Compilation Fixes
- **TB-001**: `mod-015/templates/domain/Entity.java.tpl` - Removed `final` from id field to allow assignment in static factory methods
- **TB-002**: `mod-015/templates/application/ApplicationService.java.tpl` - Removed `@Transactional` annotation (not needed without JPA, avoids spring-tx dependency)

#### HIGH - Test Fixes
- **TTB-001**: `mod-019/templates/test/ControllerTest-hateoas.java.tpl` - NEW: Added HATEOAS-specific controller test with proper assembler mock
- **TTB-002**: `mod-017/templates/test/SystemApiAdapterTest.java.tpl` - Added test case for System API error response codes

#### MEDIUM - Validator Fixes  
- **VB-001**: `mod-018/validation/integration-check.sh` - Added `CORRELATION_ID_HEADER` to correlation header detection pattern
- **VB-002**: `mod-002/validation/retry-check.sh` - Changed to search all `application*.yml` files for configuration

#### LOW - Fingerprint Alignment
- **TB-004/TB-005**: `tier-0-conformance/template-conformance-check.sh` - Updated fingerprints to match actual template outputs:
  - CorrelationIdFilter: Simplified pattern, removed `extractOrGenerate`
  - GlobalExceptionHandler: Changed `ProblemDetail` to `createError`
  - SystemApiMapper: Accept both `toRequest` and `toSystemRequest`
  - RestClientConfig: Accept both old and new configuration styles
  - ModelAssembler: Simplified super() pattern check

### Validated Against
- Package: `gen_customer-api_20260127_145144-v2.tar`
- Compilation: ✅ SUCCESS
- Tests: ✅ ALL PASS
- Validation: ✅ 17/17 PASS

---

## [3.0.10-009] - 2026-01-26

### Added
- `runtime/validation/scripts/tier-0/package-structure-check.sh` - Validates package structure before delivery
- Package Delivery Checklist section in GENERATION-ORCHESTRATOR.md

### Changed
- `mod-019/validation/hateoas-check.sh` - Added import path validation for RepresentationModelAssemblerSupport
  - CORRECT: `org.springframework.hateoas.server.mvc.RepresentationModelAssemblerSupport`
  - INCORRECT: `org.springframework.hateoas.server.RepresentationModelAssemblerSupport`

### Fixed
- Tier-0 validation now catches incorrect import paths that would cause compilation errors

### Decision Log
- DEC-029: Package Delivery Validation - Added mandatory checklist and automated validation script

---

## [3.0.10-008] - 2026-01-26

### Fixed
- **mod-017:** Removed hardcoded resilience annotations (@CircuitBreaker, @Retry) and fallback methods from SystemApiAdapter.java.tpl. Resilience is now properly added in Phase 3 by cross-cutting modules.

### Changed
- **mod-018:** RestClientConfig now uses HIGH default timeouts (30s connect, 60s read) as infrastructure protection. Resilience-level timeouts are configured by mod-003 in Phase 3.
- **mod-003:** client-timeout variant changed from GENERATION to TRANSFORMATION. Now modifies RestClientConfig instead of generating a new file.

### Added
- **mod-003:** New `timeout-config-transform.yaml` transformation descriptor
- **GENERATION-ORCHESTRATOR:** Cross-Cutting Transformation section documenting Phase 3 behavior
- **discovery-guidance:** Rule 10 for resilience target resolution (explicit vs implicit mode)

### Decision Log
- DEC-028: Phase 3 Cross-Cutting Model - Resilience patterns are TRANSFORMATIONS, not GENERATIONS

---

## [3.0.10-007] - 2026-01-25

### Added
- Initial Phase 3 cross-cutting model documentation

---

## [3.0.9] - 2026-01-23

### Added
- flow-generate-output.md specification
- Tier validation scripts framework

---

## [3.0.8] - 2026-01-20

### Added
- Initial project structure
- Core capability-index.yaml
- Base module templates
