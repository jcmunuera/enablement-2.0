# Discovery Guidance

**Version:** 3.0  
**Date:** 2025-12-19  
**Replaces:** discovery-guidance.md (v2.0)

---

## Overview

This document provides **guidance** for the discovery process - how the agent interprets user prompts to identify the appropriate domain, layer, and skill. 

> **Important:** Discovery is INTERPRETIVE, not rule-based. The agent uses semantic understanding to match user intent with platform capabilities. There are no IF/THEN rules.

> **New in v3.0:** Layer-based filtering for CODE domain and skill-index.yaml for efficient discovery at scale.

---

## Discovery Philosophy

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    DISCOVERY IS INTERPRETATION                           │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  The agent:                                                              │
│  • Understands the FULL semantic context of the user's request          │
│  • Considers what TYPE OF OUTPUT the user expects                       │
│  • Identifies the LAYER for CODE domain (SoE, SoI, SoR)                 │
│  • Uses the skill-index.yaml to filter candidates efficiently           │
│  • Matches intent against skill OVERVIEW.md descriptions                │
│  • Asks for clarification when uncertain                                │
│  • Recognizes out-of-scope requests                                     │
│                                                                          │
│  The agent does NOT:                                                     │
│  • Match keywords to domains with IF/THEN rules                         │
│  • Use pattern matching or regular expressions                          │
│  • Assume domain based on single words                                  │
│  • Read ALL skill OVERVIEW.md files (uses index to filter first)        │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Discovery Process (Updated)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         DISCOVERY FLOW                                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  1. SCOPE         Is this SDLC-related?                                 │
│        │          └─ No → Inform user, stop                             │
│        ▼                                                                 │
│  2. DOMAIN        What type of output? (CODE/DESIGN/QA/GOVERNANCE)      │
│        │                                                                 │
│        ▼                                                                 │
│  3. LAYER         (CODE only) SoE / SoI / SoR?                          │
│        │          └─ Use signals from skill-index.yaml                  │
│        ▼                                                                 │
│  4. INDEX         Query skill-index.yaml for candidates                 │
│     LOOKUP        └─ domains.{domain}.skills_by_layer.{layer}           │
│        │                                                                 │
│        ▼                                                                 │
│  5. SEMANTIC      Read OVERVIEW.md of filtered candidates only          │
│     MATCH         └─ Select best match                                  │
│        │                                                                 │
│        ▼                                                                 │
│  6. EXECUTE       Load skill, determine flow, execute                   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Scope Validation

Before attempting domain identification, validate that the request is within SDLC scope.

### In Scope (SDLC)

The platform handles requests related to:
- Software development (code, tests, configurations)
- System design (architecture, diagrams, specifications)
- Quality assurance (analysis, metrics, audits)
- Development governance (compliance, policies, documentation)

### Out of Scope

Requests that are NOT SDLC-related:
- Creative writing (poems, stories)
- General knowledge questions unrelated to software
- Personal assistance (scheduling, reminders)
- Other domains (cooking, travel, etc.)

### How to Handle Out of Scope

```
User: "Escríbeme un poema sobre el amor"

Agent: "Esta solicitud está fuera del alcance de la plataforma Enablement 2.0, 
que está especializada en automatización del ciclo de vida de desarrollo de 
software (SDLC). Puedo ayudarte con generación de código, diseño de 
arquitectura, análisis de calidad o documentación de cumplimiento."
```

---

## Domain Interpretation

### The Four Domains

| Domain | Purpose | Typical Outputs |
|--------|---------|-----------------|
| **CODE** | Source code generation and transformation | Java classes, Spring projects, configurations, tests |
| **DESIGN** | Architecture design and documentation | C4 diagrams, sequence diagrams, ADR drafts, specs |
| **QA** | Quality analysis and validation | Analysis reports, quality metrics, issue lists |
| **GOVERNANCE** | Compliance and policy verification | Compliance reports, policy docs, audit evidence |

### Interpretation Signals

The agent considers multiple signals to interpret domain:

| Signal | Questions to Ask |
|--------|-----------------|
| **Output Type** | What will the user receive? Code? Diagram? Report? |
| **Action Intent** | What action is implied? Create? Analyze? Verify? |
| **Artifacts Mentioned** | What artifacts are referenced? Microservice? Architecture? Quality? |
| **SDLC Phase** | What phase of development does this belong to? |

### Examples with Reasoning

**Example 1: Clear CODE**
```
User: "Genera un microservicio Customer con circuit-breaker y retry"

Interpretation:
- Output type: Source code (microservicio = code artifact)
- Action: Generate/create
- Artifacts: Microservice, circuit-breaker, retry (all code concepts)
- SDLC phase: Implementation

→ Domain: CODE
→ Skill type: GENERATE
```

**Example 2: DESIGN despite "genera"**
```
User: "Genera el diagrama de arquitectura técnica del sistema"

Interpretation:
- Output type: Diagram (not code)
- Action: Generate, but of a design artifact
- Artifacts: Architecture diagram
- SDLC phase: Design

→ Domain: DESIGN (not CODE, despite "genera")
→ Skill type: ARCHITECTURE or DOCUMENTATION
```

**Example 3: QA analysis**
```
User: "Analiza la calidad del código a nivel de resiliencia"

Interpretation:
- Output type: Analysis report
- Action: Analyze (not create)
- Artifacts: Code quality, resilience assessment
- SDLC phase: Quality assurance

→ Domain: QA
→ Skill type: ANALYZE
```

**Example 4: Multi-domain**
```
User: "Analiza la calidad y corrige los problemas encontrados"

Interpretation:
- Two actions: Analyze (QA) + Correct (CODE)
- Two outputs: Report + Modified code

→ Multi-domain: QA → CODE
→ Plan: [QA/ANALYZE] then [CODE/ADD or REFACTOR]
```

---

## Layer Identification (CODE Domain)

For CODE domain requests, identify the architectural layer before skill selection.

### The Three Layers

| Layer | Name | Description | Technologies |
|-------|------|-------------|--------------|
| **SoE** | System of Engagement | UI, digital channels, presentation | Angular, React, Vue, Microfrontends |
| **SoI** | System of Integration | Microservices, APIs, orchestration, business logic | Java Spring, Node.js, Quarkus |
| **SoR** | System of Record | Core systems, mainframe, master data | COBOL, CICS, DB2, JCL |

### Layer Signals

The agent uses signals from `skill-index.yaml` to identify the layer:

**SoE Signals:**
- Keywords: frontend, angular, react, componente, página, UI, formulario, SPA
- Artifacts: component, page, module, store, template

**SoI Signals:**
- Keywords: microservicio, API, REST, servicio, spring, nodejs, orquestación, dominio, hexagonal
- Artifacts: service, controller, endpoint, repository, entity, adapter, port

**SoR Signals:**
- Keywords: mainframe, COBOL, CICS, DB2, JCL, batch, programa, copybook, Z/OS
- Artifacts: program, copybook, job, procedure, transaction, cursor

### Layer Examples

**Example 1: Clear SoI**
```
User: "Genera un microservicio Customer con Spring Boot"

Layer signals:
- "microservicio" → SoI keyword
- "Spring Boot" → SoI technology

→ Layer: SoI
→ Filter: skills/code/soi/*
```

**Example 2: Clear SoR**
```
User: "Crea un programa COBOL para consulta de clientes en CICS"

Layer signals:
- "programa COBOL" → SoR keyword
- "CICS" → SoR technology

→ Layer: SoR
→ Filter: skills/code/sor/*
```

**Example 3: Ambiguous Layer**
```
User: "Genera una aplicación para gestión de clientes"

Layer signals:
- "aplicación" → Could be SoE (UI app) or SoI (backend service)
- No technology specified

→ Layer: UNCLEAR
→ Ask: "¿Es una aplicación frontend (web/móvil) o un servicio backend?"
```

---

## Skill Selection

Once domain and layer are identified, select the specific skill using the index.

### Process

1. **Query index**: Read `runtime/discovery/skill-index.yaml`
2. **Filter by layer**: Get skills from `domains.{domain}.skills_by_layer.{layer}`
3. **Optional refinement**: Filter by capability or technology if specified
4. **Read OVERVIEW.md**: Only for filtered candidates
5. **Match intent**: Compare user request with skill purposes
6. **Select best match**: Choose the skill that best fits

### Using skill-index.yaml

```yaml
# Example: User requests a microservice with Spring Boot

# Step 1: Domain = CODE, Layer = SoI
# Step 2: Query index
domains:
  code:
    skills_by_layer:
      soi:
        - skill-001-circuit-breaker-java-resilience4j
        - skill-002-retry-java-resilience4j
        - skill-020-microservice-java-spring
        # ... only 5 candidates instead of 200+

# Step 3: User wants to "generate" → filter to GENERATE flow skills
flows:
  code:
    GENERATE:
      skills:
        - skill-020-microservice-java-spring  # Only 1 candidate!

# Step 4: Read OVERVIEW.md of skill-020
# Step 5: Confirm match
```

### OVERVIEW.md Importance

OVERVIEW.md is the key document for skill discovery. It should contain:

```markdown
## Purpose
Brief description of what this skill does.

## When to Use
✅ Use this skill when:
- Condition 1
- Condition 2

## When NOT to Use
❌ Do not use when:
- Condition 1
- Condition 2

## Tags
`tag1` `tag2` `tag3`
```

The agent reads these sections to determine if the skill matches the user's intent.

### Multiple Matches

If multiple skills could apply, ask the user:

```
Agent: "Puedo ayudarte de varias formas:
1. skill-code-020: Genera un microservicio completo desde cero
2. skill-code-001: Añade circuit-breaker a un servicio existente

¿Cuál necesitas?"
```

### No Match

If no skill matches:

```
Agent: "La plataforma aún no tiene una skill para esta tarea específica. 
Lo más cercano disponible es [skill-X] que hace [description]. 
¿Te serviría?"
```

---

## Handling Ambiguity

### Domain Ambiguity

When domain is unclear:

```
Agent: "Tu solicitud podría interpretarse de varias formas:
- Si quieres GENERAR código → Dominio CODE
- Si quieres DISEÑAR la arquitectura → Dominio DESIGN
- Si quieres ANALIZAR la calidad → Dominio QA

¿Cuál es tu objetivo?"
```

### Missing Information

When the request lacks details:

```
User: "Genera un microservicio"

Agent: "Para generar el microservicio necesito saber:
- ¿Qué nombre tendrá el servicio?
- ¿Qué entidades manejará?
- ¿Qué tipo de persistencia? (JPA, System API)
- ¿Qué patrones de resiliencia? (circuit-breaker, retry, timeout)
- ¿Tienes una especificación OpenAPI?"
```

### Risky Operations

When the operation could be destructive:

```
Agent: "Esta operación modificará tu código existente directamente. 
¿Quieres que proceda o prefieres que primero analice y te muestre 
los cambios propuestos?"
```

---

## Discovery Metadata

### Domain Metadata (DOMAIN.md)

Each domain has a DOMAIN.md in `model/domains/{domain}/` that helps with discovery:

```yaml
# Content for discovery
purpose: "What this domain does"
output_types: ["type1", "type2"]
skill_types: ["TYPE1", "TYPE2"]
typical_requests:
  - "Example request 1"
  - "Example request 2"
not_this_domain:
  - "Example that looks like this domain but isn't"
```

### Skill Metadata (OVERVIEW.md)

Each skill has OVERVIEW.md that helps with selection:

```yaml
# Content for discovery
purpose: "What this skill does"
when_to_use:
  - "Condition 1"
  - "Condition 2"
when_not_to_use:
  - "Condition 1"
tags: ["tag1", "tag2"]
```

---

## Learning from Feedback

Discovery can improve over time:

1. **Track corrections**: When user corrects domain/skill selection, note the pattern
2. **Update OVERVIEW.md**: Add examples to "when to use" based on actual usage
3. **Refine DOMAIN.md**: Add examples to "typical_requests" based on patterns
4. **Document edge cases**: When ambiguous cases are resolved, document them

---

## Summary

| Aspect | Guidance |
|--------|----------|
| **Nature** | Interpretive, not rule-based |
| **Domain identification** | Based on output type and action intent |
| **Layer identification** | SoE/SoI/SoR for CODE domain using signals |
| **Skill filtering** | Use skill-index.yaml to reduce candidates |
| **Skill selection** | Read OVERVIEW.md only for filtered candidates |
| **Ambiguity** | Ask for clarification |
| **Out of scope** | Inform user, don't attempt |
| **Multi-domain** | Decompose into sequence |

---

## Related Documents

| Document | Purpose |
|----------|---------|
| `runtime/discovery/skill-index.yaml` | Pre-computed index for efficient discovery |
| `model/domains/{domain}/DOMAIN.md` | Domain-specific discovery signals |
| `skills/{domain}/{layer}/*/OVERVIEW.md` | Skill descriptions for semantic matching |
| `model/CONSUMER-PROMPT.md` | Full agent context specification |

---

**END OF DOCUMENT**
