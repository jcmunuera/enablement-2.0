# Validation - skill-042-add-persistence-java-spring

## Usage

```bash
./validate.sh /path/to/project jpa
./validate.sh /path/to/project systemapi
```

## Checks

### JPA
- JPA entities with @Entity
- JPA repositories
- Persistence adapters
- spring-boot-starter-data-jpa dependency

### System API
- System API clients
- Adapters with @CircuitBreaker
- Resilience configuration
