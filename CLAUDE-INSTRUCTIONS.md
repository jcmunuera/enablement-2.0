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
- Cualquier "¿hacemos A o B?" que se resuelva

**Cuándo NO registrar:**
- Correcciones de typos
- Añadir items a listas existentes
- Cambios triviales de formato

**Cómo registrar:**
1. Después de tomar la decisión, añadir entrada a `DECISION-LOG.md`
2. Usar el siguiente ID secuencial (DEC-XXX)
3. Informar al usuario: "Decisión registrada como DEC-XXX"

**Trigger phrases del usuario:**
- "Esto es una decisión importante"
- "Registra esta decisión"
- "Añade al decision log"

**Proactivamente preguntar:**
- "¿Quieres que registre esta decisión en el DECISION-LOG?"

### Gestión de Checkpoints

**Crear checkpoint TAR cuando:**
- Han pasado ~1-2 horas de trabajo
- Se completa un bloque significativo de cambios
- Antes de empezar algo que podría fallar
- El usuario lo pide
- El chat empieza a ir lento (señal de que puede morir)

**Naming convention:**
```
enablement-2_0-checkpoint-YYYYMMDD-HHMM.tar
enablement-2_0-vX.X.X-FINAL-YYYYMMDD.tar  (solo al final)
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

1. **DECISION-LOG.md actualizado**
   - Verificar que todas las decisiones están registradas
   - Preguntar: "¿Hay alguna decisión que no hayamos registrado?"

2. **TAR final creado**
   - Nombre: `enablement-2_0-vX.X.X-FINAL-YYYYMMDD.tar`
   - Incluye DECISION-LOG.md actualizado

3. **Session summary generado**
   - Archivo: `session-summary-YYYY-MM-DD.md`
   - Contenido:
     - Actividad principal del día
     - Decisiones tomadas (referencias a DECISION-LOG)
     - Cambios implementados
     - Próximos pasos

4. **Project context actualizado (si procede)**
   - Solo si hubo cambios estructurales al modelo
   - No actualizar por cambios menores

### Entregables de Fin de Sesión

```
/mnt/user-data/outputs/
├── enablement-2_0-vX.X.X-FINAL-YYYYMMDD.tar
├── session-summary-YYYY-MM-DD.md
└── enablement-project-context-vX.X.X.md  (si actualizado)
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
/home/claude/workspace/enablement-2.0/
├── DECISION-LOG.md          # Actualizar durante sesión
├── CHANGELOG.md
├── README.md
├── knowledge/
├── model/
├── modules/
└── runtime/
    └── discovery/
        ├── capability-index.yaml  # Fuente de verdad
        └── discovery-guidance.md
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
  → Verificar versiones
  → Identificar pendientes

DURANTE SESIÓN:
  → Decisión importante → DECISION-LOG.md
  → Cada 1-2h o bloque completo → Checkpoint TAR
  → Chat lento → Checkpoint urgente + aviso

FIN SESIÓN:
  → DECISION-LOG completo
  → TAR final
  → Session summary
  → (Opcional) Project context
```

---

**Versión:** 1.0  
**Última actualización:** 2026-01-21
