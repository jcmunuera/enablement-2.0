# Generation Orchestrator

## Version: 1.1
## Last Updated: 2026-01-26

---

## Purpose

This document defines the complete orchestration flow for code generation. An agent following these instructions MUST produce a package conforming to [OUTPUT-PACKAGE-SPEC.md](./OUTPUT-PACKAGE-SPEC.md).

---

## Orchestration Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        GENERATION ORCHESTRATION FLOW                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────┐  ┌───────────┐  ┌─────────────────┐  ┌────────────┐  ┌───────┐   │
│  │ INIT │─▶│ DISCOVERY │─▶│CONTEXT_RESOLUTION│─▶│ GENERATION │─▶│ TESTS │   │
│  └──────┘  └───────────┘  └─────────────────┘  └────────────┘  └───────┘   │
│      │           │                │                   │             │       │
│      ▼           ▼                ▼                   ▼             ▼       │
│   Create      Write           Write              Write         Generate    │
│   Package    discovery-    generation-        generation-       unit       │
│   Structure  trace.json    context.json       trace.json        tests      │
│                                  │                                          │
│                                  │ ┌──────────────────────────────────┐    │
│                                  └▶│ FAIL if variables unresolvable  │    │
│                                    └──────────────────────────────────┘    │
│                                                                             │
│  ┌───────────┐   ┌──────────┐                                              │
│  │ VALIDATE  │──▶│ PACKAGE  │                                              │
│  └───────────┘   └──────────┘                                              │
│       │               │                                                     │
│       ▼               ▼                                                     │
│   Execute        Create .tar.gz                                            │
│   validation     with all artifacts                                        │
│   scripts                                                                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Key Change (DEC-024):** CONTEXT_RESOLUTION phase ensures ALL template variables are resolved BEFORE code generation begins. If any variable cannot be resolved from inputs, generation FAILS immediately.

---

## Phase 1: INIT

### Objective
Create the package directory structure and preserve inputs.

### Steps

```python
def init_phase(prompt: str, specs: List[File], timestamp: str) -> PackageContext:
    # 1. Generate identifiers
    run_id = timestamp  # Format: YYYYMMDD_HHMMSS
    generation_id = uuid4()
    service_name = extract_service_name(prompt)
    
    # 2. Create package structure
    package_dir = f"gen_{service_name}_{run_id}"
    
    create_directory(f"{package_dir}/input")
    create_directory(f"{package_dir}/output")
    create_directory(f"{package_dir}/trace")
    create_directory(f"{package_dir}/validation/scripts/tier0")
    create_directory(f"{package_dir}/validation/scripts/tier1")
    create_directory(f"{package_dir}/validation/scripts/tier2")
    create_directory(f"{package_dir}/validation/scripts/tier3")
    create_directory(f"{package_dir}/validation/reports")
    
    # 3. Preserve inputs
    write_file(f"{package_dir}/input/prompt.txt", prompt)
    
    prompt_metadata = parse_prompt(prompt)
    write_json(f"{package_dir}/input/prompt-metadata.json", prompt_metadata)
    
    for spec in specs:
        copy_file(spec, f"{package_dir}/input/{spec.name}")
    
    # 4. Return context for next phases
    return PackageContext(
        package_dir=package_dir,
        run_id=run_id,
        generation_id=generation_id,
        service_name=service_name,
        prompt_metadata=prompt_metadata
    )
```

### Outputs
- `input/prompt.txt`
- `input/prompt-metadata.json`
- `input/*.yaml` (if specs provided)
- `input/mapping.json` (if provided)

---

## Phase 2: DISCOVERY

### Objective
Analyze prompt and specs to determine capabilities and modules.

### Steps

```python
def discovery_phase(ctx: PackageContext) -> DiscoveryResult:
    # 1. Load discovery rules
    rules = load_discovery_rules("runtime/discovery/")
    
    # 2. Analyze prompt
    prompt_analysis = analyze_prompt(ctx.prompt_metadata)
    
    # 3. Apply capability detection rules
    capabilities = []
    rules_applied = []
    
    for rule in rules:
        if rule.condition_matches(ctx):
            capabilities.append(rule.capability)
            rules_applied.append({
                "rule": rule.id,
                "condition": rule.condition,
                "result": rule.capability
            })
    
    # 4. Resolve modules for stack
    stack = determine_stack(ctx)  # e.g., "java-spring"
    modules = []
    
    for capability in capabilities:
        module = resolve_module(capability, stack)
        modules.append({
            "capability": capability,
            "module": module.id,
            "reason": f"Default for {stack} stack"
        })
    
    # 5. Derive configuration
    config = derive_config(capabilities, ctx)
    
    # 6. Write discovery trace
    discovery_trace = {
        "version": "1.0",
        "timestamp": now_iso(),
        "prompt_analysis": {
            "raw_prompt": ctx.prompt_metadata.raw,
            "detected_intent": "generate",
            "entities_identified": ctx.prompt_metadata.entities,
            "features_mentioned": ctx.prompt_metadata.features
        },
        "capability_resolution": {
            "rules_applied": rules_applied,
            "capabilities_detected": capabilities
        },
        "module_resolution": {
            "stack": stack,
            "modules_selected": modules
        },
        "config_derivation": config
    }
    
    write_json(f"{ctx.package_dir}/trace/discovery-trace.json", discovery_trace)
    
    return DiscoveryResult(
        capabilities=capabilities,
        modules=[m["module"] for m in modules],
        config=config
    )
```

### Outputs
- `trace/discovery-trace.json`

### Key Files to Read
- `runtime/discovery/discovery-rules.md`
- `runtime/discovery/capability-taxonomy.md`
- `model/domains/code/code-domain.md`

---

## Phase 2.5: CONTEXT_RESOLUTION (DEC-024)

### Objective
Resolve ALL template variables BEFORE code generation. This phase ensures deterministic code generation by:
1. Parsing all inputs (specs, mapping.json) to extract concrete values
2. Mapping extracted values to template variables
3. FAILING if any required variable cannot be resolved

### ⚠️ CRITICAL: No Improvisation Rule (DEC-025)

**If a variable cannot be resolved from inputs, the phase MUST FAIL.**

The agent MUST NOT:
- Invent values based on "general knowledge"
- Use placeholder values like "TODO" or "FIXME"
- Skip optional fields without explicit documentation

### Steps

```python
def context_resolution_phase(ctx: PackageContext, discovery: DiscoveryResult) -> GenerationContext:
    """
    Resolve ALL template variables from inputs.
    FAILS if any required variable cannot be resolved.
    """
    
    # 1. Load and parse all inputs
    inputs = {
        "prompt_metadata": ctx.prompt_metadata,
        "domain_spec": parse_openapi(f"{ctx.package_dir}/input/domain-api-spec.yaml"),
        "system_spec": parse_openapi(f"{ctx.package_dir}/input/system-api-*.yaml"),
        "mappings": parse_json(f"{ctx.package_dir}/input/mapping.json") if exists else None
    }
    
    # 2. Extract service-level variables
    service_vars = {
        "serviceName": ctx.prompt_metadata.service_name,
        "basePackage": ctx.prompt_metadata.base_package,
        "basePackagePath": ctx.prompt_metadata.base_package.replace(".", "/"),
        "javaVersion": ctx.prompt_metadata.constraints.get("java_version", "17"),
        "springBootVersion": ctx.prompt_metadata.constraints.get("spring_boot_version", "3.2.1")
    }
    
    # 3. Extract entity variables from domain spec
    entities = []
    for entity_name, entity_def in inputs["domain_spec"].components.schemas.items():
        if is_domain_entity(entity_def):  # Skip DTOs, enums
            entity = {
                "name": entity_name,
                "nameLower": to_camel_case(entity_name),
                "namePlural": to_plural(entity_name).lower(),
                "fields": extract_fields(entity_def)
            }
            entities.append(entity)
    
    # 4. Extract integration variables from system spec
    integrations = []
    if inputs["system_spec"]:
        api_name = extract_api_name(inputs["system_spec"].info.title)
        integration = {
            "name": api_name,
            "nameLower": to_camel_case(api_name),
            "baseUrlProperty": f"integration.{to_kebab_case(api_name)}.base-url",
            "resourcePath": extract_base_path(inputs["system_spec"]),
            "operations": extract_operations(inputs["system_spec"])
        }
        integrations.append(integration)
    
    # 5. Extract mapping variables
    mappings = {}
    if inputs["mappings"]:
        source = inputs["mappings"]["source"]["entity"]
        target = inputs["mappings"]["target"]["entity"]
        mappings[f"{source}_to_{target}"] = {
            "fields": [
                {
                    "domain": fm["domain"],
                    "system": fm["system"],
                    "toDomain": generate_transform(fm.get("transformation", {}).get("toDomain")),
                    "toSystem": generate_transform(fm.get("transformation", {}).get("toSystem"))
                }
                for fm in inputs["mappings"]["fieldMappings"]
            ],
            "statusMapping": extract_enum_mappings(inputs["mappings"])
        }
    
    # 6. Resolve template file mappings for each module
    templates = {}
    for module_id in discovery.modules:
        module = load_module(module_id)
        variant = select_variant(module, discovery)
        
        templates[module_id] = {
            "variant": variant,
            "files": []
        }
        
        for template in module.get_templates(variant):
            output_path = resolve_output_path(template.output, service_vars, entities)
            templates[module_id]["files"].append({
                "template": template.path,
                "output": output_path,
                "variables": template.required_variables
            })
    
    # 7. Validate ALL required variables are resolved
    all_required_vars = collect_all_required_variables(templates)
    context = {
        "service": service_vars,
        "entities": entities,
        "integrations": integrations,
        "mappings": mappings,
        "templates": templates
    }
    
    unresolved = find_unresolved_variables(all_required_vars, context)
    if unresolved:
        FAIL(f"Cannot resolve required variables: {unresolved}\n"
             f"Check inputs or update specs to include missing information.")
    
    # 8. Write generation-context.json
    generation_context = {
        "$schema": "enablement/schemas/generation-context.schema.json",
        "version": "1.0",
        "timestamp": now_iso(),
        "run_id": ctx.run_id,
        **context
    }
    
    write_json(f"{ctx.package_dir}/trace/generation-context.json", generation_context)
    
    return GenerationContext(context)
```

### Variable Resolution Rules

| Variable Source | How to Resolve | Example |
|-----------------|----------------|---------|
| `{{serviceName}}` | `prompt-metadata.json → service_name` | `customer-api` |
| `{{basePackage}}` | `prompt-metadata.json → base_package` | `com.bank.customer` |
| `{{entityName}}` | OpenAPI spec → schema names (filtered) | `Customer` |
| `{{fields}}` | OpenAPI spec → schema properties | `[{name: "id", type: "UUID"}, ...]` |
| `{{ApiName}}` | System API spec → info.title | `Parties` |
| `{{resourcePath}}` | System API spec → paths (first path) | `/parties` |
| `{{fieldMappings}}` | mapping.json → fieldMappings[] | `[{domain: "id", system: "partyId"}, ...]` |

### Outputs
- `trace/generation-context.json` - ALL resolved variables

### Failure Conditions

| Condition | Action |
|-----------|--------|
| Required variable not in inputs | FAIL with specific message |
| OpenAPI spec malformed | FAIL with parse error |
| mapping.json missing when System API present | FAIL: "mapping.json required for System API integration" |
| Entity has no fields | FAIL: "Entity {name} has no fields defined" |

---

## Phase 3: GENERATION

### Objective
Generate code in phases, tracking all decisions and files.

### Module Variant Selection

Some modules have **multiple implementation variants**. Before generating code, check each module's frontmatter for `variants:` configuration.

**Variant Selection Rules:**

```python
def select_variant(module: Module, discovery: DiscoveryResult) -> str:
    """
    Select which variant of a module to use.
    
    CRITICAL: When no variant is specified, ALWAYS use the 'default' variant.
    """
    
    if not module.has_variants:
        return None  # Module has single implementation
    
    # Check if user explicitly requested a variant
    requested = discovery.config.get(f"{module.feature}.variant")
    if requested:
        return requested
    
    # Check recommend_when conditions
    for alt in module.alternatives:
        for condition in alt.recommend_when:
            if evaluate_condition(condition, discovery):
                # Log recommendation but still use default unless explicit
                log(f"Alternative '{alt.id}' matches condition, but using default")
    
    # ALWAYS return default when not explicitly specified
    return module.default_variant.id
```

**Example: mod-003 (Timeout)**

```yaml
# Module frontmatter
variants:
  default:
    id: client-timeout           # ← This is used unless explicitly overridden
  alternatives:
    - id: annotation-async       # ← Only used if explicitly requested
```

**In practice:**
- If discovery.config has `resilience.timeout.variant = annotation-async` → use annotation-async
- Otherwise → use `client-timeout` (DEFAULT)

### Steps

### ⚠️ CRITICAL: Anti-Improvisation Rule (DEC-025)

**The GENERATION phase performs MECHANICAL SUBSTITUTION only.**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          GENERATION RULES                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  🚫 PROHIBITED:                                                              │
│     • Adding code not in template                                           │
│     • Modifying template structure                                          │
│     • "Improving" code with LLM knowledge                                   │
│     • Filling gaps with invented implementations                            │
│     • Using values not in generation-context.json                           │
│                                                                              │
│  ✅ ALLOWED:                                                                 │
│     • Substituting {{variables}} with context values                        │
│     • Reporting missing information (but NOT inventing it)                  │
│     • Basic formatting (consistent indentation)                             │
│                                                                              │
│  ⚠️ IF TEMPLATE HAS A GAP (e.g., "// TODO: add mappings"):                  │
│     1. Look in generation-context.json for the data                        │
│     2. If found → substitute                                                │
│     3. If NOT found → FAIL with clear message, DO NOT INVENT               │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Code Generation Process

```python
def generation_phase(ctx: PackageContext, discovery: DiscoveryResult, 
                     gen_context: GenerationContext) -> GenerationResult:
    """
    Generate code by SUBSTITUTING template variables with resolved values.
    
    CRITICAL: This phase does NOT interpret inputs directly.
    All values come from generation-context.json (created in CONTEXT_RESOLUTION).
    """
    
    phases_log = []
    modules_used = []
    decisions = []
    
    # 1. Group modules into phases
    phases = group_into_phases(discovery.modules)
    # Phase 1: STRUCTURAL (mod-015, mod-019)
    # Phase 2: IMPLEMENTATION (mod-017, mod-018)
    # Phase 3+: CROSS-CUTTING (mod-001, mod-002, mod-003)
    
    project_dir = f"{ctx.package_dir}/output/{ctx.service_name}"
    create_directory(project_dir)
    
    generated_files = {}
    
    # 2. Execute each phase
    for phase in phases:
        phase_start = now_iso()
        phase_files = []
        
        # Load modules for this phase
        for module_id in phase.modules:
            module = load_module(module_id)
            
            # Get pre-resolved template configuration from context
            template_config = gen_context.templates.get(module_id)
            variant_id = template_config["variant"] if template_config else None
            
            if variant_id:
                decisions.append({
                    "timestamp": now_iso(),
                    "decision": "SELECT_VARIANT",
                    "module": module_id,
                    "variant": variant_id,
                    "reason": "resolved in CONTEXT_RESOLUTION"
                })
            
            # Generate code by TEMPLATE SUBSTITUTION (not interpretation)
            for template_file in template_config["files"]:
                output_content = apply_template(
                    template_path=template_file["template"],
                    output_path=template_file["output"],
                    context=gen_context,  # Use pre-resolved context
                    module=module
                )
                
                file_path = template_file["output"]
                full_path = f"{project_dir}/{file_path}"
                write_file(full_path, output_content)
                phase_files.append(file_path)
                generated_files[file_path] = output_content
                
                # Log decision
                decisions.append({
                    "timestamp": now_iso(),
                    "decision": "GENERATE_FILE",
                    "phase": phase.number,
                    "file": file_path,
                    "module": module_id,
                    "template": template_file["template"]
                })
            
            # Track module contribution
            modules_used.append({
                "id": module_id,
                "version": module.version,
                "capability": module.capability,
                "phase": phase.number,
                "variant": variant_id,
                "files_generated": [f for f in phase_files if f not in generated_files],
                "files_modified": [f for f in phase_files if f in generated_files]
            })
        
        # Compile to verify
        compile_result = compile_project(project_dir)
        
        phases_log.append({
            "phase": phase.number,
            "name": phase.name,
            "modules": phase.modules,
            "started_at": phase_start,
            "completed_at": now_iso(),
            "files_generated": phase_files,
            "compilation_result": "PASS" if compile_result.success else "FAIL",
            "errors": compile_result.errors,
            "warnings": compile_result.warnings
        })
    
    # 3. Write generation trace
    generation_trace = {
        "version": "1.0",
        "run_id": ctx.run_id,
        "phases": phases_log,
        "summary": {
            "total_phases": len(phases),
            "total_files": len(generated_files),
            "total_duration_ms": calculate_duration(phases_log)
        }
    }
    write_json(f"{ctx.package_dir}/trace/generation-trace.json", generation_trace)
    
    # 4. Write modules-used
    modules_used_doc = {
        "version": "1.0",
        "modules": modules_used
    }
    write_json(f"{ctx.package_dir}/trace/modules-used.json", modules_used_doc)
    
    # 5. Write decisions log (JSONL)
    with open(f"{ctx.package_dir}/trace/decisions-log.jsonl", "w") as f:
        for decision in decisions:
            f.write(json.dumps(decision) + "\n")
    
    return GenerationResult(
        project_dir=project_dir,
        files=generated_files,
        modules_used=modules_used
    )
```

### Template Substitution Function

```python
def apply_template(template_path: str, output_path: str, 
                   context: GenerationContext, module: Module) -> str:
    """
    Apply template with MECHANICAL variable substitution.
    
    CRITICAL: This function does NOT interpret or add code.
    It performs string replacement ONLY.
    """
    
    # 1. Read template file
    template_content = read_file(f"modules/{module.id}/templates/{template_path}")
    
    # 2. Build substitution map from context
    substitutions = {
        # Service-level
        "{{serviceName}}": context.service["serviceName"],
        "{{basePackage}}": context.service["basePackage"],
        "{{basePackagePath}}": context.service["basePackagePath"],
        
        # Entity-level (for current entity)
        "{{entityName}}": context.current_entity["name"],
        "{{entityNameLower}}": context.current_entity["nameLower"],
        "{{entityNamePlural}}": context.current_entity["namePlural"],
        
        # Integration-level (for current integration)
        "{{ApiName}}": context.current_integration["name"] if context.current_integration else "",
        "{{apiName}}": context.current_integration["nameLower"] if context.current_integration else "",
        "{{resourcePath}}": context.current_integration["resourcePath"] if context.current_integration else "",
    }
    
    # 3. Perform substitutions
    result = template_content
    for var, value in substitutions.items():
        result = result.replace(var, str(value))
    
    # 4. Handle iterative sections (e.g., field mappings)
    result = expand_iterative_sections(result, context)
    
    # 5. CRITICAL: Check for unresolved variables
    unresolved = re.findall(r'\{\{[^}]+\}\}', result)
    if unresolved:
        FAIL(f"Unresolved variables in {output_path}: {unresolved}\n"
             f"These must be defined in generation-context.json")
    
    # 6. Add generation header
    result = add_generation_header(result, module, template_path)
    
    return result


def expand_iterative_sections(template: str, context: GenerationContext) -> str:
    """
    Expand {{#each}} blocks with actual data.
    
    Example in template:
        {{#each fieldMappings}}
        .{{domain}}({{toDomain}})
        {{/each}}
    
    Becomes:
        .id(CustomerId.fromString(response.partyId()))
        .firstName(response.firstName())
        ...
    """
    
    # Find all {{#each X}}...{{/each}} blocks
    pattern = r'\{\{#each (\w+)\}\}(.*?)\{\{/each\}\}'
    
    def replace_each(match):
        collection_name = match.group(1)
        block_template = match.group(2)
        
        # Get collection from context
        collection = context.get_collection(collection_name)
        if collection is None:
            FAIL(f"Collection '{collection_name}' not found in context")
        
        # Expand for each item
        expanded_lines = []
        for item in collection:
            line = block_template
            for key, value in item.items():
                line = line.replace(f"{{{{{key}}}}}", str(value))
            expanded_lines.append(line)
        
        return "\n".join(expanded_lines)
    
    return re.sub(pattern, replace_each, template, flags=re.DOTALL)
```

### Outputs
- `output/{service-name}/` - Complete project
- `trace/generation-trace.json`
- `trace/modules-used.json`
- `trace/decisions-log.jsonl`

### Configuration Composition Strategy

When multiple modules contribute to `application.yml`, use **YAML deep merge**, NOT multi-document (`---`):

```python
def compose_application_yml(base_config: Dict, module_configs: List[Dict]) -> str:
    """
    Merge multiple YAML configs into single document.
    Later configs override earlier ones for same keys (deep merge).
    
    Args:
        base_config: From mod-015 (spring, server, management, logging)
        module_configs: From other modules (resilience4j, systemapi, etc.)
    
    Returns:
        Single YAML document string
    """
    merged = copy.deepcopy(base_config)
    for config in module_configs:
        deep_merge(merged, config)
    return yaml.dump(merged, default_flow_style=False, sort_keys=False)
```

**CRITICAL: Do NOT use multi-document YAML:**
```yaml
# ❌ FORBIDDEN - Causes parsing issues with Python/yq
spring:
  application:
    name: my-api
---                    # <- NEVER USE THIS
resilience4j:
  circuitbreaker: ...
```

```yaml
# ✅ CORRECT - Single merged document
spring:
  application:
    name: my-api

resilience4j:
  circuitbreaker: ...
```

---

### Cross-Cutting Transformation (Phase 3+)

Cross-cutting modules (resilience, distributed-transactions) behave differently from
structural and implementation modules:

| Phase | Module Type | Behavior |
|-------|-------------|----------|
| 1 (Structural) | Foundational, API | **GENERATE** new files |
| 2 (Implementation) | Persistence, Integration | **GENERATE** new files |
| 3+ (Cross-cutting) | Resilience, Transactions | **TRANSFORM** existing files |

#### Key Difference

```python
# Phases 1-2: Generate new files
for template in module.templates:
    content = apply_template(template, context)
    write_file(output_path, content)  # Creates new file

# Phase 3+: Transform existing files (uses flow-transform.md logic)
for transformation in module.transformations:
    existing_content = read_file(transformation.target)
    modified_content = apply_transformation(existing_content, transformation)
    write_file(transformation.target, modified_content)
```

#### Transformation Types

| Type | Description | Modules |
|------|-------------|---------|
| **annotation** | Add annotations to existing methods | mod-001 (circuit-breaker), mod-002 (retry) |
| **modification** | Modify existing code/config | mod-003 sync (timeout) |
| **configuration** | Merge YAML configuration | All resilience modules |

#### Target Resolution

Targets for cross-cutting modules come from:

1. **Explicit** (from prompt): "apply circuit-breaker to CustomerSystemApiAdapter"
2. **Implicit** (convention): All adapter OUT classes when no target specified

```python
def resolve_targets(ctx, generated_files, module):
    # Check for explicit targets in context
    explicit = ctx.resilience.get("explicit_targets", {}).get(module.feature)
    if explicit:
        return match_files(generated_files, explicit)
    
    # Default: apply to adapter OUT (convention)
    if module.capability == "resilience":
        return [f for f in generated_files if "/adapter/out/" in f and "Adapter.java" in f]
    
    return []
```

#### Example: Resilience Application

```python
def apply_resilience_transformations(ctx, generated_files, resilience_modules):
    """
    Apply resilience patterns to files generated in Phase 1-2.
    """
    for module in resilience_modules:
        targets = resolve_targets(ctx, generated_files, module)
        
        for target_file in targets:
            if module.transformation_type == "annotation":
                # Add @CircuitBreaker, @Retry annotations + fallback methods
                add_annotations_to_methods(target_file, module)
                add_fallback_methods(target_file, module)
                add_imports(target_file, module.required_imports)
            
            elif module.transformation_type == "modification":
                # Modify RestClientConfig timeout values
                apply_modification_descriptor(target_file, module.transformation_descriptor)
        
        # Always merge YAML config
        merge_yaml_config(ctx.application_yml, module.yaml_config)
```

**See also:** `flow-transform.md` for detailed transformation contracts.


## Phase 4: TESTS

### Objective
Generate unit tests for all layers.

### Steps

```python
def tests_phase(ctx: PackageContext, generation: GenerationResult) -> TestResult:
    test_files = []
    
    for module_info in generation.modules_used:
        module = load_module(module_info["id"])
        
        # Each module defines what tests to generate
        if hasattr(module, "generate_tests"):
            tests = module.generate_tests(
                context=ctx,
                generated_files=generation.files
            )
            
            for test_path, content in tests.items():
                full_path = f"{generation.project_dir}/{test_path}"
                write_file(full_path, content)
                test_files.append(test_path)
    
    return TestResult(test_files=test_files)
```

### Test Generation by Module

| Module | Tests Generated |
|--------|-----------------|
| mod-015 (hexagonal) | `domain/model/*Test.java` |
| mod-017 (systemapi) | `infrastructure/adapter/out/systemapi/*Test.java` |
| mod-019 (api-exposure) | `infrastructure/adapter/in/rest/*Test.java` |

### Test Patterns

Domain tests:
- Use `@ExtendWith(MockitoExtension.class)`
- Test factory methods
- Test domain behavior
- NO Spring context

Adapter tests:
- Mock dependencies with Mockito
- Test happy path and error cases
- Verify resilience annotations

---

## Phase 5: TRACEABILITY

### Objective
Create `.enablement/manifest.json` in the generated project.

### Steps

```python
def traceability_phase(ctx: PackageContext, generation: GenerationResult, tests: TestResult):
    enablement_dir = f"{generation.project_dir}/.enablement"
    create_directory(enablement_dir)
    
    # Model v3.0: No "skill" field - replaced by discovery-based flow
    manifest = {
        "generation": {
            "id": str(ctx.generation_id),
            "timestamp": now_iso(),
            "run_id": ctx.run_id
        },
        "enablement": {
            "version": ctx.enablement_version,
            "domain": "code",
            "flow": "flow-generate"
        },
        "discovery": {
            "stack": ctx.stack,
            "capabilities": ctx.capabilities,
            "features": ctx.features
        },
        "modules": [
            {
                "id": m["id"],
                "version": m["version"],
                "capability": m["capability"],
                "phase": m["phase"]
            }
            for m in generation.modules_used
        ],
        "status": {
            "overall": "PENDING",  # Updated after validation
            "compilation": "PASS",
            "tier0": "PENDING",
            "tier1": "PENDING",
            "tier2": "PENDING",
            "tier3": "PENDING"
        },
        "metrics": {
            "files_generated": len(generation.files),
            "lines_of_code": count_loc(generation.project_dir),
            "test_files": len(tests.test_files)
        }
    }
    
    write_json(f"{enablement_dir}/manifest.json", manifest)
```

### Outputs
- `output/{service-name}/.enablement/manifest.json`

---

## Phase 6: VALIDATION

### Objective
Copy validation scripts and execute validations.

### CRITICAL: Script Collection

**IMPORTANT:** Tier-3 scripts must be collected from ALL modules used in the generation, including:
- Phase 1 modules (structural)
- Phase 2 modules (implementation)
- Phase 3+ modules (cross-cutting, e.g., resilience)

Failure to include all modules will result in incomplete validation coverage.

### Steps

```python
def validation_phase(ctx: PackageContext, generation: GenerationResult):
    validation_dir = f"{ctx.package_dir}/validation"
    
    # 1. Copy Tier-1 scripts (Universal)
    tier1_source = "runtime/validators/tier-1-universal/"
    for script in glob(f"{tier1_source}/**/*.sh"):
        copy_file(script, f"{validation_dir}/scripts/tier1/{basename(script)}")
    
    # 2. Copy Tier-2 scripts (Technology-specific)
    stack = ctx.stack  # e.g., "java-spring"
    tier2_source = f"runtime/validators/tier-2-technology/code-projects/{stack}/"
    for script in glob(f"{tier2_source}/*.sh"):
        copy_file(script, f"{validation_dir}/scripts/tier2/{basename(script)}")
    
    # 3. Copy Tier-3 scripts (Module-specific)
    # CRITICAL: Iterate over ALL modules from ALL phases
    for module_info in generation.modules_used:
        module_id = module_info['id']
        module_dir = f"modules/{module_id}/validation/"
        
        # Check if validation directory exists for this module
        if exists(module_dir):
            for script in glob(f"{module_dir}/*.sh"):
                copy_file(script, f"{validation_dir}/scripts/tier3/{basename(script)}")
    
    # 4. Generate run-all.sh from template
    # Template location: runtime/validators/run-all.sh.tpl
    template = read_file("runtime/validators/run-all.sh.tpl")
    run_all_content = template.replace("{{SERVICE_NAME}}", ctx.service_name)
    run_all_content = run_all_content.replace("{{STACK}}", ctx.stack)
    write_file(f"{validation_dir}/run-all.sh", run_all_content)
    chmod_executable(f"{validation_dir}/run-all.sh")
    
    # 5. Execute validations
    result = execute_validations(validation_dir, generation.project_dir)
    
    # 6. Write results
    write_json(f"{validation_dir}/reports/validation-results.json", result)
    
    # 7. Update manifest with results
    update_manifest_status(generation.project_dir, result)
    
    return result
```

### Module Validation Scripts Reference

| Module | Validation Script | Validates |
|--------|-------------------|-----------|
| mod-code-015 | `hexagonal-structure-check.sh` | Package structure |
| mod-code-017 | `systemapi-check.sh`, `config-check.sh` | System API adapter |
| mod-code-019 | `hateoas-check.sh`, `pagination-check.sh` | API exposure |
| mod-code-001 | `circuit-breaker-check.sh` | Circuit breaker annotations |
| mod-code-002 | `retry-check.sh` | Retry annotations |
| mod-code-003 | `timeout-check.sh` | Timeout annotations |

### run-all.sh Template

The `run-all.sh` script is generated from `runtime/validators/run-all.sh.tpl`.

**Key requirements for run-all.sh:**
- Must NOT use `set -e` (would stop on first failure)
- Must capture exit codes correctly before conditional checks
- Must iterate through all tier directories
- Must generate JSON report

### Outputs
- `validation/scripts/tier0/*.sh`
- `validation/scripts/tier1/*.sh`
- `validation/scripts/tier2/*.sh`
- `validation/scripts/tier3/*.sh`
- `validation/run-all.sh`
- `validation/reports/validation-results.json`
- Updated `output/{service}/.enablement/manifest.json`

---

## Phase 7: PACKAGE

### Objective
Create distributable package.

### Steps

```python
def package_phase(ctx: PackageContext):
    # Create tarball
    tarball_name = f"{ctx.package_dir}.tar.gz"
    create_tarball(ctx.package_dir, tarball_name)
    
    return tarball_name
```

### Outputs
- `gen_{service-name}_{timestamp}.tar.gz`

---

## Error Handling

| Phase | Error | Resolution |
|-------|-------|------------|
| INIT | Invalid prompt | Return error, no package |
| DISCOVERY | No capabilities detected | Return error with suggestions |
| GENERATION | Compilation error | Retry with fixes, max 3 attempts |
| GENERATION | Module not found | Return error listing available modules |
| TESTS | Test compilation error | Log warning, continue |
| VALIDATION | Script not found | Log warning, skip that validation |
| PACKAGE | Disk full | Return error |

---

## Checkpoints

After each phase, verify:

| Phase | Checkpoint |
|-------|------------|
| INIT | `input/` directory exists with prompt.txt |
| DISCOVERY | `trace/discovery-trace.json` is valid JSON |
| GENERATION | Project compiles successfully |
| TESTS | Test files exist in `src/test/java/` |
| TRACEABILITY | `.enablement/manifest.json` exists |
| VALIDATION | `run-all.sh` returns exit code 0 |
| PACKAGE | Tarball is valid and extractable |

---

## Related Documents

- [OUTPUT-PACKAGE-SPEC.md](./OUTPUT-PACKAGE-SPEC.md) - Package structure
- [flow-generate.md](./code/flow-generate.md) - Generation phases detail
- [Discovery Rules](../discovery/discovery-rules.md) - Capability detection

---

## Package Delivery Checklist

**MANDATORY**: Before delivering a generation package, verify ALL items:

### Structure Checklist

| # | Item | Validation |
|---|------|------------|
| 1 | `input/` directory exists | Contains prompt.md/txt and input specs |
| 2 | `output/` directory exists | Contains generated project |
| 3 | `trace/` directory exists | Contains discovery-trace.json, generation-context.json |
| 4 | `validation/` directory exists | Contains run-all.sh and scripts/ |

### Content Checklist

| # | Item | Validation |
|---|------|------------|
| 5 | Project compiles | `mvn compile` exits with 0 |
| 6 | Tier-0 validation passes | `validation/scripts/tier-0/*.sh` all exit 0 |
| 7 | All templates used | No improvised code (DEC-025) |
| 8 | Imports are correct | Validated by Tier-0 fingerprints |

### Automated Validation

Run before delivery:

```bash
# 1. Package structure check
./validation/scripts/tier-0/package-structure-check.sh .

# 2. All validations
./validation/run-all.sh

# 3. Compilation (if Maven available)
cd output/{project-name} && mvn compile
```

### Common Errors to Avoid

| Error | Cause | Prevention |
|-------|-------|------------|
| Missing `/input` | Forgot to include inputs | Run package-structure-check.sh |
| Missing `/validation` | Forgot validation scripts | Run package-structure-check.sh |
| Import errors | Improvised code | ALWAYS use templates (DEC-025) |
| Wrong package path | Variable substitution error | Check generation-context.json |

> **DEC-025 Reminder**: NEVER generate code without using a template. If a template doesn't exist, create it first.
