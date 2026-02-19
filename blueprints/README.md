# Blueprints

## Model Concept

A **Blueprint** is an opinionated, authoritative guide for building a specific type of application or system. It is a core entity of the Enablement Model alongside Domains, Capabilities, and Modules.

Blueprints are **problem-specific**. The model defines the concept; each problem instantiation defines its own blueprints.

| Problem | Example Blueprints |
|---------|-------------------|
| SDLC | Architecture blueprints (how to build banking platforms) |
| APA | Process blueprints (how to build automated workflows) |

## What a Blueprint Contains

A blueprint defines three things:

1. **Building Blocks** — Types of deployable artifacts the blueprint knows how to produce. Each block has inherent capabilities, contract types, and a status (active/planned).

2. **Bindings** — How design methodology output (e.g., DDD/BDD artifacts) maps to implementation patterns for each building block. One binding per building-block × methodology combination.

3. **Tech Stacks** — Concrete technology choices for implementing building blocks. One tech stack can serve multiple blocks. Multiple stacks can coexist.

```
Blueprint
├── Building Blocks (what to build)
│   ├── Block A (active)
│   ├── Block B (planned)
│   └── Block C (planned)
├── Bindings (how design connects to blocks)
│   ├── Block A × Methodology 1
│   └── Block B × Methodology 1 (when block activates)
└── Tech Stacks (with what technology)
    ├── Stack 1 (for blocks A, B)
    └── Stack 2 (for block C)
```

## Incremental Definition

Blueprints grow incrementally:

1. **Start minimal:** Define 1 active block, 1 binding, 1 tech stack
2. **Add blocks:** As new artifact types are needed, add planned → active
3. **Add bindings:** As new design methodologies are added
4. **Add stacks:** As new technology choices are supported

Only **active** building blocks need complete bindings and tech stacks. Planned blocks are registered for visibility but have no implementation.

## Directory Structure

```
blueprints/
├── README.md                          # This file
└── {blueprint-id}/                    # One directory per blueprint
    ├── blueprint.yaml                 # Blueprint definition
    ├── bindings/
    │   └── {block}.{methodology}.yaml # One per block × methodology
    └── tech-stacks/
        └── {stack-id}.yaml            # One per supported stack
```

## Relationship to Other Entities

```
DESIGN Domain                          CODE Domain
  │ methodology output                   │ capability-driven generation
  │ (DDD/BDD artifacts)                  │ (modules, templates)
  │                                      │
  └──────────► Blueprint ◄───────────────┘
               │
               ├── Binding: translates DESIGN → CODE input
               ├── Building Block: determines what CODE produces
               └── Tech Stack: determines which CODE modules apply
```

Blueprints are **cross-domain** — they bridge DESIGN and CODE (for SDLC). They are consumed by bridge modules (`mod-bridge-*`) that orchestrate the translation.
