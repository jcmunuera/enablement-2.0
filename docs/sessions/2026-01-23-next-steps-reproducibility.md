# Siguientes Pasos: Reproducibilidad de Generación v3.0

## Fecha: 2026-01-23
## Estado: EN PROGRESO

---

## RESUMEN

Se han creado los documentos base que faltaban en el modelo:

| Documento | Estado | Ubicación |
|-----------|--------|-----------|
| Gap Analysis | ✅ CREADO | `docs/sessions/2026-01-23-gap-analysis-reproducibility.md` |
| Output Package Spec | ✅ CREADO | `runtime/flows/OUTPUT-PACKAGE-SPEC.md` |
| Generation Orchestrator | ✅ CREADO | `runtime/flows/GENERATION-ORCHESTRATOR.md` |
| Manifest Schema | ✅ CREADO | `runtime/schemas/trace/manifest.schema.json` |

---

## TAREAS PENDIENTES

### Alta Prioridad (Para reproducibilidad básica)

| # | Tarea | Descripción | Archivo |
|---|-------|-------------|---------|
| 1 | Crear schemas restantes | discovery-trace, generation-trace, modules-used | `runtime/schemas/trace/` |
| 2 | Actualizar flow-generate.md | Añadir referencias a nuevos documentos | `runtime/flows/code/flow-generate.md` |
| 3 | Añadir templates de test a mod-015 | Tests para domain model | `modules/mod-015/templates/test/` |
| 4 | Añadir templates de test a mod-017 | Tests para adapter | `modules/mod-017/templates/test/` |
| 5 | Documentar test patterns | Qué tests genera cada módulo | `runtime/flows/TEST-GENERATION.md` |

### Media Prioridad (Para determinismo completo)

| # | Tarea | Descripción | Archivo |
|---|-------|-------------|---------|
| 6 | Crear CONSUMER-PROMPT actualizado | Instrucciones para agente sin contexto | `model/CONSUMER-PROMPT.md` |
| 7 | Crear paquete de referencia | Golden master para comparación | `runtime/reference/` |
| 8 | Documentar determinism testing | Cómo verificar reproducibilidad | `docs/DETERMINISM-TESTING.md` |

### Baja Prioridad (Mejoras)

| # | Tarea | Descripción | Archivo |
|---|-------|-------------|---------|
| 9 | Limpiar context-snapshots | Decidir si usar o eliminar | `trace/context-snapshots/` |
| 10 | Añadir schemas para .jsonl | Validación de decisions-log | `runtime/schemas/` |

---

## PRUEBA DE REPRODUCIBILIDAD

Para validar que el modelo actualizado funciona:

### Paso 1: Preparar entorno limpio
```bash
# Crear nueva sesión sin contexto previo
# Solo cargar la KB de enablement-2.0
```

### Paso 2: Ejecutar prompt de prueba
```
Crea un microservicio customer-api en Java Spring que:
- Exponga un Domain API para gestión de clientes
- Se conecte a un System API de parties en mainframe
- Use arquitectura hexagonal
- Incluya circuit breaker y retry
```

### Paso 3: Verificar output
```bash
# El agente debe producir:
gen_customer-api_{timestamp}/
├── input/          # Con prompt y specs
├── output/         # Con proyecto + .enablement/
├── trace/          # Con discovery, generation, modules, decisions
└── validation/     # Con scripts tier1, tier2, tier3
```

### Paso 4: Comparar con referencia
```bash
./validation/compare-determinism.sh \
  gen_customer-api_NEW \
  gen_customer-api_REFERENCE
```

---

## CRITERIO DE ÉXITO

✅ **El modelo está completo cuando:**

1. Un agente nuevo (sin memoria de esta sesión) puede:
   - Leer `CONSUMER-PROMPT.md` + documentos del modelo
   - Recibir el mismo prompt
   - Producir un paquete con la misma estructura
   
2. La comparación de determinismo muestra:
   - Mismos módulos seleccionados
   - Misma estructura de archivos
   - Código funcionalmente equivalente
   - Todas las validaciones pasan

---

## NOTAS

### Sobre el warning de `context-snapshots/`

El directorio vacío en `/trace/context-snapshots/` sugiere que se planeó guardar snapshots del contexto entre fases pero no se implementó. Opciones:

1. **Eliminar**: Si no se usa, quitar del spec
2. **Implementar**: Guardar contexto por fase para debugging
3. **Marcar opcional**: En OUTPUT-PACKAGE-SPEC ya está marcado como opcional

### Sobre archivos `.jsonl`

El formato JSON Lines es correcto para `decisions-log.jsonl` porque:
- Es append-only (se añaden decisiones durante generación)
- Cada línea es un JSON válido independiente
- Fácil de procesar línea por línea

Los demás archivos usan `.json` estándar porque son estructuras completas que se escriben al final de cada fase.

---

## PRÓXIMA SESIÓN

Prioridad sugerida:

1. **Completar schemas** (30 min) - Para validación automática
2. **Templates de test** (1h) - Para que módulos generen tests
3. **Actualizar CONSUMER-PROMPT** (30 min) - Para reproducibilidad
4. **Prueba de reproducibilidad** (1h) - Validar con agente limpio
