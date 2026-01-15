# Phase 4 - Skills Migration

## Aplicar

```bash
# Extraer
tar -xzf phase4-skills.tar.gz

# Copiar skills (reemplaza 020, 021 y crea 040, 041, 042)
cp -r skills/ enablement-2.0/

# Commits
cd enablement-2.0

git add skills/code/soi/skill-020-microservice-java-spring/
git commit -m "feat(skills): migrate skill-020 to Model v2.0"

git add skills/code/soi/skill-021-api-rest-java-spring/
git commit -m "feat(skills): migrate skill-021 to Model v2.0 - removed extends"

git add skills/code/soi/skill-040-add-resilience-java-spring/
git add skills/code/soi/skill-041-add-api-exposure-java-spring/
git add skills/code/soi/skill-042-add-persistence-java-spring/
git commit -m "feat(skills): add transformation skills 040, 041, 042"
```

## Contenido

```
skills/code/soi/
├── skill-020-microservice-java-spring/   # ACTUALIZADO v2.0
├── skill-021-api-rest-java-spring/       # ACTUALIZADO v2.0 (sin extends)
├── skill-040-add-resilience-java-spring/ # NUEVO
├── skill-041-add-api-exposure-java-spring/ # NUEVO
└── skill-042-add-persistence-java-spring/  # NUEVO
```

## Pendiente (manual)

1. **MIGRATE-modules.md** - Añadir `implements` a cada MODULE.md
2. **DEPRECATE-skill-001.md** - Marcar skill-001 como deprecated
