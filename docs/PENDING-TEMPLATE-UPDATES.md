# Templates Pendientes de Actualización

**Fecha:** 2026-01-26  
**Última actualización:** 2026-01-26 (v3.0.10)
**Contexto:** DEC-024 (CONTEXT_RESOLUTION) requiere que todos los templates documenten sus variables requeridas
**Decisiones relacionadas:** DEC-024, DEC-025, DEC-026

---

## 1. Especificación de Modificaciones

### ¿Qué hay que aplicar a CADA template?

Cada template debe ser modificado para incluir:

### 1.1 Header Estandarizado (OBLIGATORIO)

```java
// ═══════════════════════════════════════════════════════════════════════════════
// Template: {nombre-archivo.tpl}
// Module: {mod-code-XXX-nombre-modulo}
// Variant: {variante} (solo si el módulo tiene variantes)
// ═══════════════════════════════════════════════════════════════════════════════
// Output: {{basePackagePath}}/path/to/OutputFile.java
// Purpose: Descripción breve del propósito del template
// ═══════════════════════════════════════════════════════════════════════════════
// REQUIRED VARIABLES (must be in generation-context.json):
//   - {{variable1}}      : Descripción de la variable
//   - {{variable2}}      : Descripción de la variable
//   - {{variableN}}      : Descripción de la variable
// ═══════════════════════════════════════════════════════════════════════════════
```

**Reglas del header:**
- Línea `Output:` debe usar variables para el path (ej: `{{basePackagePath}}/adapter/out/{{Entity}}Adapter.java`)
- `REQUIRED VARIABLES` debe listar TODAS las variables `{{xxx}}` usadas en el template
- Para archivos YAML/XML, usar comentario apropiado (`#` o `<!-- -->`)

### 1.2 Anotaciones de Trazabilidad en Javadoc (OBLIGATORIO para .java)

```java
/**
 * Descripción de la clase.
 * 
 * @generated
 * @module mod-code-XXX-nombre-modulo
 * @variant variante (solo si aplica)
 * @capability capability.feature
 */
```

### 1.3 Revisión Funcional (CASO POR CASO)

Durante la revisión de cada template, verificar:

| Aspecto | Qué verificar |
|---------|---------------|
| **Naming** | Nombres de clases siguen convención (`{{Entity}}ModelAssembler`, no `{{Entity}}ResponseAssembler`) |
| **Imports** | Imports correctos y sin duplicados |
| **Herencia** | Clases base correctas (ej: `extends RepresentationModelAssemblerSupport`, no `implements`) |
| **X-Correlation-ID** | Clientes HTTP propagan `X-Correlation-ID` via MDC |
| **X-Source-System** | Clientes HTTP incluyen header `X-Source-System` |
| **Logging** | Uso de SLF4J con `LoggerFactory.getLogger()` |
| **Anotaciones** | `@Component`, `@Service`, etc. correctamente aplicados |

### 1.4 Ejemplo Completo de Template Actualizado

Ver `/modules/mod-code-018-api-integration-rest-java-spring/templates/client/restclient.java.tpl` como referencia.

---

## 2. Estado Actual

### ✅ Templates Actualizados (33)

#### mod-code-015-hexagonal-base (14/22)
- [x] `domain/Entity.java.tpl`
- [x] `domain/EntityId.java.tpl`
- [x] `domain/Repository.java.tpl`
- [x] `domain/NotFoundException.java.tpl`
- [x] `domain/Enum.java.tpl`
- [x] `application/ApplicationService.java.tpl`
- [x] `application/dto/CreateRequest.java.tpl`
- [x] `application/dto/Response.java.tpl`
- [x] `adapter/RestController.java.tpl`
- [x] `config/pom.xml.tpl`
- [x] `config/application.yml.tpl`
- [x] `infrastructure/GlobalExceptionHandler.java.tpl`
- [x] `infrastructure/CorrelationIdFilter.java.tpl`
- [x] `Application.java.tpl`

#### mod-code-017-persistence-systemapi (4/11)
- [x] `adapter/SystemApiAdapter.java.tpl`
- [x] `mapper/SystemApiMapper.java.tpl`
- [x] `exception/SystemApiUnavailableException.java.tpl`
- [x] `config/application-systemapi.yml.tpl`

#### mod-code-018-api-integration-rest (4/9)
- [x] `client/restclient.java.tpl`
- [x] `config/restclient-config.java.tpl`
- [x] `exception/IntegrationException.java.tpl`
- [x] `config/application-integration.yml.tpl`

#### mod-code-019-api-public-exposure (3/6)
- [x] `assembler/EntityModelAssembler.java.tpl`
- [x] `dto/PageResponse.java.tpl`
- [x] `dto/FilterRequest.java.tpl`

#### mod-code-001-circuit-breaker (3/7)
- [x] `annotation/basic-fallback.java.tpl`
- [x] `config/application-circuitbreaker.yml.tpl`
- [x] `config/pom-circuitbreaker.xml.tpl`

#### mod-code-002-retry (3/6)
- [x] `annotation/basic-retry.java.tpl`
- [x] `config/application-retry.yml.tpl`
- [x] `config/pom-retry.xml.tpl`

#### mod-code-003-timeout (2/8)
- [x] `client/timeout-config.java.tpl` (variante client-timeout)
- [x] `client/application-client-timeout.yml.tpl`

### ❌ Templates Pendientes (36)

#### mod-code-015-hexagonal-base (8 pendientes)
- [ ] `domain/DomainService.java.tpl`
- [ ] `application/dto/UpdateRequest.java.tpl`
- [ ] `application/dto/Response-hateoas.java.tpl`
- [ ] `infrastructure/ApplicationConfig.java.tpl`
- [ ] `test/ControllerTest.java.tpl`
- [ ] `test/EntityTest.java.tpl`
- [ ] `test/EntityIdTest.java.tpl`
- [ ] `test/DomainServiceTest.java.tpl`

#### mod-code-017-persistence-systemapi (7 pendientes)
- [ ] `client/restclient.java.tpl`
- [ ] `client/feign.java.tpl`
- [ ] `client/resttemplate.java.tpl`
- [ ] `config/feign-config.java.tpl`
- [ ] `dto/Dto.java.tpl`
- [ ] `dto/Request.java.tpl`
- [ ] `test/SystemApiAdapterTest.java.tpl`

#### mod-code-018-api-integration-rest (5 pendientes)
- [ ] `client/feign.java.tpl`
- [ ] `client/resttemplate.java.tpl`
- [ ] `config/feign-config.java.tpl`
- [ ] `config/resttemplate-config.java.tpl`
- [ ] `test/ClientTest.java.tpl`

#### mod-code-019-api-public-exposure (3 pendientes)
- [ ] `config/PageableConfig.java.tpl`
- [ ] `config/application-pagination.yml.tpl`
- [ ] `test/AssemblerTest.java.tpl`

#### mod-code-001-circuit-breaker (4 pendientes)
- [ ] `annotation/chain-fallback.java.tpl`
- [ ] `annotation/fail-fast.java.tpl`
- [ ] `programmatic/programmatic.java.tpl`
- [ ] `test/CircuitBreakerTest.java.tpl`

#### mod-code-002-retry (3 pendientes)
- [ ] `annotation/retry-with-fallback.java.tpl`
- [ ] `annotation/retry-with-circuitbreaker.java.tpl`
- [ ] `test/RetryTest.java.tpl`

#### mod-code-003-timeout (6 pendientes)
- [ ] `annotation/basic-timeout.java.tpl`
- [ ] `annotation/timeout-with-fallback.java.tpl`
- [ ] `annotation/full-resilience-stack.java.tpl`
- [ ] `config/application-timeout.yml.tpl`
- [ ] `config/pom-timeout.xml.tpl`
- [ ] `test/TimeoutTest.java.tpl`

## Prioridad de Actualización

**Completado (Alta - PoC Customer API):**
- ✅ mod-015: Templates estructurales principales
- ✅ mod-017: SystemApiAdapter, SystemApiMapper
- ✅ mod-018: restclient (default), config
- ✅ mod-019: Assembler, PageResponse
- ✅ mod-001/002/003: Resilience básicos

**Pendiente (Media):**
- Tests templates
- Variantes alternativas (feign, resttemplate)

**Pendiente (Baja):**
- Templates de casos edge
- DomainService (no usado en PoC)

---

## 3. Proceso de Actualización

### Checklist por Template

Para cada template pendiente:

- [ ] Añadir header estandarizado con REQUIRED VARIABLES
- [ ] Añadir anotaciones `@generated`, `@module`, `@capability` en Javadoc
- [ ] Verificar naming sigue convenciones
- [ ] Verificar imports correctos
- [ ] Verificar herencia/implementación correcta
- [ ] Si es cliente HTTP: verificar propagación X-Correlation-ID
- [ ] Verificar que todas las variables `{{xxx}}` están listadas en REQUIRED VARIABLES

### Cómo Actualizar

1. Abrir template pendiente
2. Copiar header de un template similar ya actualizado
3. Ajustar: nombre archivo, módulo, output path, variables
4. Revisar código del template y corregir si necesario
5. Marcar como completado en este documento

### Templates de Referencia (ya actualizados)

| Tipo de Template | Referencia |
|------------------|------------|
| Entity/Domain class | `mod-015/.../Entity.java.tpl` |
| REST Client | `mod-018/.../restclient.java.tpl` |
| Assembler HATEOAS | `mod-019/.../EntityModelAssembler.java.tpl` |
| Config YAML | `mod-015/.../application.yml.tpl` |
| POM additions | `mod-001/.../pom-circuitbreaker.xml.tpl` |
| Test class | (pendiente - definir patrón) |

---

## 4. Notas Importantes

### Correcciones Funcionales Aplicadas (v3.0.10)

| Template | Corrección | Motivo |
|----------|------------|--------|
| `restclient.java.tpl` | Añadido `addCorrelationHeaders()` | Propagar X-Correlation-ID per ERI-CODE-013 |
| `restclient.java.tpl` | Header `X-Source-System` | Trazabilidad de origen |
| `EntityModelAssembler.java.tpl` | Naming `{{entityName}}ModelAssembler` | Evitar confusión con Response |
| `EntityModelAssembler.java.tpl` | `extends RepresentationModelAssemblerSupport` | Patrón correcto Spring HATEOAS |

### Variables Comunes

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `{{basePackage}}` | Paquete Java base | `com.bank.customer` |
| `{{basePackagePath}}` | Paquete como path | `com/bank/customer` |
| `{{Entity}}` | Nombre entidad PascalCase | `Customer` |
| `{{entity}}` | Nombre entidad camelCase | `customer` |
| `{{entityName}}` | Alias de Entity | `Customer` |
| `{{entityNameLower}}` | Alias de entity | `customer` |
| `{{serviceName}}` | Nombre del servicio | `customer-api` |
| `{{ApiName}}` | Nombre API integración | `Parties` |

### Validación

Después de actualizar un template, verificar:
1. El template parsea correctamente (no hay `{{` sin cerrar)
2. Todas las variables listadas en REQUIRED VARIABLES existen en el código
3. No hay variables en el código que no estén en REQUIRED VARIABLES

---

## 5. Historial de Cambios

| Fecha | Versión | Cambio |
|-------|---------|--------|
| 2026-01-26 | v3.0.10 | 33 templates actualizados (PoC Customer API) |
| 2026-01-26 | v3.0.10 | Documento creado con tracking inicial |
| 2026-01-26 | v3.0.10 | Añadida especificación completa de modificaciones |

---

**Próxima revisión:** Después de completar PoC Customer API, evaluar prioridad de templates restantes.
