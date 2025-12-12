# Enablement 2.0: Guía de Arquitectura Técnica

**Versión:** 1.1  
**Fecha:** 2025-11-28  
**Audiencia:** Arquitectos de Software, Tech Leads, Ingenieros Senior  
**Clasificación:** Técnico Interno

---

## Tabla de Contenidos

1. [Planteamiento del Problema](#1-planteamiento-del-problema)
2. [Arquitectura de la Solución](#2-arquitectura-de-la-solución)
3. [Modelo de Base de Conocimiento](#3-modelo-de-base-de-conocimiento)
4. [Tipos de Assets en Detalle](#4-tipos-de-assets-en-detalle)
5. [Sistema de Validación](#5-sistema-de-validación)
6. [Sistema de Trazabilidad](#6-sistema-de-trazabilidad)
7. [Arquitectura de la Plataforma](#7-arquitectura-de-la-plataforma)
8. [Roles y Procesos](#8-roles-y-procesos)
9. [Puntos de Integración](#9-puntos-de-integración)
10. [Ejemplos y Recorridos](#10-ejemplos-y-recorridos)

---

## 1. Planteamiento del Problema

### 1.1 Desafíos del Estado Actual

El ciclo de vida del desarrollo de software (SDLC) enfrenta varios desafíos críticos:

```
┌─────────────────────────────────────────────────────────────────────┐
│                    PROBLEMAS IDENTIFICADOS                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ❌ CONOCIMIENTO FRAGMENTADO                                        │
│     • Decisiones arquitectónicas en la mente de pocas personas      │
│     • Documentación desactualizada o inexistente                    │
│     • Patrones reinventados en cada proyecto                        │
│                                                                      │
│  ❌ BAJA ADOPCIÓN DE ESTÁNDARES                                     │
│     • 30-40% de adopción de frameworks corporativos                 │
│     • Cada equipo implementa a su manera                            │
│     • Inconsistencia entre proyectos                                │
│                                                                      │
│  ❌ ONBOARDING LENTO                                                │
│     • 3-6 meses para productividad plena                            │
│     • Conocimiento tribal difícil de transferir                     │
│     • Curva de aprendizaje empinada                                 │
│                                                                      │
│  ❌ GOVERNANCE REACTIVO                                              │
│     • Validación manual propensa a errores                          │
│     • Cumplimiento verificado tarde en el ciclo                     │
│     • Trazabilidad limitada                                         │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 1.2 Cuantificación del Impacto

| Problema | Impacto Anual Estimado |
|----------|------------------------|
| Tiempo perdido en decisiones ya tomadas | ~$1.5M |
| Código no estándar que requiere refactoring | ~$2M |
| Defectos por inconsistencia | ~$1M |
| Onboarding extendido | ~$500K |
| **Total** | **~$5M** |

### 1.3 Análisis de Causa Raíz

```
                    ┌──────────────────────┐
                    │   CAUSA RAÍZ:        │
                    │   Conocimiento       │
                    │   No Codificado      │
                    └──────────┬───────────┘
                               │
            ┌──────────────────┼──────────────────┐
            │                  │                  │
            ▼                  ▼                  ▼
    ┌───────────────┐  ┌───────────────┐  ┌───────────────┐
    │ No hay fuente │  │ No hay forma  │  │ No hay forma  │
    │ única de      │  │ automática de │  │ de verificar  │
    │ verdad        │  │ aplicarlo     │  │ cumplimiento  │
    └───────────────┘  └───────────────┘  └───────────────┘
```

---

## 2. Arquitectura de la Solución

### 2.1 Arquitectura de Alto Nivel

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       PLATAFORMA ENABLEMENT 2.0                              │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                      BASE DE CONOCIMIENTO                               │ │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────────┐  │ │
│  │  │  ADRs   │  │  ERIs   │  │ Modules │  │ Skills  │  │ Validators  │  │ │
│  │  │Estratég.│  │Táctico  │  │Plantilla│  │Ejecución│  │  Calidad    │  │ │
│  │  └─────────┘  └─────────┘  └─────────┘  └─────────┘  └─────────────┘  │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                    │                                         │
│                                    ▼                                         │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                    CAPA DE ORQUESTACIÓN IA                              │ │
│  │                                                                          │ │
│  │   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐               │ │
│  │   │  Analizador  │──▶│Descubrimiento│──▶│  Ejecución   │               │ │
│  │   │  de Intención│   │  de Skills   │   │  de Skills   │               │ │
│  │   └──────────────┘   └──────────────┘   └──────────────┘               │ │
│  │                                                │                        │ │
│  │                                                ▼                        │ │
│  │   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐               │ │
│  │   │  Generador   │◀──│ Orquestador  │◀──│  Compositor  │               │ │
│  │   │Trazabilidad  │   │ Validación   │   │  de Módulos  │               │ │
│  │   └──────────────┘   └──────────────┘   └──────────────┘               │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                    │                                         │
│                                    ▼                                         │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                            OUTPUTS                                      │ │
│  │                                                                          │ │
│  │   📁 Proyectos      📄 Documentos    📊 Informes    ✅ Cumplimiento     │ │
│  │   (.enablement/     (HLD, LLD)       (Calidad,      (Pistas de          │ │
│  │    manifest.json)                     Seguridad)     auditoría)         │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Principios Fundamentales

1. **Conocimiento como Código (KaC)**
   - Todo conocimiento arquitectónico versionado en Git
   - Estructura estandarizada y legible por máquinas
   - Evoluciona con el tiempo

2. **Separación Meta-Modelo / Instancias**
   - `model/` = Cómo crear cosas (especificaciones)
   - `knowledge/` = Las cosas creadas (instancias)

3. **Validación como Ciudadano de Primera Clase**
   - Cada output se valida automáticamente
   - Los validators son assets reutilizables
   - Cumplimiento verificable y auditable

4. **Trazabilidad de Extremo a Extremo**
   - Cada decisión documentada
   - Cada output tiene origen conocido
   - Reproducibilidad garantizada

---

## 3. Modelo de Base de Conocimiento

### 3.1 Estructura de Directorios

```
knowledge/
│
├── model/                              # META-NIVEL (Especificaciones)
│   ├── ENABLEMENT-MODEL-v1.3.md       # Documento maestro
│   └── standards/
│       ├── ASSET-STANDARDS-v1.3.md    # Estructura de assets
│       ├── authoring/                  # Guías de creación
│       │   ├── ADR.md
│       │   ├── ERI.md
│       │   ├── MODULE.md
│       │   ├── SKILL.md               # ⚠️ CRÍTICO
│       │   ├── VALIDATOR.md
│       │   ├── CAPABILITY.md
│       │   └── PATTERN.md
│       ├── validation/README.md        # Sistema de validación
│       └── traceability/               # Sistema de trazabilidad
│           ├── BASE-MODEL.md
│           └── profiles/
│
├── ADRs/                               # INSTANCIAS - Decisiones
│   └── adr-XXX-{topic}/
│
├── ERIs/                               # INSTANCIAS - Implementaciones
│   └── eri-{domain}-XXX-{pattern}-{framework}-{library}/
│
├── validators/                         # INSTANCIAS - Validadores
│   ├── tier-1-universal/
│   ├── tier-2-technology/
│   └── tier-3-modules/
│
├── capabilities/                       # INSTANCIAS - Capacidades
│
├── patterns/                           # INSTANCIAS - Patrones
│
└── skills/                             # INSTANCIAS - Skills
    ├── modules/
    └── skill-{domain}-{NNN}-{type}-{target}/
```

### 3.2 Relaciones entre Assets

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    MODELO DE RELACIONES DE ASSETS                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   ADR ─────────────────────────────────────────────────────────────────     │
│    │ "Qué y Por qué" (Agnóstico de framework)                                │
│    │                                                                         │
│    │ implementa (1:N)                                                        │
│    ▼                                                                         │
│   ERI ─────────────────────────────────────────────────────────────────     │
│    │ "Cómo" para tecnología específica                                       │
│    │                                                                         │
│    │ abstrae_a (1:N)                                                         │
│    ▼                                                                         │
│   Module ──────────────────────────────────────────────────────────────     │
│    │ Plantillas reutilizables + validación Tier 3                            │
│    │                                                                         │
│    │ usado_por (N:N)                                                         │
│    ▼                                                                         │
│   Skill ───────────────────────────────────────────────────────────────     │
│    │ Capacidad ejecutable                                                    │
│    │                                                                         │
│    │ orquesta (N:N)                                                          │
│    ▼                                                                         │
│   Validator ───────────────────────────────────────────────────────────     │
│      Aseguramiento de calidad                                                │
│                                                                              │
│   ────────────────────────────────────────────────────────────────────────  │
│                                                                              │
│   Capability ◀────────────── agrupa ──────────────▶ Feature                 │
│                                  │                                           │
│                                  ▼                                           │
│                              Component                                       │
│                                  │                                           │
│                                  ▼                                           │
│                               Module                                         │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.3 Convenciones de Nombrado

| Asset | Patrón | Ejemplo |
|-------|--------|---------|
| ADR | `adr-XXX-{topic}` | `adr-004-resilience-patterns` |
| ERI | `eri-{domain}-XXX-{pattern}-{framework}-{library}` | `eri-code-001-hexagonal-light-java-spring` |
| Module | `mod-XXX-{pattern}-{framework}-{library}` | `mod-001-circuit-breaker-java-resilience4j` |
| Skill | `skill-{domain}-{NNN}-{type}-{target}-{framework}-{library}` | `skill-code-020-generate-microservice-java-spring` |
| Validator | `val-{tier}-{category}-{name}` | `val-tier2-code-projects-java-spring` |

---

## 4. Tipos de Assets en Detalle

### 4.1 ADR (Registro de Decisión Arquitectónica)

**Propósito:** Documentar decisiones estratégicas agnósticas de framework.

```markdown
# ADR-XXX: {Título}

## Estado
{Borrador|Propuesto|Aceptado|Obsoleto|Sustituido}

## Contexto
[El problema y las fuerzas en juego]

## Decisión
[La decisión tomada - prescriptivo]

## Justificación
[Por qué se tomó esta decisión]

## Consecuencias
[Positivas, negativas, neutras]

## Implementación
[Cómo se implementa - referencias a ERIs]
```

**Propiedad:** Software Architect  
**Revisión:** Architecture Review Board

### 4.2 ERI (Implementación de Referencia Empresarial)

**Propósito:** Implementación completa y compilable de un ADR para una tecnología específica.

```markdown
# ERI-{DOMAIN}-XXX: {Título}

## Stack Tecnológico
| Componente | Tecnología | Versión |
|------------|------------|---------|

## Estructura del Proyecto
[Diseño de directorios]

## Referencia de Código
[Ejemplos de código completos y compilables]

## Configuración
[Archivos de configuración completos]

## Lista de Verificación de Cumplimiento
[Lo que las implementaciones DEBEN satisfacer]

## Anexo: Constraints de Implementación (OBLIGATORIO)
[YAML machine-readable con eri_constraints]
```

**Innovación Clave:** Todo ERI DEBE incluir un anexo machine-readable (`eri_constraints`) que define:
- `structural_constraints` - Reglas de organización de código
- `configuration_constraints` - Requisitos de configuración
- `dependency_constraints` - Dependencias requeridas/opcionales
- `testing_constraints` - Requisitos de testing

Este anexo sirve como **fuente de verdad** para los validators de MODULE y permite la automatización con IA.

**Propiedad:** Tech Lead / Ingeniero Senior  
**Revisión:** Equipo de Arquitectura

### 4.3 Module

**Propósito:** Plantillas parametrizadas derivadas de ERIs + validación Tier 3.

```
modules/mod-XXX-{pattern}/
├── MODULE.md           # Documentación completa
├── OVERVIEW.md         # Referencia rápida
├── templates/          # Plantillas Handlebars/FreeMarker
│   └── *.hbs
└── validation/         # Validación Tier 3
    └── *-check.sh
```

**Innovación Clave:** Cada módulo incluye su propia validación que verifica que las restricciones del ERI se cumplen.

### 4.4 Skill

**Propósito:** Capacidad ejecutable que orquesta módulos y validadores.

```
skills/skill-{domain}-{NNN}-{type}-{target}/
├── SKILL.md            # Especificación completa
├── OVERVIEW.md         # Referencia rápida
├── README.md           # Documentación externa
├── prompts/            # ⚠️ CRÍTICO - Ingeniería de prompts
│   ├── system.md       # Rol, contexto, restricciones
│   ├── user.md         # Plantilla de solicitud
│   └── examples/       # Ejemplos few-shot
└── validation/
    └── validate.sh     # Orquesta Tier 1, 2, 3
```

**Derivación de Prompts:** Los prompts se derivan de la base de conocimiento:

```
Restricciones ADR  ──▶  prompts/system.md (DEBE/NO DEBE)
Patrones ERI       ──▶  prompts/system.md (Contexto)
Plantillas Module  ──▶  prompts/system.md (Herramientas disponibles)
Ejemplos           ──▶  prompts/examples/ (Few-shot)
```

### 4.5 Validator

**Propósito:** Componentes reutilizables de validación organizados por tipo de artefacto.

```
validators/
├── tier-1-universal/           # SIEMPRE se ejecutan
│   ├── project-structure/
│   └── naming-conventions/
├── tier-2-technology/         # CONDICIONAL por tipo
│   ├── code-projects/
│   │   └── java-spring/
│   ├── deployments/
│   │   └── docker/
│   ├── documents/
│   └── reports/
└── tier-3-modules/           # Embebidos en módulos
```

**Uso Entre Dominios:** Los validators se organizan por *qué validan*, no por *quién los usa*. Esto permite que el mismo validator `java-spring` sea usado por skills de CODE y de QA.

---

## 5. Sistema de Validación

### 5.1 Validación Basada en Dominio

La estrategia de validación **difiere según el dominio del skill**:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                  ORQUESTACIÓN DE VALIDACIÓN POR DOMINIO                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  DOMINIO CODE                         │  DOMINIOS DESIGN / QA / GOV         │
│  ─────────────                        │  ──────────────────────────          │
│  validate.sh ORQUESTA:                │  validate.sh INVOCA:                │
│                                        │                                      │
│  ✅ Tier-1 Universal (trazabilidad)   │  ✅ Tier-1 Universal (trazabilidad) │
│  ✅ Tier-1 Code (estructura, naming)  │  ✅ Embebido (específico del skill)  │
│  ✅ Tier-2 (tech stack)               │                                      │
│  ✅ Tier-3 (módulos)                  │  ❌ Tier-1 Code (no aplica)         │
│                                        │  ❌ Tier-2 (no aplica)              │
│                                        │  ❌ Tier-3 (no aplica)              │
│                                        │                                      │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Justificación:** Los artefactos de código tienen estructuras predecibles y estandarizadas que se benefician de validadores compartidos. Los documentos e informes tienen formatos específicos del skill que requieren validación embebida.

### 5.2 Definiciones de Tier

| Tier | Ubicación | Aplica A | Ejecución |
|------|-----------|----------|-----------|
| **1 Universal** | `tier-1-universal/traceability/` | Todos los dominios | SIEMPRE |
| **1 Code** | `tier-1-universal/code-projects/` | Solo CODE | SIEMPRE para CODE |
| **2 Artifacts** | `tier-2-technology/` | Solo CODE | Condicional |
| **3 Modules** | `modules/{mod}/validation/` | Solo CODE | Condicional |
| **Embebido** | `skills/{skill}/validation/` | DESIGN/QA/GOV | SIEMPRE para no-CODE |
| **4 Runtime** | CI/CD | Todos | Futuro |

### 5.3 Estándar de Scripts de Validación

```bash
#!/bin/bash
# {nombre}-check.sh

TARGET_DIR="${1:-.}"
ERRORS=0

# Funciones de salida
pass() { echo -e "✅ PASA: $1"; }
fail() { echo -e "❌ FALLA: $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo -e "⚠️  AVISO: $1"; }
skip() { echo -e "⏭️  OMITE: $1"; }

# Implementación de verificación
if [ condición ]; then
    pass "descripción"
else
    fail "descripción"
fi

exit $ERRORS
```

---

## 6. Sistema de Trazabilidad

### 6.1 MODELO BASE

Campos comunes requeridos por TODOS los skills:

```json
{
  "generation": {
    "id": "uuid",
    "timestamp": "ISO-8601",
    "duration_seconds": 45
  },
  "skill": {
    "id": "skill-code-020-...",
    "version": "1.0.0",
    "domain": "code"
  },
  "orchestrator": {
    "model": "claude-sonnet-4",
    "knowledge_base_version": "5.0"
  },
  "request": {
    "raw": "solicitud original del usuario",
    "parsed_intent": "interpretación estructurada"
  },
  "decisions": [
    {
      "decision": "qué se decidió",
      "reason": "por qué",
      "adr_reference": "adr-XXX"
    }
  ],
  "modules_used": ["mod-001", "mod-015"],
  "validators_executed": [
    {
      "validator": "val-tier1-...",
      "result": "PASS",
      "checks": 5
    }
  ],
  "status": {
    "overall": "SUCCESS|PARTIAL|FAILED",
    "errors": 0,
    "warnings": 2
  }
}
```

### 6.2 Perfiles por Tipo de Output

| Perfil | Usado Por | Campos Adicionales |
|--------|-----------|-------------------|
| `code-project` | skill-code-*-generate-* | artifacts_generated, dependencies_added |
| `code-transformation` | skill-code-*-add/remove-* | artifacts_modified, rollback_info |
| `document` | skill-design-*, skill-gov-* | document_type, diagrams_included |
| `report` | skill-qa-* | findings[], scores, recommendations |

---

## 7. Arquitectura de la Plataforma

### 7.1 Arquitectura Objetivo

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       PLATAFORMA ENABLEMENT 2.0                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                     INTERFACES DE USUARIO                            │   │
│   │                                                                       │   │
│   │   ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────┐   │   │
│   │   │   CLI    │  │Extensión │  │  Portal  │  │   Plugin Portal  │   │   │
│   │   │(AI-chat) │  │   IDE    │  │  (Web)   │  │   Engineering    │   │   │
│   │   └────┬─────┘  └────┬─────┘  └────┬─────┘  └────────┬─────────┘   │   │
│   │        │             │             │                  │             │   │
│   └────────┼─────────────┼─────────────┼──────────────────┼─────────────┘   │
│            │             │             │                  │                  │
│            └─────────────┴─────────────┴──────────────────┘                  │
│                                    │                                         │
│                                    ▼                                         │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                      CAPA DE ORQUESTACIÓN                            │   │
│   │                                                                       │   │
│   │   ┌────────────────┐   ┌────────────────┐   ┌────────────────┐      │   │
│   │   │   Analizador   │   │ Descubrimiento │   │   Ejecutor     │      │   │
│   │   │  de Intención  │──▶│   de Skills    │──▶│   de Skills    │      │   │
│   │   │  NLP + Contexto│   │  Coincidencia  │   │  Orquestación  │      │   │
│   │   │  Comprensión   │   │  Capacidades   │   │   Multi-paso   │      │   │
│   │   └────────────────┘   └────────────────┘   └────────────────┘      │   │
│   │                                                      │               │   │
│   └──────────────────────────────────────────────────────┼───────────────┘   │
│                                                          │                   │
│                                                          ▼                   │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                     BASE DE CONOCIMIENTO                             │   │
│   │                                                                       │   │
│   │   ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  │   │
│   │   │  ADRs   │  │  ERIs   │  │ Modules │  │ Skills  │  │Validators│  │   │
│   │   └─────────┘  └─────────┘  └─────────┘  └─────────┘  └─────────┘  │   │
│   │                                                                       │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                      CAPA DE INTEGRACIÓN                             │   │
│   │                                                                       │   │
│   │   ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────┐   │   │
│   │   │   Git    │  │  CI/CD   │  │Reposit.  │  │   APIs Portal    │   │   │
│   │   │          │  │(Jenkins) │  │Artefactos│  │   Engineering    │   │   │
│   │   └──────────┘  └──────────┘  └──────────┘  └──────────────────┘   │   │
│   │                                                                       │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 7.2 Flujo de Orquestación

```
Usuario                    Plataforma                    Base de Conocimiento
   │                           │                              │
   │  "Crear microservicio     │                              │
   │   para gestión clientes"  │                              │
   │ ─────────────────────────▶│                              │
   │                           │                              │
   │                           │  1. Analizar intención       │
   │                           │  ─────────────────────────▶  │
   │                           │                              │
   │                           │  2. Coincidir capacidades    │
   │                           │  ◀─────────────────────────  │
   │                           │     [skill-code-020-...]     │
   │                           │                              │
   │                           │  3. Cargar skill + dependenc.│
   │                           │  ─────────────────────────▶  │
   │                           │                              │
   │                           │  4. Obtener restricciones ADR│
   │                           │  ◀─────────────────────────  │
   │                           │     [adr-004, adr-009]       │
   │                           │                              │
   │                           │  5. Obtener módulos          │
   │                           │  ◀─────────────────────────  │
   │                           │     [mod-001, mod-015]       │
   │                           │                              │
   │                           │  6. Ejecutar generación      │
   │                           │  (con IA + plantillas)       │
   │                           │                              │
   │                           │  7. Ejecutar validadores     │
   │                           │  ─────────────────────────▶  │
   │                           │  ◀─────────────────────────  │
   │                           │     [✅ 47/47 verificaciones]│
   │                           │                              │
   │                           │  8. Generar trazabilidad     │
   │                           │                              │
   │  Output + Manifest        │                              │
   │ ◀─────────────────────────│                              │
   │                           │                              │
```

### 7.3 Integración MCP (Model Context Protocol)

Para integración con Claude y otros LLMs:

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SERVIDOR MCP: Enablement                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  HERRAMIENTAS:                                                       │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  list_capabilities()     → Lista capacidades disponibles      │   │
│  │  get_skill(id)           → Obtiene spec de skill              │   │
│  │  execute_skill(id, args) → Ejecuta skill                      │   │
│  │  validate_output(path)   → Valida un output                   │   │
│  │  get_adr(id)             → Obtiene ADR                        │   │
│  │  get_eri(id)             → Obtiene ERI                        │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  RECURSOS:                                                           │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  knowledge://adrs/{id}                                        │   │
│  │  knowledge://eris/{id}                                        │   │
│  │  knowledge://skills/{id}                                      │   │
│  │  knowledge://capabilities/{id}                                │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 8. Roles y Procesos

### 8.1 Matriz de Roles

| Rol | Crea | Consume | Revisa |
|-----|------|---------|--------|
| **Software Architect** | ADRs, Patterns | Skills (DESIGN) | ERIs, Skills |
| **Tech Lead** | ERIs, Modules | Skills (CODE) | Modules |
| **Ingeniero Senior** | Modules, Skills | Skills (CODE) | Skills |
| **Desarrollador** | - | Skills (CODE) | - |
| **Solution Architect** | - | Skills (DESIGN) | ADRs |
| **Ingeniero de QA** | - | Skills (QA) | Informes |
| **Equipo C4E** | Todo | Todo | Todo |

### 8.2 Proceso: Crear un Nuevo ADR

```
┌─────────────────────────────────────────────────────────────────────┐
│              PROCESO: Nueva Decisión Arquitectónica                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. IDENTIFICACIÓN                                                   │
│     Software Architect identifica necesidad de estandarización       │
│     ↓                                                                │
│  2. BORRADOR                                                         │
│     Architect crea ADR borrador usando:                              │
│     - CLI/Chat con IA (basado en diálogo)                            │
│     - Plantilla de authoring/ADR.md                                  │
│     ↓                                                                │
│  3. REVISIÓN                                                         │
│     Architecture Review Board revisa                                 │
│     ↓                                                                │
│  4. ACEPTACIÓN                                                       │
│     ADR marcado como "Aceptado"                                      │
│     ↓                                                                │
│  5. IMPLEMENTACIÓN                                                   │
│     Tech Lead crea ERIs para cada tecnología                         │
│     ↓                                                                │
│  6. PROPAGACIÓN                                                      │
│     Skills actualizados para usar nuevas restricciones               │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 8.3 Proceso: Desarrollador Usando la Plataforma

```
┌─────────────────────────────────────────────────────────────────────┐
│              PROCESO: Desarrollador Crea Microservicio               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. SOLICITUD                                                        │
│     Desarrollador: "Necesito microservicio de clientes con circuit   │
│                    breaker y API REST"                               │
│     ↓                                                                │
│  2. ANÁLISIS DE INTENCIÓN                                            │
│     Plataforma interpreta:                                           │
│     - Tipo: generate-microservice                                    │
│     - Features: [circuit-breaker, rest-api]                          │
│     - Dominio: customer                                              │
│     ↓                                                                │
│  3. SELECCIÓN DE SKILL                                               │
│     skill-code-020-generate-microservice-java-spring                 │
│     + mod-001-circuit-breaker-java-resilience4j                      │
│     ↓                                                                │
│  4. EJECUCIÓN                                                        │
│     - Cargar restricciones ADR (adr-004, adr-009)                    │
│     - Generar código usando plantillas                               │
│     - Aplicar IA para lógica específica del dominio                  │
│     ↓                                                                │
│  5. VALIDACIÓN                                                       │
│     - Tier 1: ✅ Estructura OK                                       │
│     - Tier 2: ✅ Compila, Tests pasan                                │
│     - Tier 3: ✅ Circuit breaker correcto                            │
│     ↓                                                                │
│  6. OUTPUT                                                           │
│     - customer-service/ (proyecto completo)                          │
│     - .enablement/manifest.json (trazabilidad)                       │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 9. Puntos de Integración

### 9.1 Integración con Git

```yaml
# .github/workflows/enablement-validation.yml
name: Validación Enablement

on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Ejecutar Validadores Enablement
        run: |
          .enablement/validation/validate-all.sh
      - name: Subir Informe de Validación
        uses: actions/upload-artifact@v3
        with:
          name: informe-validacion
          path: .enablement/validation/report.md
```

### 9.2 Integración con Portal de Ingeniería

```
Portal de Ingeniería
       │
       ▼
┌─────────────────────────────────────────────────────────────────────┐
│                   PLUGIN PORTAL ENABLEMENT                           │
│                                                                      │
│   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐           │
│   │  Catálogo de │   │  Generador   │   │    Panel de  │           │
│   │ Capacidades  │   │  Proyectos   │   │   Governance │           │
│   └──────────────┘   └──────────────┘   └──────────────┘           │
│                                                                      │
│   - Explorar skills disponibles                                      │
│   - Generar proyectos vía UI                                         │
│   - Ver métricas de cumplimiento                                     │
│   - Seguir KPIs de adopción                                          │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 10. Ejemplos y Recorridos

### 10.1 Ejemplo: Generar Microservicio de Cliente

**Entrada:**
```json
{
  "serviceName": "CustomerService",
  "packageName": "com.company.customer",
  "features": ["circuit-breaker", "rest-api"],
  "domain": {
    "entities": ["Customer"],
    "operations": ["create", "read", "update", "delete"]
  }
}
```

**Skill Ejecutado:** `skill-code-020-generate-microservice-java-spring`

**Estructura del Output:**
```
customer-service/
├── .enablement/
│   ├── manifest.json         # Trazabilidad
│   └── validation/
│       └── report.md         # Resultados de validación
├── src/
│   ├── main/
│   │   ├── java/com/company/customer/
│   │   │   ├── domain/       # Lógica de dominio pura
│   │   │   ├── application/  # Casos de uso
│   │   │   └── infrastructure/ # Adaptadores
│   │   └── resources/
│   │       └── application.yml
│   └── test/
├── pom.xml
├── Dockerfile
└── README.md
```

**Resultados de Validación:**
```
═══════════════════════════════════════════════════
TIER 1: GENÉRICO
═══════════════════════════════════════════════════
✅ PASA: src/main/java existe
✅ PASA: src/test/java existe
✅ PASA: Convenciones de nombrado correctas

═══════════════════════════════════════════════════
TIER 2: ARTEFACTOS
═══════════════════════════════════════════════════
✅ PASA: Proyecto compila
✅ PASA: Tests pasan (5/5)
✅ PASA: Actuator configurado
✅ PASA: application.yml válido
✅ PASA: Dockerfile válido

═══════════════════════════════════════════════════
TIER 3: MÓDULO
═══════════════════════════════════════════════════
✅ PASA: Estructura hexagonal correcta
✅ PASA: Circuit breaker configurado
✅ PASA: Métodos fallback presentes

═══════════════════════════════════════════════════
TOTAL: 11/11 verificaciones pasadas
═══════════════════════════════════════════════════
```

---

## Apéndice: Referencias de Documentos

| Documento | Propósito | Ubicación |
|-----------|-----------|-----------|
| ENABLEMENT-MODEL-v1.3.md | Modelo maestro | `model/` |
| ASSET-STANDARDS-v1.3.md | Estructura de assets | `model/standards/` |
| authoring/SKILL.md | Cómo crear skills | `model/standards/authoring/` |
| validators/README.md | Sistema de validación | `knowledge/validators/` |
| traceability/BASE-MODEL.md | Campos de trazabilidad | `model/standards/traceability/` |

---

*Guía de Arquitectura Técnica Enablement 2.0 v1.0*
