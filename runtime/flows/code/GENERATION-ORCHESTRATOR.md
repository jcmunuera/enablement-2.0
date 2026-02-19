# Generation Orchestrator

## Version: 1.5
## Last Updated: 2026-01-28

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
│  ┌──────┐  ┌───────────┐  ┌─────────────────┐  ┌──────────┐  ┌───────────┐ │
│  │ INIT │─▶│ DISCOVERY │─▶│CONTEXT_RESOLUTION│─▶│CHECKPOINT│─▶│ GENERATION│ │
│  └──────┘  └───────────┘  └─────────────────┘  └──────────┘  └───────────┘ │
│      │           │                │                  │              │       │
│      ▼           ▼                ▼                  ▼              ▼       │
│   Create      Write           Write            Present         Generate     │
│   Package    discovery-    generation-       execution-         code        │
│   Structure  trace.json    context.json       plan.md                       │
│                                  │                │                         │
│                                  │ ┌──────────────────────────────────┐    │
│                                  └▶│ FAIL if variables unresolvable  │    │
│                                    └──────────────────────────────────┘    │
│                                               │                             │
│                                               ▼                             │
│                                    ┌──────────────────────┐                │
│                                    │  HUMAN APPROVAL      │                │
│                                    │  (DEC-032)           │                │
│                                    │  "approved" to       │                │
│                                    │   proceed            │                │
│                                    └──────────────────────┘                │
│                                                                             │
│  ┌───────┐  ┌───────────┐   ┌──────────┐                                   │
│  │ TESTS │─▶│ VALIDATE  │──▶│ PACKAGE  │                                   │
│  └───────┘  └───────────┘   └──────────┘                                   │
│      │           │               │                                          │
│      ▼           ▼               ▼                                          │
│   Generate   Execute        Create .tar                                     │
│   unit       validation     with all artifacts                              │
│   tests      scripts                                                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Key Changes:**
- **(DEC-024):** CONTEXT_RESOLUTION phase ensures ALL template variables are resolved BEFORE code generation begins.
- **(DEC-032):** HUMAN APPROVAL CHECKPOINT allows review and approval of execution plan before generation starts.
- **(DEC-033):** VALIDATION ASSEMBLY must COPY scripts from KB, not generate them.
- **(DEC-034):** Use `assemble-validation.sh` script to automate validation script collection.

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
## Phase 2.7: HUMAN APPROVAL CHECKPOINT (DEC-032)

### Objective
Provide a mandatory approval checkpoint before code generation begins. This pattern:
1. **Prevents wasted effort** - Human validates plan before expensive generation
2. **Enables course correction** - Misunderstandings caught early
3. **Mitigates context compaction** - Natural breakpoint for long conversations
4. **Ensures determinism** - Approved plan becomes the contract

### When to Apply

| Scenario | Checkpoint Required? |
|----------|---------------------|
| Interactive chat generation | ✅ ALWAYS |
| Automated CI/CD pipeline | ⚠️ OPTIONAL (can be skipped with `--auto-approve`) |
| Agentic orchestration | ✅ RECOMMENDED (agent pauses for human) |

### Checkpoint Artifact: `execution-plan.md`

After CONTEXT_RESOLUTION completes successfully, generate and present an execution plan:

```markdown
# Execution Plan: {service-name}

## Generation Context
- **Package ID:** gen_{service-name}_{timestamp}
- **Stack:** {stack}
- **KB Version:** {kb-version}

## Capabilities Detected
| Capability | Feature | Module |
|------------|---------|--------|
| architecture.hexagonal | hexagonal-light | mod-015 |
| api-architecture | domain-api | mod-019 |
| ... | ... | ... |

## Phase Execution Plan

### Phase 3.1: STRUCTURAL
| Module | Files to Generate |
|--------|-------------------|
| mod-015 | Entity.java, EntityId.java, Repository.java, ... |
| mod-019 | Controller.java, ModelAssembler.java, ... |

### Phase 3.2: IMPLEMENTATION  
| Module | Files to Generate |
|--------|-------------------|
| mod-017 | SystemApiAdapter.java, SystemApiClient.java, ... |
| mod-018 | RestClientConfig.java |

### Phase 3.3: CROSS-CUTTING
| Module | Transformation |
|--------|----------------|
| mod-001 | Add @CircuitBreaker to adapters |
| mod-002 | Add @Retry to adapters |
| mod-003 | Configure timeouts |

### Phase 4: TESTS
- Unit tests for domain entities
- Controller tests with mocks
- Adapter tests with mocks

### Phase 5: VALIDATION
- 17 validation scripts (Tier 0-3)

## Variables Resolved
| Variable | Value |
|----------|-------|
| serviceName | customer-api |
| basePackage | com.bank.customer |
| Entity | Customer |
| ... | ... |

## Awaiting Approval
Please review and confirm:
- [ ] Capabilities correctly identified
- [ ] Modules appropriate for requirements
- [ ] Variables correctly resolved

**Reply "approved" to proceed with generation.**
```

### Approval Protocol

```python
def human_approval_checkpoint(ctx: PackageContext, discovery: DiscoveryResult, 
                               gen_context: GenerationContext) -> bool:
    """
    Present execution plan and wait for human approval.
    
    Returns:
        True if approved, False if rejected/modified
    """
    
    # 1. Generate execution plan
    plan = generate_execution_plan(ctx, discovery, gen_context)
    
    # 2. Write to trace
    write_file(f"{ctx.package_dir}/trace/execution-plan.md", plan)
    
    # 3. Present to human
    present_to_user(plan)
    
    # 4. Wait for response
    response = await_user_response()
    
    # 5. Handle response
    if response.lower() in ["approved", "yes", "proceed", "ok"]:
        log("Human approved execution plan")
        return True
    elif response.lower() in ["rejected", "no", "stop", "cancel"]:
        log("Human rejected execution plan")
        return False
    else:
        # Treat as modification request
        log(f"Human requested modification: {response}")
        # Re-run discovery/context with modifications
        return handle_modification_request(response, ctx, discovery)
```

### Benefits

| Benefit | Description |
|---------|-------------|
| **Anti-Compaction** | Natural checkpoint prevents mid-generation context loss |
| **Early Validation** | Catch misunderstandings before code generation |
| **Auditability** | `execution-plan.md` provides approval record |
| **Determinism** | Approved plan is the generation contract |
| **Resumability** | If session ends, plan can be re-submitted for continuation |

### Outputs
- `trace/execution-plan.md` - Human-readable execution plan
- Approval timestamp logged in generation trace

### Integration with Agentic Orchestration

For multi-agent systems, this checkpoint enables:

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│  Discovery  │────▶│  Checkpoint  │────▶│ Generation  │
│    Agent    │     │    (Human)   │     │    Agent    │
└─────────────┘     └──────────────┘     └─────────────┘
                           │
                           ▼
                    ┌──────────────┐
                    │   Approval   │
                    │   Required   │
                    └──────────────┘
```

The checkpoint can be implemented as:
- **Slack/Teams notification** with approval buttons
- **Web UI modal** requiring explicit approval
- **CLI prompt** in interactive mode
- **API callback** for automated systems with manual override

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

#### Transform Descriptors

Each cross-cutting module defines its transformation in a **transform descriptor** located at:
`modules/{module-id}/transform/{transform-name}.yaml`

| Module | Transform Descriptor | Type | Target |
|--------|---------------------|------|--------|
| mod-001 (circuit-breaker) | `circuit-breaker-transform.yaml` | annotation | *Adapter.java |
| mod-002 (retry) | `retry-transform.yaml` | annotation | *Adapter.java |
| mod-003 (timeout) | `timeout-config-transform.yaml` | modification | RestClientConfig.java |

**Loading transform descriptors:**

```python
def load_cross_cutting_modules(discovery_result):
    """
    Load cross-cutting modules and their transform descriptors.
    Sort by execution_order for correct application sequence.
    """
    cc_modules = []
    
    for module_id in discovery_result.modules:
        module = load_module(module_id)
        
        # Check if module is cross-cutting (Phase 3)
        if module.frontmatter.get("phase_group") == "cross-cutting":
            # Load transform descriptor
            transform_path = f"modules/{module_id}/transform/"
            descriptor_file = module.frontmatter.get("transformation", {}).get("descriptor")
            
            if descriptor_file:
                descriptor = load_yaml(f"{transform_path}/{descriptor_file}")
                module.transform_descriptor = descriptor
                module.execution_order = module.frontmatter.get("execution_order", 99)
                cc_modules.append(module)
    
    # Sort by execution_order (mod-001=1, mod-002=2, mod-003=3)
    return sorted(cc_modules, key=lambda m: m.execution_order)
```

#### Execution Order

Cross-cutting modules MUST be applied in a specific order:

| Order | Module | Reason |
|-------|--------|--------|
| 1 | mod-001 (circuit-breaker) | Outer wrapper - fails fast when service unavailable |
| 2 | mod-002 (retry) | Applied AFTER circuit-breaker, retries happen inside CB window |
| 3 | mod-003 (timeout) | Modifies infrastructure timeouts (separate concern) |

**Annotation order in generated code:**
```java
@CircuitBreaker(name = SERVICE_NAME, fallbackMethod = "findByIdFallback")  // Order 1
@Retry(name = SERVICE_NAME)                                                  // Order 2
public Optional<Customer> findById(CustomerId id) { ... }
```

#### Key Difference

```python
# Phases 1-2: Generate new files
for template in module.templates:
    content = apply_template(template, context)
    write_file(output_path, content)  # Creates new file

# Phase 3+: Transform existing files (uses transform descriptors)
for module in sorted_cross_cutting_modules:
    descriptor = module.transform_descriptor
    for step in descriptor['transformation']['steps']:
        apply_transform_step(step, generated_files, context)
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
def apply_resilience_transformations(ctx, generated_files, cross_cutting_modules):
    """
    Apply resilience patterns to files generated in Phase 1-2.
    Uses transform descriptors from modules/{module-id}/transform/
    """
    # Sort by execution_order
    sorted_modules = sorted(cross_cutting_modules, key=lambda m: m.execution_order)
    
    for module in sorted_modules:
        descriptor = module.transform_descriptor
        transformation = descriptor.get('transformation', {})
        
        # Resolve targets (files to transform)
        targets = resolve_targets(ctx, generated_files, transformation.get('targets', []))
        
        for target_file in targets:
            # Execute each step in the transform descriptor
            for step in transformation.get('steps', []):
                action = step.get('action')
                
                if action == 'add_imports':
                    add_imports(target_file, step.get('imports', []))
                    
                elif action == 'add_constant':
                    add_constant(target_file, step.get('snippet'), step.get('variables', {}))
                    
                elif action == 'add_annotation_to_methods':
                    add_annotations(target_file, step.get('selector', {}), step.get('annotation', {}))
                    
                elif action == 'add_fallback_methods':
                    add_fallbacks(target_file, step.get('snippet'), step.get('variables', {}))
        
        # Merge YAML configuration
        if 'yaml_merge' in transformation:
            yaml_cfg = transformation['yaml_merge']
            merge_yaml_config(
                f"{ctx.project_dir}/src/main/resources/application.yml",
                yaml_cfg.get('template'),
                yaml_cfg.get('variables', {})
            )
        
        # Add POM dependencies
        if 'pom_dependencies' in transformation:
            for dep in transformation['pom_dependencies']:
                add_pom_dependency(f"{ctx.project_dir}/pom.xml", dep)
```

**See also:** 
- `flow-transform.md` for detailed transformation contracts
- `modules/mod-00{1,2,3}/transform/*.yaml` for transform descriptor examples


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

## Phase 6: VALIDATION ASSEMBLY

### ⚠️ MANDATORY: Use assemble-validation.sh (DEC-034)

**DO NOT manually copy or generate validation scripts.**

Execute the KB's assembly script instead:

```bash
# From within the KB directory, run:
./runtime/validators/assemble-validation.sh \
    "${PACKAGE_DIR}/validation" \
    "${SERVICE_NAME}" \
    "${STACK}" \
    ${MODULES_USED[@]}

# Example with actual values:
./runtime/validators/assemble-validation.sh \
    "./gen_customer-api_20260128/validation" \
    "customer-api" \
    "java-spring" \
    mod-code-015 mod-code-017 mod-code-018 mod-code-019 \
    mod-code-001 mod-code-002 mod-code-003
```

**The script automatically:**
1. Creates the `validation/scripts/tier{0,1,2,3}/` directory structure
2. Copies Tier-0 scripts from `runtime/validators/tier-0-conformance/`
3. Copies Tier-1 scripts from `runtime/validators/tier-1-universal/`
4. Copies Tier-2 scripts from `runtime/validators/tier-2-technology/{stack}/`
5. Copies Tier-3 scripts from `modules/{module-id}/validation/` for each module
6. Generates `run-all.sh` from template with variable substitution
7. Sets executable permissions on all scripts

### ⚠️ CRITICAL: run-all.sh MUST come from template

**DO NOT generate or write run-all.sh manually.**

The `run-all.sh` file MUST:
- Come from `runtime/validators/run-all.sh.tpl`
- Contain the marker: `TEMPLATE_MARKER: ENABLEMENT_2_0_RUN_ALL_V1`
- Be created by `assemble-validation.sh`, not manually

If you generate run-all.sh yourself, it will likely have bash 4.0+ syntax (like `${var^^}`) that fails on macOS.

**If you cannot execute assemble-validation.sh**, follow the manual process below but DO NOT improvise script content.

### Objective
Assemble the `validation/` directory with all applicable scripts from each tier, then execute validations.

### Validation Tier Architecture

| Tier | Purpose | Source Location | Applies To |
|------|---------|-----------------|------------|
| **Tier-0** | Template conformance (DEC-024/DEC-025) | `runtime/validators/tier-0-conformance/` | All generated code |
| **Tier-1** | Universal validations | `runtime/validators/tier-1-universal/` | All projects |
| **Tier-2** | Technology-specific | `runtime/validators/tier-2-technology/{stack}/` | Based on stack |
| **Tier-3** | Module-specific | `modules/{module-id}/validation/` | Based on modules used |

### Expected Output Structure

```
validation/
├── run-all.sh                          # From run-all.sh.tpl
├── scripts/
│   ├── tier0/
│   │   ├── template-conformance-check.sh
│   │   └── package-structure-check.sh
│   ├── tier1/
│   │   ├── naming-conventions-check.sh
│   │   ├── project-structure-check.sh
│   │   └── traceability-check.sh
│   ├── tier2/
│   │   ├── compile-check.sh
│   │   ├── syntax-check.sh
│   │   ├── application-yml-check.sh
│   │   └── (other stack-specific scripts)
│   └── tier3/
│       ├── hexagonal-structure-check.sh  # mod-015
│       ├── systemapi-check.sh            # mod-017
│       ├── integration-check.sh          # mod-018
│       ├── hateoas-check.sh              # mod-019
│       ├── circuit-breaker-check.sh      # mod-001
│       ├── retry-check.sh                # mod-002
│       └── timeout-check.sh              # mod-003
└── reports/
    └── validation-results.json
```

### Steps

```python
def validation_phase(ctx: PackageContext, generation: GenerationResult):
    validation_dir = f"{ctx.package_dir}/validation"
    
    # ═══════════════════════════════════════════════════════════════════
    # Step 0: Create directory structure
    # ═══════════════════════════════════════════════════════════════════
    for subdir in ["scripts/tier0", "scripts/tier1", "scripts/tier2", "scripts/tier3", "reports"]:
        create_directory(f"{validation_dir}/{subdir}")
    
    # ═══════════════════════════════════════════════════════════════════
    # Step 1: Generate Tier-0 Conformance Script
    # ═══════════════════════════════════════════════════════════════════
    # Tier-0 is GENERATED dynamically based on modules used, not copied.
    # It checks template fingerprints specific to the modules in this generation.
    
    conformance_script = generate_tier0_conformance_script(
        modules_used=generation.modules_used,
        base_package=ctx.base_package,
        service_name=ctx.service_name
    )
    write_file(f"{validation_dir}/scripts/tier0/conformance-check.sh", conformance_script)
    chmod_executable(f"{validation_dir}/scripts/tier0/conformance-check.sh")
    
    # ═══════════════════════════════════════════════════════════════════
    # Step 2: Copy Tier-1 Scripts (Universal)
    # ═══════════════════════════════════════════════════════════════════
    tier1_scripts = [
        "runtime/validators/tier-1-universal/code-projects/naming-conventions/naming-conventions-check.sh",
        "runtime/validators/tier-1-universal/code-projects/project-structure/project-structure-check.sh",
        "runtime/validators/tier-1-universal/traceability/traceability-check.sh"
    ]
    for script in tier1_scripts:
        copy_file(script, f"{validation_dir}/scripts/tier1/{basename(script)}")
        chmod_executable(f"{validation_dir}/scripts/tier1/{basename(script)}")
    
    # ═══════════════════════════════════════════════════════════════════
    # Step 3: Copy Tier-2 Scripts (Technology-specific)
    # ═══════════════════════════════════════════════════════════════════
    # Select based on stack detected during discovery
    stack = ctx.stack  # e.g., "java-spring"
    tier2_source = f"runtime/validators/tier-2-technology/code-projects/{stack}/"
    
    tier2_scripts = [
        "compile-check.sh",
        "syntax-check.sh",
        "application-yml-check.sh"
        # Note: actuator-check.sh and test-check.sh are optional
    ]
    for script_name in tier2_scripts:
        source_path = f"{tier2_source}{script_name}"
        if exists(source_path):
            copy_file(source_path, f"{validation_dir}/scripts/tier2/{script_name}")
            chmod_executable(f"{validation_dir}/scripts/tier2/{script_name}")
    
    # ═══════════════════════════════════════════════════════════════════
    # Step 4: Copy Tier-3 Scripts (Module-specific)
    # ═══════════════════════════════════════════════════════════════════
    # CRITICAL: Must iterate over ALL modules from ALL phases (1, 2, 3+)
    
    for module_info in generation.modules_used:
        module_id = module_info['id']
        module_validation_dir = f"modules/{module_id}/validation/"
        
        if exists(module_validation_dir):
            for script in glob(f"{module_validation_dir}/*.sh"):
                # Skip hidden files (._*.sh)
                if not basename(script).startswith("."):
                    copy_file(script, f"{validation_dir}/scripts/tier3/{basename(script)}")
                    chmod_executable(f"{validation_dir}/scripts/tier3/{basename(script)}")
    
    # ═══════════════════════════════════════════════════════════════════
    # Step 5: Generate run-all.sh from Template
    # ═══════════════════════════════════════════════════════════════════
    template = read_file("runtime/validators/run-all.sh.tpl")
    run_all_content = template.replace("{{SERVICE_NAME}}", ctx.service_name)
    write_file(f"{validation_dir}/run-all.sh", run_all_content)
    chmod_executable(f"{validation_dir}/run-all.sh")
    
    # ═══════════════════════════════════════════════════════════════════
    # Step 6: Execute Validations (Optional in generation, required for delivery)
    # ═══════════════════════════════════════════════════════════════════
    result = execute_validations(validation_dir, generation.project_dir)
    
    # ═══════════════════════════════════════════════════════════════════
    # Step 7: Write Results and Update Manifest
    # ═══════════════════════════════════════════════════════════════════
    write_json(f"{validation_dir}/reports/validation-results.json", result)
    update_manifest_status(generation.project_dir, result)
    
    return result
```

### Tier-0: Conformance Script Generation

The Tier-0 script validates that generated code follows templates by checking **fingerprints** - unique code patterns that MUST appear if templates were used correctly.

```python
def generate_tier0_conformance_script(modules_used: list, base_package: str, service_name: str) -> str:
    """
    Generate a conformance-check.sh script dynamically based on modules used.
    
    Each module defines fingerprints in:
    - MODULE.md frontmatter (validation.fingerprints)
    - transform/*.yaml (fingerprints section)
    - runtime/validators/tier-0-conformance/template-conformance-check.sh (MODULE_FINGERPRINTS)
    """
    
    # Load fingerprint definitions
    fingerprints = {}
    for module_info in modules_used:
        module_id = module_info['id']
        module_fingerprints = load_module_fingerprints(module_id)
        fingerprints[module_id] = module_fingerprints
    
    # Generate script using template
    template = read_file("runtime/validators/tier-0-conformance/template-conformance-check.sh")
    
    # Build fingerprint checks section
    checks = []
    for module_id, fps in fingerprints.items():
        checks.append(f'\necho ""\necho "{module_id}:"')
        for fp in fps:
            file_pattern = fp['file'].replace('*', service_name.title())
            checks.append(f'''
check_fingerprint "$GENERATED_DIR/{fp['path']}/{file_pattern}" \\
    "{fp['pattern']}" \\
    "{fp['description']}"''')
    
    # Insert into template
    script = template.replace("{{FINGERPRINT_CHECKS}}", "\n".join(checks))
    script = script.replace("{{BASE_PACKAGE}}", base_package)
    script = script.replace("{{SERVICE_NAME}}", service_name)
    
    return script
```

### Module Validation Scripts Reference

| Module | Script | Validates |
|--------|--------|-----------|
| mod-015 (hexagonal-base) | `hexagonal-structure-check.sh` | Package structure, layer separation |
| mod-017 (persistence-systemapi) | `systemapi-check.sh` | Adapter implements port, mapper exists |
| mod-018 (api-integration-rest) | `integration-check.sh` | X-Correlation-ID propagation, URL config |
| mod-019 (api-public-exposure) | `hateoas-check.sh` | HATEOAS links, assembler pattern |
| mod-019 (api-public-exposure) | `config-check.sh` | CORS, serialization config |
| mod-001 (circuit-breaker) | `circuit-breaker-check.sh` | @CircuitBreaker present, config exists |
| mod-002 (retry) | `retry-check.sh` | @Retry present, annotation order |
| mod-003 (timeout) | `timeout-check.sh` | Timeout config values |

### run-all.sh Template Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `{{SERVICE_NAME}}` | Name of generated service | `customer-api` |

The template is located at `runtime/validators/run-all.sh.tpl`.

**Key requirements for run-all.sh:**
- Must NOT use `set -e` (would stop on first failure)
- Must capture exit codes before conditional checks
- Must iterate through all tier directories (tier0, tier1, tier2, tier3)
- Must generate JSON report in `reports/validation-results.json`
- Must use `bash` shebang (`#!/bin/bash`) for arrays support

### Shell Script Compatibility

**IMPORTANT:** Validation scripts should use POSIX-compatible syntax when possible, but some features require bash:

| Feature | POSIX | Bash Required |
|---------|-------|---------------|
| `[ -f file ]` | ✅ | |
| `[[ -f file ]]` | ❌ | ✅ |
| `x=$((x + 1))` | ✅ | |
| `((x++))` | ❌ | ✅ |
| `declare -a` | ❌ | ✅ |
| Process substitution `< <(...)` | ❌ | ✅ |

**Recommendation:** Use `#!/bin/bash` for `run-all.sh` (needs arrays), but individual tier scripts can use `#!/bin/sh` for portability.

### Outputs

| File | Required | Description |
|------|----------|-------------|
| `validation/run-all.sh` | Yes | Master validation orchestrator |
| `validation/scripts/tier0/conformance-check.sh` | Yes | Template fingerprint validation |
| `validation/scripts/tier1/*.sh` | Yes | Universal validations |
| `validation/scripts/tier2/*.sh` | Yes | Technology validations |
| `validation/scripts/tier3/*.sh` | Yes | Module-specific validations |
| `validation/reports/validation-results.json` | Yes | Execution results |

### Validation Execution

```bash
# From package root
cd validation

# Run all validations
./run-all.sh

# Or run specific tier
./scripts/tier0/conformance-check.sh ../output/customer-api
./scripts/tier1/naming-conventions-check.sh ../output/customer-api
```

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All validations passed |
| 1 | One or more validations failed |
| 2 | Validation skipped (feature not applicable) |

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
