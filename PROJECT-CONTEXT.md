# Enablement 2.0 - Project Context

**Última actualización:** 2026-02-04  
**Versión KB:** 3.0.16  
**Versión Orchestration:** 1.3.0

---

## 1. Visión General

**Enablement 2.0** es una plataforma de generación de código impulsada por IA que automatiza la creación de microservicios siguiendo patrones arquitectónicos empresariales. El objetivo es mejorar la adopción de frameworks de desarrollo en una organización financiera multinacional donde actualmente solo el 30-40% de los desarrolladores siguen los frameworks establecidos.

### Problema que Resuelve

- Baja adopción de frameworks corporativos (30-40%)
- Inconsistencia en implementaciones entre equipos
- Tiempo elevado para crear nuevos microservicios siguiendo estándares

### Solución

Pipeline de agentes IA que:
1. Analiza requisitos en lenguaje natural
2. Detecta capacidades necesarias
3. Genera código completo siguiendo templates corporativos
4. Produce microservicios compilables y testeables

---

## 2. Arquitectura

### Componentes Principales

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           ENABLEMENT 2.0                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐                   │
│  │     KB      │     │ORCHESTRATION│     │  GENERATED  │                   │
│  │             │     │             │     │    CODE     │                   │
│  │ • Modules   │────▶│ • Agents    │────▶│             │                   │
│  │ • Templates │     │ • Scripts   │     │ • Java/     │                   │
│  │ • Rules     │     │ • Pipeline  │     │   Spring    │                   │
│  │ • Styles    │     │             │     │ • Tests     │                   │
│  └─────────────┘     └─────────────┘     └─────────────┘                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Knowledge Base (KB)

Repositorio de conocimiento que contiene:

| Directorio | Contenido |
|------------|-----------|
| `modules/` | Módulos de código (templates, documentación) |
| `model/` | Modelo de dominio (capabilities, ADRs, ERIs) |
| `runtime/discovery/` | capability-index.yaml, discovery-guidance.md |
| `runtime/codegen/styles/` | Stack-specific style files (DEC-042) |

### Orchestration

Pipeline de ejecución con 4 agentes:

```
prompt.md + specs
       │
       ▼
┌──────────────┐
│  DISCOVERY   │ → Detecta capabilities, stack, modules
└──────────────┘
       │
       ▼
┌──────────────┐
│    PLAN      │ → Crea execution-plan.json (fases, subphases)
└──────────────┘
       │
       ▼
┌──────────────┐
│   CONTEXT    │ → Genera generation-context.json (variables, deps)
└──────────────┘
       │
       ▼
┌──────────────┐
│   CODEGEN    │ → Genera código Java aplicando templates
└──────────────┘
       │
       ▼
generated-code/
```

---

## 3. Modelo de Capabilities

### Jerarquía

```
Capability (e.g., persistence)
    └── Feature (e.g., systemapi)
            └── Implementation (e.g., java-spring)
                    └── Module (e.g., mod-code-017-persistence-systemapi)
```

### Tipos de Capabilities

| Tipo | Descripción | Ejemplo |
|------|-------------|---------|
| **Foundational** | Base arquitectónica (exactamente 1) | architecture.hexagonal-light |
| **Layered** | Capas sobre foundational | api-architecture, persistence |
| **Cross-cutting** | Decoradores aplicables | resilience, idempotency |

### Fases de Generación

| Fase | Nombre | Contenido |
|------|--------|-----------|
| 1 | Structural | Arquitectura base, domain, application |
| 2 | Implementation | Adapters OUT (persistence, integration) |
| 3 | Cross-cutting | Patrones transversales (resilience) |

---

## 4. Mecanismos Clave

### Config Flags (DEC-035)

Comunicación entre módulos via flags publicados por capabilities:

```yaml
# Capability publica
api-architecture.domain-api:
  publishes_flags:
    hateoas: true
    pagination: true

# Módulo suscribe y reacciona
mod-015:
  subscribes_to_flags:
    - flag: hateoas
      behavior: "Skip Response.java, mod-019 generates HATEOAS version"
```

### Module Variants (DEC-041)

Selección de implementaciones alternativas dentro de un módulo:

```yaml
# MODULE.md de mod-017
variants:
  http_client:
    default: restclient
    options:
      restclient: { templates: [client/restclient.java.tpl] }
      feign: { templates: [client/feign.java.tpl], keywords: [feign, openfeign] }
      resttemplate: { templates: [client/resttemplate.java.tpl] }
```

**Flujo:**
1. Discovery detecta keywords en prompt ("use Feign")
2. Context resuelve variant (o usa default)
3. CodeGen filtra templates por `// Variant:` header

### Stack-Specific Style Files (DEC-042)

Reglas de estilo inyectadas en prompt según stack:

```
KB/runtime/codegen/styles/
└── java-spring.style.md   # Reglas para Java/Spring
```

**Contenido:**
- DTOs: `String` para IDs, factory `from(entity)`
- Mappers: Helper methods con nombres exactos
- General: Trailing newlines, ASCII-only comments

---

## 5. Módulos Principales (PoC)

| ID | Nombre | Capability |
|----|--------|------------|
| mod-015 | Hexagonal Base | architecture.hexagonal-light |
| mod-017 | System API Persistence | persistence.systemapi |
| mod-019 | API Public Exposure | api-architecture.domain-api |
| mod-001 | Circuit Breaker | resilience.circuit-breaker |
| mod-002 | Retry | resilience.retry |
| mod-003 | Timeout | resilience.timeout |

---

## 6. Estado Actual de Reproducibilidad

### Métricas (2026-02-04, 5 runs)

| Métrica | Valor |
|---------|-------|
| Estructura de archivos | 100% idéntica |
| Contenido byte-identical | 70% (22/31 files) |
| Compilación + Tests | 100% |
| Style rules (String ID) | 100% cumplimiento |

### Variaciones Conocidas (Aceptables)

- `CustomerSystemApiMapper.java`: Orden de helpers, comentarios extra
- Test files (7): Orden de setup, estilo menor
- `CreateCustomerRequest.java`: Variaciones menores

Todas las variaciones son **funcionalmente equivalentes**.

---

## 7. Decisiones Arquitectónicas Recientes

| DEC | Fecha | Título | Estado |
|-----|-------|--------|--------|
| DEC-039 | 2026-02-03 | Phase 2 Reproducibility Rules | ✅ Implementado |
| DEC-040 | 2026-02-04 | HTTP Client Variant Selection | ✅ Implementado |
| DEC-041 | 2026-02-04 | Module Variants vs Config Flags | ✅ Implementado |
| DEC-042 | 2026-02-04 | Stack-Specific Style Files | ✅ Implementado |

---

## 8. Artifacts Actuales

| Artifact | Versión | Descripción |
|----------|---------|-------------|
| `enablement-2_0-kb-04022026-04.tar` | v3.0.16 | Knowledge Base completa |
| `enablement-2_0-orchestration-04022026-04.tar` | v1.3.0 | Pipeline de orquestación |

---

## 9. Próximos Pasos Potenciales

1. **Más stacks**: Crear `nodejs.style.md` cuando se añadan módulos Node.js
2. **Variant UI**: Interfaz para seleccionar variantes sin editar prompts
3. **Métricas de adopción**: Tracking de uso de frameworks generados
4. **Catálogo de variantes**: Documento consolidado de todas las variantes disponibles

---

## 10. Cómo Ejecutar

### Requisitos

- Bash, Python 3.x con PyYAML
- Java 17+, Maven 3.8+
- LLM API configurada

### Ejecución Completa

```bash
# 1. Preparar inputs
mkdir -p inputs
# Crear prompt.md, domain-api-spec.yaml, system-api-spec.yaml, mapping.json

# 2. Ejecutar pipeline
./scripts/run-discovery.sh inputs/ discovery-result.json
./scripts/run-plan.sh discovery-result.json execution-plan.json
./scripts/run-context.sh inputs/ discovery-result.json execution-plan.json generation-context.json
./scripts/run-codegen.sh 1.1 execution-plan.json generation-context.json output/
./scripts/run-codegen.sh 2.1 execution-plan.json generation-context.json output/
./scripts/run-transform.sh 3.1 execution-plan.json generation-context.json output/

# 3. Validar
cd output && mvn compile test
```

---

## 11. Contacto y Recursos

- **DECISION-LOG.md**: Registro completo de decisiones arquitectónicas
- **CHANGELOG.md**: Historial de cambios por versión
- **ARCHITECTURE.md** (orchestration): Documentación técnica del pipeline
