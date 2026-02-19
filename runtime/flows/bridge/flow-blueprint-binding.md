# Flow: Blueprint Binding

Transforms DESIGN pipeline output into CODE pipeline input by applying Blueprint building block bindings, generating API contracts, inferring capabilities, and assembling prompts.

## Prerequisites

- Completed DESIGN pipeline output (phases 0-3, all validators PASS)
- Blueprint selected (or default: organization's primary blueprint)
- Tech stack selected (or default: from blueprint's active building block)

## Input

```
{design-output}/
├── normalized-requirements.yaml
├── bounded-context-map.yaml
├── {context-id}/
│   ├── aggregate-definitions.yaml
│   ├── *.feature
│   └── scenario-tracing.yaml
└── ...
```

## Phases

| Phase | Module | Input | Output | Validation |
|-------|--------|-------|--------|------------|
| 4a | mod-bridge-001 | context-map + blueprint | block-assignment (internal) | All blocks active |
| 4b | mod-bridge-001 | aggregate + binding | openapi-spec.yaml | contract-check.sh |
| 4c | mod-bridge-001 | aggregate + map + binding + stack | manifest.yaml | manifest-check.sh |
| 4d | mod-bridge-001 | all above + BDD | prompt.md | — |

All phases use the same module. The bridge is a single module with multiple policies.

## Execution

### Phase 4a: Block Assignment

```
for each bounded_context where investment_strategy = "build":
    evaluate blueprint.block_assignment_rules in order
    assign first matching building_block (or default)
    verify building_block.status = "active"
```

Output: internal assignment map (not shipped to CODE).

### Phase 4b: Contract Generation (per build context)

```
for each assigned context:
    load aggregate-definitions.yaml
    load binding: {block}.{methodology}.yaml
    apply contract-generation.md policy:
        aggregate_root → resource path
        commands → POST/PUT/DELETE endpoints
        queries → GET endpoints
        invariants → error schemas
    render openapi-spec.yaml from template
    validate: contract-check.sh
```

### Phase 4c: Capability Inference (per build context)

```
for each assigned context:
    layer1 = building_block.inherent_capabilities
    layer2 = infer from context_map relationships using binding rules
    layer3 = tech_stack.default_capabilities
    layer4 = nfr_overlay (ask user if needed)
    manifest = deduplicate(layer1 + layer2 + layer3 + layer4)
    render manifest.yaml
    validate: manifest-check.sh
```

### Phase 4d: Prompt Assembly (per build context)

```
for each assigned context:
    load aggregate-definitions.yaml
    load *.feature (BDD scenarios)
    load openapi-spec.yaml (from 4b)
    load manifest.yaml (from 4c)
    load context relationships from bounded-context-map.yaml
    render prompt.md from template following prompt-assembly.md policy
```

## Output

Per build bounded context:
```
{bridge-output}/
├── {context-id}/
│   ├── openapi-spec.yaml     # API contract
│   ├── manifest.yaml         # Capability manifest
│   └── prompt.md             # CODE-ready prompt
├── {context-id}/
│   ├── ...
└── ...
```

Each `{context-id}/` directory is an independent CODE input package.
Each package feeds one CODE agent instance.

## CODE Handoff

```
Per bounded context, CODE receives:
  1. prompt.md          → Primary input (service description + BDD + capabilities)
  2. openapi-spec.yaml  → API contract (endpoints, schemas, errors)
  3. manifest.yaml      → Pre-resolved capabilities (CODE validates + enriches)

CODE pipeline then:
  1. Reads prompt.md
  2. Pre-loads capabilities from manifest.yaml
  3. Runs discovery on prompt.md for additional capabilities
  4. Merges manifest + discovered capabilities
  5. Resolves modules per capability
  6. Generates code (structural → implementation → cross-cutting)
```

## Error Handling

| Error | Resolution |
|-------|-----------|
| Building block not active | Report to user, suggest alternative or skip context |
| Capability not in CODE index | Report to user, remove from manifest, add as note in prompt |
| Contract validation fails | Fix OpenAPI structure, re-validate |
| Manifest validation fails | Review inference rules, check capability-index compatibility |

## Related

- [Blueprint README](../../blueprints/README.md) — Blueprint model concept
- [fusion-soi-platform](../../blueprints/fusion-soi-platform/blueprint.yaml) — Active blueprint
- [DESIGN flow](../design/flow-implementation-design.md) — Upstream: produces DESIGN output
- [CODE discovery](../../discovery/capability-index.yaml) — Downstream: consumes bridge output
