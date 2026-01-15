# Examples - skill-042-add-persistence-java-spring

## Example 1: Add JPA Persistence

**Request:**
```json
{
  "targetProject": "./customer-service",
  "persistenceType": "jpa",
  "database": "postgresql"
}
```

**Generated:**
- `CustomerJpaEntity.java` - JPA entity
- `CustomerJpaRepository.java` - Spring Data repository
- `CustomerPersistenceAdapter.java` - Implements domain repository

---

## Example 2: Add System API Persistence

**Request:**
```json
{
  "targetProject": "./account-service",
  "persistenceType": "systemapi",
  "baseUrlEnv": "ACCOUNT_SYSTEM_API_URL"
}
```

**Generated:**
- `AccountDto.java` - DTO for backend API
- `AccountClient.java` - REST client
- `AccountSystemApiAdapter.java` - With @CircuitBreaker, @Retry
