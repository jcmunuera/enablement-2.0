# Claude Instructions - Enablement 2.0

Este documento contiene instrucciones para Claude sobre cómo gestionar el contexto, decisiones y checkpoints durante las sesiones de trabajo en el proyecto Enablement 2.0.

**Adjuntar este documento al inicio de cada chat.**

---

## 1. Al Inicio de Cada Sesión

### Confirmar Contexto

Después de leer los documentos adjuntos, confirmar:

```
✅ Contexto cargado:
- Versión actual: v3.0.X
- capability-index: v2.X
- Última sesión: [fecha]
- Pendientes: [lista de próximos pasos del session-summary]
```

### Documentos Esperados

El usuario debería adjuntar:
1. `enablement-project-context-vX.X.X.md` - Contexto general
2. `session-summary-YYYY-MM-DD.md` - Resumen de última sesión
3. TAR del repo actualizado (si hay cambios)

Si falta alguno, pedirlo antes de continuar.

---

## 2. Durante la Sesión

### Gestión de Decisiones

**Cuándo registrar una decisión:**
- Cambios en el modelo (tipos, atributos, estructura)
- Cambios en comportamiento del discovery
- Elección entre opciones de diseño
- Cambios en el pipeline de orquestación (agentes, scripts, flujo)
- Cualquier "¿hacemos A o B?" que se resuelva

**Cuándo NO registrar:**
- Correcciones de typos
- Añadir items a listas existentes
- Cambios triviales de formato

**⚠️ IMPORTANTE — Dos repos, dos DECISION-LOGs:**

El proyecto tiene dos repositorios con DECISION-LOGs independientes:

| Repo | DECISION-LOG | Prefijo IDs | Ámbito |
|------|-------------|-------------|--------|
| `enablement-2.0-kb` | `DECISION-LOG.md` (raíz) | DEC-NNN | Modelo, capabilities, modules, templates, KB |
| `enablement-2.0-orchestration` | `docs/DECISION-LOG.md` | ODEC-NNN | Pipeline, agentes, scripts, ejecución |

**Regla:** Registrar SIEMPRE en el DECISION-LOG del repo correcto según el ámbito de la decisión. Si una decisión afecta a ambos repos, registrar en el principal (KB) y referenciar desde Orchestration.

**Cómo registrar:**
1. Determinar en qué repo impacta la decisión
2. Añadir entrada al DECISION-LOG correspondiente con el siguiente ID secuencial
3. Informar al usuario: "Decisión registrada como DEC-XXX" o "ODEC-XXX"

**Trigger phrases del usuario:**
- "Esto es una decisión importante"
- "Registra esta decisión"
- "Añade al decision log"

**Proactivamente preguntar:**
- "¿Quieres que registre esta decisión en el DECISION-LOG?"

### ⚠️ Cascada Obligatoria: DECISION-LOG → AUTHORING Guides

**REGLA CRÍTICA:** Cada vez que se registra una decisión (DEC-NNN) en el KB, evaluar INMEDIATAMENTE si impacta alguna guía de AUTHORING en `model/standards/authoring/`.

**Flujo obligatorio tras registrar una decisión en KB:**

```
1. Registrar DEC-NNN en DECISION-LOG.md
         │
         ▼
2. ¿Impacta cómo se CREAN o ESTRUCTURAN assets del KB?
   │                                                    
   ├─ SÍ → Identificar qué guía(s) AUTHORING afecta:   
   │    ├─ CAPABILITY.md  (config flags, types, features, requires, implies)
   │    ├─ MODULE.md      (variants, templates, dependencies, structure)
   │    ├─ TEMPLATE.md    (headers, output paths, variant markers, anti-patterns)
   │    ├─ FLOW.md        (execution phases, traceability, flow types)
   │    ├─ VALIDATOR.md   (validation tiers, conformance rules)
   │    ├─ ERI.md         (implementation options, derivation rules)
   │    ├─ ADR.md         (decision format, relationships)
   │    └─ README.md      (index table of decisions → guides)
   │    │
   │    ▼
   │  3. Actualizar la(s) guía(s) con la nueva regla/patrón
   │  4. Actualizar README.md index si se añade nueva DEC a una guía
   │  5. Informar: "AUTHORING actualizado: [guía] con DEC-NNN"
   │                                                    
   └─ NO → Decisión operacional, no requiere AUTHORING  
        Ejemplos: cambios en discovery-guidance, ajustes de keywords,
        correcciones de validación, fixes de PoC
```

**Criterio de impacto en AUTHORING:**

| Si la decisión afecta... | Actualizar guía... |
|--------------------------|-------------------|
| Cómo definir capabilities/features | CAPABILITY.md |
| Cómo crear o estructurar módulos | MODULE.md |
| Cómo escribir templates .tpl | TEMPLATE.md |
| Cómo definir flows de ejecución | FLOW.md |
| Cómo crear validadores | VALIDATOR.md |
| Cómo documentar ERIs | ERI.md |
| Config flags, pub/sub entre módulos | CAPABILITY.md + MODULE.md |
| Variants de implementación | MODULE.md + TEMPLATE.md |
| Reglas de determinismo/estilo | TEMPLATE.md |
| Traceability/manifest | FLOW.md |

**Anti-pattern:** Registrar una decisión en DECISION-LOG y NO propagar a AUTHORING. Esto causa drift entre las reglas documentadas y las reglas reales, resultando en KB inconsistente y agentes que no siguen las decisiones.

### Gestión de Checkpoints

**Crear checkpoint TAR cuando:**
- Han pasado ~1-2 horas de trabajo
- Se completa un bloque significativo de cambios
- Antes de empezar algo que podría fallar
- El usuario lo pide
- El chat empieza a ir lento (señal de que puede morir)

**Naming convention:**
```
enablement-2_0-kb-YYYYMMDD-NN.tar              (KB checkpoints, NN secuencial)
enablement-2_0-orchestration-YYYYMMDD-NN.tar    (Orchestration checkpoints)
```

**Informar al usuario:**
```
📦 Checkpoint creado: enablement-2_0-checkpoint-20260121-1430.tar
   Incluye: [lista de cambios desde último checkpoint]
```

### Señales de Alerta

**Si el chat empieza a ir lento:**
1. Crear checkpoint inmediatamente
2. Informar: "⚠️ El chat parece lento. He creado checkpoint por precaución."
3. Sugerir: "Si se vuelve inoperativo, abre nuevo chat con este checkpoint + CLAUDE-INSTRUCTIONS.md"

---

## 3. Al Final de Cada Sesión

### Checklist de Cierre

1. **DECISION-LOG.md actualizado (ambos repos si aplica)**
   - Verificar que todas las decisiones están registradas
   - Verificar repo correcto (DEC en KB, ODEC en Orchestration)
   - Preguntar: "¿Hay alguna decisión que no hayamos registrado?"

2. **AUTHORING guides sincronizadas**
   - Para cada DEC nueva: ¿se propagó a AUTHORING si aplica?
   - Verificar README.md index actualizado con nuevas referencias
   - Preguntar: "¿Las AUTHORING guides reflejan todas las decisiones de hoy?"

3. **TAR final creado (uno por repo modificado)**
   - KB: `enablement-2_0-kb-YYYYMMDD-NN.tar`
   - Orchestration: `enablement-2_0-orchestration-YYYYMMDD-NN.tar`
   - Incluye DECISION-LOGs y AUTHORING actualizados

4. **Session summary generado**
   - Archivo: `SESSION-YYYY-MM-DD.md`
   - Contenido:
     - Actividad principal del día
     - Decisiones tomadas (referencias a DECISION-LOG)
     - Cambios implementados
     - AUTHORING guides actualizadas (si aplica)
     - Próximos pasos

5. **Project context actualizado (si procede)**
   - Solo si hubo cambios estructurales al modelo
   - No actualizar por cambios menores

### Entregables de Fin de Sesión

```
/mnt/user-data/outputs/
├── enablement-2_0-kb-YYYYMMDD-NN.tar           (si KB modificado)
├── enablement-2_0-orchestration-YYYYMMDD-NN.tar (si Orchestration modificado)
├── SESSION-YYYY-MM-DD.md
└── PROJECT-CONTEXT.md                           (si actualizado)
```

---

## 4. Recuperación de Contexto

### Si el usuario dice que viene de un chat muerto

1. Pedir los documentos de contexto
2. Pedir el último checkpoint TAR
3. Verificar qué se perdió comparando con el session-summary
4. Resumir: "Según el último checkpoint, el estado es X. ¿Continuamos desde ahí?"

### Si hay discrepancia entre docs y TAR

Priorizar el TAR (código) sobre los documentos (descripción).

---

## 5. Estructura del Workspace

```
/home/claude/workspace/
├── enablement-2.0-kb/               # Repo: Knowledge Base
│   ├── DECISION-LOG.md              # DEC-NNN - Actualizar durante sesión
│   ├── CHANGELOG.md
│   ├── README.md
│   ├── knowledge/                   # ADRs, ERIs
│   ├── model/
│   │   └── standards/
│   │       └── authoring/           # ⚠️ AUTHORING GUIDES - sincronizar con DECs
│   │           ├── README.md        # Índice de decisiones → guías
│   │           ├── CAPABILITY.md
│   │           ├── MODULE.md
│   │           ├── TEMPLATE.md
│   │           ├── FLOW.md
│   │           ├── VALIDATOR.md
│   │           ├── ERI.md
│   │           └── ADR.md
│   ├── modules/
│   └── runtime/
│       ├── discovery/
│       │   ├── capability-index.yaml  # Fuente de verdad
│       │   └── discovery-guidance.md
│       └── codegen/
│           └── styles/                # Stack-specific style files
│
└── enablement-2.0-orchestration/    # Repo: Pipeline de orquestación
    ├── docs/
    │   ├── DECISION-LOG.md          # ODEC-NNN - Decisiones de pipeline
    │   ├── ARCHITECTURE.md
    │   └── CHANGELOG.md
    ├── agents/                      # Agent prompt definitions
    ├── scripts/                     # Pipeline shell scripts
    └── README.md
```

---

## 6. Versionado

### Cuándo incrementar versión

| Cambio | Versión |
|--------|---------|
| Fix menor, typos | No incrementar |
| Nuevos keywords, ajustes config | Patch (3.0.1 → 3.0.2) |
| Nuevo feature, nueva capability | Minor (3.0.X → 3.1.0) |
| Cambio breaking en modelo | Major (3.X.X → 4.0.0) |

### Cuándo crear tag Git

- Al final de cada sesión con cambios significativos
- Después de validar que todo funciona
- Usuario decide si hacer tag o no

---

## 7. Comunicación

### Informar proactivamente sobre:
- Checkpoints creados
- Decisiones registradas
- Posibles problemas (chat lento, archivos grandes)
- Cambios que afectan a múltiples archivos

### Pedir confirmación antes de:
- Cambios que afectan al modelo core
- Eliminar archivos
- Cambios breaking

---

## 8. Quick Reference

```
INICIO SESIÓN:
  → Confirmar contexto cargado
  → Verificar versiones (KB + Orchestration)
  → Identificar pendientes

DURANTE SESIÓN:
  → Decisión importante → DECISION-LOG.md del repo correcto (DEC / ODEC)
  → Tras registrar DEC → ¿Impacta AUTHORING? → Actualizar guía(s)
  → Cada 1-2h o bloque completo → Checkpoint TAR (por repo modificado)
  → Chat lento → Checkpoint urgente + aviso

FIN SESIÓN:
  → DECISION-LOGs completos (ambos repos)
  → AUTHORING guides sincronizadas con DECs del día
  → TARs finales (por repo modificado)
  → Session summary
  → (Opcional) Project context
```

---

**Versión:** 2.0  
**Última actualización:** 2026-02-05
