# Análisis de Gaps: Modelo vs Comportamiento Deseado

## Fecha: 2026-01-23
## Contexto: Sesión de validación de generación v3.0

---

## 1. RESUMEN EJECUTIVO

Durante la sesión de PoC se identificó que el código generado funcionaba correctamente, pero la **estructura de entrega** estaba incompleta. Se completó manualmente:

| Gap | Estado Antes | Estado Después |
|-----|--------------|----------------|
| Estructura de paquete | Solo `/output/customer-api/` | Paquete completo con `/input`, `/output`, `/trace`, `/validation` |
| Trazabilidad en `/trace` | No existía | `discovery-trace.json`, `generation-trace.json`, `modules-used.json`, `decisions-log.jsonl` |
| Trazabilidad en proyecto | No existía | `.enablement/manifest.json` |
| Tests unitarios | No generados | `CustomerTest.java`, `CustomerSystemApiAdapterTest.java` |
| Scripts de validación | No incluidos | 15 scripts en 3 tiers + `run-all.sh` |

**El modelo actual (KB) NO contiene instrucciones para generar estos elementos automáticamente.**

---

## 2. ANÁLISIS DETALLADO POR GAP

### 2.1 Estructura de Paquete de Entrega

**Lo que dice el modelo (flow-generate.md líneas 236-274):**
```
customer-api/
├── pom.xml
├── src/main/java/...
└── src/test/java/...
```

**Lo que necesitamos:**
```
gen_{service-name}_{timestamp}/
├── input/                          # ❌ NO DOCUMENTADO
│   ├── prompt.txt
│   ├── prompt-metadata.json
│   ├── domain-api-spec.yaml
│   ├── system-api-*.yaml
│   └── mapping.json
├── output/                         # ⚠️ PARCIALMENTE DOCUMENTADO
│   └── customer-api/               # ✅ Documentado
│       ├── pom.xml
│       ├── src/...
│       └── .enablement/            # ❌ NO DOCUMENTADO
│           └── manifest.json
├── trace/                          # ❌ NO DOCUMENTADO
│   ├── discovery-trace.json
│   ├── generation-trace.json
│   ├── modules-used.json
│   └── decisions-log.jsonl
└── validation/                     # ❌ NO DOCUMENTADO
    ├── run-all.sh
    ├── scripts/
    │   ├── tier1/
    │   ├── tier2/
    │   └── tier3/
    └── reports/
```

**Gap:** El modelo no documenta la estructura completa del paquete de entrega.

---

### 2.2 Trazabilidad en `/trace`

**Lo que dice el modelo (flow-generate.md líneas 299-312):**
- Solo menciona metadata en comentarios de archivos Java
- No menciona archivos de traza separados

**Lo que necesitamos:**

```json
// discovery-trace.json
{
  "prompt_analysis": { ... },
  "detected_capabilities": [ ... ],
  "resolved_modules": [ ... ],
  "config_derivation": { ... }
}

// generation-trace.json
{
  "phases": [
    {
      "phase": 1,
      "name": "STRUCTURAL",
      "modules": ["mod-015", "mod-019"],
      "files_generated": [ ... ]
    }
  ]
}

// modules-used.json
{
  "modules": [
    {
      "id": "mod-code-015",
      "version": "...",
      "files_generated": [ ... ]
    }
  ]
}

// decisions-log.jsonl
{"decision": "...", "reason": "...", "timestamp": "..."}
```

**Gap:** El modelo no define esquemas ni instrucciones para generar archivos de traza.

---

### 2.3 Trazabilidad en Proyecto (`.enablement/manifest.json`)

**Lo que dice el modelo:** Nada específico.

**Lo que necesitamos:**
```json
{
  "generation": {
    "id": "UUID",
    "timestamp": "ISO-8601",
    "run_id": "YYYYMMDD_HHMMSS"
  },
  "enablement": {
    "version": "3.0.6",
    "domain": "code",
    "flow": "flow-generate"
  },
  "discovery": {
    "stack": "java-spring",
    "capabilities": ["architecture.hexagonal-light", "api-architecture.domain-api"],
    "features": ["hexagonal-light", "domain-api"]
  },
  "modules": [...],
  "status": {
    "overall": "SUCCESS|PARTIAL|FAILED",
    "compilation": "PASS|FAIL",
    "tier1": "PASS|FAIL",
    "tier2": "PASS|FAIL",
    "tier3": "PASS|FAIL|PASS_WITH_WARNINGS"
  }
}
```

**Gap:** No existe esquema ni instrucciones para `manifest.json`.
**UPDATE:** Corregido en Sprint 1 - Ahora usa `enablement` + `discovery` (sin skills, alineado con v3.0).

---

### 2.4 Tests Unitarios

**Lo que dice el modelo (flow-generate.md línea 274):**
```
└── src/test/java/...
```

Menciona que existe pero NO especifica:
- Qué tests generar
- Estructura de tests
- Qué módulos generan tests
- Patrones de test por capa

**Lo que necesitamos:**

| Capa | Test | Generado por |
|------|------|--------------|
| Domain | `CustomerTest.java` | mod-015 |
| Domain | `CustomerIdTest.java` | mod-015 |
| Adapter Out | `CustomerSystemApiAdapterTest.java` | mod-017 |
| Controller | `CustomerControllerTest.java` | mod-019 |

**Gap:** Los módulos no tienen plantillas de tests ni instrucciones para generarlos.

---

### 2.5 Scripts de Validación

**Lo que dice el modelo (flow-generate.md líneas 277-287):**
```
After each phase:
1. Checksum validation
2. Compilation
3. Structure validation

After all phases:
1. Full build
2. Tests pass
3. Traceability
```

Menciona QUÉ validar pero NO:
- Dónde están los scripts
- Cómo incluirlos en el paquete
- El sistema de 3 tiers
- El master script `run-all.sh`

**Lo que necesitamos:**

| Tier | Validación | Script | Ubicación en KB |
|------|------------|--------|-----------------|
| 1 | Naming conventions | `naming-conventions-check.sh` | `runtime/validators/tier-1-universal/` |
| 1 | Project structure | `project-structure-check.sh` | `runtime/validators/tier-1-universal/` |
| 1 | Traceability | `traceability-check.sh` | `runtime/validators/tier-1-universal/` |
| 2 | Compile | `compile-check.sh` | `runtime/validators/tier-2-technology/java-spring/` |
| 2 | Syntax | `syntax-check.sh` | `runtime/validators/tier-2-technology/java-spring/` |
| ... | ... | ... | ... |
| 3 | Module-specific | `*.sh` | `modules/mod-xxx/validation/` |

**Gap:** No hay instrucciones para copiar scripts al paquete de entrega.

---

## 3. LO QUE FALTA EN EL MODELO

### 3.1 Nuevo documento: `OUTPUT-PACKAGE-SPEC.md`

Debe definir:
- Estructura del paquete `gen_{service}_{timestamp}/`
- Contenido de cada directorio
- Esquemas JSON para archivos de traza
- Instrucciones para crear `manifest.json`

### 3.2 Actualización de módulos

Cada módulo necesita añadir:
- `templates/test/` - Plantillas de tests para esa capability
- `validation/` - Script de validación tier-3 (algunos ya lo tienen)
- Documentación de qué tests genera

### 3.3 Nuevo documento: `GENERATION-ORCHESTRATOR.md`

Debe definir el flujo completo:
```
1. INIT
   - Crear estructura gen_{service}_{timestamp}/
   - Copiar inputs a /input
   
2. DISCOVERY
   - Ejecutar discovery
   - Escribir discovery-trace.json
   
3. GENERATION (por fase)
   - Ejecutar generación
   - Escribir generation-trace.json
   - Escribir modules-used.json
   - Escribir decisions-log.jsonl
   
4. TESTS
   - Generar tests unitarios por módulo
   
5. TRACEABILITY
   - Crear .enablement/manifest.json
   
6. VALIDATION
   - Copiar scripts de validación
   - Crear run-all.sh
   - Ejecutar validaciones
   - Actualizar manifest con resultados
   
7. PACKAGE
   - Crear tarball
```

### 3.4 Actualización de `flow-generate.md`

Añadir:
- Referencia a OUTPUT-PACKAGE-SPEC
- Instrucciones para generar tests
- Instrucciones para trazabilidad

### 3.5 Nuevos schemas en `runtime/schemas/`

- `discovery-trace.schema.json`
- `generation-trace.schema.json`
- `modules-used.schema.json`
- `manifest.schema.json`
- `validation-results.schema.json`

---

## 4. PLAN DE ACCIÓN

### Fase 1: Documentación Base (Prioridad Alta)
1. Crear `OUTPUT-PACKAGE-SPEC.md` con estructura completa
2. Crear schemas JSON para trazabilidad
3. Actualizar `flow-generate.md` con referencias

### Fase 2: Módulos (Prioridad Alta)
1. Añadir plantillas de tests a cada módulo
2. Asegurar que cada módulo tiene su script de validación tier-3
3. Documentar qué archivos genera cada módulo (incluyendo tests)

### Fase 3: Orquestador (Prioridad Media)
1. Crear `GENERATION-ORCHESTRATOR.md` con flujo completo
2. Documentar cómo copiar inputs, traces, y validation scripts

### Fase 4: Validación del Modelo (Prioridad Alta)
1. Ejecutar generación con modelo actualizado
2. Comparar output con paquete de referencia
3. Ajustar hasta lograr determinismo

---

## 5. CRITERIO DE ÉXITO

Un agente sin contexto previo debe poder:

1. **Leer** el flow documentation y capability-index
2. **Entender** la estructura de output esperada
3. **Generar** todos los elementos:
   - Código en `/output/`
   - Tests unitarios
   - Trazas en `/trace/`
   - Manifest en `.enablement/`
   - Scripts de validación
4. **Producir** un paquete idéntico (determinismo)

---

## 6. ARCHIVOS A MODIFICAR/CREAR

| Archivo | Acción | Prioridad |
|---------|--------|-----------|
| `runtime/flows/OUTPUT-PACKAGE-SPEC.md` | CREAR | Alta |
| `runtime/flows/GENERATION-ORCHESTRATOR.md` | CREAR | Alta |
| `runtime/flows/code/flow-generate.md` | ACTUALIZAR | Alta |
| `runtime/schemas/discovery-trace.schema.json` | CREAR | Alta |
| `runtime/schemas/generation-trace.schema.json` | CREAR | Alta |
| `runtime/schemas/manifest.schema.json` | CREAR | Alta |
| `modules/mod-015/templates/test/` | CREAR | Alta |
| `modules/mod-017/templates/test/` | CREAR | Alta |
| `modules/mod-019/templates/test/` | CREAR | Media |

---

## 7. NOTA SOBRE INCIDENCIA `/trace/context-snapshots`

En el directorio `/trace` existe un subdirectorio vacío `context-snapshots/` y archivos con extensión `.jsonl`. Esto sugiere que:

1. `context-snapshots/` estaba diseñado para guardar snapshots del contexto entre fases (pero no se implementó)
2. `.jsonl` (JSON Lines) es el formato correcto para `decisions-log.jsonl` pero puede haber confusión sobre qué otros archivos deberían usar este formato

**Recomendación:** Documentar explícitamente en OUTPUT-PACKAGE-SPEC:
- `context-snapshots/` - Opcional, para debugging de fases
- Cuáles archivos usan `.json` vs `.jsonl`
