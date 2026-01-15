# Examples - skill-041-add-api-exposure-java-spring

## Example: Promote Internal Service to Domain API

**Before:** Internal microservice with domain logic but no REST exposure.

**Request:**
```json
{
  "targetProject": "./customer-service",
  "apiLayer": "domain"
}
```

**Generated Files:**
- `CustomerController.java` - REST endpoints
- `CustomerResponse.java` - Response DTO
- `CustomerFilter.java` - Query parameters
- `PageResponse.java` - Pagination wrapper
- `CustomerModelAssembler.java` - HATEOAS links

**Result:** Service now exposes REST API at `/api/v1/customers` with:
- GET (list with pagination)
- GET /{id}
- POST
- PUT /{id}
- DELETE /{id}
