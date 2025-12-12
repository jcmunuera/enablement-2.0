# Knowledge Base Structure

**Version:** 1.1.0  
**Last Updated:** 2025-12-12  
**Status:** Active

---

## 📁 Directory Structure

```
knowledge/
├── model/                 # Enablement Model Definition
│   ├── ENABLEMENT-MODEL-v1.3.md    # Master document
│   └── standards/                   # Operational standards
├── orchestration/         # Execution rules and discovery (NEW)
│   ├── discovery-rules.md          # Prompt → Skill selection
│   ├── execution-framework.md      # Generic execution flow
│   ├── prompt-template.md          # User input template
│   └── audit-schema.json           # Audit trail schema
├── ADRs/                  # Architecture Decision Records
├── ERIs/                  # Enterprise Reference Implementations
├── capabilities/          # Capability definitions
├── patterns/              # Architectural Patterns
├── validators/            # Validation system (4 tiers)
│   ├── tier-1-universal/    # Tier 1: Universal checks
│   ├── tier-2-technology/   # Tier 2: Artifact-specific checks
│   └── tier-3-modules/      # Tier 3: Reference to module validators
└── skills/                # Automated Skills
    ├── modules/           # Reusable templates + Tier 3 validation
    └── skill-{domain}-{NNN}-.../    # Skills by domain
        ├── SKILL.md                 # Specification
        └── EXECUTION-FLOW.md        # Deterministic execution steps (NEW)
```

---

## 🏗️ **Architecture Hierarchy**

```
ADR (Strategic - Framework Agnostic)
  ↓ "implements"
ERI (Tactical - Framework Specific) 
  ↓ "abstracts to"
MODULE (Template - Reusable)
  ↓ "used by"
SKILL (Operational - Automated)
```

**Example:**
```
ADR-004: Resilience Patterns
  ↓
ERI-008: Circuit Breaker (Java/Resilience4j)
  ↓
mod-001: circuit-breaker-java-resilience4j
  ↓
skill-code-001: add-circuit-breaker-java-resilience4j
```

---

## 🎯 **Validation System (4 Tiers)**

### **Tier 1: Generic**
**Location:** `validators/tier-1-universal/`  
**Purpose:** Universal structural validations that apply to ALL projects  
**Execution:** ALWAYS

### **Tier 2: Artifacts**
**Location:** `validators/tier-2-technology/{category}/{stack}/`  
**Purpose:** Artifact-specific validations (code-projects, deployments, documents, reports)  
**Execution:** CONDITIONAL (if artifact type detected)

### **Tier 3: Module**
**Location:** `skills/modules/{module}/validation/`  
**Purpose:** Feature/pattern-specific validations (ERI constraints)  
**Execution:** CONDITIONAL (if module used)

### **Tier 4: Runtime**
**Location:** CI/CD pipeline  
**Purpose:** Execution verification (integration tests, contract tests)  
**Execution:** IN CI/CD ENVIRONMENT  
**Status:** ⏳ PENDING IMPLEMENTATION

---

## 📋 **Naming Conventions**

### **Skills (NEW)**

**Format:**
```
skill-{domain}-{NNN}-{type}-{target}-{framework}-{library}/
├── OVERVIEW.md
├── SKILL.md
├── README.md
└── validation/
    ├── README.md
    └── validate.sh            # Orchestrates 4 tiers
```

**Domain prefixes:**
- `skill-code-*` - CODE domain (generate, add, remove, refactor, migrate)
- `skill-design-*` - DESIGN domain (architecture, transform, documentation)
- `skill-qa-*` - QA domain (analyze, validate, audit)
- `skill-gov-*` - GOVERNANCE domain (documentation, compliance, policy)

**Examples:**
```
skills/
├── skill-code-001-add-circuit-breaker-java-resilience4j/
├── skill-code-020-generate-microservice-java-spring/
├── skill-design-001-architecture-microservice/
├── skill-qa-001-analyze-architecture-compliance/
└── skill-gov-001-documentation-api/
```

### **ADRs, ERIs, Modules**

Naming conventions remain unchanged:
- ADRs: `adr-XXX-{topic}/ADR.md`
- ERIs: `eri-XXX-{pattern}-{framework}-{library}/ERI.md`
- Modules: `mod-XXX-{pattern}-{framework}-{library}/MODULE.md`

---

## 📄 **Model Documents**

**Location:** `knowledge/model/`

The model directory contains the complete Enablement 2.0 definition:

| Document | Purpose |
|----------|---------|
| **ENABLEMENT-MODEL-v1.3.md** | Master document - complete conceptual model |
| **standards/ASSET-STANDARDS-v1.3.md** | Detailed structure for each asset type |
| **standards/authoring/** | Asset creation guides (ADR, ERI, MODULE, SKILL, etc.) |
| **standards/validation/** | Validation standards by domain |
| **standards/traceability/** | Traceability standards by domain |

**Read `ENABLEMENT-MODEL-v1.3.md` first** before creating any asset.

---

## 🔧 **How to Use This Knowledge Base**

### **Finding Implementation Guidance:**
1. Start with **ADR** for strategic decision
2. Find **ERI** for tactical implementation
3. Use **Module** for reusable templates
4. Execute **Skill** for automation

**Example workflow:**
```
Need resilience? 
  → Read ADR-004 (Resilience Patterns)
  → Check ERI-008 (Circuit Breaker Java implementation)
  → Use mod-001 (Circuit Breaker template)
  → Run skill-code-001 (Automated application)
```

### **Validating Generated Code:**

Generated projects include `.enablement/validation/` with:
```
.enablement/validation/
├── validate-all.sh              # Run all validations
├── infrastructure/              # Tier 1 checks
├── stacks/                      # Tier 2 checks
└── modules/                     # Tier 3 checks
```

**To validate:**
```bash
cd {generated-project}/.enablement/validation
./validate-all.sh
```

---

## 📚 **Current Inventory**

### **ADRs (5):**
- `adr-001-api-design-standards` - API design standards
- `adr-004-resilience-patterns` - Resilience patterns for distributed systems
- `adr-009-service-architecture-patterns` - Hexagonal Light architecture
- `adr-011-persistence-patterns` - Persistence patterns (JPA + System API)
- `adr-012-api-integration-patterns` - API integration patterns (REST, gRPC, Async)

### **ERIs (7):**
- `eri-code-001-hexagonal-light-java-spring` - Hexagonal architecture for Java/Spring
- `eri-code-008-circuit-breaker-java-resilience4j` - Circuit Breaker
- `eri-code-009-retry-java-resilience4j` - Retry pattern
- `eri-code-010-timeout-java-resilience4j` - Timeout pattern
- `eri-code-011-rate-limiter-java-resilience4j` - Rate Limiter
- `eri-code-012-persistence-patterns-java-spring` - Persistence (JPA + System API)
- `eri-code-013-api-integration-rest-java-spring` - REST API integration (RestClient/Feign/RestTemplate)

### **Modules (8):**
- `mod-001-circuit-breaker-java-resilience4j` - Circuit Breaker template
- `mod-002-retry-java-resilience4j` - Retry template
- `mod-003-timeout-java-resilience4j` - Timeout template
- `mod-004-rate-limiter-java-resilience4j` - Rate Limiter template
- `mod-015-hexagonal-base-java-spring` - Hexagonal architecture template
- `mod-016-persistence-jpa-spring` - JPA persistence template
- `mod-017-persistence-systemapi` - System API persistence template
- `mod-018-api-integration-rest-java-spring` - REST API integration template

### **Skills (2):**
- `skill-code-001-add-circuit-breaker-java-resilience4j` - Add circuit breaker to existing service
- `skill-code-020-generate-microservice-java-spring` - Generate new microservice (v1.2.0)

### **Capabilities (4):**
- `resilience` - Fault tolerance patterns (circuit breaker, retry, timeout, rate limiter)
- `persistence` - Data access patterns (JPA, System API)
- `api_architecture` - API layers and service architecture
- `integration` - API integration patterns (REST, gRPC, Async)

### **Validation Stacks:**
- `java-maven` - Maven compilation and tests
- `spring-boot` - Spring Boot configuration
- `docker` - Dockerfile validation

---

## 🆕 **Creating New Assets**

See `model/standards/` for detailed requirements:

- **ASSET-STANDARDS-v1.3.md** - Structure and naming
- **authoring/** - Templates for each asset type
- **validation/** - How to validate
- **traceability/** - How to trace

**Order of creation:**
1. ADR (if new strategic decision needed)
2. ERI (if new technology implementation needed)
3. Module (derived from ERI)
4. Skill (using one or more Modules)

---

## ❓ **Questions?**

For questions about structure or conventions, refer to:
- This README
- `model/ENABLEMENT-MODEL-v1.3.md` - Complete conceptual model
- `model/standards/ASSET-STANDARDS-v1.3.md` - Asset structure
- `model/standards/validation/` - Validation standards by domain
- `model/standards/traceability/` - Traceability standards by domain
- `model/standards/authoring/` - Asset creation guides
- `orchestration/` - Execution rules and discovery (how skills are selected and executed)

---

## 🔗 **Key References**

| Document | Purpose |
|----------|---------|
| **README.md** (this file) | Overview and navigation |
| **model/ENABLEMENT-MODEL-v1.3.md** | Master conceptual model |
| **model/standards/ASSET-STANDARDS-v1.3.md** | Mandatory asset structure |
| **model/standards/validation/** | Validation standards (by domain) |
| **model/standards/traceability/** | Traceability standards (by domain) |
| **model/standards/authoring/** | Asset creation guides |
| **capabilities/README.md** | Capability catalog |

---

## 📝 **Changelog**

### v1.0.0 (2025-12-01)
- **GitHub Migration** - Knowledge Base ahora versionado en Git
- **Resilience Complete** - Added Retry, Timeout, Rate Limiter ERIs and modules
- **Persistence Patterns** - New capability with JPA and System API options
- **skill-code-020 v1.2.0** - Full resilience + persistence options
- Simplified module strategy: 1 MODULE with variants instead of N separate modules
- Total: 6 ERIs, 7 MODULEs, 4 ADRs, 3 CAPABILITIEs, 2 SKILLs

> **Note:** This version corresponds to internal v7.0. See [CHANGELOG.md](../CHANGELOG.md) for version mapping.

---

**Version:** 1.0.0  
**Last Updated:** 2025-12-01  
**Maintained by:** Fusion C4E Team
