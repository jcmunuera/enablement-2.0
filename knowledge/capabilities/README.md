# Capabilities Catalog

Capabilities are high-level technical objectives that can be enabled when generating microservices. Each capability contains features (functional groupings) and components (specific patterns), implemented by modules.

---

## Hierarchy

```
┌─────────────────────────────────────────────────────────────────┐
│                         CAPABILITY                               │
│  High-level technical objective (e.g., "resilience")            │
│  Based on: ADRs (architectural decisions)                       │
├─────────────────────────────────────────────────────────────────┤
│                          FEATURES                                │
│  Functional groupings (e.g., "fault_tolerance")                 │
│  Grouped components with common purpose                         │
├─────────────────────────────────────────────────────────────────┤
│                         COMPONENTS                               │
│  Specific patterns (e.g., "circuit_breaker", "retry")           │
│  Configurable options and parameters                            │
├─────────────────────────────────────────────────────────────────┤
│                          MODULES                                 │
│  Implementation templates (e.g., mod-001-circuit-breaker...)    │
│  Framework-specific code with {{variables}}                     │
└─────────────────────────────────────────────────────────────────┘
```

**Relationship:** Capability (1) → Feature (N) → Component (N) → Module (N)

---

## Available Capabilities

| Capability | Description | Status | ADR |
|------------|-------------|--------|-----|
| [api_architecture](./api_architecture.md) | API layers and service architecture | ✅ Active | ADR-001, ADR-009 |
| [resilience](./resilience.md) | Fault tolerance patterns | ✅ Active | ADR-004 |
| [persistence](./persistence.md) | Data access patterns (JPA, System API) | ✅ Active | ADR-011 |
| [integration](./integration.md) | API integration (REST, gRPC, Async) | ✅ Active | ADR-012 |
| observability | Logging, metrics, tracing | 🔜 Planned | ADR-005 (future) |
| error_handling | Error response standards | 🔜 Planned | ADR-006 (future) |
| security | Authentication, authorization | 🔜 Planned | ADR-007 (future) |
| event_driven | Messaging patterns | 🔜 Planned | ADR-008 (future) |
| testing | Test strategy and generation | 🔜 Planned | ADR-010 (future) |

---

## Capability Configuration

Capabilities are configured in the JSON config passed to generation skills:

```json
{
  "serviceName": "my-service",
  "apiType": "domain_api",
  
  "capabilities": {
    "api_architecture": {
      "service_architecture": {
        "style": "hexagonal_light"
      }
    },
    "resilience": {
      "fault_tolerance": {
        "circuit_breaker": {
          "enabled": true,
          "pattern": "basic_fallback"
        },
        "retry": {
          "enabled": true,
          "strategy": "exponential_backoff"
        }
      }
    },
    "observability": {
      "monitoring": {
        "structured_logging": {
          "enabled": true,
          "format": "json"
        },
        "metrics": {
          "enabled": true
        }
      }
    }
  }
}
```

---

## Usage in Skills

### CREATION Skills (e.g., skill-code-020)

Capabilities are enabled at generation time:

```
Config → skill-code-020 → Generated Service
                ↓
        Capabilities determine:
        - Dependencies (pom.xml)
        - Configuration (application.yml)
        - Code patterns applied
        - Additional classes generated
```

### TRANSFORMATION Skills (e.g., skill-code-001)

Capabilities are added to existing services:

```
Existing Service + Capability Config → skill-code-001 → Modified Service
                                              ↓
                                      Adds circuit breaker:
                                      - Dependencies
                                      - Configuration
                                      - Annotations
                                      - Fallback methods
```

---

## Capability Dependencies

Some capabilities depend on or complement others:

```yaml
resilience:
  fault_tolerance:
    circuit_breaker:
      recommends: [observability.monitoring.metrics]
      conflicts_with: []
    retry:
      recommends: [fault_tolerance.circuit_breaker]
      conflicts_with: []

api_architecture:
  service_architecture:
    composable_api:
      requires: [resilience.fault_tolerance.circuit_breaker]
      recommends: [observability.distributed.tracing]
```

---

## Adding New Capabilities

1. Create `capabilities/{capability_name}.md` with:
   - Overview and purpose
   - Features and components with options
   - Dependencies (ADRs, modules)
   - Validation rules
   - Example configuration

2. Create modules implementing the capability:
   - `skills/modules/mod-XXX-{pattern}-{framework}-{library}/`

3. Update skills to support the capability:
   - Input schema
   - Generation logic
   - Validation rules

See `model/standards/ASSET-STANDARDS-v1.3.md` for detailed structure requirements.

---

## Changelog

### 2025-11-28
- Added persistence capability (JPA + System API patterns)
- Updated resilience capability with all sub-patterns

### 2025-11-26
- Renamed from features/ to capabilities/
- Updated terminology: Feature → Capability, Sub-feature → Feature, Pattern → Component
- Updated JSON config structure to reflect hierarchy
- Updated skill naming convention

### 2025-11-24
- Created features directory structure
- Added api_architecture feature
- Added resilience feature
- Defined feature catalog model
