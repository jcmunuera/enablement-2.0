# ERI-CODE-013: API Integration REST - Java/Spring

**ERI ID:** eri-code-013-api-integration-rest-java-spring  
**Version:** 1.0  
**Date:** 2025-12-01  
**Status:** Active  
**Implements:** ADR-012 (API Integration Patterns)  
**Technology:** Java 17+ / Spring Boot 3.2.x  

---

## Overview

Reference implementation for REST API integration in Java/Spring Boot. Provides patterns for calling external REST APIs (internal services, System APIs, third-party services) with built-in resilience and observability.

### When to Use

- Domain API calling System APIs (mainframe)
- Domain API calling other Domain APIs
- Composable API orchestrating Domain APIs
- BFF calling backend APIs
- Any service calling external REST APIs

---

## Client Options

This ERI documents three functionally equivalent REST client implementations. All produce the same architectural result (HTTP client calling REST API) but with different API styles.

### Option Comparison

| Aspect | Feign | RestClient | RestTemplate |
|--------|-------|------------|--------------|
| **Style** | Declarative (interface) | Fluent (builder) | Imperative |
| **Spring Boot** | Any (extra dependency) | 3.2+ (native) | Any (native) |
| **Boilerplate** | Minimal | Low | Medium |
| **Flexibility** | Limited | High | High |
| **Dynamic headers** | Interceptors | Inline | Inline |
| **Testing** | Mock interface | Mock RestClient | Mock RestTemplate |
| **Recommended for** | Stable internal APIs | External/Legacy | Legacy code |

### Default Recommendation

**RestClient** is the recommended default because:
- Native to Spring Boot 3.2+ (no extra dependencies)
- Fluent API is readable and maintainable
- Full control over request/response handling
- Easy inline header manipulation
- Best for non-standardized APIs (legacy, external)

---

## Option A: Feign Client (Declarative)

Best for well-defined, stable APIs where declarative style improves readability.

### Implementation

```java
package com.company.customer.adapter.integration.client;

import com.company.customer.adapter.integration.dto.PartyDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Feign client for Parties System API.
 * Declarative HTTP client - interface only, implementation generated.
 */
@FeignClient(
    name = "parties-system-api",
    url = "${integration.parties-api.base-url}",
    configuration = PartiesApiClientConfig.class
)
public interface PartiesApiClient {
    
    @GetMapping("/parties/{id}")
    PartyDto getById(@PathVariable("id") String id);
    
    @GetMapping("/parties")
    List<PartyDto> getAll();
    
    @PostMapping("/parties")
    PartyDto create(@RequestBody PartyDto party);
    
    @PutMapping("/parties/{id}")
    PartyDto update(@PathVariable("id") String id, @RequestBody PartyDto party);
    
    @DeleteMapping("/parties/{id}")
    void delete(@PathVariable("id") String id);
}
```

### Configuration

```java
package com.company.customer.adapter.integration.client;

import feign.RequestInterceptor;
import org.slf4j.MDC;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class PartiesApiClientConfig {
    
    @Bean
    public RequestInterceptor correlationInterceptor() {
        return template -> {
            String correlationId = MDC.get("correlationId");
            if (correlationId != null) {
                template.header("X-Correlation-ID", correlationId);
            }
            template.header("X-Source-System", "customer-domain-api");
        };
    }
}
```

### Dependencies (pom.xml)

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-openfeign</artifactId>
</dependency>
```

### Enable Feign

```java
@SpringBootApplication
@EnableFeignClients
public class CustomerApplication { }
```

---

## Option B: RestClient (Fluent) - RECOMMENDED

Best for external/legacy APIs where flexibility and control are needed.

### Implementation

```java
package com.company.customer.adapter.integration.client;

import com.company.customer.adapter.integration.dto.PartyDto;
import com.company.customer.adapter.integration.exception.IntegrationException;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.MDC;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.util.List;

/**
 * RestClient implementation for Parties System API.
 * Fluent API with full control over requests.
 */
@Slf4j
@Component
public class PartiesApiClient {
    
    private final RestClient restClient;
    private final String baseUrl;
    
    public PartiesApiClient(
            RestClient.Builder restClientBuilder,
            @Value("${integration.parties-api.base-url}") String baseUrl) {
        this.baseUrl = baseUrl;
        this.restClient = restClientBuilder
            .baseUrl(baseUrl)
            .defaultStatusHandler(
                status -> status.is4xxClientError() || status.is5xxServerError(),
                (request, response) -> {
                    throw new IntegrationException(
                        "Parties API error: " + response.getStatusCode(),
                        response.getStatusCode().value()
                    );
                }
            )
            .build();
    }
    
    public PartyDto getById(String id) {
        log.debug("Fetching party with id: {}", id);
        
        return restClient.get()
            .uri("/parties/{id}", id)
            .headers(this::addCorrelationHeaders)
            .retrieve()
            .body(PartyDto.class);
    }
    
    public List<PartyDto> getAll() {
        log.debug("Fetching all parties");
        
        return restClient.get()
            .uri("/parties")
            .headers(this::addCorrelationHeaders)
            .retrieve()
            .body(new ParameterizedTypeReference<>() {});
    }
    
    public PartyDto create(PartyDto party) {
        log.debug("Creating party: {}", party);
        
        return restClient.post()
            .uri("/parties")
            .headers(this::addCorrelationHeaders)
            .contentType(MediaType.APPLICATION_JSON)
            .body(party)
            .retrieve()
            .body(PartyDto.class);
    }
    
    public PartyDto update(String id, PartyDto party) {
        log.debug("Updating party {}: {}", id, party);
        
        return restClient.put()
            .uri("/parties/{id}", id)
            .headers(this::addCorrelationHeaders)
            .contentType(MediaType.APPLICATION_JSON)
            .body(party)
            .retrieve()
            .body(PartyDto.class);
    }
    
    public void delete(String id) {
        log.debug("Deleting party: {}", id);
        
        restClient.delete()
            .uri("/parties/{id}", id)
            .headers(this::addCorrelationHeaders)
            .retrieve()
            .toBodilessEntity();
    }
    
    private void addCorrelationHeaders(org.springframework.http.HttpHeaders headers) {
        String correlationId = MDC.get("correlationId");
        if (correlationId != null) {
            headers.set("X-Correlation-ID", correlationId);
        }
        headers.set("X-Source-System", "customer-domain-api");
    }
}
```

### Configuration

```java
package com.company.customer.infrastructure.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestClient;

@Configuration
public class RestClientConfig {
    
    @Bean
    public RestClient.Builder restClientBuilder() {
        return RestClient.builder();
    }
}
```

### Dependencies

No extra dependencies - RestClient is native to Spring Boot 3.2+.

---

## Option C: RestTemplate (Imperative)

For legacy codebases or when RestClient is not available.

### Implementation

```java
package com.company.customer.adapter.integration.client;

import com.company.customer.adapter.integration.dto.PartyDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.MDC;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import java.util.List;

/**
 * RestTemplate implementation for Parties System API.
 * Imperative style with explicit request building.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class PartiesApiClient {
    
    private final RestTemplate restTemplate;
    
    @Value("${integration.parties-api.base-url}")
    private String baseUrl;
    
    public PartyDto getById(String id) {
        log.debug("Fetching party with id: {}", id);
        
        HttpEntity<Void> entity = new HttpEntity<>(createHeaders());
        ResponseEntity<PartyDto> response = restTemplate.exchange(
            baseUrl + "/parties/{id}",
            HttpMethod.GET,
            entity,
            PartyDto.class,
            id
        );
        return response.getBody();
    }
    
    public List<PartyDto> getAll() {
        log.debug("Fetching all parties");
        
        HttpEntity<Void> entity = new HttpEntity<>(createHeaders());
        ResponseEntity<List<PartyDto>> response = restTemplate.exchange(
            baseUrl + "/parties",
            HttpMethod.GET,
            entity,
            new ParameterizedTypeReference<>() {}
        );
        return response.getBody();
    }
    
    public PartyDto create(PartyDto party) {
        log.debug("Creating party: {}", party);
        
        HttpEntity<PartyDto> entity = new HttpEntity<>(party, createHeaders());
        ResponseEntity<PartyDto> response = restTemplate.exchange(
            baseUrl + "/parties",
            HttpMethod.POST,
            entity,
            PartyDto.class
        );
        return response.getBody();
    }
    
    public void delete(String id) {
        log.debug("Deleting party: {}", id);
        
        HttpEntity<Void> entity = new HttpEntity<>(createHeaders());
        restTemplate.exchange(
            baseUrl + "/parties/{id}",
            HttpMethod.DELETE,
            entity,
            Void.class,
            id
        );
    }
    
    private HttpHeaders createHeaders() {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        
        String correlationId = MDC.get("correlationId");
        if (correlationId != null) {
            headers.set("X-Correlation-ID", correlationId);
        }
        headers.set("X-Source-System", "customer-domain-api");
        
        return headers;
    }
}
```

### Configuration

```java
@Configuration
public class RestTemplateConfig {
    
    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
}
```

---

## Common Elements

### Integration Exception

```java
package com.company.customer.adapter.integration.exception;

/**
 * Exception thrown when API integration fails.
 */
public class IntegrationException extends RuntimeException {
    
    private final int statusCode;
    
    public IntegrationException(String message, int statusCode) {
        super(message);
        this.statusCode = statusCode;
    }
    
    public IntegrationException(String message, int statusCode, Throwable cause) {
        super(message, cause);
        this.statusCode = statusCode;
    }
    
    public int getStatusCode() {
        return statusCode;
    }
}
```

### Application Configuration

```yaml
# application.yml
integration:
  parties-api:
    base-url: ${PARTIES_API_URL:http://localhost:8081}
    timeout:
      connect: 5s
      read: 10s
```

---

## Resilience Integration

REST clients SHOULD be wrapped with resilience patterns. The adapter layer applies resilience annotations:

```java
@Component
@RequiredArgsConstructor
public class CustomerIntegrationAdapter {
    
    private final PartiesApiClient client;
    private final PartyMapper mapper;
    
    @CircuitBreaker(name = "parties-api", fallbackMethod = "getCustomerFallback")
    @Retry(name = "parties-api")
    @TimeLimiter(name = "parties-api")
    public Customer getCustomer(CustomerId id) {
        PartyDto dto = client.getById(id.value());
        return mapper.toDomain(dto);
    }
    
    private Customer getCustomerFallback(CustomerId id, Throwable t) {
        log.error("Fallback for getCustomer({}): {}", id, t.getMessage());
        throw new IntegrationException("Customer service unavailable", 503, t);
    }
}
```

See ERI-008, ERI-009, ERI-010 for resilience pattern details.

---

## Package Structure

```
adapter/
└── integration/
    ├── client/                    # REST clients
    │   ├── PartiesApiClient.java
    │   └── PartiesApiClientConfig.java (Feign only)
    ├── dto/                       # DTOs matching external API
    │   └── PartyDto.java
    ├── mapper/                    # DTO to Domain mappers
    │   └── PartyMapper.java
    ├── exception/
    │   └── IntegrationException.java
    └── CustomerIntegrationAdapter.java  # Adapter with resilience
```

---

## Testing

### Unit Test (Mocking Client)

```java
@ExtendWith(MockitoExtension.class)
class CustomerIntegrationAdapterTest {
    
    @Mock
    private PartiesApiClient client;
    
    @Mock
    private PartyMapper mapper;
    
    @InjectMocks
    private CustomerIntegrationAdapter adapter;
    
    @Test
    void getCustomer_success() {
        // Given
        PartyDto dto = PartyDto.builder().id("123").build();
        Customer customer = Customer.reconstitute(CustomerId.of("123"), "John");
        
        when(client.getById("123")).thenReturn(dto);
        when(mapper.toDomain(dto)).thenReturn(customer);
        
        // When
        Customer result = adapter.getCustomer(CustomerId.of("123"));
        
        // Then
        assertThat(result.getId().value()).isEqualTo("123");
    }
}
```

### Integration Test (WireMock)

```java
@SpringBootTest
@AutoConfigureWireMock(port = 0)
class PartiesApiClientIntegrationTest {
    
    @Autowired
    private PartiesApiClient client;
    
    @Test
    void getById_returnsParty() {
        // Given
        stubFor(get(urlEqualTo("/parties/123"))
            .willReturn(okJson("{\"id\": \"123\", \"name\": \"John\"}")));
        
        // When
        PartyDto result = client.getById("123");
        
        // Then
        assertThat(result.getId()).isEqualTo("123");
    }
}
```

---

## Related

- **ADR-012:** API Integration Patterns (decision)
- **ADR-004:** Resilience Patterns (Circuit Breaker, Retry, Timeout)
- **mod-018:** api-integration-rest-java-spring (templates)
- **CAP:** integration.api.rest

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-01 | Initial version with Feign, RestClient, RestTemplate |
