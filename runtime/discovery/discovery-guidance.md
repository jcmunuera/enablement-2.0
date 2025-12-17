# Discovery Guidance

**Version:** 2.0  
**Date:** 2025-12-17  
**Replaces:** discovery-rules.md (v1.0)

---

## Overview

This document provides **guidance** for the discovery process - how the agent interprets user prompts to identify the appropriate domain and skill. 

> **Important:** Discovery is INTERPRETIVE, not rule-based. The agent uses semantic understanding to match user intent with platform capabilities. There are no IF/THEN rules.

---

## Discovery Philosophy

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    DISCOVERY IS INTERPRETATION                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  The agent:                                                              │
│  • Understands the FULL semantic context of the user's request           │
│  • Considers what TYPE OF OUTPUT the user expects                        │
│  • Matches intent against domain purposes and skill descriptions         │
│  • Asks for clarification when uncertain                                 │
│  • Recognizes out-of-scope requests                                      │
│                                                                          │
│  The agent does NOT:                                                     │
│  • Match keywords to domains with IF/THEN rules                          │
│  • Use pattern matching or regular expressions                           │
│  • Assume domain based on single words                                   │
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

## Skill Selection

Once domain is identified, select the specific skill.

### Process

1. **List candidates**: Find skills in `skills/skill-{domain}-*/`
2. **Read OVERVIEW.md**: Each skill has an OVERVIEW.md with:
   - Purpose
   - When to use
   - When NOT to use
   - Tags
3. **Match intent**: Compare user request with skill purposes
4. **Select best match**: Choose the skill that best fits

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
| **Skill selection** | Read OVERVIEW.md, match purpose |
| **Ambiguity** | Ask for clarification |
| **Out of scope** | Inform user, don't attempt |
| **Multi-domain** | Decompose into sequence |

---

**END OF DOCUMENT**
