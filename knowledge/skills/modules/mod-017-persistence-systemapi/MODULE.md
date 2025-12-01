---
id: mod-017-persistence-systemapi
title: "MOD-017: System API Persistence"
version: 1.2
date: 2025-12-01
status: Active
derived_from: eri-code-012-persistence-patterns-java-spring
depends_on:
  - mod-018-api-integration-rest-java-spring
domain: code
tags:
  - java
  - spring-boot
  - system-api
  - persistence
  - resilience
used_by:
  - skill-code-020-generate-microservice-java-spring
---

# MOD-017: System API Persistence

## Overview

Reusable templates for implementing persistence via System API delegation. The Domain API's repository delegates to a REST client that calls System APIs wrapping mainframe transactions.

**Source ERI:** [ERI-CODE-012](../../../ERIs/eri-code-012-persistence-patterns-java-spring/ERI.md)

**Depends on:** [mod-018-api-integration-rest-java-spring](../mod-018-api-integration-rest-java-spring/MODULE.md) for REST client

**Use when:** Service delegates persistence to mainframe via System APIs

---

## Structure

```
mod-017-persistence-systemapi/
├── MODULE.md
├── templates/
│   ├── dto/
│   │   └── Dto.java.tpl
│   ├── mapper/
│   │   └── SystemApiMapper.java.tpl
│   ├── adapter/
│   │   └── SystemApiAdapter.java.tpl     # Uses client from mod-018
│   ├── config/
│   │   └── application-systemapi.yml.tpl
│   ├── exception/
│   │   └── SystemApiUnavailableException.java.tpl
│   └── test/
│       └── SystemApiAdapterTest.java.tpl
└── validation/
    ├── README.md
    └── systemapi-check.sh
```

> **Note:** REST client templates (feign, restclient, resttemplate) have been moved to 
> [mod-018-api-integration-rest-java-spring](../mod-018-api-integration-rest-java-spring/MODULE.md).
> This module focuses on the persistence adapter that wraps the client with resilience patterns.

---

## Template: DTO

```java
// File: {basePackage}/adapter/systemapi/dto/{Entity}Dto.java

package {basePackage}.adapter.systemapi.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class {Entity}Dto {
    
    @JsonProperty("{idJsonField}")
    private String id;
    
    // Add fields matching System API contract
}
```

---

## Template: Client (Feign)

```java
// File: {basePackage}/adapter/systemapi/client/{Entity}SystemApiClient.java

package {basePackage}.adapter.systemapi.client;

import {basePackage}.adapter.systemapi.dto.{Entity}Dto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@FeignClient(
    name = "{serviceName}-system-api",
    url = "${system-api.{serviceName}.base-url}",
    configuration = SystemApiFeignConfig.class
)
public interface {Entity}SystemApiClient {
    
    @GetMapping("/api/v1/{resourcePath}/{id}")
    {Entity}Dto findById(@PathVariable("id") String id);
    
    @PostMapping("/api/v1/{resourcePath}")
    {Entity}Dto save(@RequestBody {Entity}Dto dto);
    
    @DeleteMapping("/api/v1/{resourcePath}/{id}")
    void deleteById(@PathVariable("id") String id);
}
```

---

## Template: Client (RestTemplate)

```java
// File: {basePackage}/adapter/systemapi/client/{Entity}SystemApiClient.java

package {basePackage}.adapter.systemapi.client;

import {basePackage}.adapter.systemapi.dto.{Entity}Dto;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

@Component
@RequiredArgsConstructor
public class {Entity}SystemApiClient {
    
    private final RestTemplate restTemplate;
    
    @Value("${system-api.{serviceName}.base-url}")
    private String baseUrl;
    
    public {Entity}Dto findById(String id) {
        HttpEntity<Void> entity = new HttpEntity<>(createHeaders());
        ResponseEntity<{Entity}Dto> response = restTemplate.exchange(
            baseUrl + "/api/v1/{resourcePath}/{id}",
            HttpMethod.GET,
            entity,
            {Entity}Dto.class,
            id
        );
        return response.getBody();
    }
    
    public {Entity}Dto save({Entity}Dto dto) {
        HttpEntity<{Entity}Dto> entity = new HttpEntity<>(dto, createHeaders());
        ResponseEntity<{Entity}Dto> response = restTemplate.exchange(
            baseUrl + "/api/v1/{resourcePath}",
            HttpMethod.POST,
            entity,
            {Entity}Dto.class
        );
        return response.getBody();
    }
    
    public void deleteById(String id) {
        HttpEntity<Void> entity = new HttpEntity<>(createHeaders());
        restTemplate.exchange(
            baseUrl + "/api/v1/{resourcePath}/{id}",
            HttpMethod.DELETE,
            entity,
            Void.class,
            id
        );
    }
    
    private HttpHeaders createHeaders() {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("X-Source-System", "{serviceName}-domain-api");
        headers.set("X-Correlation-Id", java.util.UUID.randomUUID().toString());
        return headers;
    }
}
```

---

## Template: Client (RestClient)

```java
// File: {basePackage}/adapter/systemapi/client/{Entity}SystemApiClient.java

package {basePackage}.adapter.systemapi.client;

import {basePackage}.adapter.systemapi.dto.{Entity}Dto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

@Component
@RequiredArgsConstructor
public class {Entity}SystemApiClient {
    
    private final RestClient restClient;
    
    public {Entity}Dto findById(String id) {
        return restClient.get()
            .uri("/api/v1/{resourcePath}/{id}", id)
            .header("X-Source-System", "{serviceName}-domain-api")
            .retrieve()
            .body({Entity}Dto.class);
    }
    
    public {Entity}Dto save({Entity}Dto dto) {
        return restClient.post()
            .uri("/api/v1/{resourcePath}")
            .header("X-Source-System", "{serviceName}-domain-api")
            .body(dto)
            .retrieve()
            .body({Entity}Dto.class);
    }
    
    public void deleteById(String id) {
        restClient.delete()
            .uri("/api/v1/{resourcePath}/{id}", id)
            .header("X-Source-System", "{serviceName}-domain-api")
            .retrieve()
            .toBodilessEntity();
    }
}
```

---

## Template: Mapper

```java
// File: {basePackage}/adapter/systemapi/mapper/{Entity}SystemApiMapper.java

package {basePackage}.adapter.systemapi.mapper;

import {basePackage}.adapter.systemapi.dto.{Entity}Dto;
import {basePackage}.domain.model.{Entity};
import org.springframework.stereotype.Component;

@Component
public class {Entity}SystemApiMapper {
    
    public {Entity} toDomain({Entity}Dto dto) {
        if (dto == null) return null;
        
        return {Entity}.builder()
            .id(dto.getId())
            // Map other fields
            .build();
    }
    
    public {Entity}Dto toDto({Entity} domain) {
        if (domain == null) return null;
        
        return {Entity}Dto.builder()
            .id(domain.getId())
            // Map other fields
            .build();
    }
}
```

---

## Template: Adapter (with Resilience)

```java
// File: {basePackage}/adapter/systemapi/{Entity}SystemApiAdapter.java

package {basePackage}.adapter.systemapi;

import {basePackage}.adapter.systemapi.client.{Entity}SystemApiClient;
import {basePackage}.adapter.systemapi.dto.{Entity}Dto;
import {basePackage}.adapter.systemapi.mapper.{Entity}SystemApiMapper;
import {basePackage}.domain.model.{Entity};
import {basePackage}.domain.repository.{Entity}Repository;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import io.github.resilience4j.retry.annotation.Retry;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
@RequiredArgsConstructor
@Slf4j
public class {Entity}SystemApiAdapter implements {Entity}Repository {
    
    private final {Entity}SystemApiClient client;
    private final {Entity}SystemApiMapper mapper;
    
    private static final String SYSTEM_API = "{serviceName}SystemApi";
    
    @Override
    @CircuitBreaker(name = SYSTEM_API, fallbackMethod = "findByIdFallback")
    @Retry(name = SYSTEM_API)
    public Optional<{Entity}> findById(String id) {
        log.debug("Fetching {entity} from System API: {}", id);
        {Entity}Dto dto = client.findById(id);
        return Optional.ofNullable(mapper.toDomain(dto));
    }
    
    private Optional<{Entity}> findByIdFallback(String id, Exception ex) {
        log.warn("System API unavailable for {entity}: {}. Error: {}", id, ex.getMessage());
        return Optional.empty();
    }
    
    @Override
    @CircuitBreaker(name = SYSTEM_API)
    @Retry(name = SYSTEM_API)
    public {Entity} save({Entity} entity) {
        log.debug("Saving {entity} via System API: {}", entity.getId());
        {Entity}Dto dto = mapper.toDto(entity);
        {Entity}Dto saved = client.save(dto);
        return mapper.toDomain(saved);
    }
    
    @Override
    @CircuitBreaker(name = SYSTEM_API)
    @Retry(name = SYSTEM_API)
    public void deleteById(String id) {
        log.debug("Deleting {entity} via System API: {}", id);
        client.deleteById(id);
    }
}
```

---

## Template: Feign Configuration

```java
// File: {basePackage}/adapter/systemapi/config/SystemApiFeignConfig.java

package {basePackage}.adapter.systemapi.config;

import feign.Logger;
import feign.RequestInterceptor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SystemApiFeignConfig {
    
    @Bean
    public Logger.Level feignLoggerLevel() {
        return Logger.Level.BASIC;
    }
    
    @Bean
    public RequestInterceptor systemApiRequestInterceptor() {
        return requestTemplate -> {
            requestTemplate.header("X-Source-System", "{serviceName}-domain-api");
            requestTemplate.header("X-Correlation-Id", java.util.UUID.randomUUID().toString());
        };
    }
}
```

---

## Template: Configuration

### application.yml

```yaml
system-api:
  {serviceName}:
    base-url: ${SYSTEM_API_{SERVICE_NAME}_URL:http://localhost:8081}
    connect-timeout: 5s
    read-timeout: 10s

# Feign (if using Feign)
feign:
  client:
    config:
      {serviceName}-system-api:
        connectTimeout: 5000
        readTimeout: 10000
        loggerLevel: basic

# Resilience4j
resilience4j:
  circuitbreaker:
    instances:
      {serviceName}SystemApi:
        slidingWindowSize: 10
        failureRateThreshold: 50
        waitDurationInOpenState: 30s
        permittedNumberOfCallsInHalfOpenState: 3
        
  retry:
    instances:
      {serviceName}SystemApi:
        maxAttempts: 3
        waitDuration: 500ms
        enableExponentialBackoff: true
        exponentialBackoffMultiplier: 2
        retryExceptions:
          - java.net.ConnectException
          - java.net.SocketTimeoutException
        ignoreExceptions:
          - {basePackage}.domain.exception.{Entity}NotFoundException

management:
  health:
    circuitbreakers:
      enabled: true
```

---

## Template: Dependencies

### pom.xml (Feign)

```xml
<!-- Feign Client -->
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-openfeign</artifactId>
</dependency>

<!-- Resilience4j -->
<dependency>
    <groupId>io.github.resilience4j</groupId>
    <artifactId>resilience4j-spring-boot3</artifactId>
    <version>2.1.0</version>
</dependency>

<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-aop</artifactId>
</dependency>
```

### pom.xml (RestTemplate/RestClient)

```xml
<!-- Web Client -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>

<!-- Resilience4j -->
<dependency>
    <groupId>io.github.resilience4j</groupId>
    <artifactId>resilience4j-spring-boot3</artifactId>
    <version>2.1.0</version>
</dependency>

<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-aop</artifactId>
</dependency>
```

---

## Template: Unit Test

```java
// File: {basePackage}/adapter/systemapi/{Entity}SystemApiAdapterTest.java

package {basePackage}.adapter.systemapi;

import {basePackage}.adapter.systemapi.client.{Entity}SystemApiClient;
import {basePackage}.adapter.systemapi.dto.{Entity}Dto;
import {basePackage}.adapter.systemapi.mapper.{Entity}SystemApiMapper;
import {basePackage}.domain.model.{Entity};
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class {Entity}SystemApiAdapterTest {
    
    @Mock
    private {Entity}SystemApiClient client;
    
    @Mock
    private {Entity}SystemApiMapper mapper;
    
    @InjectMocks
    private {Entity}SystemApiAdapter adapter;
    
    @Test
    void findById_existingEntity_returnsEntity() {
        // Arrange
        String id = "test-id";
        {Entity}Dto dto = new {Entity}Dto();
        {Entity} expected = {Entity}.builder().id(id).build();
        
        when(client.findById(id)).thenReturn(dto);
        when(mapper.toDomain(dto)).thenReturn(expected);
        
        // Act
        Optional<{Entity}> result = adapter.findById(id);
        
        // Assert
        assertThat(result).isPresent();
        assertThat(result.get().getId()).isEqualTo(id);
        verify(client).findById(id);
    }
    
    @Test
    void save_validEntity_returnsPersistedEntity() {
        // Arrange
        {Entity} entity = {Entity}.builder().id("test-id").build();
        {Entity}Dto dto = new {Entity}Dto();
        
        when(mapper.toDto(entity)).thenReturn(dto);
        when(client.save(dto)).thenReturn(dto);
        when(mapper.toDomain(dto)).thenReturn(entity);
        
        // Act
        {Entity} result = adapter.save(entity);
        
        // Assert
        assertThat(result).isNotNull();
        verify(client).save(dto);
    }
}
```

---

## Parameter Reference

| Parameter | Description | Example |
|-----------|-------------|---------|
| `{basePackage}` | Base Java package | `com.company.customer` |
| `{Entity}` | Entity name (PascalCase) | `Customer` |
| `{entity}` | Entity name (camelCase) | `customer` |
| `{serviceName}` | Service name (lowercase) | `customer` |
| `{SERVICE_NAME}` | Service name (UPPERCASE) | `CUSTOMER` |
| `{resourcePath}` | REST resource path | `customers` |
| `{idJsonField}` | JSON field for ID | `customer_id` |

---

## Client Selection

| Client | Use When | Dependencies |
|--------|----------|--------------|
| **Feign** | New projects, clean interfaces | spring-cloud-starter-openfeign |
| **RestTemplate** | Legacy code, simple cases | spring-boot-starter-web |
| **RestClient** | Spring Boot 3.2+, modern API | spring-boot-starter-web |

---

## Validation

See [validation/README.md](validation/README.md) for validation script details.

---

## Related

- **Source ERI:** [ERI-CODE-012](../../../ERIs/eri-code-012-persistence-patterns-java-spring/ERI.md)
- **Alternative:** mod-016-persistence-jpa-spring (for local database)
- **Resilience:** mod-001 (Circuit Breaker), mod-002 (Retry)
