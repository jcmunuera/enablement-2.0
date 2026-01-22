# Decision Log - Enablement 2.0

Este documento registra las decisiones de diseño importantes tomadas durante el desarrollo del proyecto. Cada decisión incluye contexto, opciones consideradas, decisión final y justificación.

**Convención de IDs:** DEC-XXX (secuencial)

---

## Índice

- [DEC-001](#dec-001) - Eliminar Skills del modelo
- [DEC-002](#dec-002) - Single discovery path
- [DEC-003](#dec-003) - Phase-based execution
- [DEC-004](#dec-004) - Stack en module frontmatter
- [DEC-005](#dec-005) - Flows genéricos (generate/transform)
- [DEC-006](#dec-006) - Nueva taxonomía de capability types
- [DEC-007](#dec-007) - Feature `standard` como default en api-architecture
- [DEC-008](#dec-008) - `requires` apunta a capability, no a feature
- [DEC-009](#dec-009) - `phase_group` como atributo explícito

---

## 2026-01-20 (Sesión: Migración v2.x → v3.0)

### DEC-001: Eliminar Skills del modelo {#dec-001}

**Fecha:** 2026-01-20  
**Estado:** ✅ Implementado (v3.0.0)

**Contexto:**  
El modelo v2.x tenía Skills como entidades ejecutables separadas de Capabilities. Esto causaba:
- Redundancia (skills duplicaban lógica de capabilities)
- Dual discovery path (skill-index + capability-index)
- Mantenimiento doble

**Opciones:**
- A) Mantener skills y capabilities separados
- B) Fusionar skills en capabilities como features enriquecidas
- C) Eliminar capabilities y mantener solo skills

**Decisión:** Opción B - Eliminar skills, enriquecer features

**Justificación:**
- Una sola fuente de verdad (capability-index.yaml)
- Features pueden tener config, input_spec, implementations
- Menos archivos que mantener
- Discovery más simple

**Implicación:**
- Eliminado directorio `skills/`
- Eliminado `skill-index.yaml`
- Features enriquecidas en capability-index.yaml

---

### DEC-002: Single discovery path {#dec-002}

**Fecha:** 2026-01-20  
**Estado:** ✅ Implementado (v3.0.0)

**Contexto:**  
En v2.x existían dos paths de discovery:
- Path 1: prompt → skill-index → skill → capabilities
- Path 2: prompt → capability-index → capability

**Decisión:** Un solo path a través de capability-index.yaml

**Justificación:**
- Elimina ambigüedad sobre qué path usar
- Una sola fuente de verdad
- Simplifica implementación de Discovery Agent

---

### DEC-003: Phase-based execution {#dec-003}

**Fecha:** 2026-01-20  
**Estado:** ✅ Diseñado, pendiente implementación en agentes

**Contexto:**  
El Generator Agent v2.x cargaba todos los módulos simultáneamente (~197KB de contexto), resultando en menor calidad de generación comparado con chat directo.

**Opciones:**
- A) Optimizar módulos para reducir tamaño
- B) Dividir generación en fases con contexto reducido
- C) Usar modelo con mayor context window

**Decisión:** Opción B - Generación por fases

**Justificación:**
- Cada fase tiene ~50KB de contexto (manejable)
- Permite enfoque en un aspecto a la vez
- Compatible con cualquier modelo
- Más determinista

**Implicación:**
- Definidas 3 fases: STRUCTURAL, IMPLEMENTATION, CROSS-CUTTING
- flow-generate.md documenta el proceso
- Generator Agent debe implementar phase planning

---

### DEC-004: Stack en module frontmatter {#dec-004}

**Fecha:** 2026-01-20  
**Estado:** ✅ Implementado (v3.0.0)

**Contexto:**  
Los módulos no declaraban explícitamente para qué stack eran.

**Decisión:** Añadir `stack: java-spring` (u otro) en el frontmatter de cada MODULE.md

**Justificación:**
- Trazabilidad clara module → stack
- Facilita filtrado en discovery
- Preparación para multi-stack futuro

---

### DEC-005: Flows genéricos (generate/transform) {#dec-005}

**Fecha:** 2026-01-20  
**Estado:** ✅ Implementado (v3.0.0)

**Contexto:**  
v2.x tenía flujos específicos por skill (GENERATE.md, ADD.md para cada skill).

**Decisión:** Dos flujos genéricos:
- `flow-generate.md` - Crear proyecto nuevo
- `flow-transform.md` - Modificar código existente

**Justificación:**
- Los flujos son los mismos independientemente de qué features se usen
- Reduce duplicación
- Más fácil de mantener

---

## 2026-01-21 (Sesión: capability-index v2.2)

### DEC-006: Nueva taxonomía de capability types {#dec-006}

**Fecha:** 2026-01-21  
**Estado:** ✅ Implementado (v3.0.1)

**Contexto:**  
Los tipos `structural` y `compositional` de v2.1 no capturaban bien la semántica de las capabilities:
- ¿`api-architecture` es structural o compositional?
- ¿Qué capabilities pueden aplicarse sin proyecto base?

**Opciones:**
- A) Mantener structural/compositional
- B) Nueva taxonomía: foundational/layered/cross-cutting

**Decisión:** Opción B - Nueva taxonomía

**Definiciones:**
- **foundational:** Base architecture, exactly-one required, no transformable
- **layered:** Adds layers on foundational, multiple allowed, transformable
- **cross-cutting:** Decorators, no requiere foundational, transformable

**Justificación:**
- Semántica clara sobre comportamiento de cada tipo
- `foundational` garantiza que siempre hay base
- `cross-cutting` permite flow-transform sin proyecto nuevo
- Mapeo directo a fases de ejecución

**Implicación:**
- architecture → foundational
- api-architecture, persistence, integration → layered
- resilience, distributed-transactions → cross-cutting

---

### DEC-007: Feature `standard` como default en api-architecture {#dec-007}

**Fecha:** 2026-01-21  
**Estado:** ✅ Implementado (v3.0.1)

**Contexto:**  
Cuando el usuario dice "Genera una API" sin especificar tipo (Domain, System, etc.), ¿qué feature usar?

**Opciones:**
- A) `domain-api` - Es el más común en la organización
- B) `standard` - Nuevo feature, menos opinionado
- C) Preguntar al usuario

**Decisión:** Opción B - Nuevo feature `standard` como default

**Justificación:**
- `domain-api` tiene semántica muy específica:
  - HATEOAS requerido
  - Transaccional
  - Idempotente
  - No puede llamar otras Domain APIs
- "Genera una API" no implica estas restricciones
- `standard` es más genérico: REST básico sin restricciones Fusion
- El usuario puede pedir "Domain API" explícitamente si lo necesita

**Implicación:**
- Nuevo feature `api-architecture.standard` con `is_default: true`
- `domain-api` cambia a `is_default: false`
- `standard` config: `hateoas: false, compensation_available: false`

---

### DEC-008: `requires` apunta a capability, no a feature {#dec-008}

**Fecha:** 2026-01-21  
**Estado:** ✅ Implementado (v3.0.1)

**Contexto:**  
¿Cómo expresar que un feature requiere otro?

**Antes (v2.1):**
```yaml
domain-api:
  requires:
    - architecture.hexagonal-light  # Feature específico
```

**Opciones:**
- A) Mantener referencia a feature específico
- B) Referenciar capability y usar su default_feature

**Decisión:** Opción B - Referenciar capability

**Después (v2.2):**
```yaml
domain-api:
  requires:
    - architecture  # Capability - usa default_feature
```

**Justificación:**
- Más flexible: si añadimos `hexagonal-full`, no hay que cambiar requires
- El resolver usa `default_feature` automáticamente
- Menos acoplamiento entre features
- Si el usuario ya eligió un feature de esa capability, se respeta

---

### DEC-009: `phase_group` como atributo explícito {#dec-009}

**Fecha:** 2026-01-21  
**Estado:** ✅ Implementado (v3.0.1)

**Contexto:**  
¿Cómo determinar en qué fase se ejecuta cada capability?

**Opciones:**
- A) Inferir del `type` (foundational→1, layered→1-2, cross-cutting→3)
- B) Atributo explícito `phase_group` en cada capability

**Decisión:** Opción B - `phase_group` explícito

**Valores:**
- `structural` → Phase 1
- `implementation` → Phase 2
- `cross-cutting` → Phase 3+

**Justificación:**
- `type` describe QUÉ es la capability
- `phase_group` describe CUÁNDO se ejecuta
- Son conceptos diferentes:
  - `api-architecture` es `layered` pero phase_group `structural`
  - `persistence` es `layered` pero phase_group `implementation`
- Asignación automática sin ambigüedad

---

## Plantilla para Nuevas Decisiones

```markdown
### DEC-XXX: [Título descriptivo] {#dec-xxx}

**Fecha:** YYYY-MM-DD  
**Estado:** 🔄 En discusión | ✅ Implementado | ❌ Descartado

**Contexto:**  
[Descripción del problema o situación que requiere decisión]

**Opciones:**
- A) [Opción 1]
- B) [Opción 2]
- C) [Opción 3]

**Decisión:** Opción X - [Descripción corta]

**Justificación:**
- [Razón 1]
- [Razón 2]

**Implicación:**
- [Cambio necesario 1]
- [Cambio necesario 2]
```

---

**Última actualización:** 2026-01-21

---

## 2026-01-21 (Sesión: Actualización Authoring Guides)

### DEC-010: Actualizar Authoring Guides a v3.0.1 {#dec-010}

**Fecha:** 2026-01-21  
**Estado:** ✅ Implementado

**Contexto:**  
Las guías de authoring estaban desactualizadas:
- CAPABILITY.md usaba tipos `structural/compositional` (obsoletos)
- MODULE.md referenciaba Skills (eliminados)
- TAGS.md hablaba de "Skill Tags" (ya no existen)

**Decisión:** Actualizar todos los documentos de authoring para reflejar modelo v3.0.1

**Cambios aplicados:**

| Documento | Versión | Cambios |
|-----------|---------|---------|
| CAPABILITY.md | 3.0 → 3.1 | Nueva taxonomía, phase_group, cardinality, default_feature, is_default |
| MODULE.md | 2.1 → 3.0 | Eliminar refs a Skills, actualizar diagrama, flow-based roles |
| TAGS.md | 1.1 → 2.0 | Deprecation notice, redirect a keywords en capability-index |
| README.md | 3.0 → 3.1 | Actualizar tabla de versiones, nueva taxonomía |

**Implicación:**
- Los autores ahora tienen guías coherentes con capability-index v2.2
- Nuevas capabilities deben seguir taxonomía foundational/layered/cross-cutting

---

## 2026-01-22 (Sesión: Revisión Authoring Guides)

### DEC-011: Completar actualización de Authoring Guides {#dec-011}

**Fecha:** 2026-01-22  
**Estado:** ✅ Implementado

**Contexto:**  
Tras DEC-010 (ayer), quedaban por revisar: FLOW.md, ADR.md, ERI.md, VALIDATOR.md

**Revisión realizada:**

| Documento | Versión | Cambios |
|-----------|---------|---------|
| FLOW.md | 3.0 → 3.1 | Ya actualizado ayer (phase_group, cross-cutting independence) |
| ADR.md | 1.0 | ✅ Sin cambios necesarios (agnóstico de Skills) |
| ERI.md | 1.2 → 1.3 | Eliminar refs a Skills, actualizar automated_by → derived_modules, diagrama relationships |
| VALIDATOR.md | 1.0 → 1.1 | Eliminar refs a Skills, actualizar a modules/flows |

**Implicación:**
- Todos los authoring guides ahora coherentes con modelo v3.0.1
- No quedan referencias a Skills en ningún documento de authoring
