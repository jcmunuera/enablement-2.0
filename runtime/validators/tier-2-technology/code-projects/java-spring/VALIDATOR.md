---
validator_id: val-tier2-code-java-spring
tier: 2
category: code-projects
target: java-spring
version: 1.0.0
stack_components:
  - java-17+
  - maven
  - spring-boot-3.x
cross_domain_usage:
  - code: "Validates generated Java-Spring projects compile and pass tests"
  - qa: "Verifies code under analysis compiles before running quality checks"
---

# Validator: Java-Spring

## Purpose

Validates that a generated Java-Spring project is correctly configured, compiles successfully, passes tests, and follows Spring Boot best practices.

## Checks

| Script | Type | Description |
|--------|------|-------------|
| `compile-check.sh` | Required | Verifies Maven compilation succeeds |
| `test-check.sh` | Required | Verifies all tests pass |
| `actuator-check.sh` | Required | Verifies Spring Actuator is configured |
| `application-yml-check.sh` | Required | Verifies application.yml has required configuration |

## Usage

Run individual checks:
```bash
./compile-check.sh <service-directory>
./test-check.sh <service-directory>
./actuator-check.sh <service-directory>
./application-yml-check.sh <service-directory>
```

Or orchestrate all (typically done by skill's validate.sh):
```bash
for check in compile-check.sh test-check.sh actuator-check.sh application-yml-check.sh; do
    ./$check "$SERVICE_DIR" || exit 1
done
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Check passed |
| 1 | Check failed |

## Check Details

### compile-check.sh

Runs `mvn clean compile` to verify the project compiles:

```
✅ PASS: Maven compilation successful
```

**Skip conditions:**
- No `pom.xml` found (not a Maven project)
- Maven not installed in environment

### test-check.sh

Runs `mvn test` to verify all tests pass:

```
✅ PASS: All tests passed (15 tests)
```

**Skip conditions:**
- No `pom.xml` found
- Maven not installed
- No test classes found

### actuator-check.sh

Verifies Spring Actuator is properly configured:

| Check | Description |
|-------|-------------|
| Dependency | `spring-boot-starter-actuator` in pom.xml |
| Health endpoint | `/actuator/health` configured |
| Management port | Management port configured (if required) |

```
✅ PASS: Actuator dependency found
✅ PASS: Health endpoint configured
⚠️  WARN: Management port not explicitly configured
```

### application-yml-check.sh

Verifies application.yml has required configuration:

| Check | Description |
|-------|-------------|
| File exists | `src/main/resources/application.yml` present |
| Server port | `server.port` configured |
| Application name | `spring.application.name` configured |
| Logging | Basic logging configuration |

```
✅ PASS: application.yml exists
✅ PASS: Server port configured (8080)
✅ PASS: Application name configured
⚠️  WARN: Logging level not explicitly configured
```

## Dependencies

- **Maven** 3.8+ (or skip if not available)
- **Java** 17+ (matching project requirements)
- **yq** (optional, for YAML parsing - falls back to grep)

## When This Runs

- **Tier:** 2 (Artifacts - Code Projects)
- **Frequency:** When generating/validating Java-Spring projects
- **Order:** After Tier 1 generic validators

## Execution Order

Recommended order for these checks:

1. `compile-check.sh` - Must compile first
2. `test-check.sh` - Tests require compilation
3. `application-yml-check.sh` - Configuration validation
4. `actuator-check.sh` - Spring-specific checks

## Related

- **ADR:** adr-009-service-architecture-patterns
- **ERI:** eri-code-001-hexagonal-light-java-spring
- **Tier 1:** project-structure, naming-conventions (run before this)
- **Tier 2:** deployments/docker (typically run after this)

## Future Enhancements

- [ ] Gradle support (`build.gradle` detection)
- [ ] Spring Security configuration validation
- [ ] OpenAPI/Swagger configuration validation
- [ ] Profile-specific configuration validation
