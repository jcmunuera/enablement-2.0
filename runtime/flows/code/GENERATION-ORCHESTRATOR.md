# Generation Orchestrator

## Version: 1.0
## Last Updated: 2026-01-23

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
│  ┌─────────┐   ┌───────────┐   ┌────────────┐   ┌───────┐   ┌───────────┐  │
│  │  INIT   │──▶│ DISCOVERY │──▶│ GENERATION │──▶│ TESTS │──▶│ VALIDATE  │  │
│  └─────────┘   └───────────┘   └────────────┘   └───────┘   └───────────┘  │
│       │              │               │              │             │         │
│       ▼              ▼               ▼              ▼             ▼         │
│   Create         Write          Write          Generate      Execute       │
│   Package       discovery-     generation-      unit         validation    │
│   Structure     trace.json     trace.json       tests        scripts       │
│                                                                             │
│                              ┌──────────┐                                   │
│                              │ PACKAGE  │                                   │
│                              └──────────┘                                   │
│                                   │                                         │
│                                   ▼                                         │
│                              Create .tar.gz                                 │
│                              with all artifacts                             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

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

## Phase 3: GENERATION

### Objective
Generate code in phases, tracking all decisions and files.

### Steps

```python
def generation_phase(ctx: PackageContext, discovery: DiscoveryResult) -> GenerationResult:
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
            
            # Generate code using module templates
            files = module.generate(
                context=ctx,
                config=discovery.config,
                existing_files=generated_files
            )
            
            for file_path, content in files.items():
                full_path = f"{project_dir}/{file_path}"
                write_file(full_path, content)
                phase_files.append(file_path)
                generated_files[file_path] = content
                
                # Log decision
                decisions.append({
                    "timestamp": now_iso(),
                    "decision": "GENERATE_FILE",
                    "phase": phase.number,
                    "file": file_path,
                    "module": module_id
                })
            
            # Track module contribution
            modules_used.append({
                "id": module_id,
                "version": module.version,
                "capability": module.capability,
                "phase": phase.number,
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

### Outputs
- `output/{service-name}/` - Complete project
- `trace/generation-trace.json`
- `trace/modules-used.json`
- `trace/decisions-log.jsonl`

---

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
    
    manifest = {
        "generation": {
            "id": str(ctx.generation_id),
            "timestamp": now_iso(),
            "run_id": ctx.run_id
        },
        "enablement": {
            "version": "3.0.6",
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

### Steps

```python
def validation_phase(ctx: PackageContext, generation: GenerationResult):
    validation_dir = f"{ctx.package_dir}/validation"
    
    # 1. Copy Tier-1 scripts (Universal)
    tier1_source = "runtime/validators/tier-1-universal/"
    for script in glob(f"{tier1_source}/**/*.sh"):
        copy_file(script, f"{validation_dir}/scripts/tier1/{basename(script)}")
    
    # 2. Copy Tier-2 scripts (Technology-specific)
    stack = "java-spring"
    tier2_source = f"runtime/validators/tier-2-technology/code-projects/{stack}/"
    for script in glob(f"{tier2_source}/*.sh"):
        copy_file(script, f"{validation_dir}/scripts/tier2/{basename(script)}")
    
    # 3. Copy Tier-3 scripts (Module-specific)
    for module_info in generation.modules_used:
        module_dir = f"modules/{module_info['id']}/validation/"
        for script in glob(f"{module_dir}/*.sh"):
            copy_file(script, f"{validation_dir}/scripts/tier3/{basename(script)}")
    
    # 4. Generate run-all.sh
    generate_run_all_sh(validation_dir, generation.modules_used)
    
    # 5. Execute validations
    result = execute_validations(validation_dir, generation.project_dir)
    
    # 6. Write results
    write_json(f"{validation_dir}/reports/validation-results.json", result)
    
    # 7. Update manifest with results
    update_manifest_status(generation.project_dir, result)
    
    return result
```

### Outputs
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
