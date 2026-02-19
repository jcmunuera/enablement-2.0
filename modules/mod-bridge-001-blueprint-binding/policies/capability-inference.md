# Capability Inference Policy

## Purpose

Defines how CODE capabilities are derived from DESIGN artifacts, Blueprint configuration, and tech stack defaults. The result is a capability manifest that CODE receives as pre-resolved input.

## Capability Resolution Chain

Capabilities are resolved in layers. Each layer adds to the result. No layer removes capabilities added by a previous layer.

```
Layer 1: INHERENT (from building block)
  ↓ always applied, non-negotiable
Layer 2: INFERRED (from design artifacts)
  ↓ derived from context map relationships and aggregate structure
Layer 3: STACK DEFAULTS (from tech stack)
  ↓ organizational baseline NFRs
Layer 4: NFR OVERLAY (manual, optional)
  ↓ user/org specific additions
═══════════════════════════════
Result: union of all layers (deduplicated)
```

## Layer 1: Inherent Capabilities

Source: `blueprint.yaml → building_block.inherent_capabilities`

These are **always** included for any context assigned to this building block. They define the architectural foundation.

Example for `fusion-api-rest`:
```
architecture.hexagonal-light    → Always hexagonal
api-architecture.domain-api     → Default API tier (may be overridden per context)
```

### API Tier Override

The default tier is `domain-api`. Override when:
- Context has ONLY ACL relationships to SoR and NO domain logic → `system-api`
- Context aggregates multiple downstream services → `composable-api`
- Context is public-facing (SoE layer) → `experience-api`

Detection rules:
```
IF context has 0 commands AND all queries are pass-through (reference entities only)
  → api-architecture.system-api (override domain-api)

IF context has relationships ONLY as upstream (other contexts depend on it)
  AND context calls multiple downstream SoR
  → api-architecture.composable-api (override domain-api)
```

If override cannot be determined with high confidence, keep `domain-api` as default and note in manifest for CODE discovery to validate.

## Layer 2: Design-Inferred Capabilities

Source: `binding.yaml → strategic_bindings.relationships.*.infers_capabilities`

For each relationship in the context map where THIS context is the **downstream** side:

| Relationship type | Inferred capabilities |
|------------------|----------------------|
| ACL to SoR | `persistence.systemapi`, `integration.api-rest`, `resilience.circuit-breaker` |
| Customer-supplier | `integration.api-rest` |
| Async event | (future: eventing capability) |

### Additional inferences from aggregate structure

| Aggregate signal | Inferred capability |
|-----------------|---------------------|
| Domain events with `scope: cross-context` | (future: eventing/messaging) |
| Multiple aggregates with shared invariants | (future: distributed-transactions) |

Currently, only relationship-based inference is active. Aggregate-structure inference is documented for future activation.

## Layer 3: Tech Stack Defaults

Source: `tech-stack.yaml → default_capabilities`

These are organizational baseline NFRs that every service on this stack gets:

Example for `java-spring-boot-3`:
```
resilience.circuit-breaker    → All services get circuit-breaker
resilience.timeout            → All services get timeout
```

Also from tech stack: implementation variant preferences:
```
patterns:
  http_client: feign          → When integration.api-rest is selected, use Feign
  circuit_breaker: annotation → Annotation-based circuit breaker
  timeout: annotation         → Annotation-based timeout
```

These variant preferences are included in the manifest as `tech_defaults.patterns` for CODE to apply during module resolution.

## Layer 4: NFR Overlay (Optional)

Source: user input, organization profile, or manual enrichment.

This layer handles capabilities that cannot be derived from functional requirements or design artifacts:

- Caching requirements (`caching.redis`, future)
- Specific resilience configurations (custom timeouts, retry policies)
- Observability requirements (tracing, metrics, future)
- Security requirements beyond auth (rate limiting, input sanitization, future)
- Forced implementation variants (specific library versions, patterns)

### How to apply

The bridge asks the user if there are additional NFRs:

```
"The following capabilities have been pre-resolved from your design:
  [list capabilities with sources]
  
Are there additional non-functional requirements to apply?
Examples: specific resilience policies, caching, observability, security.
If none, the tech stack defaults will be used."
```

If the user provides NFRs, add them to Layer 4 with `source: manual`.

## Manifest Output Format

```yaml
context_id: "{context-id}"
building_block: "{block-id}"
tech_stack: "{stack-id}"
blueprint: "{blueprint-id}"

capabilities:
  - id: "{capability.feature}"
    source: inherent|inferred|stack|manual
    reason: "{why this capability is included}"

tech_defaults:
  patterns:
    "{pattern-key}": "{variant}"
```

## Validation

Run `manifest-check.sh`:
- Every capability ID exists in CODE `capability-index.yaml`
- Every pattern variant is valid for the corresponding capability
- Building block is active in blueprint
- Tech stack is compatible with building block
- No duplicate capabilities
