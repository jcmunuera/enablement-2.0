# Code Style Rules: Java/Spring

These rules MUST be followed when generating Java/Spring code.
They ensure consistency and reproducibility across generation runs.

---

## DTOs (Request/Response)

| Rule | Implementation |
|------|----------------|
| ID fields use `String` | `private String id;` NOT `private UUID id;` |
| Factory method required | `public static XxxResponse from(Entity entity)` |
| Constructor for required fields | Enable immutability and validation |

**Example:**
```java
public class CustomerResponse {
    private String id;  // ✅ String, not UUID
    private String firstName;
    
    public static CustomerResponse from(Customer entity) {
        CustomerResponse response = new CustomerResponse();
        response.id = entity.getId().value().toString();
        response.firstName = entity.getFirstName();
        return response;
    }
}
```

---

## Mappers

| Rule | Implementation |
|------|----------------|
| Private helper methods | Create reusable null-safe transformation helpers |
| Exact method names | `toUpperCase()`, `toLowerCase()`, `toProperCase()`, `toCode()` |
| Helper placement | Place ALL helpers at END of class, after main mapping methods |
| Helper order | Alphabetical: `toCode()`, `toLowerCase()`, `toProperCase()`, `toUpperCase()` |

**Example:**
```java
@Component
public class CustomerSystemApiMapper {
    
    // Main mapping methods first
    public CustomerSystemApiRequest toSystemApi(Customer domain) { ... }
    public Customer toDomain(CustomerSystemApiResponse response) { ... }
    
    // ========== Helper Methods (alphabetical order) ==========
    
    private String toCode(CustomerStatus status) {
        return status != null ? status.getCode() : null;
    }
    
    private String toLowerCase(String value) {
        return value != null ? value.toLowerCase() : null;
    }
    
    private String toProperCase(String value) {
        if (value == null || value.isEmpty()) return value;
        return value.substring(0, 1).toUpperCase() + value.substring(1).toLowerCase();
    }
    
    private String toUpperCase(String value) {
        return value != null ? value.toUpperCase() : null;
    }
}
```

---

## General Code Style

| Rule | Implementation |
|------|----------------|
| Trailing newline | Every file ends with exactly ONE newline character |
| ASCII comments only | Use `<->` not `↔`, use `->` not `→` |
| No inline null checks | Use helper methods instead of `x != null ? x.toUpperCase() : null` |

---

## Test Code

| Rule | Implementation |
|------|----------------|
| Use String for IDs in tests | `String id = UUID.randomUUID().toString();` |
| Consistent setup order | 1. Create ID, 2. Create Response/Request, 3. Setup mocks, 4. Execute, 5. Verify |
| Factory methods in tests | Use `Request.of(...)` or `new Request(...)` consistently (prefer factory if available) |

---

## Application Services

| Rule | Implementation |
|------|----------------|
| Use DTO factory methods | `return CustomerResponse.from(entity);` NOT manual field mapping |
| No @Transactional with System API | System API uses HTTP, not DB transactions |

**Example:**
```java
@Service
public class CustomerApplicationService {
    
    public CustomerResponse getCustomer(String id) {
        Customer entity = repository.findById(CustomerId.of(id))
            .orElseThrow(() -> new CustomerNotFoundException(id));
        return CustomerResponse.from(entity);  // ✅ Use factory method
    }
}
```
