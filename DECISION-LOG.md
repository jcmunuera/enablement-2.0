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
- [DEC-018](#dec-018) - Output Specification por Flow
- [DEC-019](#dec-019) - Formato manifest.json v3.0 (sin skills)
- [DEC-020](#dec-020) - Schemas de Trazabilidad
- [DEC-021](#dec-021) - Templates de Test en Módulos
- [DEC-022](#dec-022) - Eliminar validación 'skill' en traceability-check
- [DEC-023](#dec-023) - Selección de variante default en módulos
- [DEC-024](#dec-024) - CONTEXT_RESOLUTION: Resolución de variables antes de generación
- [DEC-025](#dec-025) - No Improvisation Rule
- [DEC-026](#dec-026) - Template Headers Estandarizados
- [DEC-027](#dec-027) - Tier-0 Conformance Validation
- [DEC-028](#dec-028) - Phase 3 Cross-Cutting Model
- [DEC-029](#dec-029) - Package Delivery Validation
- [DEC-030](#dec-030) - Transform Descriptors Implementation
- [DEC-031](#dec-031) - PoC Validation Fixes (Golden Master)
- [DEC-032](#dec-032) - Human Approval Checkpoint Pattern
- [DEC-033](#dec-033) - Validation Script Management (No Improvisation)
- [DEC-034](#dec-034) - Validation Assembly Script (Automation)

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

---

## 2026-01-23 (Sesión: Reproducibilidad y Testing)

### DEC-018: Output Specification por Flow {#dec-018}

**Fecha:** 2026-01-23  
**Estado:** ✅ Implementado

**Contexto:**  
El modelo v3.0 no especificaba completamente qué debe producir una generación. Esto impedía:
- Reproducibilidad (diferentes sesiones producían estructuras diferentes)
- Validación automática (no había contrato de output)
- Testing determinístico

**Análisis del gap:**

| Elemento | Generado | Documentado |
|----------|----------|-------------|
| Estructura proyecto | ✅ | ✅ (flow-generate.md) |
| Paquete completo | ✅ | ❌ |
| Directorio /input | ✅ | ❌ |
| Directorio /trace | ✅ | ❌ |
| manifest.json | ✅ | ❌ |

**Opciones:**
- A) Documento único para todos los flows
- B) Output spec por flow (flow-generate-output.md, flow-transform-output.md)

**Decisión:** Opción B - Output specification por flow

**Justificación:**
- Cada flow produce output diferente:
  - `flow-generate`: Proyecto nuevo completo + trazas
  - `flow-transform`: Posiblemente solo diffs o proyecto modificado
- Separación de concerns: proceso (flow) vs contrato (output-spec)
- Permite evolución independiente

**Cambios aplicados:**

| Archivo | Cambio |
|---------|--------|
| `runtime/flows/code/flow-generate-output.md` | NUEVO - Especifica paquete completo |
| `runtime/flows/code/flow-generate.md` | Añadida referencia a output-spec |
| `runtime/flows/code/GENERATION-ORCHESTRATOR.md` | MOVIDO desde flows/ |

**Estructura definida:**

```
gen_{service-name}_{YYYYMMDD_HHMMSS}/
├── input/           # Inputs originales preservados
├── output/          # Proyecto generado + .enablement/manifest.json
├── trace/           # discovery-trace, generation-trace, modules-used
└── validation/      # Scripts tier1/2/3 + reports/
```

---

### DEC-019: Formato manifest.json v3.0 (sin skills) {#dec-019}

**Fecha:** 2026-01-23  
**Estado:** ✅ Implementado

**Contexto:**  
El manifest.json de paquetes generados aún usaba estructura de v2.x con `skill` object, inconsistente con el modelo v3.0 que eliminó skills (DEC-001).

**Antes (v2.x):**
```json
{
  "skill": {
    "id": "skill-code-001-domain-api-java-spring",
    "version": "3.0.6"
  },
  "modules": [...]
}
```

**Después (v3.0):**
```json
{
  "enablement": {
    "version": "3.0.6",
    "domain": "code",
    "flow": "flow-generate"
  },
  "discovery": {
    "stack": "java-spring",
    "capabilities": ["architecture.hexagonal-light", ...],
    "features": ["hexagonal-light", ...]
  },
  "modules": [...]
}
```

**Decisión:** Reemplazar `skill` con `enablement` + `discovery`

**Justificación:**
- Alineación con modelo v3.0 (capability-driven)
- `enablement` captura metadata de plataforma
- `discovery` captura resultado del capability discovery
- Cada módulo referencia su capability de origen

**Cambios aplicados:**

| Archivo | Cambio |
|---------|--------|
| `runtime/schemas/trace/manifest.schema.json` | Actualizado: skill → enablement + discovery |
| `runtime/flows/code/flow-generate-output.md` | Ejemplo actualizado |
| `runtime/flows/code/GENERATION-ORCHESTRATOR.md` | Código ejemplo actualizado |

---

### DEC-020: Schemas de Trazabilidad {#dec-020}

**Fecha:** 2026-01-23  
**Estado:** ✅ Implementado

**Contexto:**  
Los archivos de traza (discovery-trace.json, generation-trace.json, etc.) no tenían schemas formales, lo que impedía:
- Validación automática de trazas
- Documentación clara de estructura esperada
- Integración con herramientas de análisis

**Decisión:** Crear JSON Schemas para todos los archivos de traza

**Schemas creados:**

| Schema | Propósito | Valida |
|--------|-----------|--------|
| `manifest.schema.json` | Metadata de generación | `.enablement/manifest.json` |
| `discovery-trace.schema.json` | Traza de discovery | `trace/discovery-trace.json` |
| `generation-trace.schema.json` | Traza de generación por fases | `trace/generation-trace.json` |
| `modules-used.schema.json` | Contribución de cada módulo | `trace/modules-used.json` |
| `validation-results.schema.json` | Resultados de validación | `validation/reports/validation-results.json` |

**Justificación:**
- Validación automática con `ajv` o `jsonschema`
- Documentación ejecutable
- Base para testing de determinismo
- Facilita debugging de generaciones fallidas

**Ubicación:** `runtime/schemas/trace/`

---

### DEC-021: Templates de Test en Módulos {#dec-021}

**Fecha:** 2026-01-23  
**Estado:** ✅ Implementado

**Contexto:**  
Los módulos generaban código de producción pero los tests eran ad-hoc o incompletos. Esto causaba:
- Tests inconsistentes entre generaciones
- No todos los módulos contribuían tests
- Difícil saber qué tests debería generar cada módulo

**Decisión:** Cada módulo define explícitamente qué tests genera en `templates/test/`

**Templates añadidos:**

| Módulo | Templates de Test | Propósito |
|--------|-------------------|-----------|
| mod-015 | `EntityTest.java.tpl` | Factory methods, domain behavior |
| mod-015 | `EntityIdTest.java.tpl` | Value object creation, equality |
| mod-015 | `ControllerTest.java.tpl` | REST endpoints (@WebMvcTest) |
| mod-019 | `AssemblerTest.java.tpl` | HATEOAS link generation |

**Justificación:**
- Cada módulo es responsable de sus propios tests
- Tests consistentes entre generaciones
- Sección "Tests Generated" en MODULE.md documenta expectativa
- Patrones claros: Domain tests sin Spring, Controller tests con @WebMvcTest

**Convención de patrones de test:**

| Layer | Spring Context | Framework |
|-------|---------------|-----------|
| Domain (Entity, ValueObject) | None (pure POJO) | JUnit 5 + AssertJ |
| Domain Service | None (Mockito only) | JUnit 5 + Mockito + AssertJ |
| Adapter OUT (SystemApi) | None (Mockito only) | JUnit 5 + Mockito + AssertJ |
| Adapter IN (Controller) | @WebMvcTest | Spring Test + MockMvc |

**Model version:** 3.0.7

---

### DEC-022: Eliminar validación 'skill' en traceability-check {#dec-022}

**Fecha:** 2026-01-23  
**Estado:** ✅ Implementado

**Contexto:**  
El validador `traceability-check.sh` seguía requiriendo el campo `skill` en manifest.json, a pesar de que DEC-001 y DEC-019 eliminaron skills del modelo v3.0.

**Error detectado:**
```
FAIL: traceability-check - Missing required field: skill
```

**Análisis:**
- `traceability-check.sh` línea 52: `REQUIRED_FIELDS=("generation" "skill" "status")`
- Inconsistente con manifest.schema.json que ya usa `enablement` + `discovery`

**Decisión:** Actualizar validador para alinearse con modelo v3.0

**Cambios aplicados:**

| Archivo | Cambio |
|---------|--------|
| `runtime/validators/tier-1-universal/traceability/traceability-check.sh` | `skill` → `enablement`, añadir validación de `enablement.version` y `discovery` |

**Validación actualizada:**
- Campo `enablement` requerido (reemplaza `skill`)
- Campo `enablement.version` debe existir
- Campo `discovery` recomendado (warning si ausente)
- Eliminada validación de `skill.id` naming convention

**Model version:** 3.0.8

---

### DEC-023: Selección de variante default en módulos {#dec-023}

**Fecha:** 2026-01-23  
**Estado:** ✅ Implementado

**Contexto:**  
El módulo `mod-code-003-timeout-java-resilience4j` tiene dos variantes:
- `client-timeout` (default): Configuración HTTP client, métodos síncronos
- `annotation-async` (alternativa): `@TimeLimiter`, requiere `CompletableFuture<T>`

**Error detectado:**
```
FAIL: timeout-check - @TimeLimiter on synchronous methods (requires CompletableFuture)
```

**Análisis:**
- MODULE.md frontmatter declaraba `default: client-timeout`
- MODULE.md body solo documentaba `@TimeLimiter` (la alternativa)
- GENERATION-ORCHESTRATOR.md no tenía lógica de selección de variantes
- Resultado: Código generado usaba variante incorrecta

**Decisión:** 
1. Reestructurar MODULE.md: Variante DEFAULT primero y prominente
2. Añadir lógica explícita de selección de variantes en orquestador
3. Documentar "qué NO hacer" con ejemplos de uso incorrecto

**Cambios aplicados:**

| Archivo | Cambio |
|---------|--------|
| `modules/mod-code-003-timeout-java-resilience4j/MODULE.md` | Reestructurar: client-timeout (DEFAULT) primero, tabla de decisión, ejemplos incorrectos |
| `runtime/flows/code/GENERATION-ORCHESTRATOR.md` | Añadir `select_variant()` function y lógica en generation loop |

**Regla de selección:**
```python
def select_variant(module, discovery):
    # Check explicit config
    requested = discovery.config.get(f"{module.feature}.variant")
    if requested:
        return requested
    # ALWAYS return default when not specified
    return module.default_variant.id
```

**Implicación para mod-003:**

| Config | Variante Seleccionada | Genera |
|--------|----------------------|--------|
| (ninguno) | client-timeout | `RestClientConfig.java` con timeouts HTTP |
| `resilience.timeout.variant: annotation-async` | annotation-async | `@TimeLimiter` + `CompletableFuture<T>` |

**Model version:** 3.0.8

---

## DEC-024: Fase CONTEXT_RESOLUTION para Determinismo en Generación

**Fecha:** 2026-01-26  
**Estado:** ✅ Implementado

**Contexto:**  
Durante la simulación del PoC Customer API, se detectó que el código generado no seguía los templates definidos en los módulos. El agente "improvisó" implementaciones en lugar de aplicar los templates mecánicamente.

**Problema detectado:**
- `CustomerResponseAssembler.java` generado con `implements RepresentationModelAssembler` cuando el template define `extends RepresentationModelAssemblerSupport`
- `PartiesSystemApiClient.java` sin propagación de `X-Correlation-ID` cuando el template lo incluye explícitamente
- Naming incorrecto: `CustomerResponseAssembler` en lugar de `CustomerModelAssembler`

**Root cause:**
El flujo de generación no obligaba a:
1. Parsear los inputs (specs, mapping.json) para extraer variables
2. Usar los templates como única fuente de código
3. Sustituir variables mecánicamente sin interpretación

**Decisión:**  
Añadir fase **CONTEXT_RESOLUTION** entre DISCOVERY y GENERATION:

```
INIT → DISCOVERY → CONTEXT_RESOLUTION → GENERATION → TESTS → ...
                         │
                         ▼
              generation-context.json
              (TODAS las variables resueltas)
```

**Principios:**
1. **Fail-fast:** Si una variable no puede resolverse de los inputs, FALLAR antes de generar
2. **Trazabilidad:** `generation-context.json` documenta TODAS las variables usadas
3. **Determinismo:** El agente solo sustituye, no interpreta
4. **Validación:** Scripts tier-1 verifican que el código cumple con templates

**Cambios aplicados:**

| Archivo | Cambio |
|---------|--------|
| `GENERATION-ORCHESTRATOR.md` | Nueva fase CONTEXT_RESOLUTION (Phase 2.5) |
| `schemas/generation-context.schema.json` | Schema del nuevo artefacto |
| `templates/*.tpl` | Documentar variables requeridas en header |

**Model version:** 3.0.9

---

## DEC-025: Regla Anti-Improvisación en Generación de Código

**Fecha:** 2026-01-26  
**Estado:** ✅ Implementado

**Contexto:**  
Complemento a DEC-024. Define explícitamente qué está permitido y prohibido durante la fase de generación.

**Decisión:**

**🚫 PROHIBIDO durante GENERATION:**
- Añadir código que no esté en el template
- Modificar estructura del template (orden de métodos, imports extra)
- "Mejorar" el código con conocimiento general del LLM
- Rellenar "huecos" con implementaciones inventadas
- Usar valores que no estén en `generation-context.json`

**✅ PERMITIDO durante GENERATION:**
- Sustituir `{{variables}}` con valores de `generation-context.json`
- Reportar si falta información (pero NO inventarla)
- Formateo básico (indentación consistente)

**Regla de validación:**
```python
def validate_generated_code(file_path, template_path, context):
    # 1. Verificar que tiene header @generated
    assert has_generated_header(file_path)
    
    # 2. Verificar que la estructura coincide con template
    template_structure = extract_structure(template_path)
    generated_structure = extract_structure(file_path)
    assert structures_match(template_structure, generated_structure)
    
    # 3. Verificar que no hay código extra
    extra_code = find_extra_code(template_path, file_path, context)
    assert len(extra_code) == 0, f"Código no autorizado: {extra_code}"
```

**Implicación:**
Si un template tiene un "hueco" (comentario tipo `// TODO: add field mappings`), el agente debe:
1. Buscar la información en `generation-context.json`
2. Si existe → sustituir
3. Si NO existe → FALLAR con mensaje claro, no improvisar

**Model version:** 3.0.9

---

## DEC-026: Actualización de Headers en Templates Críticos para PoC

**Fecha:** 2026-01-26  
**Estado:** ✅ Implementado

**Contexto:**  
Como parte de DEC-024 (CONTEXT_RESOLUTION), los templates deben documentar explícitamente sus variables requeridas para que la fase de resolución de contexto pueda validar que todas las variables están disponibles antes de generar código.

**Decisión:**  
Actualizar todos los templates críticos para el PoC Customer API con un header estandarizado que incluye:
- Identificación del template y módulo
- Path de output esperado
- Propósito del template
- Lista de variables requeridas

**Formato de Header Estandarizado:**
```
// ═══════════════════════════════════════════════════════════════════════════════
// Template: {filename}
// Module: {module-id}
// ═══════════════════════════════════════════════════════════════════════════════
// Output: {{basePackagePath}}/path/to/Output.java
// Purpose: Brief description
// ═══════════════════════════════════════════════════════════════════════════════
// REQUIRED VARIABLES: {{var1}} {{var2}} {{var3}}
// ═══════════════════════════════════════════════════════════════════════════════
```

**Templates Actualizados (33 total):**

| Módulo | Templates | Cobertura |
|--------|-----------|-----------|
| mod-015 (hexagonal-base) | Entity, EntityId, Repository, NotFoundException, Enum, ApplicationService, CreateRequest, Response, RestController, pom.xml, application.yml, GlobalExceptionHandler, CorrelationIdFilter, Application | 14/22 |
| mod-017 (persistence-systemapi) | SystemApiAdapter, SystemApiMapper, SystemApiUnavailableException, application-systemapi.yml | 4/11 |
| mod-018 (integration-rest) | restclient, restclient-config, IntegrationException, application-integration.yml | 4/9 |
| mod-019 (public-exposure) | EntityModelAssembler, PageResponse, FilterRequest | 3/6 |
| mod-001 (circuit-breaker) | basic-fallback, application-circuitbreaker.yml, pom-circuitbreaker.xml | 3/7 |
| mod-002 (retry) | basic-retry, application-retry.yml, pom-retry.xml | 3/6 |
| mod-003 (timeout) | timeout-config, application-client-timeout.yml | 2/8 |

**Templates Pendientes (36 restantes):**
- Tests templates (no críticos para generación)
- Variantes alternativas (feign, resttemplate)
- Templates de casos no cubiertos por el PoC

**Beneficios:**
1. **Trazabilidad:** Cada archivo generado es rastreable a su template y módulo
2. **Validación:** CONTEXT_RESOLUTION puede verificar que todas las variables están resueltas
3. **Documentación:** Los templates son auto-documentados
4. **Determinismo:** Elimina ambigüedad sobre qué variables necesita cada template

**Model version:** 3.0.10
---

## DEC-027: Tier-0 Conformance Validation

**Fecha:** 2026-01-26  
**Estado:** ✅ Implementado

**Contexto:**  
Las reglas DEC-024 (CONTEXT_RESOLUTION) y DEC-025 (No Improvisation) definen cómo debe comportarse el generador, pero no existía un mecanismo de validación post-generación que verificara que el código generado realmente sigue los templates.

En pruebas con v3.0.8, se detectó que Claude "improvisaba" código en lugar de seguir estrictamente los templates:
- `CorrelationIdFilter`: usaba `private static final` en lugar de `public static final`, faltaba método `getCurrentCorrelationId()`
- `CustomerModelAssembler`: usaba `implements RepresentationModelAssembler` en lugar de `extends RepresentationModelAssemblerSupport`

Esto impedía alcanzar el determinismo necesario para pruebas reproducibles.

**Decisión:**  
Crear un nuevo tier de validación (Tier-0) que se ejecuta ANTES de las validaciones de código:

```
runtime/validators/
├── tier-0-conformance/           ← NUEVO: Valida proceso de generación
│   └── template-conformance-check.sh
├── tier-1-universal/             ← Valida estructura, naming
├── tier-2-technology/            ← Valida compilación, sintaxis
└── (tier-3 en modules/*/validation/)  ← Valida requisitos de módulo
```

**Orden de Ejecución:**
```
tier-0 (conformidad generación) → tier-1 (universal) → tier-2 (tecnología) → tier-3 (módulo)
```

**Mecanismo de Validación:**

El script `template-conformance-check.sh` usa "fingerprints" - patrones únicos que DEBEN aparecer si el template fue seguido correctamente:

```bash
# Ejemplo de fingerprints para mod-015
MODULE_FINGERPRINTS["mod-code-015:CorrelationIdFilter.java"]="public static final String CORRELATION_ID_HEADER|public static String getCurrentCorrelationId|extractOrGenerate"

# Ejemplo de fingerprints para mod-019
MODULE_FINGERPRINTS["mod-code-019:*ModelAssembler.java"]="extends RepresentationModelAssemblerSupport|super(.*Controller.class.*Response.class)"
```

**Validaciones Incluidas:**
1. **Fingerprints por módulo:** Patrones obligatorios de cada template
2. **Anti-improvisación:** Detecta patrones incorrectos conocidos (ej: `implements RepresentationModelAssembler` en lugar de `extends`)
3. **Naming conventions:** Verifica nombres correctos (ej: `*ModelAssembler` no `*ResponseAssembler`)

**Justificación de Tier-0:**
- Tier-0 valida el **proceso de generación**, no el código en sí
- Debe ejecutarse primero porque si la generación fue incorrecta, las demás validaciones son irrelevantes
- Mantiene coherencia con el modelo de tiers existente donde tier-3 es específico de módulo

**Resultado esperado:**
- Código v3.0.8 (improvisado): FAIL con errores específicos
- Código v3.0.10 (template-driven): PASS

**Archivos Añadidos:**
- `runtime/validators/tier-0-conformance/template-conformance-check.sh`

**Model version:** 3.0.10-003

---

## DEC-028: Phase 3 Cross-Cutting Model Clarification

**Fecha:** 2026-01-26  
**Estado:** ✅ Implementado

**Contexto:**  
Durante la validación del PoC Customer API, se detectó que el template de mod-017 (SystemApiAdapter) tenía anotaciones de resiliencia (@CircuitBreaker, @Retry) y métodos fallback hardcodeados. Esto violaba el modelo de fases donde:

- **Phase 1-2:** GENERAN archivos nuevos (structural, implementation)
- **Phase 3+:** TRANSFORMAN archivos existentes (cross-cutting)

El hardcoding de resiliencia en Phase 2 hacía que los módulos de Phase 3 (mod-001, mod-002, mod-003) fueran redundantes, y el código generado no seguía la arquitectura definida.

**Investigación:**  
Revisando la documentación del modelo:

1. `flow-transform.md` define claramente que cross-cutting modules son transformadores
2. `ENABLEMENT-MODEL-v3.0.md` especifica phase_group: cross-cutting para resilience
3. `mod-001/MODULE.md` describe templates como "fragments for transformation"
4. El orchestrator tracking distingue `files_generated` vs `files_modified`

El modelo estaba correctamente diseñado, pero alguien había "solucionado" un problema de implementación hardcodeando resiliencia en mod-017.

**Decisión:**  
Restaurar la separación correcta entre phases:

1. **mod-017:** Template genera adapter SIN resiliencia
2. **mod-018:** RestClientConfig con timeouts ALTOS (30s/60s) como protección de infraestructura
3. **mod-003 (client-timeout):** Cambia de GENERAR a MODIFICAR - ajusta timeouts para resiliencia
4. **GENERATION-ORCHESTRATOR:** Nueva sección documentando comportamiento de Phase 3+
5. **discovery-guidance:** Nueva Rule 10 para target resolution de resiliencia

**Modelo de Timeout:**

| Capa | Responsabilidad | Valores | Módulo |
|------|-----------------|---------|--------|
| Infraestructura | Protección contra cuelgues infinitos | 30s/60s | mod-018 |
| Resiliencia | Control fino de fault tolerance | 5s/10s | mod-003 |

**Modelo de Target Resolution:**

| Modo | Trigger | Resultado |
|------|---------|-----------|
| Explicit | "apply X to CustomerAdapter" | Target específico |
| Implicit | "con circuit-breaker" (sin target) | Todos los adapter OUT |

**Archivos Modificados:**

```
modules/mod-code-017-persistence-systemapi/
  templates/adapter/SystemApiAdapter.java.tpl    # Removida resiliencia

modules/mod-code-018-api-integration-rest-java-spring/
  templates/config/restclient-config.java.tpl    # Timeouts 30s/60s

modules/mod-code-003-timeout-java-resilience4j/
  MODULE.md                                       # Frontmatter v1.2
  templates/client/timeout-config-transform.yaml  # NUEVO: descriptor de transformación

runtime/flows/code/
  GENERATION-ORCHESTRATOR.md                      # Sección Cross-Cutting

runtime/discovery/
  discovery-guidance.md                           # Rule 10 Target Resolution
```

**Model version:** 3.0.10-008

---

## DEC-029: Package Delivery Validation

**Date:** 2026-01-26  
**Status:** Approved  
**Category:** Validation  
**Model Version:** 3.0.10-009

**Context:**  
Durante la validación E2E del PoC Customer API, se detectaron dos fallos:

1. **TAR incompleto:** Faltaban directorios `/input` y `/validation`
2. **Error de compilación:** Import incorrecto de `RepresentationModelAssemblerSupport`
   - Incorrecto: `org.springframework.hateoas.server.RepresentationModelAssemblerSupport`
   - Correcto: `org.springframework.hateoas.server.mvc.RepresentationModelAssemblerSupport`

**Root Cause Analysis:**

| Fallo | Causa | Template existe? |
|-------|-------|------------------|
| TAR incompleto | Error de ejecución, no de KB | N/A |
| Import incorrecto | Código improvisado, violación DEC-025 | ✅ Template correcto |

El template `EntityModelAssembler.java.tpl` tenía el import correcto. El error ocurrió porque el código fue improvisado en lugar de usar el template (violación de DEC-025 No Improvisation Rule).

El fingerprint Tier-0 existente (`extends RepresentationModelAssemblerSupport`) no detectó el error porque solo validaba la herencia, no el import.

**Decisión:**  
Añadir validaciones preventivas para evitar estos errores:

1. **Script `package-structure-check.sh`** en `runtime/validation/scripts/tier-0/`
   - Valida estructura obligatoria: input/, output/, trace/, validation/
   - Se ejecuta antes de entregar el package

2. **Mejora de `hateoas-check.sh`** en `mod-019/validation/`
   - Añadida validación específica de import path
   - Detecta import incorrecto (`server.RMAS` vs `server.mvc.RMAS`)

3. **Package Delivery Checklist** en `GENERATION-ORCHESTRATOR.md`
   - Checklist obligatorio antes de entregar
   - Incluye comandos de validación automatizada

**Archivos Modificados:**

```
runtime/validation/scripts/tier-0/
  package-structure-check.sh                    # NUEVO

modules/mod-code-019-api-public-exposure-java-spring/validation/
  hateoas-check.sh                              # Import validation añadida

runtime/flows/code/
  GENERATION-ORCHESTRATOR.md                    # Package Delivery Checklist
```

**Validation Commands:**

```bash
# Antes de entregar:
./validation/scripts/tier-0/package-structure-check.sh .
./validation/run-all.sh
cd output/{project} && mvn compile
```

**Lessons Learned:**

1. **DEC-025 es crítico:** Nunca improvisar código, siempre usar templates
2. **Fingerprints deben ser específicos:** Validar imports, no solo estructuras
3. **Validación automatizada:** Scripts deben ejecutarse antes de entregar

**Model version:** 3.0.10-009

---

## DEC-030: Transform Descriptors Implementation {#dec-030}

**Date:** 2026-01-27  
**Status:** ✅ Implemented  
**Category:** Architecture  
**Model Version:** 3.0.10-010

**Context:**  
DEC-028 established the conceptual model for Phase 3 cross-cutting transformations, but the actual implementation artifacts (transform descriptors, snippets, execution order metadata) were missing from the KB. This prevented automated Golden Master generation because:

1. **mod-001 (circuit-breaker):** No transform descriptor existed
2. **mod-002 (retry):** No transform descriptor existed  
3. **mod-003 (timeout):** Transform descriptor existed but was in wrong location
4. **MODULE.md files:** Missing `phase_group` and `execution_order` metadata
5. **GENERATION-ORCHESTRATOR.md:** Phase 6 (Validation Assembly) was incomplete

**Decision:**  
Implement complete transform descriptor infrastructure:

### 1. Transform Descriptors Created

| Module | File | Type |
|--------|------|------|
| mod-001 | `transform/circuit-breaker-transform.yaml` | annotation |
| mod-002 | `transform/retry-transform.yaml` | annotation |
| mod-003 | `transform/timeout-config-transform.yaml` | modification |

### 2. Code Snippets for mod-001

```
modules/mod-code-001-.../transform/snippets/
├── service-name-constant.java    # SERVICE_NAME constant
└── fallback-method.java          # Fallback method template
```

### 3. MODULE.md Metadata

Each cross-cutting module now includes:

```yaml
phase_group: cross-cutting
execution_order: N  # 1=circuit-breaker, 2=retry, 3=timeout

transformation:
  type: annotation | modification
  descriptor: transform/{name}.yaml
```

### 4. Execution Order Enforcement

```java
// Order in generated code:
@CircuitBreaker(name = SERVICE_NAME, fallbackMethod = "findByIdFallback")  // Order 1
@Retry(name = SERVICE_NAME)                                                  // Order 2
public Optional<Customer> findById(CustomerId id) { ... }
```

### 5. Phase 6 Documentation Complete

GENERATION-ORCHESTRATOR.md now includes:
- Complete validation directory structure
- Script collection from all tiers (0-3)
- Dynamic Tier-0 script generation based on modules used
- Module validation scripts reference table
- Shell compatibility notes (POSIX vs bash)

**Additional Fixes:**

| File | Change | Reason |
|------|--------|--------|
| `pom-circuitbreaker.xml.tpl` | Added `spring-boot-starter-aop` | Required for @CircuitBreaker annotations |
| `syntax-check.sh` | `head -10` → `head -20` | Templates have longer headers |

**Files Created:**

```
decisions/
└── DEC-028-phase3-cross-cutting-model.md

modules/mod-code-001-circuit-breaker-java-resilience4j/transform/
├── circuit-breaker-transform.yaml
└── snippets/
    ├── service-name-constant.java
    └── fallback-method.java

modules/mod-code-002-retry-java-resilience4j/transform/
└── retry-transform.yaml

modules/mod-code-003-timeout-java-resilience4j/transform/
└── timeout-config-transform.yaml (reorganized)
```

**Files Modified:**

```
modules/mod-code-001-.../MODULE.md
modules/mod-code-001-.../templates/config/pom-circuitbreaker.xml.tpl
modules/mod-code-002-.../MODULE.md
modules/mod-code-003-.../MODULE.md
runtime/flows/code/GENERATION-ORCHESTRATOR.md
runtime/validators/tier-2-technology/.../syntax-check.sh
```

**Justification:**

1. **Completeness:** KB now has all artifacts needed for automated generation
2. **Traceability:** Each transformation step is documented and auditable
3. **Determinism:** Execution order is explicit, not implicit
4. **Validation:** Transform descriptors include fingerprints for Tier-0 checks

**Model version:** 3.0.10-010

---

## DEC-031: PoC Validation Fixes (Golden Master) {#dec-031}

**Date:** 2026-01-27  
**Status:** ✅ Implemented  
**Category:** Templates, Validators  
**Model Version:** 3.0.10-011

**Context:**  
Durante la ejecución del PoC customer-api como Golden Master, se identificaron 10 defectos que impedían la compilación, ejecución de tests, o validación del código generado. Estos defectos se agrupan en 3 categorías:

1. **Template Bugs (5):** Código generado con errores de compilación
2. **Validator Bugs (3):** Validadores con patrones incorrectos o demasiado restrictivos
3. **Test Template Bugs (2):** Templates de tests incompletos

**Root Cause Analysis:**

| ID | Severidad | Síntoma | Causa Raíz |
|----|-----------|---------|------------|
| TB-001 | CRÍTICO | `cannot assign final variable id` | Template Entity.java declara `final` pero factory methods asignan post-construcción |
| TB-002 | CRÍTICO | `package org.springframework.transaction.annotation does not exist` | Template ApplicationService usa `@Transactional` sin JPA, spring-tx no incluido |
| TB-003 | MEDIO | Validator no encuentra `resilience4j.retry` | Config en application-retry.yml pero validator solo busca en application.yml |
| TB-004 | BAJO | Fingerprint `toRequest` no encontrado | Template genera `toSystemRequest`, fingerprint desalineado |
| TB-005 | BAJO | Fingerprint `ProblemDetail` no encontrado | Template genera `createError`, fingerprint desalineado |
| VB-001 | MEDIO | `Missing X-Correlation-ID` aunque código correcto | Validator no detecta constante `CORRELATION_ID_HEADER` |
| VB-002 | MEDIO | `resilience4j.retry not found` aunque existe | Validator solo busca en application.yml, no en application-*.yml |
| VB-003 | BAJO | `-e` aparece en output | `echo -e` no portable, debe usar `printf` |
| TTB-001 | ALTO | NPE en ControllerTest | Mock de `assembler.toModel()` no configurado |
| TTB-002 | ALTO | Test incompleto | Placeholder `// Verification would continue...` sin assertions |

**Decision:**  
Aplicar fixes a templates, validators y fingerprints para garantizar que el código generado compile, pase tests, y supere validación sin intervención manual.

### Fixes Aplicados

#### CRÍTICO - Compilación

**TB-001: Entity.java.tpl - Quitar `final` del campo id**

```diff
- private final {{Entity}}Id id;
+ // TB-001 FIX: Removed 'final' - field is assigned via static factory methods
+ private {{Entity}}Id id;
```

**TB-002: ApplicationService.java.tpl - Quitar `@Transactional`**

Decisión arquitectónica: Para SystemAPI sin JPA, `@Transactional` no tiene sentido semántico. Se elimina en lugar de añadir spring-tx.

```diff
- import org.springframework.transaction.annotation.Transactional;
+ // TB-002 FIX: @Transactional removed - only needed with JPA persistence

- @Transactional(readOnly = true)
  @Service
```

#### ALTO - Tests

**TTB-001: ControllerTest-hateoas.java.tpl (NUEVO)**

Nuevo template específico para tests de controllers con HATEOAS que configura correctamente el mock del assembler:

```java
@MockBean
private {{Entity}}ModelAssembler assembler;

// En cada test:
when(assembler.toModel(any({{Entity}}Response.class)))
    .thenReturn(EntityModel.of(response));
```

**TTB-002: SystemApiAdapterTest.java.tpl - Test completo**

Añadido test para System API error codes:

```java
@Test
void findById_WhenSystemReturnsError_ReturnsEmpty() {
    {{Entity}}Dto errorDto = {{Entity}}Dto.builder()
        .sysRc("99")  // Error code
        .build();
    when(client.getById(id)).thenReturn(errorDto);
    
    Optional<{{Entity}}> result = adapter.findById(id);
    
    assertTrue(result.isEmpty());
}
```

#### MEDIO - Validators

**VB-001: integration-check.sh - Detectar constante**

```diff
- if ! grep -q "X-Correlation-ID\|x-correlation-id\|correlationId" "$file"; then
+ if ! grep -qE "X-Correlation-ID|x-correlation-id|correlationId|CORRELATION_ID_HEADER" "$file"; then
```

**VB-002: retry-check.sh - Buscar en todos los YAML**

```diff
- if grep -q "resilience4j:" "$TARGET_DIR/src/main/resources/application.yml"
+ if grep -rq "resilience4j:" "$RESOURCES_DIR"/application*.yml 2>/dev/null
```

#### BAJO - Fingerprints

**TB-004/TB-005: template-conformance-check.sh**

Fingerprints actualizados para coincidir con output real de templates:

```bash
# mod-015
MODULE_FINGERPRINTS["mod-code-015:CorrelationIdFilter.java"]="...getCurrentCorrelationId"  # removed extractOrGenerate
MODULE_FINGERPRINTS["mod-code-015:GlobalExceptionHandler.java"]="...createError|@ExceptionHandler"  # was ProblemDetail

# mod-017
MODULE_FINGERPRINTS["mod-code-017:*SystemApiMapper.java"]="...toSystemRequest\|toRequest"  # accept both

# mod-019
MODULE_FINGERPRINTS["mod-code-019:*ModelAssembler.java"]="extends RepresentationModelAssemblerSupport|withSelfRel"  # simplified
```

**Files Modified:**

```
modules/mod-code-015-hexagonal-base-java-spring/templates/
├── domain/Entity.java.tpl                    # TB-001: removed final
└── application/ApplicationService.java.tpl   # TB-002: removed @Transactional

modules/mod-code-017-persistence-systemapi/templates/test/
└── SystemApiAdapterTest.java.tpl             # TTB-002: complete test

modules/mod-code-019-api-public-exposure-java-spring/templates/test/
└── ControllerTest-hateoas.java.tpl           # TTB-001: NEW file

modules/mod-code-002-retry-java-resilience4j/validation/
└── retry-check.sh                            # VB-002: search all YAML

modules/mod-code-018-api-integration-rest-java-spring/validation/
└── integration-check.sh                      # VB-001: detect constant

runtime/validators/tier-0-conformance/
└── template-conformance-check.sh             # TB-004/TB-005: aligned fingerprints
```

**Validation Results Post-Fix:**

| Check | Before | After |
|-------|--------|-------|
| `mvn compile` | ❌ 5 errors | ✅ SUCCESS |
| `mvn test` | ❌ NPE | ✅ ALL PASS |
| Tier-0 validation | ❌ 6 failures | ✅ PASS |
| Tier-1 validation | ✅ PASS | ✅ PASS |
| Tier-2 validation | ❌ compile, test | ✅ PASS |
| Tier-3 validation | ❌ 4 failures | ✅ PASS |
| **Total** | **13/17 PASS** | **17/17 PASS** |

**Golden Master Package:**

```
gen_customer-api_20260127_145144-v2.tar
├── input/           (5 files)
├── output/          (Maven project, 25 Java files)
├── trace/           (4 trace files)
└── validation/      (17 scripts + runner)
```

**Lessons Learned:**

1. **Template ↔ Fingerprint alignment:** Fingerprints must be updated when templates change
2. **@Transactional is JPA-specific:** Don't include without actual transaction management
3. **Factory method pattern incompatible with final:** Use private setters or builder instead
4. **Test templates must be complete:** Placeholder comments are not acceptable
5. **Validators must be flexible:** Accept constants, multiple file locations

**Model version:** 3.0.10-011

---

## DEC-032: Human Approval Checkpoint Pattern {#dec-032}

**Date:** 2026-01-27  
**Status:** ✅ Implemented  
**Category:** Orchestration, Process  
**Model Version:** 3.0.10-012

**Context:**  
During the customer-api PoC Golden Master validation, we observed that:

1. **Context compaction risk**: Long generation sessions risk mid-execution compaction, causing incomplete outputs
2. **Wasted effort**: Errors in discovery/context resolution only surface after expensive code generation
3. **No course correction**: Once generation starts, there's no opportunity to catch misunderstandings
4. **Non-determinism**: Without explicit approval, the "contract" for generation is implicit

We successfully used a two-phase pattern during the PoC:
- **Phase 1 (Planning)**: INIT → DISCOVERY → CONTEXT_RESOLUTION → Present plan for approval
- **Phase 2 (Execution)**: Human approves → GENERATION → TESTS → VALIDATION → PACKAGE

This pattern proved valuable enough to formalize as a best practice.

**Decision:**  
Introduce a mandatory **Human Approval Checkpoint** (Phase 2.7) between CONTEXT_RESOLUTION and GENERATION.

### Pattern Definition

```
PLANNING PHASES (Pre-Approval)
├── Phase 1: INIT
├── Phase 2: DISCOVERY  
├── Phase 2.5: CONTEXT_RESOLUTION
└── Phase 2.7: HUMAN APPROVAL CHECKPOINT ← NEW
    ├── Generate execution-plan.md
    ├── Present to human
    └── Await "approved" response

EXECUTION PHASES (Post-Approval)
├── Phase 3: GENERATION (3.1, 3.2, 3.3)
├── Phase 4: TESTS
├── Phase 5: TRACEABILITY
├── Phase 6: VALIDATION ASSEMBLY
└── Phase 7: PACKAGE
```

### Checkpoint Artifact

The checkpoint produces `trace/execution-plan.md` containing:
- Package metadata (ID, stack, KB version)
- Capabilities detected with modules
- Phase-by-phase file generation plan
- All resolved variables
- Explicit approval request

### Approval Protocol

| Response | Action |
|----------|--------|
| "approved", "yes", "proceed" | Continue to GENERATION |
| "rejected", "no", "cancel" | Abort generation |
| Other text | Treat as modification request, re-run discovery |

### Benefits

| Benefit | Impact |
|---------|--------|
| **Anti-Compaction** | Natural breakpoint prevents mid-generation context loss |
| **Early Validation** | Catch misunderstandings before expensive code generation |
| **Auditability** | `execution-plan.md` provides approval record |
| **Determinism** | Approved plan becomes the generation contract |
| **Resumability** | If session ends, plan can be re-submitted for continuation |

### Applicability

| Scenario | Checkpoint Required? |
|----------|---------------------|
| Interactive chat (Claude.ai) | ✅ ALWAYS |
| Automated CI/CD pipeline | ⚠️ OPTIONAL (`--auto-approve` flag) |
| Agentic orchestration | ✅ RECOMMENDED |
| Batch processing | ⚠️ Can be disabled for trusted inputs |

### Integration Points

For multi-agent or automated systems:

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│  Discovery  │────▶│  Checkpoint  │────▶│ Generation  │
│    Agent    │     │   Gateway    │     │    Agent    │
└─────────────┘     └──────────────┘     └─────────────┘
                           │
                    ┌──────┴──────┐
                    │             │
               ┌────▼────┐  ┌─────▼─────┐
               │  Human  │  │   Auto    │
               │ Approval│  │  Approve  │
               └─────────┘  │ (trusted) │
                            └───────────┘
```

Implementation options:
- **Slack/Teams**: Notification with approval buttons
- **Web UI**: Modal requiring explicit approval
- **CLI**: Interactive prompt
- **API**: Callback with manual override capability

**Files Modified:**

```
runtime/flows/code/GENERATION-ORCHESTRATOR.md
├── Version: 1.1 → 1.2
├── Orchestration Flow diagram updated
└── New section: Phase 2.7: HUMAN APPROVAL CHECKPOINT
```

**Justification:**

1. **Proven in practice**: Successfully used in customer-api PoC
2. **Low overhead**: Single checkpoint, clear approval protocol
3. **High value**: Prevents wasted generation effort
4. **Flexible**: Can be disabled for automated trusted pipelines
5. **Auditable**: Creates approval artifact for compliance

**Model version:** 3.0.10-012

---

## DEC-033: Validation Script Management (No Improvisation) {#dec-033}

**Date:** 2026-01-28  
**Status:** ✅ Implemented  
**Category:** Orchestration, Validation  
**Model Version:** 3.0.10-013

**Context:**  
During the new-chat PoC test (2026-01-27), we discovered that the chat agent **improvised validation scripts** instead of copying them from the KB. This violates DEC-025 (No Improvisation Rule).

### Observed Behavior

The chat generated 17 custom validation scripts instead of copying the existing ones:

| Expected | Actual |
|----------|--------|
| Copy `hateoas-check.sh` (~80 lines, colors, import validation) | Generated new script (~30 lines, basic) |
| Copy `systemapi-check.sh` | Created `systemapi-adapter-check.sh` (different name) |
| Copy `circuit-breaker-check.sh` | Created `circuit-breaker-annotations-check.sh` |
| Use `run-all.sh.tpl` from KB | Generated custom `run-all.sh` with `${tier^^}` (macOS incompatible) |

Scripts created by chat that don't exist in KB:
- `application-config-check.sh`
- `correlation-id-check.sh`
- `domain-api-check.sh`
- `exception-handling-check.sh`
- `field-mapping-check.sh`
- `java-version-check.sh`
- `resilience4j-check.sh`
- `spring-boot-check.sh`
- `tests-exist-check.sh`

### Root Cause Analysis

`GENERATION-ORCHESTRATOR.md` Phase 6 said "Copy Tier-X Scripts" but:
1. No prominent warning about NOT generating scripts
2. No explicit statement that improvisation is prohibited
3. The instruction was buried in pseudocode, not highlighted

### Decision

Add explicit **WARNING** at the start of Phase 6 in `GENERATION-ORCHESTRATOR.md`:

```markdown
### ⚠️ CRITICAL WARNING - DEC-033

**DO NOT GENERATE validation scripts. COPY them from the KB.**

This is a violation of DEC-025 (No Improvisation Rule). Validation scripts:
- MUST be copied from their source locations in the KB
- MUST NOT be generated or improvised
- MUST use the exact script names from the KB
- MUST preserve the full content (colors, detailed checks, import validation)

**If a validation script does not exist in the KB, it should NOT be included.**
```

### Script Location Reference

| Tier | Source Location | What to Do |
|------|-----------------|------------|
| Tier 0 | `runtime/validators/tier-0-conformance/template-conformance-check.sh` | GENERATE using template + module fingerprints |
| Tier 1 | `runtime/validators/tier-1-universal/**/*.sh` | COPY all applicable scripts |
| Tier 2 | `runtime/validators/tier-2-technology/{stack}/**/*.sh` | COPY based on stack |
| Tier 3 | `modules/{module-id}/validation/*.sh` | COPY for each module used |
| run-all.sh | `runtime/validators/run-all.sh.tpl` | COPY and replace `{{SERVICE_NAME}}` |

### Module → Script Mapping

| Module | Script(s) to Copy |
|--------|-------------------|
| mod-code-015 | `hexagonal-structure-check.sh` |
| mod-code-017 | `systemapi-check.sh` |
| mod-code-018 | `integration-check.sh` |
| mod-code-019 | `hateoas-check.sh`, `config-check.sh` |
| mod-code-001 | `circuit-breaker-check.sh` |
| mod-code-002 | `retry-check.sh` |
| mod-code-003 | `timeout-check.sh` |

### Impact

| Aspect | Before | After |
|--------|--------|-------|
| Phase 6 clarity | Implicit "copy" in pseudocode | Explicit WARNING at top |
| Script quality | Risk of improvised, basic scripts | Guaranteed use of KB scripts |
| macOS compatibility | Risk of bash 4.0+ syntax | Uses KB's POSIX-compatible scripts |
| Validation coverage | Inconsistent | Consistent with KB standards |

### Files Modified

```
runtime/flows/code/GENERATION-ORCHESTRATOR.md
├── Version: 1.2 → 1.3
├── Phase 6: Added ⚠️ CRITICAL WARNING section at top
└── Key Changes: Added DEC-033 reference
```

### Verification

After this change, a new chat executing Phase 6 should:
1. ✅ Read the WARNING before proceeding
2. ✅ COPY scripts from listed locations
3. ✅ NOT generate custom scripts
4. ✅ Use exact script names from KB
5. ✅ Preserve full script content

**Model version:** 3.0.10-013

---

## DEC-034: Validation Assembly Script (Automation) {#dec-034}

**Date:** 2026-01-28  
**Status:** ✅ Implemented  
**Category:** Orchestration, Validation, Automation  
**Model Version:** 3.0.10-014

**Context:**  
DEC-033 added a WARNING to Phase 6 instructing agents to copy validation scripts from KB instead of generating them. However, testing showed that **the WARNING was not effective** - agents continued to improvise all validation scripts.

### Problem Evidence (PoC 2026-01-28)

Despite the explicit WARNING in Phase 6:
- 100% of validation scripts were improvised
- Scripts with matching names had completely different content
- Wrong tier assignments (hexagonal-structure-check.sh in tier-2 instead of tier-3)
- Missing scripts from KB (integration-check.sh, config-check.sh, etc.)

Example comparison of `naming-conventions-check.sh`:

| Aspect | KB Version | Improvised Version |
|--------|------------|-------------------|
| Shebang | `#!/bin/sh` (POSIX) | `#!/bin/bash` |
| Lines | ~60 | ~25 |
| Functions | `pass()`, `fail()`, `warn()` | None |
| Output | Structured with colors | Basic echo |

### Root Cause

Text-based warnings are not enforceable. The agent:
1. Reads the warning
2. Understands the intent
3. Still improvises because it's "easier" than navigating KB paths

### Solution

Create an **executable script** that the agent MUST run instead of manually copying files.

```bash
runtime/validators/assemble-validation.sh <validation-dir> <service-name> <stack> <module-1> [module-2] ...
```

The script:
1. Takes modules discovered in Phase 2 as input
2. Automatically copies scripts from correct KB locations
3. Handles path resolution (module names with suffixes like `-java-resilience4j`)
4. Configures `run-all.sh` with variable substitution
5. Sets executable permissions

### Additional Fix: Consolidate Duplicate Folders

Eliminated confusion between two similar folders:

| Before | After |
|--------|-------|
| `runtime/validators/` | `runtime/validators/` ✅ (kept) |
| `runtime/validation/` | (deleted) |

Moved `runtime/validation/scripts/tier-0/package-structure-check.sh` → `runtime/validators/tier-0-conformance/`

### Files Changed

```
NEW:
  runtime/validators/assemble-validation.sh

UPDATED:
  runtime/flows/code/GENERATION-ORCHESTRATOR.md (v1.3 → v1.4)
    - Phase 6: Replaced WARNING with MANDATORY script execution
    - Key Changes: Added DEC-034 reference

MOVED:
  runtime/validation/scripts/tier-0/package-structure-check.sh
    → runtime/validators/tier-0-conformance/package-structure-check.sh

DELETED:
  runtime/validation/ (entire folder - was duplicate/confusing)
```

### Usage in Phase 6

```bash
# Agent MUST execute this command, not manually copy scripts
./runtime/validators/assemble-validation.sh \
    "${PACKAGE_DIR}/validation" \
    "${SERVICE_NAME}" \
    "${STACK}" \
    mod-code-015 mod-code-017 mod-code-018 mod-code-019 \
    mod-code-001 mod-code-002 mod-code-003
```

### Expected Outcome

| Aspect | Before (DEC-033) | After (DEC-034) |
|--------|------------------|-----------------|
| Agent action | Read warning, ignore it | Execute script |
| Script source | Improvised | Copied from KB |
| Tier assignment | Often wrong | Automatic/correct |
| Missing scripts | Common | None (script handles all) |
| Consistency | Variable | Guaranteed |

### Verification

After running `assemble-validation.sh`, the `validation/` directory should contain:
- Tier-0: 2 scripts (template-conformance-check.sh, package-structure-check.sh)
- Tier-1: 3 scripts (naming-conventions, project-structure, traceability)
- Tier-2: 5+ scripts (compile, syntax, application-yml, etc.)
- Tier-3: N scripts (one per module with validation/*.sh)

**Model version:** 3.0.10-014

---

## DEC-035: Config Flags Pub/Sub Pattern {#dec-035}

**Fecha:** 2026-02-03  
**Estado:** ✅ Aprobado  
**Versión modelo:** 3.0.11

### Contexto

Feature modules need to influence code generation in core modules without tight coupling. Example: mod-019 (HATEOAS) needs mod-015's `Response.java` to extend `RepresentationModel` instead of being a record.

**The problem:**
- mod-015 generates `Response.java` (core)
- mod-019 activates HATEOAS feature
- Both modules are in Phase 1 (STRUCTURAL)
- No explicit mechanism for mod-019 to influence mod-015's output

**Previous attempts:**
- Template priority by module number (arbitrary, doesn't scale)
- Duplicate templates in feature modules (duplication, maintenance burden)

### Decisión

Implement a **Publish/Subscribe model for config flags**:

1. **Publishers** (feature capabilities) declare flags they activate
2. **Subscribers** (core modules/templates) declare which flags affect their behavior
3. Flags propagate through `generation-context.json`
4. Templates use conditional logic based on flags

### Modelo Pub/Sub

```
┌─────────────────────────────────────────────────────────────────────┐
│                     CONFIG FLAGS REGISTRY                           │
├─────────────────────────────────────────────────────────────────────┤
│  Flag              │ Publishers         │ Subscribers              │
├────────────────────┼────────────────────┼──────────────────────────┤
│  hateoas           │ mod-019            │ mod-015 (Response.tpl)   │
│  pagination        │ mod-019            │ mod-015 (Controller.tpl) │
│  jpa               │ mod-016            │ mod-015 (Entity.tpl)     │
│  systemapi         │ mod-017            │ mod-015 (Repository.tpl) │
│  circuit-breaker   │ mod-001            │ mod-017 (Adapter.tpl)    │
└─────────────────────────────────────────────────────────────────────┘
```

### Sintaxis

**Publisher (capability-index.yaml):**
```yaml
api-architecture:
  features:
    domain-api:
      module: mod-code-019-api-public-exposure-java-spring
      publishes_flags:
        hateoas: true
        pagination: true
```

**Subscriber (MODULE.md):**
```yaml
subscribes_to_flags:
  - flag: hateoas
    affects:
      - templates/application/dto/Response.java.tpl
    behavior: |
      true  → class extends RepresentationModel
      false → record (immutable DTO)
```

**Template conditional:**
```java
{{#config.hateoas}}
public class {{Entity}}Response extends RepresentationModel<{{Entity}}Response> {
{{/config.hateoas}}
{{^config.hateoas}}
public record {{Entity}}Response(
{{/config.hateoas}}
```

**Runtime (generation-context.json):**
```json
{
  "config_flags": {
    "hateoas": true,
    "pagination": true
  }
}
```

### Beneficios de Governance

1. **Visibilidad**: Query todas las relaciones pub/sub
2. **Análisis de impacto**: "Si activo mod-019, ¿qué templates cambian?"
3. **Validación**: Detectar flags huérfanos o sin publisher
4. **Documentación**: Generar matriz de dependencias automáticamente

### Documentos Actualizados

| Documento | Cambio |
|-----------|--------|
| `model/ENABLEMENT-MODEL-v3.0.md` | Nueva sección: Config Flags Pub/Sub |
| `model/standards/authoring/CAPABILITY.md` | Atributo: `publishes_flags` |
| `model/standards/authoring/MODULE.md` | Sección: `subscribes_to_flags` |
| `capability-index.yaml` | mod-019 publica `hateoas` |
| `mod-015/MODULE.md` | Suscribe a `hateoas` |
| `mod-015/Response.java.tpl` | Condicional en `config.hateoas` |

### Justificación

- **Desacoplamiento**: Modules no se conocen, solo flags
- **Escalabilidad**: Nuevos flags sin modificar código existente
- **Governance**: Relaciones explícitas y auditables
- **Simplicidad**: Un template por artifact, lógica condicional interna

**Modelo version:** 3.0.11

---

## DEC-036: Explicit Template Output Paths {#dec-036}

**Fecha:** 2026-02-03  
**Estado:** Implementado  
**Contexto:** Orchestration Session - E2E Validation

### Problema

Template output paths using `...` (e.g., `{{basePackagePath}}/.../Application.java`) caused:
1. Manifest checker couldn't resolve expected file paths
2. False warnings about "missing" files that were actually generated
3. Reduced governance visibility

### Decisión

All template `// Output:` comments must use **explicit, resolvable paths**:

| Before (ambiguous) | After (explicit) |
|--------------------|------------------|
| `{{basePackagePath}}/.../Application.java` | `{{basePackagePath}}/{{ServiceName}}Application.java` |
| `{{basePackagePath}}/.../CreateRequest.java` | `{{basePackagePath}}/application/dto/Create{{Entity}}Request.java` |
| `{{basePackagePath}}/.../application.yml` | `src/main/resources/application.yml` |

### Variables Soportadas por Manifest Checker

| Variable | Resolución |
|----------|------------|
| `{{basePackagePath}}` | `com/bank/customer` |
| `{{Entity}}` | `Customer` |
| `{{entity}}` | `customer` |
| `{{ServiceName}}` | `CustomerApi` |
| `{{entityPlural}}` | `customers` |

### Justificación

- **Governance**: Manifest checker validates 100% of expected outputs
- **Determinism**: Clear contract between template and generated file
- **Debugging**: Easy to trace which template produces which file

**Modelo version:** 3.0.12

---

## DEC-037: Mandatory Enum Generation Rule {#dec-037}

**Fecha:** 2026-02-03  
**Estado:** Implementado  
**Contexto:** Compilation failure due to missing `CustomerStatus.java`

### Problema

LLM generated code referencing `CustomerStatus` enum type but didn't generate the enum file, causing 13 compilation errors.

### Decisión

Added **CRITICAL rule** to CodeGen prompt:

> "If ANY field uses an Enum type (e.g., CustomerStatus, OrderType), you MUST generate the enum file using `Enum.java.tpl`."

### Regla en Prompt

```
## CRITICAL: Enum Generation

If ANY field uses an Enum type, you MUST generate the enum file.
Use Enum.java.tpl from mod-015:
- Output path: {{basePackagePath}}/domain/model/{{EnumName}}.java

Example: If Customer has field `status` of type `CustomerStatus`, 
generate CustomerStatus.java with values: ACTIVE, INACTIVE, SUSPENDED, PENDING

Rule: Never reference an enum type without generating its definition file.
```

### Justificación

- **Compilation guarantee**: All referenced types must exist
- **Explicit instruction**: LLM needs clear directive for dynamic artifacts
- **Fail-fast**: Better to over-generate than compile-fail

**Modelo version:** 3.0.12

---

## DEC-038: Traceability Manifest Structure {#dec-038}

**Fecha:** 2026-02-03  
**Estado:** Implementado  
**Contexto:** traceability-check.sh failing on valid manifests

### Problema

Validator expected old manifest structure (`service`, `generator`, `capabilities`) but actual manifests use new structure (`generation`, `enablement`, `modules`).

### Decisión

Align validator with actual manifest structure produced by orchestration:

**Expected Manifest Structure:**
```json
{
  "generation": {
    "id": "uuid",
    "timestamp": "ISO-8601",
    "service_name": "customer-api"
  },
  "enablement": {
    "version": "3.0.x",
    "domain": "code",
    "flow": "flow-generate"
  },
  "modules": [
    {"id": "mod-xxx", "capability": "...", "phase": 1}
  ],
  "status": {
    "generation": "SUCCESS",
    "validation": "PENDING"
  },
  "metrics": {
    "files_generated": 34,
    "test_files": 7
  }
}
```

### Validator Checks (Updated)

| Check | Field | Required |
|-------|-------|----------|
| Generation info | `generation` | ✅ Yes |
| Enablement info | `enablement` | ✅ Yes |
| Module list | `modules` | ⚠️ Warn |
| Status | `status` | ⚠️ Warn |
| Service name | `generation.service_name` | ⚠️ Warn |
| Version | `enablement.version` | ⚠️ Warn |
| Timestamp | `generation.timestamp` | ⚠️ Warn |

### Justificación

- **Consistency**: Validator matches actual output
- **Single source of truth**: Orchestration defines structure, validators follow
- **Backward compatibility**: Warns but doesn't fail on optional fields

**Modelo version:** 3.0.12

---

## DEC-039: Phase 2 Reproducibility Rules {#dec-039}

**Fecha:** 2026-02-03  
**Estado:** Implementado  
**Contexto:** Analysis of 3 E2E runs showed cosmetic variations in Phase 2 files

### Problema

Phase 2 (SystemAPI) files showed variations across runs:

| Variation Type | Example | Impact |
|----------------|---------|--------|
| Trailing newlines | Run06 missing final `\n` | Cosmetic |
| Helper methods | `toUppercase()` vs inline null checks | Structural |
| Unicode in comments | `↔` vs `<->` | Cosmetic |

### Decisión

Implement three-pronged approach:

#### 1. Post-Processing (Orchestration)
```python
# Ensure content ends with exactly one newline
normalized_content = content.rstrip() + '\n'
```

#### 2. Prompt Rules (CodeGen)
```
## CRITICAL: Code Style Consistency

### 1. Trailing Newlines
- Every file MUST end with exactly ONE newline

### 2. Helper Methods Style
- ALWAYS create private helper methods for null-safe transformations
- Use EXACT names: toUpperCase(), toLowerCase(), toProperCase()

### 3. ASCII Only in Comments
- Use <-> for bidirectional arrows, NOT ↔
```

#### 3. Template Cleanup (KB)
- Replace all Unicode arrows in templates with ASCII equivalents

### Análisis de Variaciones

**Before DEC-039:**
| File | Run05 | Run06 | Run07 |
|------|-------|-------|-------|
| CustomerSystemApiMapper.java | 189 | 174 | 184 |
| CustomerSystemApiAdapter.java | 68 | 67 | 68 |

**Expected After DEC-039:**
- Trailing newlines: 100% consistent
- Helper methods: 100% consistent (always use helpers)
- Unicode: 100% consistent (ASCII only)

### Archivos Modificados

**Orchestration:**
- `scripts/run-codegen.sh` - Added style rules + trailing newline normalization

**KB Templates:**
- `mod-001/templates/annotation/chain-fallback.java.tpl`
- `mod-015/templates/application/dto/Response.java.tpl`
- `mod-015/templates/domain/Entity.java.tpl`
- `mod-017/templates/mapper/SystemApiMapper.java.tpl`

### Justificación

- **Determinism**: Reduce LLM interpretation variance
- **Diff-friendly**: Consistent outputs for code review
- **CI/CD**: Reproducible builds across environments

**Modelo version:** 3.0.13

---

## DEC-040: HTTP Client Variant Selection {#dec-040}

**Fecha:** 2026-02-04  
**Estado:** ✅ Implementado

**Contexto:**  
mod-017 tiene 3 templates de cliente HTTP (`feign.java.tpl`, `restclient.java.tpl`, `resttemplate.java.tpl`) todos declarando el mismo output path (`{{Entity}}SystemApiClient.java`). El LLM debería elegir uno, pero en pruebas de reproducibilidad (Run 03 del 2026-02-04), generó los tres con nombres diferentes.

### Problema

| Run | Files | Extra Files |
|-----|-------|-------------|
| 01 | 32 | - |
| 02 | 32 | - |
| 03 | 34 | `CustomerSystemApiRestClient.java`, `CustomerSystemApiRestTemplateClient.java` |

El LLM interpretó que debía generar implementaciones alternativas cuando solo debe usar UNA.

### Decisión

Implementar **variant selection via Config Flags**:

1. `persistence.systemapi` publica flag `http_client: restclient` (default)
2. Templates declaran `// Variant: <variant_name>`
3. CodeGen filtra templates que no coincidan con la variante activa

### Implementación

**1. capability-index.yaml** (KB):
```yaml
persistence:
  features:
    systemapi:
      publishes_flags:
        http_client: restclient  # Options: restclient, feign, resttemplate
```

**2. run-codegen.sh** (Orchestration):
```python
# Get variant from config_flags
http_client_variant = config_flags.get('http_client', 'restclient')

# Filter templates by variant
variant_match = re.search(r'// Variant:\s*(\w+)', content)
if variant_match:
    if variant_match.group(1).lower() != http_client_variant.lower():
        continue  # Skip non-matching variant
```

**3. Templates** (already have header):
```java
// Template: restclient.java.tpl
// Output: {{basePackage}}/adapter/out/systemapi/client/{{Entity}}SystemApiClient.java
// Variant: restclient
```

### Variantes Disponibles

| Variant | Template | Dependencies | Notes |
|---------|----------|--------------|-------|
| `restclient` | restclient.java.tpl | None (Spring 6.1+) | **DEFAULT** |
| `feign` | feign.java.tpl | spring-cloud-starter-openfeign | Declarative |
| `resttemplate` | resttemplate.java.tpl | None | Legacy/deprecated |

### Uso

Para cambiar la variante, el usuario puede:
1. Modificar el prompt: "use Feign for HTTP client"
2. Modificar discovery-result.json manualmente
3. (Futuro) Añadir UI para selección de variantes

### Resultado Esperado

- Solo 1 template de cliente incluido en el prompt
- 100% reproducible (32 files en todos los runs)
- Extensible a otras variantes (e.g., WebClient reactivo)

**Modelo version:** 3.0.14

---

## DEC-041: Module Variants vs Config Flags {#dec-041}

**Fecha:** 2026-02-04  
**Estado:** ✅ Aprobado

**Contexto:**  
DEC-040 introdujo `http_client` como "config flag" publicado por `persistence.systemapi`. Pero surgió la pregunta: ¿cómo puede el usuario sobrescribir este valor vía prompt? La solución inicial (Discovery extrae override) era un parche que mezclaba conceptos.

### Problema Conceptual

El modelo de Config Flags (DEC-035) define:
- **Productor**: Capability que publica un flag
- **Consumidor**: Módulo que reacciona al flag

Pero `http_client` no encaja:
- No es una "capacidad activa" (hateoas, pagination)
- Es una "elección de implementación" dentro de un módulo
- El dueño natural es el módulo, no la capability

### Distinción: Config Flags vs Variants

| Aspecto | Config Flag | Variant |
|---------|-------------|---------|
| **Semántica** | ¿Está activa esta capacidad? | ¿Qué implementación usar? |
| **Definido en** | capability-index.yaml | MODULE.md |
| **Producido por** | Capability activa | Usuario (prompt) o default |
| **Consumido por** | Otros módulos suscritos | El propio módulo |
| **Ejemplo** | `hateoas: true` | `http_client: feign` |

### Decisión

Separar los conceptos:

1. **Config Flags** - Cross-module influence (sin cambios)
   ```
   Capability A activa → publica flag → Module B reacciona
   ```

2. **Module Variants** - Intra-module configuration (NUEVO)
   ```
   Module define opciones → User selecciona (o default) → Module usa
   ```

### Modelo de Variants

**Definición en MODULE.md:**
```yaml
# En frontmatter o sección dedicada
variants:
  http_client:
    description: "HTTP client implementation"
    default: restclient
    options:
      restclient:
        description: "Spring 6.1+ RestClient"
        templates: [client/restclient.java.tpl]
        keywords: [restclient, "rest client"]
      feign:
        description: "OpenFeign declarative client"  
        templates: [client/feign.java.tpl, config/feign-config.java.tpl]
        keywords: [feign, openfeign, declarative]
      resttemplate:
        description: "Legacy RestTemplate"
        templates: [client/resttemplate.java.tpl]
        keywords: [resttemplate, legacy]
```

**Flujo de selección:**
```
1. Discovery detecta módulo + analiza prompt para keywords de variante
2. Discovery output: variant_selections: { "mod-017.http_client": "feign" }
3. Context Agent resuelve: usa selection o default del MODULE.md
4. CodeGen filtra templates por variante activa
```

### Migración de DEC-040

- ELIMINAR: `publishes_flags.http_client` de capability-index
- AÑADIR: `variants.http_client` en MODULE.md de mod-017
- ACTUALIZAR: Discovery Agent para detectar variant keywords
- MANTENER: Filtrado por `// Variant:` en CodeGen (ya implementado)

### Beneficios

1. **Claridad** - Cada concepto tiene su lugar
2. **Ownership** - Módulo define sus propias variantes
3. **Escalable** - Nuevos módulos añaden variantes sin tocar modelo global
4. **Discoverable** - Catálogo en MODULE.md, visible para el usuario
5. **Validable** - Solo opciones definidas son válidas

### Ejemplos de Uso

**Prompt del usuario:**
```
Necesito una Customer API con integración a System API usando Feign client
```

**Discovery detecta:**
- Capability: persistence.systemapi → mod-017
- Variant keyword: "feign" → mod-017.http_client = feign

**Sin mención en prompt:**
- Usa default de MODULE.md: restclient

**Modelo version:** 3.0.15

---

## DEC-042: Stack-Specific Style Files {#dec-042}

**Fecha:** 2026-02-04  
**Estado:** ✅ Implementado

**Contexto:**  
Las Code Style Guidelines en MODULE.md (DEC-041) no se seguían consistentemente por el LLM. En pruebas, 4/5 runs usaron UUID en lugar de String para IDs en DTOs, a pesar de la documentación.

### Problema

| Ubicación | Efectividad | Motivo |
|-----------|-------------|--------|
| MODULE.md | ~80% | LLM puede ignorar documentación |
| Prompt CodeGen (hardcoded) | ~95% | Pero agente pierde agnóstico |
| Template hardcoded | 100% | Pero inflexible |

### Decisión

Crear **Stack-Specific Style Files** que se cargan dinámicamente según el stack detectado:

```
KB/
└── runtime/
    └── codegen/
        └── styles/
            ├── java-spring.style.md   ← Reglas Java/Spring
            └── nodejs.style.md        ← Futuro
```

### Flujo

```
1. Discovery detecta stack: java-springboot
         │
         ▼
2. CodeGen carga: runtime/codegen/styles/java-spring.style.md
         │
         ▼
3. Contenido se inyecta en prompt (reemplaza {{STYLE_RULES}})
         │
         ▼
4. LLM sigue reglas con alta fidelidad
```

### Contenido del Style File

El fichero `java-spring.style.md` incluye reglas para:

1. **DTOs** - `String` para IDs, factory method `from(entity)`
2. **Mappers** - Helper methods con nombres exactos, orden alfabético
3. **General** - Trailing newlines, ASCII only en comentarios
4. **Tests** - Consistencia en setup, uso de String para IDs
5. **Application Services** - Uso de factory methods, no @Transactional con System API

### Implementación

**KB:**
- Nuevo directorio: `runtime/codegen/styles/`
- Nuevo fichero: `java-spring.style.md`

**Orchestration (run-codegen.sh):**
```bash
# Load style file based on stack
STACK=$(python3 -c "..." || echo "java-spring")
STYLE_FILE="${KB_DIR}/runtime/codegen/styles/${STACK}.style.md"

# Inject into prompt
content.replace('{{STYLE_RULES}}', style_content)
```

### Beneficios

| Aspecto | Resultado |
|---------|-----------|
| Agente agnóstico | ✅ Solo carga fichero según stack |
| Efectividad | Alta (en prompt, no en docs) |
| Mantenibilidad | Fichero separado en KB |
| Extensibilidad | Añadir nuevos stacks fácilmente |
| Trazabilidad | Log indica qué style file se usó |

### Relación con MODULE.md

- **MODULE.md** = Documentación para humanos + referencia
- **style.md** = Reglas para LLM (se inyectan en prompt)

Las reglas pueden duplicarse, pero el style file es la fuente autoritativa para el LLM.

**Modelo version:** 3.0.16

---

## DEC-043: Phase 3 Timeout Coherence Fixes {#dec-043}

**Fecha:** 2026-02-05  
**Estado:** ✅ Implementado

**Contexto:**  
Tras la primera ejecución E2E exitosa con Phase 3 (Transform Agent, ODEC-022), se detectaron 3 incoherencias entre el modelo de dos capas de timeout (DEC-028) y la implementación real.

### Problemas Detectados

#### Issue 1: RestClientConfig.java no se genera

**Síntoma:** mod-003 transform descriptor apunta a `**/infrastructure/config/RestClientConfig.java`, pero este archivo no existe en el output generado.

**Causa:** mod-018 tiene el template `config/restclient-config.java.tpl` (con `RestClientConfig` y timeouts 30s/60s), pero el CodeGen no lo genera. Probablemente filtrado por variant o no incluido en el scope de Phase 2.

**Impacto:** El descriptor de mod-003 no encuentra su target → no puede modificar los timeouts de infraestructura a valores de resiliencia.

**Fix:** Verificar que `restclient-config.java.tpl` de mod-018 se incluye en la generación de Phase 2 cuando la variante es `restclient`. Si se genera correctamente, mod-003 podrá transformar los valores de 30s/60s → 5s/5s.

#### Issue 2: application-systemapi.yml incluye sección timelimiter

**Síntoma:** `application-systemapi.yml` generado en Phase 2 contiene:
```yaml
resilience4j:
  timelimiter:
    instances:
      customer-api:
        timeoutDuration: 10s
        cancelRunningFuture: true
```

**Causa:** El template `application-systemapi.yml.tpl` de mod-017 incluye incondicionalmente la sección `timelimiter`. Esta configuración es de la variante `annotation-async` de mod-003, no de `client-timeout`.

**Impacto:** Configuración de resiliencia innecesaria/confusa. `timelimiter` no tiene efecto sin `@TimeLimiter` annotations, pero genera ruido y puede confundir.

**Fix:** Condicionar la sección `timelimiter` en el template de mod-017 a un flag, o eliminarla del template de Phase 2 y que sea mod-003 quien la añada en Phase 3 solo si la variante es `annotation-async`.

#### Issue 3: application-systemapi.yml incluye resilience4j completo

**Síntoma:** El mismo template incluye circuitbreaker y retry config que Phase 3 (mod-001, mod-002) también genera vía transform → posible duplicación/conflicto.

**Causa:** `application-systemapi.yml.tpl` fue creado antes del modelo de fases (DEC-028). Asume que toda la config de resiliencia va junto con la config de System API.

**Impacto:** Duplicación de configuración entre Phase 2 (`application-systemapi.yml`) y Phase 3 (`application.yml`). En el output actual hay dos definiciones de circuitbreaker y retry.

**Fix:** Limpiar `application-systemapi.yml.tpl` de mod-017 para que solo contenga:
- Configuración de conectividad (`system-api.{serviceName}.base-url`)
- Logging
- (Opcional) Config de Feign si aplica

La configuración de `resilience4j.*` debe generarse exclusivamente en Phase 3 por los módulos de resiliencia correspondientes.

### Plan de Implementación

| # | Fix | Módulo | Impacto |
|---|-----|--------|---------|
| 1 | Asegurar generación de RestClientConfig.java | mod-018 | CodeGen Phase 2 |
| 2 | Limpiar application-systemapi.yml.tpl | mod-017 | Eliminar resilience4j.* |
| 3 | Validar mod-003 descriptor funciona con target real | mod-003 | Transform Phase 3 |

### Modelo de Timeout Correcto (DEC-028 recordatorio)

```
Phase 2 (mod-018):
  RestClientConfig.java → connect: 30s, read: 60s (protección infraestructura)
  application-systemapi.yml → SOLO config de conectividad, NO resilience

Phase 3 (mod-003, variante client-timeout):
  TRANSFORMA RestClientConfig.java → connect: 5s, read: 5s (resiliencia)
  MERGE application.yml → integration.timeout.connect: 5s, read: 5s

Phase 3 (mod-003, variante annotation-async, SI se selecciona):
  AÑADE @TimeLimiter a métodos async
  MERGE application.yml → resilience4j.timelimiter config
```

**Modelo version:** 3.0.17

---

## DEC-044: Template Stack Version Compatibility {#dec-044}

**Fecha:** 2026-02-05  
**Estado:** 🟡 Decisión pendiente (documentada para futuro)

**Contexto:**  
Los templates (.tpl) de los modules están escritos para un stack tecnológico concreto (actualmente Java 17 + Spring Boot 3.2.x). Contienen imports, annotations y patrones que son específicos de esa versión. Ejemplos:

- `@MockBean` de `org.springframework.boot.test.mock.mockito` → deprecated en Spring Boot 3.4, reemplazado por `@MockitoBean` de `org.springframework.test.context.bean.override.mockito`
- `RestClient` (Spring 6.1+) vs `RestTemplate` (legacy) vs `FeignClient`
- Annotation patterns que cambian entre versiones mayores

**Problema:**  
No existe un mecanismo formal para:
1. Declarar qué versión de stack soporta un module/template
2. Que el Discovery valide compatibilidad entre el stack solicitado en el prompt y los templates disponibles
3. Mantener múltiples versiones de templates para diferentes stacks

**Impacto actual:** Bajo — toda la PoC asume Spring Boot 3.2.x y funciona. Pero es deuda técnica que crecerá al soportar nuevos stacks o versiones.

**Dirección futura (no implementar ahora):**

```
capability-index.yaml:
  persistence:
    features:
      systemapi:
        implementations:
          - id: java-spring-3.2
            module: mod-code-017-persistence-systemapi
            stack: java-spring
            stack_version: ">=3.0 <3.4"
          - id: java-spring-3.4
            module: mod-code-017-persistence-systemapi-v34
            stack: java-spring
            stack_version: ">=3.4"
```

```
Discovery flow:
  1. Prompt: "Spring Boot 3.4"
  2. Discovery: stack=java-spring, version=3.4
  3. Module selection: filtrar implementations por stack_version compatible
  4. Si no hay compatible → ERROR con mensaje claro
```

**Decisión:** Documentar como deuda técnica. No implementar hasta que se necesite soportar un segundo stack o versión mayor. Mientras tanto, asumir Spring Boot 3.2.x en todos los templates.

**Modelo version:** 3.0.18

---

## DEC-045: Test Generation Strategy — Templates vs LLM {#dec-045}

**Fecha:** 2026-02-05  
**Estado:** 🟡 Decisión pendiente (evaluar en futuro)

**Contexto:**  
Análisis de reproducibilidad sobre 6 runs E2E muestra que los archivos de test tienen la mayor varianza (6/6 versiones diferentes en algunos casos), mientras que el código de producción es más estable.

**Evidencia (6 runs):**

| Categoría | Archivos | Estabilidad |
|-----------|----------|-------------|
| Infrastructure/Config | 12 | 100% idénticos |
| Domain/Application | 11 | 2-3 versiones |
| **Tests** | 9 | 4-6 versiones |

**Archivos de test con alta varianza:**
- `CustomerControllerTest.java` — 6 versiones
- `CustomerControllerHateoasTest.java` — 6 versiones  
- `CustomerSystemApiAdapterTest.java` — 6 versiones
- `CustomerIdTest.java` — 5 versiones
- `CustomerTest.java` — 5 versiones

**Observación:** Aunque hay varianza, todos los runs compilan y pasan tests. La varianza es cosmética (nombres de métodos, orden de setup, estilo de assertions), no funcional.

**Opciones futuras:**

1. **Mantener LLM generation** (actual) — Acepta varianza cosmética, tests funcionalmente equivalentes
2. **Templates para tests** — Mayor determinismo pero más rigidez y mantenimiento
3. **Híbrido** — Templates para estructura base, LLM para assertions específicas

**Decisión:** No actuar ahora. La varianza en tests no impacta funcionalidad ni cobertura. Reevaluar si:
- La varianza causa problemas en CI/CD (flaky tests)
- Se necesita comparar outputs entre runs para auditoría
- El equipo reporta confusión por tests diferentes

**Modelo version:** 3.0.19
