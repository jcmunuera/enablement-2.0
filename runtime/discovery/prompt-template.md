# Prompt Template: Microservice Generation Request

**Version:** 1.0  
**Last Updated:** 2025-12-05

---

## Purpose

This template helps users provide complete information for microservice generation,
minimizing back-and-forth and ensuring deterministic code generation.

---

## Template for Users

Copy and fill in the following template:

```markdown
## Microservice Generation Request

### 1. Service Information (Required)

- **Service name:** _____________________ (e.g., customer-service)
- **Main entity name:** _____________________ (e.g., Customer)
- **Brief description:** _____________________

### 2. Organization (Required)

- **Group ID:** _____________________ (e.g., com.mybank.customer)
- **Base package:** _____________________ (e.g., com.mybank.customer)

### 3. API Type (Choose one)

- [ ] **Domain API** - Exposes a business capability (most common)
- [ ] **Composable API** - Orchestrates multiple backend services
- [ ] **Experience API** - BFF for specific frontend/channel

### 4. Data Source (Choose one)

- [ ] **Own Database (JPA)**
  - Database type: [ ] PostgreSQL  [ ] MySQL  [ ] Oracle  [ ] Other: _____
  
- [ ] **External System API**
  - System API name: _____________________ (e.g., Parties, Accounts)
  - REST client: [ ] RestClient (recommended)  [ ] Feign  [ ] RestTemplate

### 5. Resilience Patterns (Select all that apply)

- [ ] **Circuit Breaker** - Prevent cascade failures
- [ ] **Retry** - Automatic retry on transient failures
- [ ] **Timeout** - Limit wait time for responses
- [ ] **Rate Limiter** - Throttle request rate

### 6. Entity Fields (List main fields)

| Field Name | Type | Required | Description |
|------------|------|----------|-------------|
| id | UUID | Yes | Unique identifier |
| _____ | _____ | _____ | _____ |
| _____ | _____ | _____ | _____ |
| _____ | _____ | _____ | _____ |

### 7. Attachments (if applicable)

- [ ] Domain API OpenAPI spec (YAML/JSON)
- [ ] System API OpenAPI spec (YAML/JSON)
- [ ] Field mapping file (if domain ↔ system api fields differ)

### 8. Additional Requirements (Optional)

_____________________
```

---

## Example: Completed Template

```markdown
## Microservice Generation Request

### 1. Service Information (Required)

- **Service name:** customer-service
- **Main entity name:** Customer
- **Brief description:** Domain API for customer management, data from Parties System API

### 2. Organization (Required)

- **Group ID:** com.bank.customer
- **Base package:** com.bank.customer

### 3. API Type (Choose one)

- [x] **Domain API** - Exposes a business capability (most common)
- [ ] **Composable API** - Orchestrates multiple backend services
- [ ] **Experience API** - BFF for specific frontend/channel

### 4. Data Source (Choose one)

- [ ] **Own Database (JPA)**
  
- [x] **External System API**
  - System API name: Parties
  - REST client: [x] RestClient (recommended)  [ ] Feign  [ ] RestTemplate

### 5. Resilience Patterns (Select all that apply)

- [x] **Circuit Breaker** - Prevent cascade failures
- [x] **Retry** - Automatic retry on transient failures
- [x] **Timeout** - Limit wait time for responses
- [ ] **Rate Limiter** - Throttle request rate

### 6. Entity Fields (List main fields)

| Field Name | Type | Required | Description |
|------------|------|----------|-------------|
| id | UUID | Yes | Unique identifier |
| firstName | String | Yes | Customer first name |
| lastName | String | Yes | Customer last name |
| email | String | Yes | Contact email |
| status | Enum | Yes | ACTIVE, INACTIVE |
| createdAt | Instant | Yes | Creation timestamp |

### 7. Attachments (if applicable)

- [x] Domain API OpenAPI spec (YAML/JSON) → domain-api-spec.yaml
- [x] System API OpenAPI spec (YAML/JSON) → system-api-parties.yaml
- [x] Field mapping file (if domain ↔ system api fields differ) → mapping.json

### 8. Additional Requirements (Optional)

Use standard bank logging format. Include correlation ID tracking.
```

---

## What Happens After Submission

1. **Discovery Phase:**
   - Your request is analyzed
   - Capabilities are identified (api_architecture, persistence, resilience)
   - Appropriate skill is selected

2. **Input Generation:**
   - A `generation-request.json` is created from your answers
   - Missing information is flagged

3. **Code Generation:**
   - Skill executes using deterministic flow
   - Templates from modules are processed
   - Code is generated with full traceability

4. **Validation:**
   - Tier-1: Project structure
   - Tier-2: Technology compliance
   - Tier-3: Module-specific rules

5. **Output:**
   - Generated project
   - `manifest.json` with file traceability
   - `validation-report.json` with results
   - `execution-audit.json` with complete trace

---

## Minimum Required Information

At minimum, we need:

| Information | Why |
|-------------|-----|
| Service name | Project naming, package structure |
| Entity name | Domain model generation |
| API type | Architecture selection |
| Data source | Persistence layer generation |
| OpenAPI specs | API contract, DTOs, field types |

Without these, code generation cannot proceed deterministically.

---

## Field Mapping File (mapping.json)

If your domain model differs from the System API model, provide a mapping:

```json
{
  "entity": "Customer",
  "systemApiEntity": "Party",
  "fields": [
    {
      "domain": "id",
      "systemApi": "PARTY_ID",
      "transformation": "uuid_format"
    },
    {
      "domain": "firstName",
      "systemApi": "FIRST_NM",
      "transformation": "direct"
    },
    {
      "domain": "status",
      "systemApi": "STAT_CD",
      "transformation": "enum_to_code",
      "mappings": {
        "ACTIVE": "A",
        "INACTIVE": "I"
      }
    }
  ]
}
```

If not provided:
- We'll assume direct 1:1 mapping
- Field names will be inferred from OpenAPI specs
- You may need to adjust the generated mapper manually

---

## Free-Form Alternative

If you prefer natural language, include at minimum:

> "I need a [service-name] microservice that [does what]. 
> The data comes from [own database / System API named X].
> I need [resilience patterns].
> Attached: [list of files]."

Example:
> "I need a customer-service microservice that exposes a Domain API for managing customers.
> The data comes from the Parties System API.
> I need circuit breaker, retry, and timeout.
> Attached: domain-api-spec.yaml, system-api-parties.yaml, mapping.json"
