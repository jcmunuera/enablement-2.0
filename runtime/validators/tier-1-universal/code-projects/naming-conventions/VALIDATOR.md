---
validator_id: val-tier1-generic-naming-conventions
tier: 1
category: generic
target: naming-conventions
version: 1.0.0
cross_domain_usage:
  - code: "Validates generated code follows naming standards"
  - qa: "Verifies code under analysis follows naming standards"
---

# Validator: Naming Conventions

## Purpose

Validates that a generated project follows established naming conventions for classes, packages, and common architectural components. This validator is **technology-agnostic** for basic checks but includes Java-specific conventions.

## Checks

| Check | Type | Description |
|-------|------|-------------|
| Java class names | Warning | Must be PascalCase |
| Package names | Warning | Must be lowercase |
| Controller naming | Warning | Files in `/controller/` should end with `Controller.java` |
| Service naming | Warning | Files in `/service/` should end with `Service.java` |

## Usage

```bash
./naming-conventions-check.sh <service-directory>
```

**Example:**
```bash
./naming-conventions-check.sh /path/to/generated/microservice
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All checks passed (warnings may exist) |
| 1 | One or more critical checks failed |

## Output Example

```
✅ PASS: Java classes follow PascalCase convention
✅ PASS: Package names are lowercase
✅ PASS: Controllers follow naming convention (*Controller.java)
⚠️  WARN: Some services don't end with 'Service'
```

## Dependencies

- Bash shell
- `find` command
- `grep` command
- `basename` command

## When This Runs

- **Tier:** 1 (Generic)
- **Frequency:** ALWAYS - runs for every code generation skill
- **Order:** After project-structure, before technology-specific validators

## Naming Standards

### Classes

| Pattern | Convention | Example |
|---------|------------|---------|
| Regular class | PascalCase | `CustomerService.java` |
| Interface | PascalCase, often `I` prefix or descriptive | `CustomerRepository.java` |
| Implementation | PascalCase + `Impl` suffix (optional) | `CustomerServiceImpl.java` |

### Packages

| Layer | Convention | Example |
|-------|------------|---------|
| Domain | lowercase, singular | `com.company.service.customer` |
| Infrastructure | lowercase | `com.company.service.infrastructure` |
| Application | lowercase | `com.company.service.application` |

### Architectural Components

| Component | Suffix | Example |
|-----------|--------|---------|
| REST Controller | `Controller` | `CustomerController.java` |
| Service | `Service` | `CustomerService.java` |
| Repository | `Repository` | `CustomerRepository.java` |
| Entity | (none or `Entity`) | `Customer.java` |
| DTO | `DTO` or `Request`/`Response` | `CustomerDTO.java` |

## Related

- **ADR:** adr-009-service-architecture-patterns (defines naming standards)
- **Validators:** Works alongside project-structure validator

## Notes

- All checks are currently warnings to allow flexibility
- Future versions may make some checks required based on ADR compliance
