# Determinism Rules for Code Generation

**Version:** 1.4  
**Date:** 2026-01-19  
**Status:** Active

---

## Purpose

This document defines mandatory rules to ensure **deterministic code generation** across the Enablement 2.0 platform. Following these rules guarantees that:

1. Multiple executions with the same input produce **identical** code
2. Generated code follows established **best practices**
3. Code quality is **predictable and consistent**

---

## Scope

These rules apply to:
- All CODE domain modules (`mod-code-*`)
- All CODE domain skills (`skill-code-*`)
- All generated Java/Spring Boot code

---

## Rule Priority (Conflict Resolution)

When rules conflict, follow this priority (highest to lowest):

| Priority | Source | Example |
|----------|--------|---------|
| 1 (Highest) | MODULE.md `## ⚠️ CRITICAL` section | "NO @Transactional with System API" |
| 2 | MODULE.md templates | Specific code patterns |
| 3 | DETERMINISM-RULES.md | Global patterns (this file) |
| 4 (Lowest) | LLM training knowledge | Default behavior |

**Principle:** Specific rules override general rules. Module rules override global rules.

---

## Global Patterns

### 1. Value Objects (Entity IDs)

**Rule:** Entity IDs MUST be `record` types wrapping `UUID`.

```java
// ✅ CORRECT
public record CustomerId(UUID value) {
    
    public CustomerId {
        Objects.requireNonNull(value, "CustomerId must not be null");
    }
    
    public static CustomerId generate() {
        return new CustomerId(UUID.randomUUID());
    }
    
    public static CustomerId of(String value) {
        return new CustomerId(UUID.fromString(value));
    }
    
    public static CustomerId of(UUID value) {
        return new CustomerId(value);
    }
    
    @Override
    public String toString() {
        return value.toString();
    }
}

// ❌ WRONG - String instead of UUID
public record CustomerId(String value) { ... }

// ❌ WRONG - Class instead of record
public class CustomerId {
    private final String value;
    ...
}
```

**Rationale:**
- `record` ensures immutability
- `UUID` provides type safety and uniqueness
- Compact constructor validates non-null

---

### 2. Request DTOs

**Rule:** Request DTOs MUST be `record` types with validation annotations.

```java
// ✅ CORRECT
public record CreateCustomerRequest(
    @NotBlank(message = "First name is required")
    String firstName,
    
    @NotBlank(message = "Last name is required")
    String lastName,
    
    @Email(message = "Invalid email format")
    String email,
    
    @Past(message = "Date of birth must be in the past")
    LocalDate dateOfBirth
) {}

// ❌ WRONG - Class with Lombok
@Data
@Builder
public class CreateCustomerRequest {
    private String firstName;
    ...
}
```

**Rationale:**
- Records are immutable (DTOs should not change)
- Less boilerplate than Lombok
- Validation annotations work with records

---

### 3. Response DTOs

**Rule:** Response DTOs follow conditional pattern:

| Condition | Pattern |
|-----------|---------|
| No HATEOAS | `record` |
| With HATEOAS | `class extends RepresentationModel` |

```java
// ✅ CORRECT - Without HATEOAS
public record CustomerResponse(
    String id,
    String firstName,
    String lastName,
    String email,
    CustomerStatus status,
    Instant createdAt
) {}

// ✅ CORRECT - With HATEOAS
@Relation(collectionRelation = "customers", itemRelation = "customer")
public class CustomerResponse extends RepresentationModel<CustomerResponse> {
    
    private String id;
    private String firstName;
    // ... getters and setters required for HATEOAS
}
```

**Rationale:**
- HATEOAS requires `extends RepresentationModel` which records cannot do
- Without HATEOAS, records provide immutability

---

### 4. Domain Entities

**Rule:** Domain entities MUST be `class` (not record).

```java
// ✅ CORRECT
public class Customer {
    
    private final CustomerId id;
    private String firstName;
    private String lastName;
    private CustomerStatus status;
    private final Instant createdAt;
    private Instant updatedAt;
    
    // Constructor, business methods, getters...
    
    public void activate() {
        this.status = CustomerStatus.ACTIVE;
        this.updatedAt = Instant.now();
    }
}

// ❌ WRONG - Record (entities are mutable by design)
public record Customer(...) {}
```

**Rationale:**
- Entities have lifecycle and mutable state
- Business methods modify internal state
- Records are immutable by design

---

### 5. Domain Enums

**Rule:** Domain enums MUST be simple (no attributes). Code mapping belongs in Mapper.

```java
// ✅ CORRECT - Simple enum
public enum CustomerStatus {
    ACTIVE,
    INACTIVE,
    BLOCKED
}

// ✅ CORRECT - Mapping in Mapper class
@Component
public class SystemApiMapper {
    
    private CustomerStatus toStatus(String code) {
        return switch (code) {
            case "A" -> CustomerStatus.ACTIVE;
            case "I" -> CustomerStatus.INACTIVE;
            case "B" -> CustomerStatus.BLOCKED;
            default -> throw new IllegalArgumentException("Unknown code: " + code);
        };
    }
    
    private String toCode(CustomerStatus status) {
        return switch (status) {
            case ACTIVE -> "A";
            case INACTIVE -> "I";
            case BLOCKED -> "B";
        };
    }
}

// ❌ WRONG - Enum with code attribute
public enum CustomerStatus {
    ACTIVE("A"),
    INACTIVE("I"),
    BLOCKED("B");
    
    private final String code;
    
    CustomerStatus(String code) { this.code = code; }
    
    public static CustomerStatus fromCode(String code) { ... }
}
```

**Rationale:**
- Separates domain concept from external representation
- Mapper is the single place for transformation logic
- Enum stays pure domain, mapper handles integration

---

### 6. External API DTOs

**Rule:** DTOs for external APIs (System API, third-party) MUST be `record`.

```java
// ✅ CORRECT
public record PartyResponse(
    @JsonProperty("CUST_ID") String custId,
    @JsonProperty("CUST_FNAME") String custFname,
    @JsonProperty("CUST_LNAME") String custLname,
    @JsonProperty("CUST_STATUS") String custStatus,
    @JsonProperty("SYS_RC") String sysRc,
    @JsonProperty("SYS_MSG") String sysMsg
) {}

// ❌ WRONG - Lombok @Data
@Data
@Builder
@Jacksonized
public class PartyResponse {
    @JsonProperty("CUST_ID")
    private String custId;
    ...
}
```

**Rationale:**
- External DTOs are data carriers (immutable)
- `@JsonProperty` works with records
- No need for Lombok complexity

---

### 7. Mappers

**Rule:** Mappers MUST be dedicated `@Component` classes with clear responsibilities.

```java
// ✅ CORRECT
@Component
public class PartyMapper {
    
    private static final DateTimeFormatter DATE_FORMAT = 
        DateTimeFormatter.ofPattern("yyyy-MM-dd");
    
    public Customer toDomain(PartyResponse response) {
        return new Customer(
            toCustomerId(response.custId()),
            toProperCase(response.custFname()),
            toProperCase(response.custLname()),
            response.custEmailAddr().toLowerCase(),
            parseDate(response.custDob()),
            toStatus(response.custStatus()),
            Instant.now(),
            Instant.now()
        );
    }
    
    public PartyCreateRequest toRequest(Customer customer) {
        return new PartyCreateRequest(
            customer.getFirstName().toUpperCase(),
            customer.getLastName().toUpperCase(),
            customer.getEmail().toUpperCase(),
            formatDate(customer.getDateOfBirth())
        );
    }
    
    // Private helper methods for transformations
    private CustomerId toCustomerId(String mainframeId) { ... }
    private CustomerStatus toStatus(String code) { ... }
    private String toCode(CustomerStatus status) { ... }
    private String toProperCase(String value) { ... }
    private LocalDate parseDate(String date) { ... }
    private String formatDate(LocalDate date) { ... }
}
```

**Rationale:**
- Single responsibility for transformation
- All mapping logic in one place
- Testable in isolation

---

## Required Annotations

### Generated Code Annotations

All generated files MUST include Javadoc with:

```java
/**
 * [Class description]
 * 
 * @generated {skill-id} v{version}
 * @module {module-id}
 * @variant {variant-id}  // Only if non-default variant used
 */
```

**Example:**

```java
/**
 * Customer aggregate root.
 * 
 * @generated skill-021-api-rest-java-spring v2.1.0
 * @module mod-code-015-hexagonal-base-java-spring
 */
public class Customer { ... }

/**
 * REST client for Parties System API.
 * 
 * @generated skill-021-api-rest-java-spring v2.1.0
 * @module mod-code-018-api-integration-rest-java-spring
 * @variant restclient
 */
@Component
public class PartiesApiClient { ... }
```

---

## Forbidden Patterns

| Pattern | Reason | Alternative |
|---------|--------|-------------|
| Lombok `@Data` on DTOs | Records are cleaner, immutable | Java `record` |
| Lombok `@Slf4j` | Inconsistent logging setup | Explicit `LoggerFactory.getLogger()` |
| Code mapping in Enum | Couples domain to external systems | Mapper class |
| `String` for entity IDs | Type safety loss | `record` with `UUID` |
| `@TimeLimiter` for sync calls | Forces CompletableFuture unnecessarily | Client-level timeout config |
| Inline validation in constructors | Inconsistent validation | Dedicated validation methods or annotations |
| Mutable DTOs | Data carriers should be immutable | `record` |

---

## Validation

### Tier-3 Validation Scripts

Each module SHOULD include validation scripts that check determinism rules:

```bash
#!/bin/bash
# determinism-check.sh

# Check: All entity IDs are records with UUID
grep -r "public record.*Id(" --include="*.java" | grep -v "UUID" && \
    echo "❌ FAIL: Entity IDs must use UUID" && exit 1

# Check: No Lombok @Data on DTOs
grep -r "@Data" --include="*.java" | grep -E "(Request|Response|Dto)" && \
    echo "❌ FAIL: DTOs must be records, not @Data classes" && exit 1

# Check: Enums have no constructor with parameters
grep -rA5 "public enum" --include="*.java" | grep -E "^\s+[A-Z_]+\(" && \
    echo "❌ FAIL: Enums must be simple (no attributes)" && exit 1

echo "✅ PASS: Determinism rules validated"
exit 0
```

---

## Code Style Conventions (v1.1)

> **NEW in v1.1:** These conventions ensure consistent code style across generations.

### Method Ordering

**Rule:** Methods in generated classes MUST follow this order:

```
1. Static factory methods (of, from, create, generate)
2. Constructor(s)
3. Public business methods (alphabetically)
4. Public getters (alphabetically)
5. Protected methods (alphabetically)
6. Private methods (alphabetically)
7. equals/hashCode/toString (if not record)
8. Builder class (if applicable)
```

**Example:**

```java
public class CustomerApplicationService {
    
    // 1. Static factory (none in this case)
    
    // 2. Constructor
    public CustomerApplicationService(CustomerRepository repository) {
        this.repository = repository;
    }
    
    // 3. Public business methods (alphabetically)
    public CustomerResponse createCustomer(CreateCustomerRequest request) { ... }
    
    public void deleteCustomer(CustomerId id) { ... }
    
    public CustomerResponse getCustomer(CustomerId id) { ... }
    
    public List<CustomerResponse> listCustomers() { ... }
    
    public CustomerResponse updateCustomer(CustomerId id, UpdateCustomerRequest request) { ... }
    
    // 4. Private methods
    private Customer mapToDomain(CreateCustomerRequest request) { ... }
    
    private CustomerResponse mapToResponse(Customer customer) { ... }
}
```

### Javadoc Standards

**Rule:** Generated code MUST include Javadoc for:
- Class/interface declarations
- Public methods
- Complex private methods

**Javadoc Template:**

```java
/**
 * Brief description (one line).
 * 
 * Extended description if needed (optional).
 * 
 * @param paramName parameter description
 * @return return value description
 * @throws ExceptionType when this happens
 * 
 * @generated {skillId} v{skillVersion}
 * @module {moduleId}
 */
```

**Mandatory Javadoc Elements:**

| Element | Required | Example |
|---------|----------|---------|
| Brief description | ✅ Yes | `Customer repository port.` |
| @param | ✅ If has params | `@param id the customer ID` |
| @return | ✅ If non-void | `@return the customer if found` |
| @throws | ⚠️ If throws | `@throws CustomerNotFoundException` |
| @generated | ✅ Yes | `@generated skill-021 v2.3.0` |
| @module | ✅ Yes | `@module mod-code-015` |

**Example:**

```java
/**
 * Find customer by ID.
 * 
 * Retrieves customer from System API and maps to domain model.
 * 
 * @param id the customer ID (must not be null)
 * @return Optional containing the customer if found, empty otherwise
 * @throws SystemApiUnavailableException if System API is down
 * 
 * @generated skill-021-api-rest-java-spring v2.3.0
 * @module mod-code-017-persistence-systemapi
 */
public Optional<Customer> findById(CustomerId id) {
    ...
}
```

---

## Method Ordering Convention (v1.2)

**Rule:** Methods in generated classes MUST follow this order:

### For all classes:

```
1. Static factory methods (of(), from(), create())
2. Constructor(s)
3. Public methods (alphabetical)
4. Package-private methods (alphabetical)
5. Private methods (alphabetical)
```

### For Controllers:

```
1. POST (create)
2. GET by ID (read one)
3. GET all (read many/list)
4. PUT (update)
5. PATCH (partial update)
6. DELETE (delete)
```

### For Repositories:

```
1. findById()
2. findAll()
3. save()
4. deleteById()
5. existsById()
6. Custom query methods (alphabetical)
```

### For Services:

```
1. Create operations
2. Read operations (get, find, list)
3. Update operations
4. Delete operations
5. Validation/utility methods
```

**Example - ApplicationService:**

```java
@Service
public class CustomerApplicationService {
    
    // 1. Create
    public CustomerResponse createCustomer(CreateCustomerRequest request) { ... }
    
    // 2. Read
    public CustomerResponse getCustomer(UUID id) { ... }
    public Page<CustomerResponse> listCustomers(Pageable pageable) { ... }
    
    // 3. Update
    public CustomerResponse updateCustomer(UUID id, UpdateCustomerRequest request) { ... }
    
    // 4. Delete
    public void deleteCustomer(UUID id) { ... }
}
```

---

## Javadoc Standards (v1.2)

**Rule:** All public classes and methods MUST have Javadoc comments.

### Class-level Javadoc:

```java
/**
 * Brief description of the class purpose.
 * 
 * <p>Additional details if needed, explaining behavior or constraints.</p>
 * 
 * @generated {skillId} v{skillVersion}
 * @module {moduleId}
 */
public class CustomerApplicationService { ... }
```

### Method-level Javadoc:

```java
/**
 * Brief description of what the method does.
 * 
 * @param paramName description of the parameter
 * @return description of return value
 * @throws ExceptionType when this exception is thrown
 */
public CustomerResponse getCustomer(UUID id) { ... }
```

### Required Tags:

| Element | Required Tags |
|---------|---------------|
| Public class | Description + `@generated` + `@module` |
| Public method | Description + `@param` (all) + `@return` (if not void) + `@throws` (if applicable) |
| Interface | Description + purpose |
| Enum | Description + each constant |

### Forbidden:

```java
// ❌ WRONG - No Javadoc
public CustomerResponse getCustomer(UUID id) { ... }

// ❌ WRONG - Empty Javadoc
/**
 */
public CustomerResponse getCustomer(UUID id) { ... }

// ❌ WRONG - Redundant/useless Javadoc
/**
 * Gets the customer.
 * @param id the id
 * @return the customer
 */
public CustomerResponse getCustomer(UUID id) { ... }
```

### Correct:

```java
/**
 * Retrieves a customer by their unique identifier.
 * 
 * @param id the customer's UUID
 * @return the customer data including personal information and status
 * @throws CustomerNotFoundException if no customer exists with the given ID
 */
public CustomerResponse getCustomer(UUID id) { ... }
```

---

## Applicability by Module

| Module | Applies | Notes |
|--------|---------|-------|
| mod-code-015-hexagonal-base | ✅ Full | Core patterns |
| mod-code-016-persistence-jpa | ✅ Full | JPA entities follow entity rules |
| mod-code-017-persistence-systemapi | ✅ Full | External DTOs, mappers |
| mod-code-018-api-integration-rest | ✅ Full | Client DTOs |
| mod-code-019-api-public-exposure | ✅ Partial | HATEOAS exception for Response |
| mod-code-020-compensation | ✅ Full | Domain types |
| mod-code-001/002/003/004 (Resilience) | ⚠️ Limited | Focus on annotation placement |

---

## Related Documents

- `model/standards/authoring/MODULE.md` - Module authoring guide
- `model/standards/ASSET-STANDARDS-v1.4.md` - Asset standards
- `runtime/flows/code/GENERATE.md` - Generation flow with variant selection
- `runtime/schemas/manifest.schema.json` - Manifest JSON Schema (v1.1)

---

## Known LLM Hallucinations (CRITICAL)

> **These are patterns that LLMs consistently generate incorrectly.**
> **Memorize these anti-patterns and NEVER use them.**

### Module-Specific Rules

Some hallucination rules are **module-specific** and documented in their respective MODULE.md files:

| Rule | Module | Description |
|------|--------|-------------|
| NO @Transactional with System API | mod-017 | Don't use database transactions with HTTP persistence |
| NO Spring Data Pageable without JPA | mod-019 | Use @RequestParam for pagination, not Pageable |
| RestClient is DEFAULT | mod-018 | Only use Feign if explicitly requested |

**Principle:** Module-specific rules live with their modules. If a module is deprecated, its rules go with it.

---

### HALLUCINATION-001: String.replace with 3 arguments

**The LLM frequently generates:**
```java
// ❌ DOES NOT COMPILE - This method does not exist in Java
String result = value.replace("-", "T", 3);
String result = value.replace(".", ":", 3);

// ❌ DOES NOT COMPILE - replace() does not accept an index parameter
value.replace(":", ".", value.lastIndexOf('.'));
```

**Java String.replace() signatures:**
- `replace(char oldChar, char newChar)` ✅
- `replace(CharSequence target, CharSequence replacement)` ✅
- `replace(String, String, int)` ❌ **DOES NOT EXIST**

**Correct alternative for DB2 timestamp parsing:**
```java
// ✅ CORRECT - Use substring() for positional manipulation
// DB2 format: 2024-01-15-10.30.00.000000 (26 chars)
// ISO format: 2024-01-15T10:30:00.000000Z
if (timestamp.length() >= 26) {
    String iso = timestamp.substring(0, 10) + "T" +  // yyyy-MM-dd
        timestamp.substring(11, 13) + ":" +          // HH
        timestamp.substring(14, 16) + ":" +          // mm
        timestamp.substring(17, 19) + "." +          // ss
        timestamp.substring(20) + "Z";               // SSSSSS
    return Instant.parse(iso);
}
```

**Common context:** DB2 timestamp parsing (`yyyy-MM-dd-HH.mm.ss.SSSSSS`)

**Correct implementation:** See `mod-code-017-persistence-systemapi/MODULE.md` section "CRITICAL: Timestamp Parsing"
## Mandatory Dependency Versions (CRITICAL)

> **LLMs frequently generate incorrect or non-existent dependency versions.**
> **ALWAYS use the EXACT versions specified below.**

### Spring Boot Stack (pom.xml)

```xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.2.0</version>
    <relativePath/>
</parent>

<properties>
    <java.version>17</java.version>
    <resilience4j.version>2.2.0</resilience4j.version>
    <mapstruct.version>1.5.5.Final</mapstruct.version>
    <springdoc.version>2.3.0</springdoc.version>
    <testcontainers.version>1.19.3</testcontainers.version>
</properties>
```

### Resilience4j (CRITICAL)

**MANDATORY version: 2.2.0**

```xml
<!-- ✅ CORRECT - Use property for version -->
<dependency>
    <groupId>io.github.resilience4j</groupId>
    <artifactId>resilience4j-spring-boot3</artifactId>
    <version>${resilience4j.version}</version>
</dependency>

<!-- ❌ WRONG - Version 3.x DOES NOT EXIST -->
<dependency>
    <groupId>io.github.resilience4j</groupId>
    <artifactId>resilience4j-spring-boot3</artifactId>
    <version>3.0.1</version>  <!-- DOES NOT EXIST IN MAVEN CENTRAL -->
</dependency>
```

### OpenAPI/SpringDoc

```xml
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>${springdoc.version}</version>
</dependency>
```

### Complete pom.xml Dependencies Template

```xml
<dependencies>
    <!-- Spring Boot Starters (version from parent) -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-validation</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-hateoas</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-aop</artifactId>
    </dependency>
    
    <!-- Resilience4j - MUST use ${resilience4j.version} -->
    <dependency>
        <groupId>io.github.resilience4j</groupId>
        <artifactId>resilience4j-spring-boot3</artifactId>
        <version>${resilience4j.version}</version>
    </dependency>
    
    <!-- OpenAPI Documentation -->
    <dependency>
        <groupId>org.springdoc</groupId>
        <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
        <version>${springdoc.version}</version>
    </dependency>
    
    <!-- Testing -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```

### HALLUCINATION-003: Non-existent Resilience4j Versions

**The LLM frequently generates:**
```xml
<!-- ❌ DOES NOT EXIST IN MAVEN CENTRAL -->
<version>3.0.0</version>
<version>3.0.1</version>
<version>2.3.0</version>
```

**Actual available versions (as of 2026-01):**
- 2.1.0 ✅ (recommended for Spring Boot 3.x)
- 2.0.2 ✅
- 1.7.x (for Spring Boot 2.x)

**Rule:** ALWAYS define `<resilience4j.version>2.2.0</resilience4j.version>` in properties and reference as `${resilience4j.version}`.

### POM Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `<n>` instead of `<name>` | Typo/truncation | Use `<name>` tag |
| Missing version for resilience4j | Not in Spring Boot BOM | Add explicit version |
| Wrong parent version | Hallucination | Use 3.2.0 |

---

### HALLUCINATION-006: Missing java.time Imports

**The LLM frequently forgets:**
```java
// ❌ WRONG - Missing import
public record Customer(LocalDate birthDate) { }  // LocalDate not imported
```

**Correct:**
```java
// ✅ CORRECT - Always import java.time classes
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Instant;

public record Customer(LocalDate birthDate) { }
```

**Rule:** ALWAYS import `java.time.*` classes explicitly. Never assume they are auto-imported.
