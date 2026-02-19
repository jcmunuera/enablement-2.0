# Blueprint Binding Policy

## Overview

This policy governs how DESIGN output is translated into CODE input using a Blueprint's building blocks, bindings, and tech stacks. The bridge operates holistically (reads all contexts) but produces independent packages per bounded context.

## Scope

Process ONLY bounded contexts with `investment_strategy: build`. Skip `buy/reuse` contexts (they are integration boundaries, not deployable units to generate).

---

## Step 4a: Building Block Assignment

### Input
- `bounded-context-map.yaml` (all contexts with types and relationships)
- `blueprint.yaml` (building blocks with assignment rules)

### Process

1. Read the blueprint's `block_assignment_rules` in order
2. For each BUILD context, evaluate conditions:
   - Match the FIRST rule whose condition is satisfied
   - If no rule matches, apply `default` block
3. Output the assignment

### Rules

- A single context gets exactly ONE building block
- All build contexts in a map MUST be assigned a block
- If the assigned block's `status` is not `active`, STOP and report error
- If a context matches a `planned` block, ask the user: "Context {id} needs a {block-name} but this building block is not yet active. Should we skip this context or assign the default?"

### Output
```yaml
# block-assignment.yaml (internal, not shipped to CODE)
assignments:
  - context_id: "card-management"
    building_block: "fusion-api-rest"
    confidence: high
    reason: "Has commands AND queries, ACL to SoR"
  - context_id: "global-position"
    building_block: "fusion-api-rest"
    confidence: high
    reason: "default assignment"
```

---

## Step 4b: Contract Generation

### Input
- `{context}/aggregate-definitions.yaml`
- Binding file for the assigned block × methodology (e.g., `fusion-api-rest.ddd-bdd.yaml`)

### Process

Follow the rules in `contract-generation.md` policy. The process is template-driven:

1. Read aggregate root → derive resource path
2. Read commands → derive endpoints (method, path, request/response schemas)
3. Read queries → derive endpoints (method, path, query params, response schemas)
4. Read invariants → derive error response schemas
5. Read value objects → derive embedded schemas
6. Assemble OpenAPI spec from template

### Rules

- ONE OpenAPI spec per bounded context (not per aggregate — a context IS a service)
- If a context has multiple aggregates (rare but possible), all share the same spec as separate resource paths
- Use the binding's `tactical_bindings` for all DDD→API translations
- Use the binding's `error_handling` for error response schemas
- Validate with `contract-check.sh`

### Output
`{context}/openapi-spec.yaml`

---

## Step 4c: Capability Inference

### Input
- `{context}/aggregate-definitions.yaml`
- `bounded-context-map.yaml` (relationships for this context)
- Binding file (capability inference rules in `strategic_bindings.relationships`)
- Tech stack file (default capabilities)
- Blueprint (inherent capabilities from building block)

### Process

Follow the rules in `capability-inference.md` policy. Build the capability list by layering:

```
Layer 1: Building block inherent capabilities
  → From blueprint.yaml building_block.inherent_capabilities
  
Layer 2: Design-inferred capabilities  
  → From binding strategic_bindings.relationships.*.infers_capabilities
  → Applied per relationship in the context map for THIS context
  
Layer 3: Tech stack default capabilities
  → From tech-stack.yaml default_capabilities
  
Layer 4: NFR overlay (optional, manual)
  → Additional capabilities specified by user/org profile
  
Result: union of all layers (deduplicated)
```

### Rules

- Layer 1 is NON-NEGOTIABLE — always applied
- Layer 2 is INFERRED — derived from design artifacts, high confidence
- Layer 3 is ORGANIZATIONAL — tech-stack baseline, overridable
- Layer 4 is MANUAL — user/org specific, highest priority
- If a capability appears in multiple layers, include it once
- Validate with `manifest-check.sh` (every capability must be resolvable in CODE capability-index)

### Output
```yaml
# {context}/manifest.yaml
context_id: "card-management"
building_block: "fusion-api-rest"
tech_stack: "java-spring-boot-3"

capabilities:
  - id: architecture.hexagonal-light
    source: inherent
  - id: api-architecture.domain-api
    source: inherent
  - id: persistence.systemapi
    source: inferred
    reason: "ACL relationship to core-banking-gateway"
  - id: integration.api-rest
    source: inferred
    reason: "ACL relationship to core-banking-gateway"
  - id: resilience.circuit-breaker
    source: inferred+stack
    reason: "ACL relationship + tech-stack default"
  - id: resilience.timeout
    source: stack
    reason: "tech-stack default"

tech_defaults:
  patterns:
    http_client: feign
    circuit_breaker: annotation
    timeout: annotation
```

---

## Step 4d: Prompt Assembly

### Input
- `{context}/aggregate-definitions.yaml`
- `{context}/scenarios.feature`
- `{context}/scenario-tracing.yaml`
- `{context}/openapi-spec.yaml` (from Step 4b)
- `{context}/manifest.yaml` (from Step 4c)
- `bounded-context-map.yaml` (relationships for cross-context references)

### Process

Follow the rules in `prompt-assembly.md` policy. Assemble prompt.md using the template:

1. Service description (from aggregate + context map)
2. Architecture reference (blueprint, building block, tech stack)
3. API contract reference (from Step 4b)
4. Business logic specification (FULL BDD scenarios from .feature)
5. Pre-resolved capabilities (from manifest)
6. Integration context (upstream/downstream from context map)
7. NFR notes (if any overlay was applied)

### Rules

- **BDD scenarios go in FULL** — do not summarize. They are the primary business logic specification. The LLM should read them BEFORE generating code, like a developer doing BDD.
- If context window is a concern (>50 scenarios for one context), apply priority:
  1. ALWAYS include: happy-path + invariant scenarios (core business logic)
  2. ALWAYS include: validation scenarios (input rules)
  3. SUMMARIZE only: pagination + not-found (predictable patterns)
- **OpenAPI contract is REFERENCED**, not inlined. The prompt says "see openapi-spec.yaml" and CODE receives it as a separate file.
- **Manifest capabilities are listed explicitly** with source annotations, so CODE knows what's pre-resolved vs. what to discover additionally.

### Output
`{context}/prompt.md`

---

## Cross-Context Consistency

The bridge ensures consistency BEFORE per-context generation:

1. **Shared domain model:** Entities referenced across contexts (e.g., Account in both account-query and transfer-operations) use the same field definitions in their respective OpenAPI schemas.

2. **Interface contracts:** If context A has an ACL relationship to context B's underlying SoR, context A's system API contract references the same entity definitions.

3. **Event schemas:** (Future) If context A publishes events that context B consumes, the event schema is generated once and referenced by both.

Currently, cross-context consistency is implicit (same DESIGN artifacts → same entity definitions). When multi-target generation is active (some contexts as APIs, others as event processors), explicit schema sharing will be needed.

---

## What NOT to Do

- Do NOT generate code — the bridge produces CODE INPUT, not code
- Do NOT invent capabilities — only include what's inherent, inferred from design, or in tech-stack defaults
- Do NOT modify DESIGN artifacts — the bridge is read-only on design output
- Do NOT skip BDD scenarios in the prompt — they are the business specification
- Do NOT resolve technology choices beyond tech-stack defaults — CODE discovery handles the rest
