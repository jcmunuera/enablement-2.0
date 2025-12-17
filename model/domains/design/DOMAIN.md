---
id: design
name: "DESIGN"
version: 1.1
status: Planned
created: 2025-12-12
updated: 2025-12-17
swarm_alignment: "DESIGN Swarm"
---

# Domain: DESIGN

## Purpose

Architecture design, system transformation, and design documentation. This domain produces architectural artifacts including designs, diagrams, transformation plans, and ADR drafts.

---

## Discovery Guidance

> **NEW in v1.1:** Semantic guidance for domain identification.

### When is a request DESIGN domain?

The agent should identify DESIGN domain when:

| Signal | Examples |
|--------|----------|
| **Output is design artifact** | Diagrams, architecture documents, specs, ADRs |
| **Action is architectural** | Design, architect, plan, model, document architecture |
| **Artifacts are design-related** | Architecture, diagram, HLD, LLD, C4, sequence diagram |
| **SDLC phase is design** | Pre-implementation, architectural planning |

### Typical Requests (DESIGN)

✅ These requests belong to DESIGN domain:

```
"Diseña la arquitectura de integración entre sistemas"
→ Output: architecture design document
→ Skill type: ARCHITECTURE

"Genera el diagrama C4 del microservicio Customer"
→ Output: C4 diagram (visual artifact, not code)
→ Skill type: DOCUMENTATION

"Genera el diagrama de secuencia del flujo de pago"
→ Output: sequence diagram
→ Skill type: DOCUMENTATION

"Crea un ADR para la decisión de usar event sourcing"
→ Output: ADR draft document
→ Skill type: DOCUMENTATION

"Planifica la migración de monolito a microservicios"
→ Output: transformation plan
→ Skill type: TRANSFORM
```

### NOT DESIGN Domain (Common Confusions)

❌ These requests are NOT DESIGN domain:

```
"Genera un microservicio Customer"
→ Output is CODE, not design → CODE domain

"Implementa la arquitectura hexagonal en el servicio"
→ Action is IMPLEMENT (code), not design → CODE domain

"Analiza si la arquitectura cumple los estándares"
→ Action is ANALYZE (quality) → QA domain

"Genera documentación del API (Swagger)"
→ Could be CODE (OpenAPI generation) or DESIGN (spec design)
→ Ask for clarification if unclear
```

### Key Distinction: Design vs Implementation

| Request | Domain | Reason |
|---------|--------|--------|
| "Diseña un microservicio" | DESIGN | Output is design/plan |
| "Genera un microservicio" | CODE | Output is actual code |
| "Genera el diagrama del microservicio" | DESIGN | Output is diagram |
| "Genera el código del microservicio" | CODE | Output is code |

**Focus on what the user will RECEIVE, not just the action verb.**

---

## Skill Types

| Type | Purpose | Input | Output |
|------|---------|-------|--------|
| **ARCHITECTURE** | Design new architecture (greenfield) | Requirements, constraints | Architecture design, diagrams |
| **TRANSFORM** | Transform existing architecture (brownfield) | Existing code + target architecture | Transformation plan, work items |
| **DOCUMENTATION** | Generate design documentation | Code/requirements | ADR drafts, diagrams, specs |

See `skill-types/` for detailed execution flows.

---

## Module Structure

Modules in the DESIGN domain contain:

| Component | Required | Description |
|-----------|----------|-------------|
| `MODULE.md` | ✅ | Module specification |
| `templates/` | ✅ | Document templates (.md.tpl, .mermaid.tpl) |
| `patterns/` | ⚠️ Optional | Architectural pattern definitions |
| `validation/` | ✅ | Document structure validators |

### Template Types

| Type | Extension | Purpose |
|------|-----------|---------|
| Markdown | `.md.tpl` | Design documents, ADRs |
| Mermaid | `.mermaid.tpl` | Architecture diagrams |
| PlantUML | `.puml.tpl` | Sequence, class diagrams |
| OpenAPI | `.openapi.tpl` | API specifications |

---

## Output Types

| Type | Description | Example |
|------|-------------|---------|
| `design-document` | Architecture document | HLD, LLD, Technical Design |
| `diagram` | Visual architecture representation | Component, sequence, class |
| `transformation-plan` | Migration roadmap | Monolith to microservices plan |
| `adr-draft` | Architecture Decision Record draft | ADR-XXX draft |

---

## Capabilities

Planned capabilities for DESIGN domain:

| Capability | Description | Status |
|------------|-------------|--------|
| `architecture_patterns` | Microservices, event-driven, etc. | 🔜 Planned |
| `diagramming` | Component, sequence, class diagrams | 🔜 Planned |
| `documentation` | HLD, LLD, Technical Design | 🔜 Planned |

---

## Applicable Concerns

| Concern | How it applies to DESIGN |
|---------|--------------------------|
| Security | Security architecture, threat modeling |
| Performance | Capacity planning, bottleneck identification |
| Observability | Observability design, metrics definition |

---

## Naming Conventions

| Asset | Pattern | Example |
|-------|---------|---------|
| ERI | `eri-design-{NNN}-{pattern}` | `eri-design-001-hexagonal-architecture` |
| Module | `mod-design-{NNN}-{pattern}` | `mod-design-001-hld-template` |
| Skill | `skill-design-{NNN}-{type}-{target}` | `skill-design-001-architecture-microservice` |

---

## Status

This domain is **planned** but not yet implemented. Priority focus is on CODE domain.

### Planned Skills

```
DESIGN/ARCHITECTURE:
├── skill-design-001-architecture-microservice
├── skill-design-002-architecture-api-contract
└── skill-design-003-architecture-data-model

DESIGN/TRANSFORM:
├── skill-design-040-transform-monolith-to-microservices
├── skill-design-041-transform-layered-to-hexagonal
└── skill-design-042-transform-sync-to-event-driven

DESIGN/DOCUMENTATION:
├── skill-design-080-documentation-adr-draft
├── skill-design-081-documentation-architecture-diagram
└── skill-design-082-documentation-sequence-diagram
```
