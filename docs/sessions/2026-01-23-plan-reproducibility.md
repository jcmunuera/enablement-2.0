# Plan: Modelo v3.0 - Reproducibilidad y Testing

## Fecha: 2026-01-23
## Objetivo: Permitir pruebas determinísticas en chat y con agentes

---

## CONTEXTO

### Situación Actual
- El modelo v3.0 eliminó skills → discovery es capability → feature → module
- Los flows documentan procesos pero no definen completamente el output
- No hay especificación clara de qué debe producir una generación
- Los módulos no generan tests automáticamente
- Los scripts de validación no se incluyen en el paquete generado

### Objetivo Final
Un agente (o sesión de chat) que:
1. Lee el modelo (capability-index, flows, modules)
2. Recibe un prompt
3. Produce un paquete determinístico y validable
4. El paquete es comparable con una referencia (golden master)

---

## ARQUITECTURA CONCEPTUAL

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              MODELO v3.0                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐                   │
│  │   DISCOVERY  │    │    FLOWS     │    │   MODULES    │                   │
│  ├──────────────┤    ├──────────────┤    ├──────────────┤                   │
│  │ capability-  │    │ flow-generate│    │ mod-015      │                   │
│  │ index.yaml   │    │ flow-transform    │ mod-017      │                   │
│  │              │    │ (+ output specs)  │ mod-019      │                   │
│  │ discovery-   │    │              │    │ ...          │                   │
│  │ guidance.md  │    │              │    │              │                   │
│  └──────────────┘    └──────────────┘    └──────────────┘                   │
│         │                   │                   │                            │
│         └───────────────────┼───────────────────┘                            │
│                             ▼                                                │
│                    ┌──────────────┐                                          │
│                    │  VALIDATORS  │                                          │
│                    ├──────────────┤                                          │
│                    │ tier-1 (univ)│                                          │
│                    │ tier-2 (tech)│                                          │
│                    │ tier-3 (mod) │                                          │
│                    └──────────────┘                                          │
│                                                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                           EJECUTORES                                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────────────────┐         ┌──────────────────────┐                  │
│  │   AGENTE (target)    │         │   CHAT (testing)     │                  │
│  ├──────────────────────┤         ├──────────────────────┤                  │
│  │ Orquestador Python   │         │ Claude leyendo flows │                  │
│  │ Agentes especializados         │ Ejecución manual     │                  │
│  │ Lógica interna       │         │ Simula orquestación  │                  │
│  └──────────────────────┘         └──────────────────────┘                  │
│            │                                 │                               │
│            └─────────────┬───────────────────┘                               │
│                          ▼                                                   │
│                 ┌──────────────┐                                             │
│                 │   OUTPUT     │                                             │
│                 │   PACKAGE    │                                             │
│                 │ (determinístico)                                           │
│                 └──────────────┘                                             │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## PLAN DE MODIFICACIONES

### FASE 1: Correcciones Inmediatas
**Objetivo:** Eliminar referencias a "skill", alinear con modelo v3.0

| # | Archivo | Acción | Prioridad |
|---|---------|--------|-----------|
| 1.1 | `runtime/flows/OUTPUT-PACKAGE-SPEC.md` | Renombrar a `flow-generate-output.md`, eliminar "skill" del manifest | ALTA |
| 1.2 | `runtime/flows/GENERATION-ORCHESTRATOR.md` | Eliminar referencias a "skill" | ALTA |
| 1.3 | `runtime/schemas/trace/manifest.schema.json` | Reemplazar "skill" por "enablement" + "capabilities" | ALTA |
| 1.4 | `runtime/flows/code/flow-generate.md` | Añadir referencia a `flow-generate-output.md` | ALTA |
| 1.5 | `docs/sessions/2026-01-23-gap-analysis-reproducibility.md` | Corregir referencias a skill | MEDIA |

**Cambio en manifest.json:**
```json
// ANTES (incorrecto - usa skill)
{
  "skill": {
    "id": "skill-code-001-...",
    "version": "3.0.6"
  }
}

// DESPUÉS (correcto - usa enablement + capabilities)
{
  "enablement": {
    "version": "3.0.6",
    "domain": "code",
    "flow": "flow-generate"
  },
  "discovery": {
    "capabilities": ["architecture.hexagonal-light", "api-architecture.domain-api"],
    "features": ["hexagonal-light", "domain-api", "systemapi"],
    "stack": "java-spring"
  },
  "modules": [...]
}
```

---

### FASE 2: Estructura de Output por Flow
**Objetivo:** Definir output específico para cada flow

| # | Archivo | Acción | Prioridad |
|---|---------|--------|-----------|
| 2.1 | `runtime/flows/code/flow-generate-output.md` | Crear (renombrar de OUTPUT-PACKAGE-SPEC) | ALTA |
| 2.2 | `runtime/flows/code/flow-transform-output.md` | Crear placeholder | BAJA |
| 2.3 | `runtime/flows/OUTPUT-COMMON.md` | Crear elementos comunes (trace, validation) | MEDIA |

**Estructura propuesta:**
```
runtime/flows/
├── OUTPUT-COMMON.md                 # Elementos comunes a todos los flows
│   - Formato de trace/
│   - Formato de validation/
│   - Naming conventions
│
└── code/
    ├── flow-generate.md             # Proceso de generación
    ├── flow-generate-output.md      # Output específico para generate
    │   - Estructura: input/ output/ trace/ validation/
    │   - Contenido de cada directorio
    │
    ├── flow-transform.md            # Proceso de transformación
    └── flow-transform-output.md     # Output específico (futuro)
        - Estructura: puede ser diff o proyecto completo
```

---

### FASE 3: Schemas de Trazabilidad
**Objetivo:** Schemas JSON para validación automática de trazas

| # | Archivo | Acción | Prioridad |
|---|---------|--------|-----------|
| 3.1 | `runtime/schemas/trace/manifest.schema.json` | Actualizar (ya existe, corregir) | ALTA |
| 3.2 | `runtime/schemas/trace/discovery-trace.schema.json` | Crear | ALTA |
| 3.3 | `runtime/schemas/trace/generation-trace.schema.json` | Crear | ALTA |
| 3.4 | `runtime/schemas/trace/modules-used.schema.json` | Crear | MEDIA |
| 3.5 | `runtime/schemas/validation/validation-results.schema.json` | Crear | MEDIA |

---

### FASE 4: Tests en Módulos
**Objetivo:** Cada módulo define qué tests genera

| # | Módulo | Acción | Prioridad |
|---|--------|--------|-----------|
| 4.1 | `mod-code-015-hexagonal-base` | Añadir `templates/test/` con tests de domain | ALTA |
| 4.2 | `mod-code-017-persistence-systemapi` | Añadir `templates/test/` con tests de adapter | ALTA |
| 4.3 | `mod-code-019-api-public-exposure` | Añadir `templates/test/` con tests de controller | MEDIA |
| 4.4 | `mod-code-001/002/003` (resilience) | Añadir tests de anotaciones | MEDIA |

**Estructura por módulo:**
```
modules/mod-code-015-hexagonal-base-java-spring/
├── MODULE.md
├── templates/
│   ├── domain/
│   │   ├── Entity.java.template
│   │   └── ...
│   └── test/                        # NUEVO
│       ├── EntityTest.java.template
│       └── EntityIdTest.java.template
└── validation/
    └── hexagonal-structure-check.sh
```

**Documentar en MODULE.md:**
```markdown
## Tests Generated

| Test File | Description | Pattern |
|-----------|-------------|---------|
| `{Entity}Test.java` | Domain entity unit tests | Factory methods, domain behavior |
| `{Entity}IdTest.java` | Value object tests | Equality, creation |
```

---

### FASE 5: Validadores
**Objetivo:** Asegurar que todos los validadores están en KB y se copian correctamente

| # | Archivo | Acción | Prioridad |
|---|---------|--------|-----------|
| 5.1 | `runtime/validators/README.md` | Documentar estructura de validadores | ALTA |
| 5.2 | `runtime/validators/tier-1-universal/` | Verificar scripts completos | ALTA |
| 5.3 | `runtime/validators/tier-2-technology/java-spring/` | Verificar scripts completos | ALTA |
| 5.4 | Cada `module/*/validation/` | Verificar script tier-3 existe | ALTA |
| 5.5 | `runtime/validators/run-all-template.sh` | Crear template del master script | ALTA |

**Mapeo de validadores:**
```
runtime/validators/
├── README.md                           # Documentación
├── run-all-template.sh                 # Template para generar run-all.sh
├── tier-1-universal/
│   └── code-projects/
│       ├── naming-conventions/
│       │   └── naming-conventions-check.sh
│       ├── project-structure/
│       │   └── project-structure-check.sh
│       └── traceability/
│           └── traceability-check.sh
└── tier-2-technology/
    └── code-projects/
        └── java-spring/
            ├── compile-check.sh
            ├── syntax-check.sh
            ├── application-yml-check.sh
            ├── actuator-check.sh
            └── test-check.sh

modules/mod-code-*/
└── validation/
    └── *-check.sh                      # Tier-3 específico del módulo
```

---

### FASE 6: Pruebas de Determinismo
**Objetivo:** Framework para verificar reproducibilidad

| # | Archivo | Acción | Prioridad |
|---|---------|--------|-----------|
| 6.1 | `runtime/testing/README.md` | Crear documentación de testing | ALTA |
| 6.2 | `runtime/testing/prompts/customer-api-reference.txt` | Prompt de referencia | ALTA |
| 6.3 | `runtime/testing/golden-master/` | Paquete de referencia | ALTA |
| 6.4 | `runtime/testing/compare-determinism.sh` | Script de comparación | ALTA |
| 6.5 | `runtime/testing/DETERMINISM-GUIDE.md` | Guía de pruebas | MEDIA |

**Proceso de prueba:**
```bash
# 1. Generar nuevo paquete (en chat o con agente)
# Input: prompts/customer-api-reference.txt
# Output: gen_customer-api_{timestamp}/

# 2. Comparar con golden master
./compare-determinism.sh \
  gen_customer-api_NEW \
  golden-master/gen_customer-api_reference

# 3. Resultado
# - Lista de diferencias
# - Score de determinismo (% archivos idénticos)
# - Diferencias aceptables (timestamps, UUIDs) vs inaceptables
```

**Qué comparar:**
| Elemento | Comparación | Tolerancia |
|----------|-------------|------------|
| Estructura de directorios | Exacta | Ninguna |
| Nombres de archivos | Exacta | Ninguna |
| Contenido Java | Normalizado | Ignorar imports order, whitespace |
| Contenido YAML/JSON | Semántica | Ignorar orden de keys |
| Timestamps | Ignorar | N/A |
| UUIDs | Ignorar | N/A |
| Checksums | Recalcular | N/A |

---

### FASE 7: Documentación de Consumo
**Objetivo:** Actualizar prompts de consumo para agentes/chat

| # | Archivo | Acción | Prioridad |
|---|---------|--------|-----------|
| 7.1 | `model/CONSUMER-PROMPT.md` | Actualizar para v3.0 (sin skills) | ALTA |
| 7.2 | `model/CONSUMER-PROMPT-CHAT.md` | Crear versión específica para chat | MEDIA |
| 7.3 | `model/CONSUMER-PROMPT-AGENT.md` | Crear versión específica para agentes | MEDIA |

**CONSUMER-PROMPT debe incluir:**
```markdown
## Para ejecutar flow-generate:

1. Leer `runtime/discovery/capability-index.yaml`
2. Leer `runtime/discovery/discovery-guidance.md`
3. Ejecutar discovery del prompt
4. Leer módulos necesarios de `modules/`
5. Leer `runtime/flows/code/flow-generate.md`
6. Leer `runtime/flows/code/flow-generate-output.md`
7. Generar paquete conforme a output spec
8. Copiar validadores de `runtime/validators/`
9. Ejecutar validaciones
```

---

## RESUMEN DE PRIORIDADES

### Sprint 1: Correcciones Base (Inmediato)
- [ ] 1.1-1.5: Eliminar referencias a skill
- [ ] 2.1: Crear flow-generate-output.md
- [ ] 3.1: Corregir manifest.schema.json

### Sprint 2: Trazabilidad Completa
- [ ] 3.2-3.5: Schemas de trazabilidad
- [ ] 2.3: OUTPUT-COMMON.md

### Sprint 3: Tests y Validadores
- [ ] 4.1-4.4: Templates de test en módulos
- [ ] 5.1-5.5: Completar validadores en KB

### Sprint 4: Framework de Testing
- [ ] 6.1-6.5: Framework de determinismo
- [ ] 7.1-7.3: Actualizar prompts de consumo

---

## CRITERIO DE ÉXITO

✅ **El modelo está completo cuando:**

1. **Reproducibilidad en Chat:**
   - Nueva sesión de chat (sin memoria)
   - Lee CONSUMER-PROMPT.md + modelo
   - Ejecuta prompt de referencia
   - Produce paquete comparable con golden master
   - Todas las validaciones pasan

2. **Reproducibilidad con Agente:**
   - Agente orquestador lee flows
   - Genera código basado en modules
   - Produce mismo output que chat
   - Determinismo verificable

3. **Documentación Completa:**
   - Sin referencias a "skill"
   - Flows documentan proceso + output
   - Schemas validan trazas
   - Módulos documentan tests que generan

---

## SIGUIENTE ACCIÓN

¿Procedemos con **Sprint 1: Correcciones Base**?

1. Renombrar OUTPUT-PACKAGE-SPEC → flow-generate-output.md
2. Eliminar "skill" de todos los documentos creados
3. Actualizar manifest.schema.json
4. Añadir referencia en flow-generate.md
