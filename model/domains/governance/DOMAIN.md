---
id: governance
name: "GOVERNANCE"
version: 1.1
status: Planned
created: 2025-12-12
updated: 2025-12-17
swarm_alignment: "GOVERNANCE Swarm"
---

# Domain: GOVERNANCE

## Purpose

Documentation generation, compliance verification, and policy management. This domain produces documentation, compliance reports, and enforces organizational policies.

---

## Discovery Guidance

> **NEW in v1.1:** Semantic guidance for domain identification.

### When is a request GOVERNANCE domain?

The agent should identify GOVERNANCE domain when:

| Signal | Examples |
|--------|----------|
| **Output is governance artifact** | Policies, compliance reports, documentation (non-design), changelogs |
| **Action is policy/compliance** | Verify compliance, enforce policy, document, generate changelog |
| **Artifacts are governance-related** | License, policy, compliance, audit trail, documentation |
| **SDLC phase is governance** | Release management, compliance, policy enforcement |

### Typical Requests (GOVERNANCE)

✅ These requests belong to GOVERNANCE domain:

```
"Genera la documentación del API"
→ Output: API documentation (Swagger/OpenAPI docs)
→ Skill type: DOCUMENTATION

"Verifica que las licencias de dependencias cumplan las políticas"
→ Output: license compliance report
→ Skill type: COMPLIANCE

"Genera el changelog para la release"
→ Output: changelog document
→ Skill type: DOCUMENTATION

"Aplica las políticas de branch protection"
→ Output: applied policy configuration
→ Skill type: POLICY

"Genera el runbook del servicio"
→ Output: operational runbook document
→ Skill type: DOCUMENTATION

"Verifica el cumplimiento de políticas de seguridad del repositorio"
→ Output: security policy compliance report
→ Skill type: COMPLIANCE
```

### NOT GOVERNANCE Domain (Common Confusions)

❌ These requests are NOT GOVERNANCE domain:

```
"Diseña la arquitectura de seguridad"
→ Action is DESIGN → DESIGN domain

"Analiza la seguridad del código"
→ Action is ANALYZE code quality → QA domain

"Implementa los controles de seguridad"
→ Action is IMPLEMENT code → CODE domain

"Genera el diagrama de arquitectura"
→ Output is DIAGRAM (design artifact) → DESIGN domain
```

### Key Distinction: Governance vs Other Domains

| Request | Domain | Reason |
|---------|--------|--------|
| "Documenta el API" | GOVERNANCE | Output is documentation |
| "Diseña el API" | DESIGN | Output is API design/spec |
| "Genera el código del API" | CODE | Output is API code |
| "Analiza la calidad del API" | QA | Output is quality report |

### Documentation Ambiguity

"Documentation" can belong to different domains:

| Type of Documentation | Domain | Reason |
|----------------------|--------|--------|
| API reference docs (Swagger) | GOVERNANCE | Operational documentation |
| Architecture documentation | DESIGN | Design artifact |
| Code comments/Javadoc | CODE | Part of code |
| Test documentation | QA | Quality artifact |

**When ambiguous, ask the user what type of documentation they need.**

---

## Skill Types

| Type | Purpose | Input | Output |
|------|---------|-------|--------|
| **DOCUMENTATION** | Generate documentation | Code/data | Documentation artifacts |
| **COMPLIANCE** | Verify and apply policies | Code + policies | Compliance report |
| **POLICY** | Manage and enforce policies | Policy definitions | Applied policies |

See `skill-types/` for detailed execution flows.

---

## Module Structure

Modules in the GOVERNANCE domain contain:

| Component | Required | Description |
|-----------|----------|-------------|
| `MODULE.md` | ✅ | Module specification |
| `templates/` | ✅ | Documentation templates |
| `policies/` | ⚠️ Optional | Policy definitions |
| `validation/` | ✅ | Document/compliance validators |

### Policy Structure

```yaml
# policy-definition.yaml
policy:
  id: branch-protection
  version: 1.0
  scope: repository
  rules:
    - name: "Require PR reviews"
      config:
        required_approvals: 2
    - name: "Require status checks"
      config:
        checks: ["build", "test", "lint"]
```

---

## Output Types

| Type | Description | Example |
|------|-------------|---------|
| `documentation` | Generated docs | API docs, changelog, runbook |
| `compliance-report` | Policy compliance status | License compliance report |
| `policy-artifact` | Applied policy | Branch protection rules |

---

## Capabilities

Planned capabilities for GOVERNANCE domain:

| Capability | Description | Status |
|------------|-------------|--------|
| `api_documentation` | OpenAPI, AsyncAPI docs | 🔜 Planned |
| `changelog_generation` | Automated changelogs | 🔜 Planned |
| `license_compliance` | License checking | 🔜 Planned |
| `policy_enforcement` | Repository policies | 🔜 Planned |

---

## Applicable Concerns

| Concern | How it applies to GOVERNANCE |
|---------|------------------------------|
| Security | Security policy enforcement |
| Performance | N/A |
| Observability | Documentation of observability setup |

---

## Naming Conventions

| Asset | Pattern | Example |
|-------|---------|---------|
| ERI | `eri-gov-{NNN}-{doc-type}` | `eri-gov-001-api-documentation` |
| Module | `mod-gov-{NNN}-{doc-type}` | `mod-gov-001-openapi-docs` |
| Skill | `skill-gov-{NNN}-{type}-{target}` | `skill-gov-001-documentation-api` |

---

## Status

This domain is **planned** but not yet implemented.

### Planned Skills

```
GOVERNANCE/DOCUMENTATION:
├── skill-gov-001-documentation-api
├── skill-gov-002-documentation-changelog
├── skill-gov-003-documentation-release-notes
└── skill-gov-004-documentation-runbook

GOVERNANCE/COMPLIANCE:
├── skill-gov-040-compliance-license
├── skill-gov-041-compliance-security-policies
└── skill-gov-042-compliance-data-governance

GOVERNANCE/POLICY:
├── skill-gov-080-policy-branch-protection
├── skill-gov-081-policy-code-owners
└── skill-gov-082-policy-pr-enforcement
```
