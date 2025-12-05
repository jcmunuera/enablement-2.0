# Execution Flow: skill-code-001-add-circuit-breaker-java-resilience4j

**Skill Type:** ADD (Transformation)  
**Version:** 1.0  
**Last Updated:** 2025-12-05

---

## Overview

This document defines the **deterministic execution flow** for adding circuit breaker 
pattern to an existing Java/Spring Boot service. This is a TRANSFORMATION skill - it 
modifies existing code rather than generating from scratch.

---

## Prerequisites

Before execution, the following inputs MUST be available:

| Input | Source | Required |
|-------|--------|----------|
| `transformation-request.json` | User or orchestrator | ✅ |
| Existing project source code | User's codebase | ✅ |

---

## Input Schema

```json
{
  "targetClass": "string (fully qualified class name)",
  "targetMethod": "string (method to protect)",
  "circuitBreakerName": "string (optional, defaults to methodName)",
  "pattern": {
    "type": "basic_fallback | fail_fast | multiple_fallbacks | programmatic"
  },
  "config": {
    "failureRateThreshold": 50,
    "waitDurationInOpenState": 60000,
    "slidingWindowSize": 100,
    "minimumNumberOfCalls": 10
  }
}
```

---

## Execution Steps

### Step 1: Validate Input

```
ACTION: Validate transformation-request.json
INPUT:  transformation-request.json
OUTPUT: Validated input or ERROR

RULES:
1. Validate required fields:
   - targetClass (string, valid Java class name)
   - targetMethod (string, valid method name)
2. Validate pattern.type is one of allowed values
3. Set defaults for optional fields:
   - circuitBreakerName = targetMethod if not provided
   - pattern.type = "basic_fallback" if not provided
   - config values = ERI defaults if not provided
4. Log: "Input validated successfully"
```

### Step 2: Resolve Module

```
ACTION: Identify the module to use
INPUT:  Skill definition
OUTPUT: module_to_use

RULES:
1. This skill uses exactly ONE module: mod-001-circuit-breaker-java-resilience4j
2. No conditional resolution needed (unlike GENERATE skills)
3. Log: "Module resolved: mod-001-circuit-breaker-java-resilience4j"
```

### Step 3: Locate Target Class

```
ACTION: Find the target class file in the project
INPUT:  targetClass from request, project root
OUTPUT: target_file_path or ERROR

RULES:
1. Convert class name to path: 
   - com.example.service.PaymentService → com/example/service/PaymentService.java
2. Search in: src/main/java/{path}
3. If not found → ERROR: "Target class not found"
4. Parse the Java file to AST (or simple text analysis)
5. Verify targetMethod exists in the class
6. If method not found → ERROR: "Target method not found"
7. Log: "Target located: {path}"
```

### Step 4: Select Template Based on Pattern

```
ACTION: Choose the appropriate template from module's Template Catalog
INPUT:  pattern.type from request
OUTPUT: template_to_use

RULES:
1. Read: mod-001/MODULE.md → Template Catalog
2. Match pattern.type to template:
   - "basic_fallback" → annotation/basic-circuitbreaker.java.tpl
   - "circuitbreaker_with_fallback" → annotation/circuitbreaker-with-fallback.java.tpl
   - "fail_fast" → annotation/basic-circuitbreaker.java.tpl (no fallback)
   - "programmatic" → programmatic/circuitbreaker-registry.java.tpl
3. Log: "Template selected: {template}"
```

### Step 5: Build Variable Context

```
ACTION: Prepare variables for template rendering
INPUT:  transformation-request.json, target class analysis
OUTPUT: variable_context{}

RULES:
1. From request:
   - circuitBreakerName = request.circuitBreakerName
   - methodName = request.targetMethod
   - failureRateThreshold = request.config.failureRateThreshold
   - waitDurationInOpenState = request.config.waitDurationInOpenState
   - slidingWindowSize = request.config.slidingWindowSize
   - minimumNumberOfCalls = request.config.minimumNumberOfCalls

2. From target class analysis:
   - className = extracted class name
   - packageName = extracted package
   - methodSignature = extracted method signature
   - returnType = extracted return type
   - parameters = extracted parameters
   - existingImports = list of current imports

3. Log: "Variable context built"
```

### Step 6: Generate Code Modifications

```
ACTION: Render templates and prepare modifications
INPUT:  template, variable_context
OUTPUT: modifications[]

6.1. Render Annotation Template
     - Read: mod-001/templates/{selected_template}
     - Substitute variables
     - Output: annotation code to add

6.2. Generate Fallback Method (if pattern requires)
     - If pattern.type in ["basic_fallback", "multiple_fallbacks"]:
       - Generate fallback method with same signature + Throwable
       - Return type matches original method
     
6.3. Prepare Import Statements
     - Required: io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker
     - If fallback: No additional imports needed
     - Check against existingImports to avoid duplicates

6.4. Prepare Configuration Snippet
     - Read: mod-001/templates/config/application-circuitbreaker.yml.tpl
     - Render with config values
     - This will be merged into application.yml

6.5. Prepare Dependency Snippet
     - Read: mod-001/templates/config/pom-circuitbreaker.xml.tpl
     - This will be merged into pom.xml

6.6. Log: "Modifications prepared: [count] changes"
```

### Step 7: Apply Modifications

```
ACTION: Modify the target files
INPUT:  modifications[], target files
OUTPUT: modified_files[]

7.1. Modify Target Java Class
     - Add import statement (after package, before class)
     - Add @CircuitBreaker annotation before target method
     - Add fallback method (if applicable) after target method
     - Preserve original formatting as much as possible

7.2. Modify application.yml
     - Load existing application.yml
     - Merge circuit breaker configuration under resilience4j.circuitbreaker
     - If resilience4j section doesn't exist, create it
     - Write back

7.3. Modify pom.xml
     - Load existing pom.xml
     - Check if resilience4j dependency already exists
     - If not, add to <dependencies> section
     - Write back

7.4. Add Traceability Comment
     In modified Java file, add before the annotation:
     ```java
     // Added by: skill-code-001-add-circuit-breaker-java-resilience4j
     // Template: {template_name}
     // Timestamp: {ISO-8601}
     ```

7.5. Log: "Modifications applied to [count] files"
```

### Step 8: Run Validations

```
ACTION: Validate the modifications
INPUT:  Modified project
OUTPUT: validation-report.json

8.1. Tier-1 Validation
     - Verify traceability comment added

8.2. Tier-2 Validation
     - Compile check: mvn compile
     - Verify no syntax errors introduced

8.3. Tier-3 Validation (Module-specific)
     - Run: mod-001/validation/circuitbreaker-check.sh
     - Verifies:
       - @CircuitBreaker annotation present
       - Configuration in application.yml
       - Dependency in pom.xml
       - Fallback method signature matches (if applicable)

8.4. Generate Report
     {
       "timestamp": "{ISO-8601}",
       "overall": "PASS|FAIL",
       "tier1": { ... },
       "tier2": { ... },
       "tier3": { "mod-001": { ... } }
     }

WRITE: validation-report.json
Log: "Validation complete: {status}"
```

### Step 9: Generate Execution Audit

```
ACTION: Create audit trail
INPUT:  All execution data
OUTPUT: execution-audit.json

SCHEMA:
{
  "executionId": "{UUID}",
  "timestamp": "{ISO-8601}",
  "skill": "skill-code-001-add-circuit-breaker-java-resilience4j",
  "skillType": "ADD",
  "input": {
    "transformationRequest": { /* full content */ },
    "targetClass": "com.example.service.PaymentService",
    "targetMethod": "processPayment"
  },
  "decisions": {
    "moduleUsed": {
      "module": "mod-001-circuit-breaker-java-resilience4j",
      "reason": "single module for this skill"
    },
    "templateSelected": {
      "template": "annotation/circuitbreaker-with-fallback.java.tpl",
      "reason": "pattern.type = basic_fallback"
    },
    "patternApplied": "basic_fallback"
  },
  "modifications": [
    {
      "file": "src/main/java/.../PaymentService.java",
      "type": "JAVA_CLASS",
      "changes": ["added import", "added annotation", "added fallback method"]
    },
    {
      "file": "src/main/resources/application.yml",
      "type": "CONFIG",
      "changes": ["added resilience4j.circuitbreaker section"]
    },
    {
      "file": "pom.xml",
      "type": "BUILD",
      "changes": ["added resilience4j-spring-boot3 dependency"]
    }
  ],
  "validation": { /* from validation-report.json */ }
}

WRITE: execution-audit.json
Log: "Execution audit generated"
```

---

## Comparison: GENERATE vs ADD Skills

| Aspect | GENERATE (skill-020) | ADD (skill-001) |
|--------|---------------------|-----------------|
| Input | generation-request.json | transformation-request.json |
| Modules | Multiple, resolved by features | Single, fixed |
| Templates | Many, from Template Catalog | Few, selected by pattern |
| Output | New project from scratch | Modifications to existing code |
| File operations | CREATE new files | MODIFY existing files |
| Traceability | Header in each file | Comment before modification |
| Validation | All tiers for new code | Focus on modification correctness |

---

## Error Handling

| Error | Action |
|-------|--------|
| Target class not found | STOP, return error |
| Target method not found | STOP, return error |
| Method already has @CircuitBreaker | WARN, skip (idempotent) |
| Compile fails after modification | ROLLBACK changes, return error |
| Validation fails | WARN, include in report |

---

## Determinism Guarantees

1. **Same input → Same template:** Pattern type determines template
2. **Same template → Same modifications:** Variable substitution is deterministic
3. **Idempotent:** Running twice produces same result (skips if already applied)
4. **Full traceability:** Every decision recorded in audit
