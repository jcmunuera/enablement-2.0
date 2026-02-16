# Runtime Defaults

This directory contains default configuration values for code generation.

## Files

| File | Purpose |
|------|---------|
| `code-defaults.yaml` | Default values for CODE domain generation |

## Usage

Defaults are applied when:
1. A parameter is not provided in the generation request
2. A feature needs a default configuration

## Priority

1. **Explicit input** (highest) - values provided in generation request
2. **Skill defaults** - defined in SKILL.md
3. **Runtime defaults** (this directory) - enterprise-wide defaults
4. **Module defaults** (lowest) - fallback values in MODULE.md

## Customization

To customize defaults for your organization:
1. Edit the appropriate defaults file
2. Update version and date
3. Commit to repository

---

*Managed by C4E Team*
