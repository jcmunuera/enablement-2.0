# Flow: Implementation Design (DDD/BDD)

## Overview

The Implementation Design flow takes unstructured user requirements and produces structured design artifacts through a sequential pipeline. Phases 0-3 produce solution-target agnostic DDD/BDD artifacts. Phase 4 applies Blueprint bindings to produce CODE-ready input (OpenAPI contracts, capability manifests, and enriched prompts).

This flow implements the `implementation-design` capability (variant: `ddd-bdd`). See: `design-capability-index.yaml`, DEC-065.

## When to Use

- User provides functional requirements (any format, any language)
- Goal is to produce design artifacts for code generation
- No existing design artifacts to modify

## Input

From User:
```
Unstructured functional requirements in natural language.
Can be in any language (Spanish, English, etc.).
Can be a free-text description, bullet points, or a mix.
```

## Execution

### Phase Planning

Features are always executed sequentially in fixed order. There is no parallelization within this flow.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           PHASE PLANNING                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PHASE 0: REQUIREMENTS NORMALIZATION                                        │
│  ────────────────────────────────────                                       │
│  Module: mod-design-000-requirements-normalization                          │
│  Type: policy-driven                                                        │
│  Key: Interactive Enrichment Protocol — agent ASKS user, doesn't guess      │
│  Input: Unstructured requirements (natural language)                        │
│  Output: {output_dir}/normalized-requirements.yaml                          │
│  Validation: requirements-check.sh (structural + gap detection G1-G6)       │
│  Gate: PASS required (0 errors). Warnings trigger enrichment questions.     │
│                                                                             │
│  PHASE 1: STRATEGIC DDD                                                     │
│  ──────────────────────                                                     │
│  Module: mod-design-001-strategic-ddd                                       │
│  Type: policy-driven                                                        │
│  Input: {output_dir}/normalized-requirements.yaml                           │
│  Output: {output_dir}/bounded-context-map.yaml                              │
│  Validation: context-map-check.sh                                           │
│  Gate: PASS required (0 errors, 0 warnings)                                 │
│                                                                             │
│  PHASE 2: TACTICAL DDD                                                      │
│  ────────────────────                                                       │
│  Module: mod-design-002-tactical-design                                     │
│  Type: policy-driven                                                        │
│  Scope: Only contexts with investment_strategy: build (DEC-066)             │
│  Input: {output_dir}/bounded-context-map.yaml                               │
│         + {output_dir}/normalized-requirements.yaml                         │
│  Output: {output_dir}/{context-id}/aggregate-definitions.yaml               │
│          (one per in-scope bounded context)                                 │
│  Validation: aggregate-check.sh (per file)                                  │
│  Gate: ALL files PASS (0 errors, 0 warnings)                                │
│                                                                             │
│  PHASE 3: BDD SCENARIOS                                                     │
│  ───────────────────                                                        │
│  Module: mod-design-004-bdd-scenarios                                       │
│  Type: hybrid                                                               │
│  Scope: Only contexts with aggregate-definitions that have commands          │
│         or queries (DEC-066)                                                │
│  Input: {output_dir}/{context-id}/aggregate-definitions.yaml                │
│         + {output_dir}/bounded-context-map.yaml                             │
│  Output: {output_dir}/{context-id}/{aggregate-id}.feature                   │
│          {output_dir}/{context-id}/scenario-tracing.yaml                    │
│  Validation: gherkin-syntax-check.sh + tracing-check.sh                     │
│              + coverage-check.sh (per context)                              │
│  Gate: ALL files PASS (0 errors, 0 warnings)                                │
│                                                                             │
│  ═══════════════════════════════════════════════════════════════════════════ │
│  BIND POINT: Phases 0-3 output is solution-target agnostic.               │
│  Phase 4 applies Blueprint bindings to produce CODE-ready input.          │
│  ═══════════════════════════════════════════════════════════════════════════ │
│                                                                             │
│  PHASE 4: BLUEPRINT BINDING (Bridge)                                       │
│  ────────────────────────────────────                                      │
│  Module: mod-bridge-001-blueprint-binding                                  │
│  Type: policy-driven + script-assisted                                     │
│  Scope: Only contexts with investment_strategy: build                      │
│  Prerequisites: Blueprint selected (default: fusion-soi-platform)          │
│                 Tech stack selected (default: java-spring-boot-3)          │
│                                                                             │
│  Step 4a: Block Assignment                                                 │
│    Input: bounded-context-map.yaml + blueprint.yaml                        │
│    Output: internal assignment (not persisted)                             │
│    Rule: Each build context → one building block                           │
│                                                                             │
│  Step 4b: Contract Generation (per context)                                │
│    Input: aggregate-definitions.yaml + binding (fusion-api-rest.ddd-bdd)   │
│    Policy: policies/contract-generation.md                                 │
│    Script: scripts/contract-gen.py (optional, for deterministic generation)│
│    Output: {context-id}/openapi-spec.yaml                                  │
│    Rule: 1 endpoint per command/query, error codes from invariants         │
│                                                                             │
│  Step 4c: Capability Inference (per context)                               │
│    Input: aggregate-defs + context-map + binding + tech-stack              │
│    Policy: policies/capability-inference.md                                │
│    Output: {context-id}/manifest.yaml                                      │
│    Validation: manifest-check.sh (vs CODE capability-index)               │
│    Gate: ALL manifests PASS                                                │
│                                                                             │
│  Step 4d: Prompt Assembly (per context)                                    │
│    Input: aggregate + BDD scenarios + openapi + manifest + context-map     │
│    Policy: policies/prompt-assembly.md                                     │
│    Output: {context-id}/prompt.md                                          │
│    Rule: BDD scenarios go FULL in prompt (no summarizing)                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Per-Phase Execution

For each phase:

```python
def execute_phase(phase: Phase, context: DesignContext):
    # 1. Load module for this phase
    module = resolve_module(phase.module_id)
    
    # 2. Read policy, schema, examples from module
    policy = module.read("policies/*.md")
    schema = module.read("schemas/*.schema.yaml")
    examples = module.read("examples/*")
    
    # 3. Prepare phase input
    phase_input = {
        "policy": policy,
        "schema": schema,
        "examples": examples,
        "input_files": resolve_input_paths(phase, context),
        "output_dir": context.output_dir,
    }
    
    # 4. Execute (LLM generates following policy)
    # Phase 0 may trigger Interactive Enrichment Protocol (user questions)
    output = generate_with_policy(phase_input)
    
    # 5. Validate output
    for validator in module.validators:
        result = validator.run(output)
        if result.has_errors:
            # Fix and retry
            output = fix_validation_errors(output, result)
        if result.has_warnings and phase.number == 0:
            # Trigger enrichment questions
            questions = derive_questions(result.warnings)
            answers = ask_user(questions)
            output = regenerate_with_enrichment(phase_input, answers)
    
    # 6. Write to output_dir
    write_output(output, context.output_dir)
    
    return output
```

### Interactive Enrichment (Phase 0 only)

Phase 0 implements the Interactive Enrichment Protocol (DEC-057):

```
1. SILENT EXTRACTION — Parse requirements into structured form
2. GAP DETECTION — Run G1-G8 rules, identify missing information
3. QUESTION GENERATION — Formulate targeted questions by priority:
   Priority A: Data sources and ownership (G1)
   Priority B: State machines and lifecycles (G2)
   Priority C: Business criticality classification (G3)
   Priority D: Integration access details (G4)
   Priority E: Constraints and business rules (G6)
   Priority F: Implicit lifecycle for view-only entities (G7)
   Priority G: Incomplete state operations (G8)
4. ASK USER — Present questions, wait for answers
5. REGENERATE — Produce final normalized-requirements.yaml with enriched data
6. VALIDATE — Run requirements-check.sh, expect 0 warnings
```

## Output

### Directory Structure

```
design_{domain}_{timestamp}/
├── normalized-requirements.yaml          # Phase 0 output
├── bounded-context-map.yaml              # Phase 1 output
├── {context-id}/                         # Phases 2-4 output (per context)
│   ├── aggregate-definitions.yaml        #   Phase 2: tactical design
│   ├── {aggregate-id}.feature            #   Phase 3: BDD scenarios
│   ├── scenario-tracing.yaml             #   Phase 3: traceability
│   ├── openapi-spec.yaml                 #   Phase 4b: API contract
│   ├── manifest.yaml                     #   Phase 4c: capability manifest
│   └── prompt.md                         #   Phase 4d: CODE-ready prompt
└── ...
```

**Naming conventions:**
- `{context-id}`: kebab-case, matches bounded context ID from context map
- `{aggregate-id}`: kebab-case, matches aggregate ID from aggregate-definitions
- Only contexts with `investment_strategy: build` get subdirectories (DEC-066)

### Output File Summary

| Phase | File | Location | One Per |
|-------|------|----------|---------|
| 0 | `normalized-requirements.yaml` | Root | Pipeline |
| 1 | `bounded-context-map.yaml` | Root | Pipeline |
| 2 | `aggregate-definitions.yaml` | `{context-id}/` | Bounded context |
| 3 | `{aggregate-id}.feature` | `{context-id}/` | Aggregate |
| 3 | `scenario-tracing.yaml` | `{context-id}/` | Bounded context |
| 4b | `openapi-spec.yaml` | `{context-id}/` | Bounded context |
| 4c | `manifest.yaml` | `{context-id}/` | Bounded context |
| 4d | `prompt.md` | `{context-id}/` | Bounded context |

**Total per context: 6 files** (3 DESIGN + 3 Bridge)
**Total root: 2 files**

### Context Size Management

Each phase loads only its module:

```
Phase 0: ~15KB (mod-000: policy + schema + example)
Phase 1: ~20KB (mod-001: policy + schema + example + Phase 0 output)
Phase 2: ~25KB (mod-002: policy + schema + example + Phase 0+1 output)
Phase 3: ~30KB (mod-004: policy + schema + examples + Phase 1+2 output per context)
Phase 4: ~20KB (mod-bridge-001: policies + binding + tech-stack + Phase 2+3 output per context)

Iterative approach: max ~30KB per phase
```

## Validation

After each phase:
1. **Schema conformance:** Output YAML matches module schema
2. **Validation scripts:** Module validators pass with 0 errors
3. **Gate check:** 0 warnings (except Phase 0 pre-enrichment)

After all phases:
1. **Traceability:** Every requirement traces to ≥1 capability → ≥1 aggregate → ≥1 scenario
2. **Coverage:** Every command has happy path + validation BDD scenarios
3. **Completeness:** Every in-scope bounded context has aggregate-definitions + BDD

## Error Handling

| Error | Resolution |
|-------|------------|
| Validation error in Phase N | Fix output, re-validate, retry |
| Phase 0 warnings (gaps) | Trigger enrichment questions, regenerate |
| Missing bounded context in Phase 2 | Check scope rule (DEC-066): is it GENERIC? |
| BDD coverage gap | Generate additional scenarios per coverage-check output |
| Schema mismatch | Compare output against schema, fix field names/types |

## Continuation: CODE Pipeline

After Phase 4, each bounded context has a complete CODE input package:

```
{context-id}/
├── openapi-spec.yaml    # API contract
├── manifest.yaml        # Pre-resolved capabilities
└── prompt.md            # CODE-ready prompt with BDD scenarios

Each package feeds one CODE agent instance (flow-generate).
```

See: `blueprints/README.md` for blueprint definitions and bindings.

## Output Structure

See: `OUTPUT-STRUCTURE.md` for the complete normalized output structure
including all phases (0-4). All test executions must follow this structure.

## Related

- [Design Capability Index](../../discovery/design-capability-index.yaml) — Capability and feature definitions
- [DOMAIN.md](../../../model/domains/design/DOMAIN.md) — DESIGN domain overview
- [Implementation Design Capability](../../../model/domains/design/capabilities/implementation_design.md) — Capability doc
- [Blueprints](../../../blueprints/README.md) — Blueprint definitions and bindings
- [Bridge Module](../../../modules/mod-bridge-001-blueprint-binding/MODULE.md) — Phase 4 module
- [OUTPUT-STRUCTURE.md](OUTPUT-STRUCTURE.md) — Normalized output format
- [Flow: Generate (CODE)](../code/flow-generate.md) — CODE pipeline flow for reference
