---
id: mod-bridge-001-blueprint-binding
name: "Blueprint Binding"
domain: bridge
type: bridge
version: "1.0"
status: active
---

# mod-bridge-001-blueprint-binding

## Purpose

Translates DESIGN pipeline output (solution-target agnostic DDD/BDD artifacts) into CODE pipeline input (OpenAPI contracts, capability manifest, enriched prompt) by applying Blueprint building block bindings.

This is a **bridge module** — it connects the DESIGN and CODE domains. It belongs to neither; it consumes DESIGN output and produces CODE input.

## When to Use

After the DESIGN pipeline (phases 0-3) completes and before CODE generation begins.

## Input

```
{design-output}/
├── normalized-requirements.yaml        # Phase 0
├── bounded-context-map.yaml            # Phase 1
├── {context-id}/
│   ├── aggregate-definitions.yaml      # Phase 2
│   ├── scenarios.feature               # Phase 3
│   └── scenario-tracing.yaml           # Phase 3
└── ...
```

Plus:
- Blueprint selection (e.g., `fusion-soi-platform`)
- Tech stack selection (e.g., `java-spring-boot-3`)
- NFR overlay (optional)

## Output

Per build bounded context:
```
{bridge-output}/{context-id}/
├── openapi-spec.yaml          # API contract (from aggregate + binding)
├── manifest.yaml              # Capability manifest (inherent + inferred + stack)
└── prompt.md                  # CODE-ready prompt (service desc + BDD + capabilities)
```

## Module Structure

```
mod-bridge-001-blueprint-binding/
├── MODULE.md                              # This file
├── policies/
│   ├── blueprint-binding.md               # Overall binding process
│   ├── contract-generation.md             # Aggregate → OpenAPI rules
│   ├── capability-inference.md            # Design artifacts → CODE capabilities
│   └── prompt-assembly.md                 # How to assemble prompt.md
├── schemas/
│   └── manifest.schema.yaml              # Capability manifest format
├── templates/
│   ├── openapi-base.yaml.tpl             # OpenAPI skeleton
│   └── prompt.md.tpl                     # Prompt template
├── examples/
│   ├── card-management-openapi.yaml      # Reference example
│   ├── card-management-manifest.yaml     # Reference example
│   └── card-management-prompt.md         # Reference example
└── validation/
    ├── contract-check.sh                 # OpenAPI structural validation
    └── manifest-check.sh                 # Capabilities resolvable check
```

## Execution Phases

| Step | Name | Input | Output |
|------|------|-------|--------|
| 4a | Block Assignment | context-map + blueprint | block per context |
| 4b | Contract Generation | aggregate + binding | openapi-spec.yaml |
| 4c | Capability Inference | aggregate + context-map + binding + tech-stack | manifest.yaml |
| 4d | Prompt Assembly | aggregate + BDD + manifest + contract | prompt.md |

## Key Principles

1. **Holistic view, per-context output.** The bridge reads ALL design artifacts to ensure cross-context consistency, but produces independent packages per context.
2. **Template-driven contracts.** OpenAPI generation is mechanical (binding rules → templates), not LLM-creative. Determinism over elegance.
3. **BDD as business specification.** Full Gherkin scenarios go into prompt.md as the primary business logic specification for CODE.
4. **Capability manifest is primary.** CODE receives pre-resolved capabilities. Discovery validates and enriches, not replaces.
