---
validator_id: val-tier2-deploy-docker
tier: 2
category: deployments
target: docker
version: 1.0.0
cross_domain_usage:
  - code: "Validates generated Dockerfile follows best practices"
  - qa: "Verifies Dockerfile security and efficiency"
  - gov: "Ensures Dockerfile meets compliance standards"
---

# Validator: Docker

## Purpose

Validates that a generated Dockerfile follows best practices for security, efficiency, and maintainability. This validator is **technology-agnostic** - it validates Dockerfiles for any language/stack.

## Checks

| Script | Type | Description |
|--------|------|-------------|
| `dockerfile-check.sh` | Required | Validates Dockerfile syntax and best practices |

## Usage

```bash
./dockerfile-check.sh <service-directory>
```

**Example:**
```bash
./dockerfile-check.sh /path/to/generated/microservice
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All required checks passed |
| 1 | One or more required checks failed |

## Check Details

### dockerfile-check.sh

Validates multiple aspects of Dockerfile configuration:

| Check | Type | Description |
|-------|------|-------------|
| File exists | Required | `Dockerfile` present in project root |
| FROM instruction | Required | Base image specified |
| CMD/ENTRYPOINT | Required | Container startup command defined |
| Multi-stage build | Warning | Recommended for smaller images |
| WORKDIR | Warning | Recommended for clarity |
| EXPOSE | Warning | Documents exposed ports |
| USER | Warning | Non-root user for security |
| Syntax validation | Pass/Warn | Uses Docker CLI if available |

## Output Example

```
✅ PASS: Dockerfile exists
✅ PASS: FROM instruction present
✅ PASS: Using Java base image
✅ PASS: Multi-stage build detected (2 stages)
✅ PASS: WORKDIR instruction present
✅ PASS: EXPOSE instruction present: 8080
✅ PASS: COPY/ADD instructions present
✅ PASS: CMD or ENTRYPOINT instruction present
⚠️  WARN: No USER instruction (running as root, consider security implications)
✅ PASS: Dockerfile syntax valid (docker build --check)
```

## Best Practices Checked

### Security

| Practice | Validation |
|----------|------------|
| Non-root user | Checks for `USER` instruction |
| Minimal base image | Warns if using large base images |
| No secrets in Dockerfile | (Future enhancement) |

### Efficiency

| Practice | Validation |
|----------|------------|
| Multi-stage builds | Checks for multiple `FROM` instructions |
| Layer optimization | (Future enhancement) |
| .dockerignore | (Future enhancement) |

### Maintainability

| Practice | Validation |
|----------|------------|
| WORKDIR usage | Checks for explicit working directory |
| EXPOSE documentation | Checks ports are documented |
| Clear CMD/ENTRYPOINT | Checks startup command exists |

## Dependencies

- **Docker CLI** (optional) - For syntax validation
- **Bash** - Script execution
- **grep, sed** - Text processing

## When This Runs

- **Tier:** 2 (Artifacts - Deployments)
- **Frequency:** When generating projects that include Dockerfile
- **Order:** After code-projects validators (compile/test)

## Related

- **ADR:** adr-009-service-architecture-patterns (container standards)
- **Tier 2:** code-projects/java-spring (typically run before this)
- **Tier 2:** deployments/kubernetes (typically run after this)

## Future Enhancements

- [ ] HEALTHCHECK instruction validation
- [ ] Base image version pinning check
- [ ] Secret detection (no passwords/keys in Dockerfile)
- [ ] .dockerignore validation
- [ ] Layer optimization recommendations
- [ ] Hadolint integration (if available)
