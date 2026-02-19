# Work Methodology

**Version:** 1.0  
**Date:** 2025-12-01

---

## Overview

This document defines how we work on the Enablement 2.0 project, including the AI (Claude) workflow, version management, and documentation.

---

## Branching Strategy

```
main                     ← Stable versions (v1.0.0, v1.1.0, v2.0.0)
  │
  └── develop            ← Work in progress
        │
        └── feature/*    ← New features
```

### Branches

| Branch | Purpose | Merges to |
|--------|---------|-----------|
| `main` | Stable versions, tagged | - |
| `develop` | Work in progress integration | `main` (on releases) |
| `feature/*` | Specific new functionality | `develop` |

> **Note:** Proofs of concept are executed outside the repository in a separate workspace.

---

## Commits

### Message Convention

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

| Type | Usage |
|------|-------|
| `feat` | New functionality (ERI, MODULE, SKILL, etc.) |
| `fix` | Bug fixes |
| `docs` | Documentation |
| `refactor` | Refactoring without functional change |
| `chore` | Maintenance, configuration |

### Scopes

| Scope | Description |
|-------|-------------|
| `ERI` | Enterprise Reference Implementations |
| `MODULE` | Skill Modules |
| `SKILL` | Skills |
| `ADR` | Architecture Decision Records |
| `CAP` | Capabilities |
| `model` | Model and standards |
| `authoring` | Authoring guides |
| `validation` | Validation system |

### Examples

```bash
# New functionality
feat(ERI): add ERI-012 persistence patterns

# Fix
fix(MODULE): fix mod-015 persistence reference

# Documentation
docs(authoring): add module breakdown criteria

# Refactoring
refactor(SKILL): update skill-code-020 to v1.2.0

# Work session
feat: session 2025-12-01 - persistence patterns complete
```

---

## Commit Granularity

### General Rule

**1 commit per work session** with Claude.

### Exceptions

- **Major initiative closure** → immediate commit + tag
- **Critical hotfix** → independent commit

### Session Commit Format

```bash
git commit -m "feat: session YYYY-MM-DD - <brief summary>

<detailed description of changes>

Assets added/modified:
- ERI-XXX: description
- mod-XXX: description
- ...

Session doc: docs/sessions/YYYY-MM-DD.md"
```

---

## Versioning

### Semantic Versioning

```
MAJOR.MINOR.PATCH
```

| Level | When to increment | Example |
|-------|-------------------|---------|
| **MAJOR** | Breaking changes, complete new capability | 1.0.0 → 2.0.0 |
| **MINOR** | New ERIs, MODULEs, SKILLs | 1.0.0 → 1.1.0 |
| **PATCH** | Fixes, documentation improvements | 1.0.0 → 1.0.1 |

### Tags

```bash
# Create tag
git tag -a v1.1.0 -m "Release v1.1.0 - Persistence patterns"

# Push tag
git push origin v1.1.0
```

---

## AI (Claude) Workflow

### Typical Session

```
1. Session start
   - Claude reads previous context (if exists)
   - Review current state and objectives

2. Iterative work
   - Define changes to make
   - Claude generates/modifies content
   - Review and adjust

3. Session close
   - Claude generates session summary (docs/sessions/YYYY-MM-DD.md)
   - Claude prepares Git commands
   - You execute commit and push
```

### Commit Preparation

Claude prepares exact commands:

```bash
# Claude provides these commands
cd /path/to/enablement-2.0
git add .
git status  # Verify changes
git commit -m "feat: session 2025-12-01 - ..."
git push origin develop
```

### Session Documentation

Each session generates `docs/sessions/YYYY-MM-DD.md` with:

- Session objectives
- Changes made
- Decisions taken
- Next steps
- Assets created/modified

---

## Session Document Structure

```markdown
# Session YYYY-MM-DD

## Objectives
- [ ] Objective 1
- [ ] Objective 2

## Executive Summary
[Brief paragraph of what was achieved]

## Changes Made

### New Assets
| Type | ID | Description |
|------|-----|-------------|
| ERI | CODE-012 | Persistence Patterns |

### Modified Assets
| Type | ID | Change |
|------|-----|--------|
| MODULE | mod-015 | Added persistence note |

## Decisions Made
1. **Decision:** [description]
   - **Context:** [why]
   - **Alternatives:** [what was discarded]

## Next Steps
- [ ] Step 1
- [ ] Step 2

## Technical Notes
[Relevant details for resuming work]
```

---

## Pre-Commit Validation

Before each commit, verify:

- [ ] New files have correct structure
- [ ] Cross-references are valid
- [ ] Versions updated where appropriate
- [ ] Session document generated

---

## Future Exploration: MCP

For greater productivity, we will explore MCP integration:

```
Claude ←→ MCP Git Server ←→ GitHub
```

This would allow:
- Direct commits from Claude
- Repository state reading
- Branch management

**Status:** Pending evaluation

---

**Last Updated:** 2025-12-01
