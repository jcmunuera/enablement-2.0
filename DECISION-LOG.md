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
- [DEC-010](#dec-010) - Actualizar Authoring Guides a v3.0.1
- [DEC-011](#dec-011) - Completar actualización de Authoring Guides
- [DEC-012](#dec-012) - Refinamientos capability-index v2.3
- [DEC-013](#dec-013) - Idempotencia como capability, implies y config_rules
- [DEC-014](#dec-014) - Renombrar compensation_available → supports_distributed_transactions
- [DEC-015](#dec-015) - Roles de transacción distribuida y custom-api
- [DEC-016](#dec-016) - Resolución de ambigüedad persistence → jpa
- [DEC-017](#dec-017) - Semántica "transaccional" → domain-api

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

### DEC-012: Refinamientos capability-index v2.3 {#dec-012}

**Fecha:** 2026-01-22  
**Estado:** ✅ Implementado

**Contexto:**  
Durante la validación de test cases se identificaron dos problemas:
1. `compensation_available=true` en domain-api no indica CUÁNDO generar compensación
2. `persistence.jpa` y `persistence.systemapi` marcados como incompatibles, pero escenarios híbridos son válidos

**Decisiones:**

**A) Semántica de `compensation_available`:**
- Es un flag de **capacidad**, no de acción
- `true` = Esta API admite implementar compensación si se solicita
- Para GENERAR compensación → usuario debe pedir `saga-compensation`
- Nueva validación: `saga-compensation.requires_config` verifica que API tenga `compensation_available=true`

**B) Persistencia híbrida:**
- Eliminar `incompatible_with` entre `jpa` y `systemapi`
- Escenarios válidos: Customer (JPA local) + Account (System API mainframe)

**C) Nueva Rule 7: Config Prerequisite Validation:**
```yaml
requires_config:
  - capability: api-architecture
    config_key: compensation_available
    value: true
    error_message: "Compensation requires API that supports it"
```

**Cambios aplicados:**

| Archivo | Cambio |
|---------|--------|
| capability-index.yaml | v2.2 → v2.3, eliminar incompatible_with, añadir requires_config |
| discovery-guidance.md | Añadir Rule 7, actualizar test cases 6-8 |
| CAPABILITY.md (authoring) | v3.1 → v3.2, documentar requires_config |

**Implicación:**
- Test Case 6 ("JPA y System API") ahora es válido (híbrido)
- Test Case 7 ("Domain API con compensación") válido
- Test Case 8 ("API REST con compensación") error (compensation_available=false)

### DEC-013: Idempotencia como capability, implies y config_rules {#dec-013}

**Fecha:** 2026-01-22  
**Estado:** ✅ Implementado (modelo) / 🟡 Pendiente (ADR/ERI/Module)

**Contexto:**  
Análisis de config flags `transactional` e `idempotent` en domain-api reveló:
1. Los flags eran fijos pero no está claro si se generaba código para ellos
2. Vincular flags a features específicas (saga-compensation) no escala si añadimos más patterns (2PC)
3. ¿Idempotencia es dependiente de transaccionalidad o puede existir independiente?

**Decisiones AUTHOR:**

**A) Idempotencia como capability independiente:**
- Tiene sentido API idempotente sin transaccionalidad (pagos, reservas)
- Transaccionalidad SÍ implica idempotencia (no se puede hacer retry sin idempotencia)
- Nueva capability `idempotency` con feature `idempotency-key`
- **Status: planned** - Pendiente ADR-014, ERI-016, mod-021

**B) Nuevo atributo `implies` (nivel capability):**
- Dependencias automáticas entre capabilities
- `distributed-transactions` → implies → `idempotency`
- Diferente de `requires`: implies auto-añade, requires valida

**C) Nueva sección `config_rules` (nivel top):**
- Flags calculados por **capability**, no por feature
- Future-proof: si añadimos `two-phase-commit`, automáticamente activa `transactional=true`
- Reglas definidas:
  - `transactional`: activated_by distributed-transactions
  - `idempotent`: activated_by idempotency OR distributed-transactions

**D) Nuevas reglas de discovery:**
- Rule 8: Resolve Implications
- Rule 9: Calculate Config Flags

**Cambios aplicados:**

| Archivo | Cambio |
|---------|--------|
| capability-index.yaml | v2.3 → v2.4, nueva capability idempotency (planned), implies, config_rules |
| discovery-guidance.md | v3.1 → v3.2, Rule 8, Rule 9, algoritmo actualizado |
| CAPABILITY.md (authoring) | v3.2 → v3.3, documentar implies y config_rules |
| CAPABILITY-BACKLOG.md | Nuevo documento de tracking de pendientes |

**Pendiente para completar:**
- [ ] ADR-014-idempotency
- [ ] ERI-016-idempotency-java-spring  
- [ ] mod-code-021-idempotency-key-java-spring

**Implicación:**
- Caso 3 ("Domain API"): config_flags = {transactional: false, idempotent: false}
- Caso 7 ("Domain API con compensación"): implies añade idempotency pero sin módulo aún
- Caso 9 ("Domain API idempotente"): capability matched pero WARNING: no implementation
- Model version: 3.0.3

### DEC-014: Renombrar compensation_available → supports_distributed_transactions {#dec-014}

**Fecha:** 2026-01-22  
**Estado:** ✅ Implementado

**Contexto:**  
Test Case 17 ("Domain API transaccional") reveló confusión semántica:
- domain-api.config tenía `transactional: true` como valor **estático**
- Pero `transactional` también es un flag **calculado** por config_rules
- `compensation_available` es muy específico (solo SAGA), pero Domain API soporta CUALQUIER patrón de transacción distribuida

**Análisis:**

```
Domain API
  └── compensation_available: true  ← Muy específico (solo SAGA)
  
Lo correcto:
  └── supports_distributed_transactions: true  ← Capacidad general
      └── Puede implementarse con:
          ├── SAGA + Compensación
          ├── Two-Phase Commit (2PC)
          ├── TCC (Try-Confirm-Cancel)
          └── Otros patrones futuros
```

**Decisiones:**

1. **Renombrar flag de capacidad:**
   - `compensation_available` → `supports_distributed_transactions`
   - Semántica: "Esta API PUEDE participar en transacciones distribuidas"

2. **Eliminar flags estáticos de domain-api.config:**
   - QUITAR: `transactional: true`
   - QUITAR: `idempotent: true`
   - Estos son CALCULADOS por config_rules cuando se seleccionan features

3. **Actualizar requires_config de saga-compensation:**
   - `config_key: supports_distributed_transactions`
   - `error_message: "SAGA compensation requires an API type that supports distributed transactions"`

**Cambios aplicados:**

| Archivo | Cambio |
|---------|--------|
| capability-index.yaml | v2.4 → v2.5, rename flag, eliminar transactional/idempotent de domain-api |
| discovery-guidance.md | v3.2 → v3.3, actualizar referencias |
| CAPABILITY.md | v3.3 → v3.4, documentar cambio |
| FLOW.md | Actualizar referencia |

**Tabla de API Types (actualizada):**

| API Type | supports_distributed_transactions | Puede usar SAGA | Puede usar 2PC |
|----------|:---------------------------------:|:---------------:|:--------------:|
| standard | false | ❌ | ❌ |
| domain-api | true | ✅ | ✅ (futuro) |
| system-api | false | ❌ | ❌ |
| experience-api | false | ❌ | ❌ |
| composable-api | false | ❌ | ❌ |

**Clarificación semántica:**

| Tipo | Ejemplo | Naturaleza |
|------|---------|------------|
| CAPACIDAD (estática) | `supports_distributed_transactions` | Define QUÉ puede hacer el API type |
| ACCIÓN (calculada) | `transactional`, `idempotent` | Define QUÉ se está generando |

**Model version:** 3.0.4

### DEC-015: Roles de transacción distribuida y custom-api {#dec-015}

**Fecha:** 2026-01-22  
**Estado:** ✅ Implementado

**Contexto:**  
TC22 ("API REST con SAGA") reveló que un flag único `supports_distributed_transactions` mezclaba dos conceptos:
- PARTICIPAR en una transacción (implementar Compensation)
- GESTIONAR/ORQUESTAR una transacción (ser el coordinator/manager)

Además, la rigidez de los API types Fusion no permite casos edge donde el usuario necesita configuración custom.

**Análisis:**

```
Antes (un flag):
  supports_distributed_transactions: true/false
  
  Problema: Composable API orquesta SAGA pero no participa
            ¿Qué valor debería tener?

Después (dos roles):
  distributed_transactions:
    participant: true/false    # ¿Puede implementar Compensation?
    manager: true/false        # ¿Puede orquestar transacciones?
```

**Decisiones:**

1. **Separar en dos roles:**
   - `participant`: Puede implementar Compensation interface
   - `manager`: Puede orquestar transacciones (SAGA coordinator)

2. **Actualizar API Types:**

| API Type | participant | manager | Descripción |
|----------|:-----------:|:-------:|-------------|
| standard | false | false | API básica opinionada |
| domain-api | **true** | false | Participa en transacciones |
| system-api | false | false | Wrapper backend |
| experience-api | false | false | BFF, delega |
| composable-api | false | **true** | Orquesta transacciones |
| **custom-api** | ⚙️ | ⚙️ | **Configurable** (nuevo) |

3. **Añadir custom-api:**
   - Escape hatch para casos que no encajan en Fusion
   - Configurable via input_spec
   - WARNING: "Bypasses Fusion architectural guardrails"

4. **Actualizar requires_config de saga-compensation:**
   - `config_key: distributed_transactions.participant`
   - Ahora domain-api Y custom-api (si participant=true) pueden usar SAGA

5. **Futuro saga-orchestration:**
   - Requerirá `distributed_transactions.manager = true`
   - Para Composable API o custom-api con manager=true

**Cambios aplicados:**

| Archivo | Cambio |
|---------|--------|
| capability-index.yaml | v2.5 → v2.6, nuevos roles, custom-api, updated requires_config |
| discovery-guidance.md | v3.3 → v3.4, nueva tabla de roles |
| CAPABILITY.md | v3.4 → v3.5, documentar nueva estructura |
| FLOW.md | Actualizar ejemplo |

**Implicación semántica:**

```
"Genera una API REST con SAGA"
  → Matchea standard (participant=false)
  → ERROR R7: "Use Domain API or Custom API with participant=true"

"Genera una Custom API con SAGA" + input { participant: true }
  → Matchea custom-api
  → participant=true (configurable) 
  → R7 PASS ✅
```

**Model version:** 3.0.5

### DEC-016: Resolución de ambigüedad persistence → jpa {#dec-016}

**Fecha:** 2026-01-22  
**Estado:** ✅ Implementado

**Contexto:**  
TC16 "Genera un microservicio con persistencia" era ambiguo:
- `persistence` tiene dos features: `jpa` y `systemapi`
- Sin `default_feature`, el Discovery Agent debía preguntar
- Pero "persistencia" sin calificador típicamente implica base de datos local

**Opciones:**
- A) Mantener sin default (preguntar siempre)
- B) `default_feature: jpa` (asumir local)
- C) `default_feature: systemapi` (asumir backend)

**Decisión:** Opción B - `default_feature: jpa`

**Justificación:**
- JPA (local database) es el caso más común
- Si el usuario quiere System API, dice "via System API" o "backend"
- Reduce fricción para el caso típico
- `systemapi` tiene keywords específicos ("mainframe", "backend", "legacy")

**Cambios aplicados:**

| Archivo | Cambio |
|---------|--------|
| capability-index.yaml | v2.6 → v2.7, persistence.default_feature = jpa, jpa.is_default = true |
| discovery-guidance.md | v3.4 → v3.5, documentar resolución en Handling Ambiguity |

**Implicación:**
- TC16 ahora resuelve a `persistence.jpa` sin preguntar
- "via System API" sigue funcionando por keyword match

---

### DEC-017: Semántica "transaccional" → domain-api {#dec-017}

**Fecha:** 2026-01-22  
**Estado:** ✅ Implementado

**Contexto:**  
TC17/TC20 "Genera una Domain API transaccional" resolvía a SAGA:
- Discovery Agent infería "transaccional" → distributed-transactions
- Pero "transaccional" es genérico (puede ser ACID local o distribuido)
- Solo hay un feature en distributed-transactions (saga-compensation)
- Resultado: "API transaccional" = "API con SAGA" (semánticamente incorrecto)

**Análisis:**

| Término | Significado Real | Interpretación Anterior |
|---------|-----------------|------------------------|
| "transaccional" | ACID local OR distribuido | → SAGA (forzado) |
| "SAGA/compensación" | Transacciones distribuidas | → SAGA ✅ |

**Decisión:** "transaccional" es keyword de `domain-api`, no de `distributed-transactions`

**Justificación:**
- Domain API tiene semántica transaccional inherente (diseño Fusion)
- "API transaccional" → Domain API (sin SAGA implícito)
- "API con SAGA" → Domain API + saga-compensation (explícito)
- Separación semántica clara: tipo de API vs patrón de transacción

**Cambios aplicados:**

| Archivo | Cambio |
|---------|--------|
| capability-index.yaml | v2.6 → v2.7, añadir "transaccional", "transactional API" a domain-api.keywords |
| discovery-guidance.md | v3.4 → v3.5, documentar semántica en Handling Ambiguity |

**Nueva semántica:**

| Prompt | Resolución |
|--------|------------|
| "API transaccional" | domain-api (sin SAGA) |
| "Domain API transaccional" | domain-api (sin SAGA) |
| "API con SAGA" | domain-api + saga-compensation |
| "Domain API con compensación" | domain-api + saga-compensation |

**Implicación:**
- TC17/TC20 ahora resuelven a `domain-api` SIN saga-compensation
- Para SAGA, el usuario debe decir "SAGA", "compensación", o "transacción distribuida"
- config_flags: {transactional: false, idempotent: false} para Domain API básico

**Model version:** 3.0.6
