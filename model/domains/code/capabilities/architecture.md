# Capability: Architecture

## Overview

The Architecture capability defines foundational architectural patterns that establish the code structure for all generated applications. This is a **foundational capability** - exactly one is required for every generation and cannot be added via transformation.

## Type

- **Type:** Foundational
- **Phase Group:** structural
- **Cardinality:** exactly-one
- **Transformable:** No
- **Required:** Yes (for all code generation)

## Discovery (v2.2)

### Capability-Level Keywords

The architecture capability can be matched by generic terms at the capability level:

```yaml
keywords:
  - microservicio
  - microservice
  - servicio
  - service
  - aplicación
  - application
  - backend
  - proyecto
  - project
```

### Default Feature

When a capability-level keyword matches but no specific feature is mentioned, the default feature is used:

```yaml
default_feature: hexagonal-light
```

**Example:** "Genera un microservicio" → `architecture.hexagonal-light` (via default)

## Features

### hexagonal-light (default)

**Description:** Hexagonal Light architecture implementing the Ports and Adapters pattern with three main layers:
- **Domain Layer:** Pure business logic (POJOs, no framework dependencies)
- **Application Layer:** Use cases and orchestration
- **Infrastructure Layer:** Framework integrations, adapters, configuration

**Package Structure:**
```
com.company.service/
├── domain/
│   ├── model/           # Entities, Value Objects, Enums
│   ├── port/            # Repository interfaces (outbound ports)
│   ├── service/         # Domain services (optional)
│   └── exception/       # Domain exceptions
├── application/
│   ├── service/         # Application services (@Service)
│   └── dto/             # DTOs for application layer
└── infrastructure/
    ├── adapter/
    │   ├── in/          # Inbound adapters (REST controllers)
    │   └── out/         # Outbound adapters (DB, external APIs)
    ├── config/          # Spring configuration
    └── exception/       # Infrastructure exceptions
```

**Key Principles:**
1. Domain layer has NO external dependencies
2. Dependencies point inward (infrastructure → application → domain)
3. Ports define contracts, adapters implement them
4. Business logic is isolated and testable

**Module:** `mod-code-015-hexagonal-base-java-spring`

**Related ADR:** [adr-code-009-service-architecture-patterns](../../../knowledge/ADRs/adr-code-009-service-architecture-patterns/ADR.md)

### hexagonal-full (Future)

**Description:** Full Hexagonal architecture with additional layers and more explicit port definitions. To be implemented when needed for complex applications.

## Usage

### In Discovery

Architecture features are automatically required by other features:

```yaml
# In capability-index.yaml
api-architecture:
  features:
    domain-api:
      requires:
        - architecture.hexagonal-light  # Automatically included
```

### In Generation

The architecture module is always loaded first (Phase 1: Structural) and generates:
- Project structure (Maven/Gradle)
- Package hierarchy
- Base classes and interfaces
- Configuration files

## Compatibility

- **Compatible with all compositional capabilities**
- All compositional capabilities require an architecture feature
- Cannot be transformed (structural by nature)

## Implementation Matrix

| Feature | Java Spring | Java Quarkus | Node.js |
|---------|-------------|--------------|---------|
| hexagonal-light | ✅ mod-015 | 🔜 Planned | 🔜 Planned |
| hexagonal-full | 🔜 Planned | - | - |

## Decision Rationale

The Hexagonal Light pattern was chosen as the default because:

1. **Separation of Concerns:** Clear boundaries between business logic and infrastructure
2. **Testability:** Domain layer can be tested without frameworks
3. **Flexibility:** Easy to swap infrastructure components
4. **Team Adoption:** Simpler than full hexagonal, easier to adopt
5. **Enterprise Standard:** Aligned with organization's architectural guidelines

See [ADR-009](../../../knowledge/ADRs/adr-code-009-service-architecture-patterns/ADR.md) for detailed decision record.
