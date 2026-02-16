# Domains

**Version:** 2.0  
**Last Updated:** 2025-12-17  
**Status:** Active

---

## Overview

Domains represent distinct phases of the SDLC, each aligned with a specialized Swarm in the platform architecture. Every domain has its own:

- **ADRs** (strategic decisions applicable to that domain)
- **ERIs** (reference implementations)
- **Capabilities** (feature groups)
- **Modules** (reusable components)
- **Skills** (automated actions)
- **Skill Types** (categories of skills with specific execution flows)

---

## Current Domains

| Domain | Swarm | Purpose | Status |
|--------|-------|---------|--------|
| [CODE](code/DOMAIN.md) | CODE Swarm | Code generation, modification, migration | ✅ Active |
| [DESIGN](design/DOMAIN.md) | DESIGN Swarm | Architecture design, transformation | 🔜 Planned |
| [QA](qa/DOMAIN.md) | QA Swarm | Analysis, validation, audit | 🔜 Planned |
| [GOVERNANCE](governance/DOMAIN.md) | GOVERNANCE Swarm | Documentation, compliance, policy | 🔜 Planned |

---

## Domain Structure

Each domain follows this structure:

```
domains/{domain}/
├── DOMAIN.md              # Domain definition with Discovery Guidance
├── capabilities/          # Feature groups for this domain
│   └── {capability}.md
└── module-structure.md    # Module structure specific to this domain
```

> **Note:** Execution flows are now centralized in `runtime/flows/{domain}/`

---

## DOMAIN.md Structure

Each DOMAIN.md includes:

### Required Sections

| Section | Purpose |
|---------|---------|
| **Purpose** | What this domain does |
| **Discovery Guidance** | How the agent identifies this domain (NEW in v1.1) |
| **Skill Types** | Table of skill types with purpose, input, output |
| **Module Structure** | What modules in this domain contain |
| **Output Types** | What artifacts this domain produces |
| **Naming Conventions** | Asset naming patterns for this domain |
| **Current Inventory** | List of ERIs, Modules, Skills |

### Discovery Guidance Section

> **NEW in v1.1:** Each DOMAIN.md now includes semantic guidance for discovery.

The Discovery Guidance section helps the agent identify when a request belongs to this domain:

```markdown
## Discovery Guidance

### When is a request {DOMAIN} domain?

| Signal | Examples |
|--------|----------|
| **Output type** | What artifacts are produced |
| **Action intent** | What action is implied |
| **Artifacts mentioned** | What concepts are referenced |
| **SDLC phase** | What development phase |

### Typical Requests ({DOMAIN})

✅ Examples of requests that belong to this domain...

### NOT {DOMAIN} Domain (Common Confusions)

❌ Examples of requests that look like this domain but aren't...

### Key Distinction

How to distinguish this domain from similar ones...
```

This guidance enables **interpretive discovery** - the agent reads these descriptions to understand domain scope, rather than following rigid IF/THEN rules.

---

## Asset Ownership by Domain

| Asset | Domain Indicator | Location |
|-------|------------------|----------|
| ADR | `domains:` in metadata | `knowledge/ADRs/` |
| ERI | `eri-{domain}-XXX` in name | `knowledge/ERIs/` |
| Capability | Located in domain folder | `model/domains/{domain}/capabilities/` |
| Module | `mod-{domain}-XXX` in name | `modules/` |
| Skill | `skill-{domain}-XXX` in name | `modules/` |
| Flow | Located in runtime | `runtime/flows/{domain}/` |

---

## Creating a New Domain

> **Note:** The current four domains (CODE, DESIGN, QA, GOVERNANCE) cover the complete SDLC. Creating new domains should be rare.

To add a new domain:

1. Create folder structure:
   ```bash
   mkdir -p model/domains/{domain}/capabilities
   mkdir -p runtime/flows/{domain}
   ```

2. Create `DOMAIN.md` following the template below

3. Create execution flows in `runtime/flows/{domain}/`

4. Define module structure in `module-structure.md`

5. Update this README

### DOMAIN.md Template

```yaml
---
id: {domain-id}
name: "{DOMAIN NAME}"
version: 1.0
status: Draft | Active | Deprecated
created: YYYY-MM-DD
updated: YYYY-MM-DD
swarm_alignment: "{SWARM} Swarm"
---

# Domain: {NAME}

## Purpose

[What this domain does - one paragraph]

---

## Discovery Guidance

### When is a request {DOMAIN} domain?

| Signal | Examples |
|--------|----------|
| **Output type** | [What artifacts are produced] |
| **Action intent** | [What action is implied] |
| **Artifacts mentioned** | [What concepts are referenced] |
| **SDLC phase** | [What development phase] |

### Typical Requests ({DOMAIN})

✅ These requests belong to {DOMAIN} domain:

```
"Example request 1"
→ Output: [type]
→ Skill type: [TYPE]
```

### NOT {DOMAIN} Domain (Common Confusions)

❌ These requests are NOT {DOMAIN} domain:

```
"Example that looks like {DOMAIN} but isn't"
→ Output is [type] → [OTHER] domain
```

### Key Distinction

[How to distinguish this domain from similar ones]

---

## Skill Types

| Type | Purpose | Input | Output |
|------|---------|-------|--------|
| **TYPE1** | [purpose] | [input] | [output] |

---

## Module Structure

[What modules in this domain contain]

---

## Output Types

| Type | Description | Example |
|------|-------------|---------|
| `type-1` | [description] | [example] |

---

## Naming Conventions

| Asset | Pattern | Example |
|-------|---------|---------|
| ERI | `eri-{domain}-{NNN}-{pattern}` | `eri-{domain}-001-...` |
| Module | `mod-{domain}-{NNN}-{pattern}` | `mod-{domain}-001-...` |
| Skill | `skill-{domain}-{NNN}-{type}-{target}` | `skill-{domain}-001-...` |

---

## Current Inventory

### ERIs
- (list)

### Modules
- (list)

### Skills
- (list)
```

---

## Cross-Domain Operations

Some requests span multiple domains. See [ENABLEMENT-MODEL-v2.0.md Section 10](../ENABLEMENT-MODEL-v2.0.md#10-multi-domain-operations) for details on:

- How to detect multi-domain requests
- Decomposition into domain chain
- Context passing between domains
- Unified traceability

---

## Related

- [ENABLEMENT-MODEL-v2.0.md](../ENABLEMENT-MODEL-v2.0.md) - Complete model
- [discovery-guidance.md](../../runtime/discovery/discovery-guidance.md) - Discovery process
- [runtime/flows/](../../runtime/flows/) - Execution flows by domain
