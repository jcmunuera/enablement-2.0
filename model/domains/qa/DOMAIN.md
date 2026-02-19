---
id: qa
name: "QA"
version: 1.1
status: Planned
created: 2025-12-12
updated: 2025-12-17
swarm_alignment: "QA Swarm"
---

# Domain: QA

## Purpose

Code analysis, validation, and audit. This domain produces analysis reports, validation results, and audit documentation to ensure code quality and compliance.

---

## Discovery Guidance

> **NEW in v1.1:** Semantic guidance for domain identification.

### When is a request QA domain?

The agent should identify QA domain when:

| Signal | Examples |
|--------|----------|
| **Output is report/assessment** | Analysis reports, metrics, findings, audit results |
| **Action is evaluation** | Analyze, check, validate, audit, measure, assess |
| **Artifacts are quality-related** | Quality, coverage, compliance, vulnerabilities, debt |
| **SDLC phase is verification** | Testing, quality assurance, review |

### Typical Requests (QA)

✅ These requests belong to QA domain:

```
"Analiza la calidad del código a nivel de resiliencia"
→ Output: analysis report with findings
→ Skill type: ANALYZE

"Verifica si el servicio cumple con los estándares de arquitectura"
→ Output: compliance validation report
→ Skill type: VALIDATE

"Genera un reporte de cobertura de tests"
→ Output: coverage report
→ Skill type: ANALYZE

"Audita las dependencias del proyecto"
→ Output: dependency audit report
→ Skill type: AUDIT

"Revisa la calidad del código y encuentra problemas"
→ Output: quality issues report
→ Skill type: ANALYZE

"Identifica vulnerabilidades de seguridad"
→ Output: security findings report
→ Skill type: ANALYZE
```

### NOT QA Domain (Common Confusions)

❌ These requests are NOT QA domain:

```
"Corrige los problemas de calidad encontrados"
→ Action is FIX (modify code) → CODE domain

"Diseña una estrategia de testing"
→ Output is STRATEGY (design) → DESIGN domain

"Genera tests unitarios para el servicio"
→ Output is CODE (tests) → CODE domain

"Implementa las mejoras de seguridad"
→ Action is IMPLEMENT → CODE domain
```

### Key Distinction: Analysis vs Action

| Request | Domain | Reason |
|---------|--------|--------|
| "Analiza los problemas" | QA | Output is report |
| "Corrige los problemas" | CODE | Output is modified code |
| "Analiza y propón mejoras" | QA + DESIGN | Multi-domain |
| "Analiza y corrige" | QA + CODE | Multi-domain |

### Multi-Domain Patterns

QA often appears in multi-domain requests:

```
"Analiza la calidad y propón mejoras"
→ QA (analyze) + DESIGN (propose)
→ Execute: QA/ANALYZE → DESIGN/DOCUMENTATION

"Analiza la calidad y corrige los problemas"
→ QA (analyze) + CODE (fix)
→ Execute: QA/ANALYZE → CODE/REFACTOR or ADD
→ ⚠️ Ask for confirmation before modifying code
```

**Focus on what the user will RECEIVE as OUTPUT.**

---

## Skill Types

| Type | Purpose | Input | Output |
|------|---------|-------|--------|
| **ANALYZE** | Analyze code to detect issues | Existing code | Analysis report |
| **VALIDATE** | Verify compliance with standards | Existing code + standards | Validation report |
| **AUDIT** | Generate audit reports | Existing code | Audit report |

See `skill-types/` for detailed execution flows.

---

## Module Structure

Modules in the QA domain contain:

| Component | Required | Description |
|-----------|----------|-------------|
| `MODULE.md` | ✅ | Module specification |
| `templates/` | ✅ | Report templates |
| `rules/` | ✅ | Analysis rules and checks |
| `validation/` | ✅ | Report format validators |

### Rule Structure

```
rules/
├── rule-001-check-name.sh      # Individual check
├── rule-002-check-name.sh
└── ruleset.yaml                # Rule configuration
```

### Ruleset Format

```yaml
ruleset:
  id: architecture-compliance
  version: 1.0
  rules:
    - id: rule-001
      name: "Hexagonal Layer Separation"
      severity: ERROR
      check: "rule-001-hexagonal-layers.sh"
    - id: rule-002
      name: "No Domain to Infrastructure"
      severity: ERROR
      check: "rule-002-dependency-direction.sh"
```

---

## Output Types

| Type | Description | Example |
|------|-------------|---------|
| `analysis-report` | Detailed analysis findings | Architecture compliance report |
| `validation-report` | Pass/fail validation | ADR compliance check |
| `audit-report` | Comprehensive audit | Security audit, dependency audit |

---

## Capabilities

Planned capabilities for QA domain:

| Capability | Description | Status |
|------------|-------------|--------|
| `architecture_analysis` | Architecture compliance checks | 🔜 Planned |
| `code_quality` | Code quality metrics | 🔜 Planned |
| `security_analysis` | Security vulnerability detection | 🔜 Planned |
| `dependency_audit` | Dependency analysis | 🔜 Planned |

---

## Applicable Concerns

| Concern | How it applies to QA |
|---------|----------------------|
| Security | Security-focused analysis rules |
| Performance | Performance analysis rules |
| Observability | Observability completeness checks |

---

## Naming Conventions

| Asset | Pattern | Example |
|-------|---------|---------|
| ERI | `eri-qa-{NNN}-{analysis-type}` | `eri-qa-001-architecture-compliance` |
| Module | `mod-qa-{NNN}-{analysis-type}` | `mod-qa-001-adr-compliance-rules` |
| Skill | `skill-qa-{NNN}-{type}-{target}` | `skill-qa-001-analyze-architecture-compliance` |

---

## Status

This domain is **planned** but not yet implemented.

### Planned Skills

```
QA/ANALYZE:
├── skill-qa-001-analyze-architecture-compliance
├── skill-qa-002-analyze-security-vulnerabilities
├── skill-qa-003-analyze-performance-bottlenecks
└── skill-qa-004-analyze-code-quality

QA/VALIDATE:
├── skill-qa-040-validate-adr-compliance
├── skill-qa-041-validate-coding-standards
├── skill-qa-042-validate-api-contract
└── skill-qa-043-validate-test-coverage

QA/AUDIT:
├── skill-qa-080-audit-dependencies
├── skill-qa-081-audit-technical-debt
├── skill-qa-082-audit-security-posture
└── skill-qa-083-audit-license-compliance
```
