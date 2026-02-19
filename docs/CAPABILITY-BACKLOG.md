# Capability Backlog

**Version:** 1.0  
**Last Updated:** 2026-01-22  
**Purpose:** Track planned capabilities, features, and modules pending implementation

---

## Overview

This document tracks all capabilities and features that exist in the model (capability-index.yaml) but are not yet fully implemented with ADRs, ERIs, and modules.

---

## Implementation Status Legend

| Status | Description |
|--------|-------------|
| ✅ **Implemented** | ADR + ERI + Module complete |
| 🟡 **Planned** | In capability-index with `status: planned` |
| 💭 **Future** | Commented in capability-index as future consideration |
| ❌ **Not Started** | Not in capability-index yet |

---

## Current State (v2.4)

### Fully Implemented Capabilities

| Capability | Features | ADR | ERI | Modules |
|------------|----------|-----|-----|---------|
| architecture | hexagonal-light | ADR-009 | ERI-001 | mod-015 |
| api-architecture | standard, domain-api, system-api, experience-api, composable-api | ADR-001 | ERI-014 | mod-019 |
| integration | api-rest | ADR-012 | ERI-013 | mod-018 |
| persistence | jpa, systemapi | ADR-011 | ERI-012 | mod-016, mod-017 |
| resilience | circuit-breaker, retry, timeout, rate-limiter | ADR-004 | ERI-008,009,010,011 | mod-001,002,003,004 |
| distributed-transactions | saga-compensation | ADR-013 | ERI-015 | mod-020 |

**Total: 6 capabilities, 15 features, 10 modules**

---

## Planned (Priority 1) 🟡

### idempotency

**Status:** `planned` in capability-index v2.4

| Item | ID | Status | Notes |
|------|----|--------|-------|
| ADR | ADR-014-idempotency | ❌ Pending | Define idempotency patterns and when to use |
| ERI | ERI-016-idempotency-java-spring | ❌ Pending | X-Idempotency-Key implementation |
| Module | mod-code-021-idempotency-key-java-spring | ❌ Pending | Templates for idempotency filter/interceptor |

**Features:**
- `idempotency-key` (default) - Client-provided idempotency key via header

**Blocked by:** Nothing (can start immediately)

**Priority rationale:** 
- Required by `distributed-transactions` via `implies`
- Currently SAGA compensation works but idempotency module is missing
- Test Case 7 and 9 reference this capability

---

## Future Features (Priority 2) 💭

### architecture.hexagonal-full

**Description:** Full Hexagonal architecture with CQRS/Event Sourcing

| Item | ID | Status |
|------|----|--------|
| ADR | ADR-009 extension | 💭 Extend existing |
| ERI | ERI-002-hexagonal-full-java-spring | ❌ Not started |
| Module | mod-code-022-hexagonal-full-java-spring | ❌ Not started |

### integration.api-grpc

**Description:** gRPC integration for high-performance service-to-service calls

| Item | ID | Status |
|------|----|--------|
| ADR | ADR-015-grpc-integration | ❌ Not started |
| ERI | ERI-017-grpc-java-spring | ❌ Not started |
| Module | mod-code-023-grpc-java-spring | ❌ Not started |

### integration.event-kafka

**Description:** Kafka event-driven integration

| Item | ID | Status |
|------|----|--------|
| ADR | ADR-016-event-driven | ❌ Not started |
| ERI | ERI-018-kafka-java-spring | ❌ Not started |
| Module | mod-code-024-kafka-java-spring | ❌ Not started |

### distributed-transactions.two-phase-commit

**Description:** 2PC for strict consistency scenarios

| Item | ID | Status |
|------|----|--------|
| ADR | ADR-013 extension | 💭 Extend existing |
| ERI | ERI-015 extension | 💭 Extend existing |
| Module | mod-code-025-2pc-java-spring | ❌ Not started |

### idempotency.natural-idempotency

**Description:** Idempotency via natural keys (PUT, DELETE operations)

| Item | ID | Status |
|------|----|--------|
| ADR | ADR-014 (shared) | ❌ Pending |
| ERI | ERI-016 extension | ❌ Pending |
| Module | (pattern, no module) | N/A |

### idempotency.conditional-update

**Description:** Idempotency via ETags/versioning

| Item | ID | Status |
|------|----|--------|
| ADR | ADR-014 (shared) | ❌ Pending |
| ERI | ERI-016 extension | ❌ Pending |
| Module | mod-code-026-etag-java-spring | ❌ Not started |

---

## Future Capabilities (Priority 3) 💭

### caching

**Description:** Caching strategies for performance optimization

**Planned features:**
- `redis` - Distributed cache with Redis
- `local` - In-memory cache with Caffeine

| Item | ID | Status |
|------|----|--------|
| ADR | ADR-017-caching | ❌ Not started |
| ERI | ERI-019-caching-java-spring | ❌ Not started |
| Modules | mod-code-027-redis, mod-code-028-caffeine | ❌ Not started |

### security

**Description:** Security patterns for API protection

**Planned features:**
- `oauth2` - OAuth2/JWT authentication
- `api-key` - API key authentication

| Item | ID | Status |
|------|----|--------|
| ADR | ADR-018-security | ❌ Not started |
| ERI | ERI-020-security-java-spring | ❌ Not started |
| Modules | mod-code-029-oauth2, mod-code-030-apikey | ❌ Not started |

### observability

**Description:** Observability and monitoring patterns

**Planned features:**
- `metrics` - Prometheus/Micrometer metrics
- `tracing` - OpenTelemetry distributed tracing

| Item | ID | Status |
|------|----|--------|
| ADR | ADR-019-observability | ❌ Not started |
| ERI | ERI-021-observability-java-spring | ❌ Not started |
| Modules | mod-code-031-metrics, mod-code-032-tracing | ❌ Not started |

---

## Implementation Roadmap

### Phase 1: Complete Core (Current)
- [x] All resilience patterns
- [x] Hexagonal architecture
- [x] API exposure (all Fusion types)
- [x] Persistence (JPA + System API)
- [x] API integration (REST)
- [x] Distributed transactions (SAGA)
- [ ] **Idempotency** ← Next priority

### Phase 2: Enhanced Patterns
- [ ] Hexagonal Full (CQRS/ES)
- [ ] Two-phase commit
- [ ] Additional idempotency patterns

### Phase 3: Integration Expansion
- [ ] gRPC integration
- [ ] Kafka events

### Phase 4: Cross-cutting Concerns
- [ ] Caching
- [ ] Security
- [ ] Observability

---

## How to Add New Capability

1. **Create ADR** in `knowledge/ADRs/adr-XXX-{name}/ADR.md`
2. **Create ERI** in `knowledge/ERIs/eri-code-XXX-{name}/ERI.md`
3. **Create Module** in `modules/mod-code-XXX-{name}/`
4. **Add to capability-index.yaml** with `status: active` (not planned)
5. **Update this backlog** to mark as implemented
6. **Add test cases** in discovery-guidance.md

---

## Metrics

| Category | Count |
|----------|-------|
| Implemented capabilities | 6 |
| Implemented features | 15 |
| Implemented modules | 10 |
| Planned capabilities | 1 |
| Future features | 6 |
| Future capabilities | 3 |

**Coverage:** 6/10 planned capabilities (60%)
