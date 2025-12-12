# Skills Directory

**Version:** 3.0  
**Last Updated:** 2025-11-26

---

## Directory Structure

```
skills/
├── README.md                                    # This file
├── modules/                                     # Reusable templates (Tier 3 validation)
└── skill-{domain}-{NNN}-{type}-{target}-.../    # Individual skills
```

---

## What are Skills?

Skills automate code transformation and generation following ERIs and ADRs.

**Domains:**
- **CODE:** Generate, add, remove, refactor, migrate code
- **DESIGN:** Architecture, transform, documentation design
- **QA:** Analyze, validate, audit quality
- **GOVERNANCE:** Documentation, compliance, policy enforcement

**Types:**
- **TRANSFORMATION:** Modify existing code
- **CREATION:** Generate new code
- **ANALYSIS:** Analyze without modifying

---

## Modules

**Location:** `skills/modules/`

Modules are reusable code templates extracted from ERIs, used by multiple skills.

**Naming:** `mod-XXX-pattern-framework-library/`

**Example:** `mod-001-circuit-breaker-java-resilience4j/`

**Benefits:**
- Single source of truth
- No duplication between skills
- Consistency guaranteed
- Tier 3 validations live with modules

---

## Naming Conventions

### Skills:
```
skill-{domain}-{NNN}-{type}-{target}-{framework}-{library}
```

**Domains:** `code`, `design`, `qa`, `gov`

**Examples:**
- `skill-code-001-add-circuit-breaker-java-resilience4j`
- `skill-code-020-generate-microservice-java-spring`
- `skill-design-001-architecture-microservice`
- `skill-qa-001-analyze-architecture-compliance`
- `skill-gov-001-documentation-api`

### Modules:
```
mod-XXX-pattern-framework-library/
```

**Examples:**
- `mod-001-circuit-breaker-java-resilience4j/`
- `mod-015-hexagonal-base-java-spring/`

---

## Relationship: ADR → ERI → Module → Skill

```
ADR-004: Resilience Patterns
  ↓
ERI-008: circuit-breaker-java-resilience4j
  ↓
mod-001: circuit-breaker-java-resilience4j
  ↓
Skills:
  ├─ skill-code-001 (TRANSFORMATION - add CB)
  └─ skill-code-020 (CREATION - generate microservice with CB)
```

---

## Current Inventory

### Modules:
- `mod-001-circuit-breaker-java-resilience4j/`
- `mod-015-hexagonal-base-java-spring/`

### Skills:
- `skill-code-001-add-circuit-breaker-java-resilience4j/` (TRANSFORMATION)
- `skill-code-020-generate-microservice-java-spring/` (CREATION)

---

## Related Documentation

- **Model:** `../model/ENABLEMENT-MODEL-v1.3.md`
- **Standards:** `../model/standards/ASSET-STANDARDS-v1.3.md`
- **ADRs:** `../ADRs/`
- **ERIs:** `../ERIs/`
- **Modules:** `modules/`

---

**Last Updated:** 2025-11-26
