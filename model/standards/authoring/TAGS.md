# Authoring Guide: Tags

**Version:** 2.0  
**Date:** 2026-01-21  
**Model Version:** 3.0.1

---

## ⚠️ Deprecation Notice

In model v3.0, **Skills have been eliminated**. Tags were previously used for skill discovery via YAML frontmatter in skill OVERVIEW.md files.

With the single discovery path through `capability-index.yaml`, tags are now handled differently:

| v2.x (Skills) | v3.0 (Capabilities) |
|---------------|---------------------|
| Tags in skill OVERVIEW.md | Keywords in capability-index.yaml |
| Skill discovery via tags | Feature discovery via keywords |
| Dimensional tag system | Simple keyword arrays |

---

## Current Approach: Keywords

Discovery now uses **keywords** defined in `capability-index.yaml`:

```yaml
capabilities:
  resilience:
    keywords:           # Capability-level keywords
      - resilience
      - resiliencia
      - fault tolerance
    
    features:
      circuit-breaker:
        keywords:       # Feature-level keywords
          - circuit breaker
          - cortocircuito
          - CB
```

### Keyword Guidelines

1. **Include synonyms:** circuit breaker, CB, cortocircuito
2. **Include Spanish equivalents:** resilience → resiliencia
3. **Include abbreviations:** CB for circuit breaker
4. **Avoid generic terms:** "code", "service", "application"
5. **Be specific:** "Domain API" not just "API"

### Keyword Priority

Discovery matches in this order:
1. Feature keywords (highest priority)
2. Capability keywords
3. Stack keywords (lowest priority)

---

## Module Tags (Still Used)

Modules still use YAML frontmatter for metadata:

```yaml
---
id: mod-code-015-hexagonal-base-java-spring
version: 1.0.0
capability: architecture
feature: hexagonal-light
stack: java-spring
---
```

See `authoring/MODULE.md` for details.

---

## Migration from v2.x

If you have existing skills with tags:

1. Identify the capability the skill implements
2. Extract relevant tags as keywords
3. Add keywords to capability-index.yaml
4. Delete the skill (it's now redundant)

---

## Related

- `runtime/discovery/capability-index.yaml` - Where keywords are defined
- `runtime/discovery/discovery-guidance.md` - How keywords are matched
- `authoring/CAPABILITY.md` - Capability authoring guide

---

**Last Updated:** 2026-01-21
