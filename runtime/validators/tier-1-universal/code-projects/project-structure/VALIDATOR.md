---
validator_id: val-tier1-generic-project-structure
tier: 1
category: generic
target: project-structure
version: 1.0.0
cross_domain_usage:
  - code: "Validates generated project structure"
  - qa: "Verifies code under analysis has correct structure"
---

# Validator: Project Structure

## Purpose

Validates that a generated project has the basic directory structure required for a well-formed project. This validator is **technology-agnostic** and applies to all Java-based projects.

## Checks

| Check | Type | Description |
|-------|------|-------------|
| `src/main/java` | Required | Main source code directory |
| `src/test/java` | Required | Test source code directory |
| `src/main/resources` | Warning | Resources directory (optional) |
| `src/test/resources` | Warning | Test resources directory (optional) |

## Usage

```bash
./project-structure-check.sh <service-directory>
```

**Example:**
```bash
./project-structure-check.sh /path/to/generated/microservice
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All required directories present |
| 1 | One or more required directories missing |

## Output Example

```
✅ PASS: src/main/java exists
✅ PASS: src/test/java exists
✅ PASS: src/main/resources exists
⚠️  WARN: src/test/resources missing (optional)
```

## Dependencies

- Bash shell
- Standard Unix tools (test, echo)

## When This Runs

- **Tier:** 1 (Generic)
- **Frequency:** ALWAYS - runs for every code generation skill
- **Order:** First, before any technology-specific validators

## Related

- **ADR:** adr-009-service-architecture-patterns (defines project structure standards)
- **Validators:** Typically followed by technology-specific validators (java-spring, nodejs, etc.)

## Notes

This validator currently assumes Java project structure. Future versions may parameterize the expected structure based on technology stack.
