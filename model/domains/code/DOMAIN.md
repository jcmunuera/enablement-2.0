---
id: code
name: "CODE"
version: 1.2
status: Active
created: 2025-01-15
updated: 2025-12-24
swarm_alignment: "CODE Swarm"
---

# Domain: CODE

## Purpose

Code generation, modification, and migration. This domain produces executable code artifacts following organizational standards defined in ADRs and implemented according to ERIs.

---

## Tag Taxonomy

> **NEW in v1.2:** Tag-based discovery for CODE skills.

CODE domain skills use tags for discovery. See **[TAG-TAXONOMY.md](./TAG-TAXONOMY.md)** for:

- Tag dimensions: `artifact-type`, `stack`, `runtime-model`, `protocol`, `api-model`
- Extraction rules from user prompts
- Default values and weights
- Coherence rules for skill extension

---

## Discovery Guidance

> **NEW in v1.1:** Semantic guidance for domain identification.

### When is a request CODE domain?

The agent should identify CODE domain when:

| Signal | Examples |
|--------|----------|
| **Output is source code** | Java classes, Spring projects, configurations, tests |
| **Action is implementation** | Generate, create, add, modify, refactor, migrate CODE |
| **Artifacts are code-related** | Microservice, API, class, method, endpoint, configuration |
| **SDLC phase is implementation** | Building, coding, programming |

### Typical Requests (CODE)

✅ These requests belong to CODE domain:

```
"Genera un microservicio Customer con circuit-breaker y retry"
→ Output: source code project
→ Skill type: GENERATE

"Añade circuit-breaker al servicio de pagos"
→ Output: modified source code
→ Skill type: ADD

"Refactoriza el servicio para usar arquitectura hexagonal"
→ Output: restructured source code
→ Skill type: REFACTOR

"Migra el proyecto de Spring Boot 2 a Spring Boot 3"
→ Output: migrated source code
→ Skill type: MIGRATE
```

### NOT CODE Domain (Common Confusions)

❌ These requests are NOT CODE domain:

```
"Genera el diagrama de arquitectura del microservicio"
→ Output is DIAGRAM, not code → DESIGN domain

"Analiza la calidad del código"
→ Output is REPORT, not code → QA domain

"Diseña la arquitectura de integración"
→ Output is DESIGN DOCUMENT, not code → DESIGN domain

"Genera un reporte de cobertura"
→ Output is REPORT, not code → QA domain
```

### Key Distinction

The word "genera" (generate) does NOT automatically mean CODE:
- "Genera código" → CODE ✓
- "Genera diagrama" → DESIGN (output is diagram)
- "Genera reporte" → QA (output is report)

**Focus on the OUTPUT TYPE, not the action verb.**

---

## Skill Types

| Type | Purpose | Input | Output |
|------|---------|-------|--------|
| **GENERATE** | Create new code from scratch | Requirements JSON/YAML | New project structure |
| **ADD** | Add specific feature to existing code | Existing code + feature spec | Modified code |
| **REMOVE** | Remove feature or code | Existing code + target | Modified code |
| **REFACTOR** | Improve code without changing behavior | Existing code + goal | Improved code |
| **MIGRATE** | Transform version or framework | Existing code + target version | Migrated code |

See `skill-types/` for detailed execution flows for each type.

---

## Module Structure

Modules in the CODE domain MUST have:

| Component | Required | Description |
|-----------|----------|-------------|
| `MODULE.md` | ✅ | Module specification |
| `templates/` | ✅ | Code templates (.java.tpl, .yml.tpl, etc.) |
| `Template Catalog` | ✅ | Section in MODULE.md mapping templates to output paths |
| `variables.md` | ✅ | Variable definitions and defaults |
| `validation/` | ✅ | Tier 3 validators for this module |

### Template Catalog Format

```markdown
## Template Catalog

| Template | Output Path | Condition |
|----------|-------------|-----------|
| `Config.java.tpl` | `src/main/java/{{package}}/config/{{Name}}Config.java` | Always |
| `application.yml.tpl` | `src/main/resources/application.yml` | Merge |
| `pom.xml.tpl` | `pom.xml` | Merge |
```

See `module-structure.md` for complete specification.

---

## Output Types

| Type | Description | Example |
|------|-------------|---------|
| `code-project` | Complete new project | Microservice scaffold |
| `code-modification` | Changes to existing files | Added circuit breaker |
| `code-migration` | Migrated codebase | Spring Boot 2 → 3 |

---

## Capabilities

Current capabilities for CODE domain:

| Capability | Description | Modules |
|------------|-------------|---------|
| [resilience](capabilities/resilience.md) | Fault tolerance patterns | mod-code-001 to mod-code-004 |
| [persistence](capabilities/persistence.md) | Data access patterns | mod-code-016, mod-code-017 |
| [api_architecture](capabilities/api_architecture.md) | API layers and structure | mod-code-015 |
| [integration](capabilities/integration.md) | External API integration | mod-code-018 |

---

## Applicable Concerns

| Concern | How it applies to CODE |
|---------|------------------------|
| Security | Authentication, authorization, input validation, secrets management |
| Performance | Caching, async patterns, connection pooling, query optimization |
| Observability | Logging (SLF4J), metrics (Micrometer), tracing (OpenTelemetry) |

---

## Validators

| Tier | Location | When Applied |
|------|----------|--------------|
| Tier 1 | `validators/tier-1-universal/` | Always |
| Tier 2 | `validators/tier-2-technology/code-projects/` | For code outputs |
| Tier 3 | Module's `validation/` folder | When module is used |
| Tier 4 | CI/CD pipeline | At runtime |

---

## Naming Conventions

| Asset | Pattern | Example |
|-------|---------|---------|
| ERI | `eri-code-{NNN}-{pattern}-{framework}-{library}` | `eri-code-008-circuit-breaker-java-resilience4j` |
| Module | `mod-code-{NNN}-{pattern}-{framework}-{library}` | `mod-code-001-circuit-breaker-java-resilience4j` |
| Skill | `skill-code-{NNN}-{type}-{target}-{framework}-{library}` | `skill-code-020-generate-microservice-java-spring` |

---

## Related ADRs

| ADR | Topic | Relationship |
|-----|-------|--------------|
| ADR-001 | API Design Standards | Defines API structure |
| ADR-004 | Resilience Patterns | Defines fault tolerance |
| ADR-009 | Service Architecture | Defines Hexagonal Light |
| ADR-011 | Persistence Patterns | Defines data access |
| ADR-012 | API Integration | Defines external calls |

---

## Current Inventory

### ERIs
- `eri-code-001-hexagonal-light-java-spring`
- `eri-code-008-circuit-breaker-java-resilience4j`
- `eri-code-009-retry-java-resilience4j`
- `eri-code-010-timeout-java-resilience4j`
- `eri-code-011-rate-limiter-java-resilience4j`
- `eri-code-012-persistence-patterns-java-spring`
- `eri-code-013-api-integration-rest-java-spring`

### Modules
- `mod-code-001-circuit-breaker-java-resilience4j`
- `mod-code-002-retry-java-resilience4j`
- `mod-code-003-timeout-java-resilience4j`
- `mod-code-004-rate-limiter-java-resilience4j`
- `mod-code-015-hexagonal-base-java-spring`
- `mod-code-016-persistence-jpa-spring`
- `mod-code-017-persistence-systemapi`
- `mod-code-018-api-integration-rest-java-spring`

### Skills
- `skill-code-001-add-circuit-breaker-java-resilience4j`
- `skill-code-020-generate-microservice-java-spring`
