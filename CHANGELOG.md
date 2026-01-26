# Changelog

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

## [3.0.10-007] - 2026-01-25

### Added
- Initial Phase 3 cross-cutting model documentation

## [3.0.9] - 2026-01-23

### Added
- flow-generate-output.md specification
- Tier validation scripts framework

## [3.0.8] - 2026-01-20

### Added
- Initial mod-001, mod-002, mod-003 resilience modules
- Discovery guidance rules 1-9
