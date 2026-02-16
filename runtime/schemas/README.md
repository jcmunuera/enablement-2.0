# Runtime Schemas

JSON Schemas for validating generation artifacts and traces.

## Directory Structure

```
schemas/
├── README.md
└── trace/                           # Trace and output schemas
    ├── manifest.schema.json         # .enablement/manifest.json
    ├── discovery-trace.schema.json  # trace/discovery-trace.json
    ├── generation-trace.schema.json # trace/generation-trace.json
    ├── modules-used.schema.json     # trace/modules-used.json
    └── validation-results.schema.json # validation/reports/validation-results.json
```

## Schemas

| Schema | Purpose | Location in Package |
|--------|---------|---------------------|
| `manifest.schema.json` | Generation metadata | `output/{project}/.enablement/manifest.json` |
| `discovery-trace.schema.json` | Discovery phase trace | `trace/discovery-trace.json` |
| `generation-trace.schema.json` | Generation phase trace | `trace/generation-trace.json` |
| `modules-used.schema.json` | Module contributions | `trace/modules-used.json` |
| `validation-results.schema.json` | Validation results | `validation/reports/validation-results.json` |

## Schema Descriptions

### manifest.schema.json

Validates the generation manifest stored in each generated project. Contains:
- **generation**: Unique identifiers (id, timestamp, run_id)
- **enablement**: Platform metadata (version, domain, flow)
- **discovery**: Detected capabilities, features, stack
- **modules**: List of modules used with phase info
- **status**: Validation results per tier
- **metrics**: File counts, LOC

### discovery-trace.schema.json

Traces how the prompt was analyzed and capabilities were resolved:
- **prompt_analysis**: Raw prompt, detected intent, entities
- **capability_resolution**: Rules applied, capabilities detected
- **module_resolution**: Stack detection, module selection
- **config_derivation**: Static config and calculated flags
- **phase_assignment**: How features were grouped into phases

### generation-trace.schema.json

Traces what was generated in each phase:
- **phases**: List of phases with files generated/modified
- **compilation_result**: Per-phase compilation status
- **tests_generated**: Unit and integration tests
- **summary**: Total files, LOC, duration

### modules-used.schema.json

Details each module's contribution:
- **templates_used**: Which templates were applied
- **files_generated**: Files created with checksums
- **files_modified**: Files modified and how
- **dependencies_added**: Maven/Gradle dependencies
- **config_added**: Configuration sections

### validation-results.schema.json

Captures validation suite results:
- **tiers**: Results for tier1, tier2, tier3
- **validations**: Individual validation results
- **summary**: Overall pass/fail counts
- **environment**: OS, shell, Java version

## Usage

### JavaScript/Node.js

```javascript
const Ajv = require('ajv');
const addFormats = require('ajv-formats');

const ajv = new Ajv();
addFormats(ajv);

const schema = require('./trace/manifest.schema.json');
const validate = ajv.compile(schema);

const manifest = JSON.parse(fs.readFileSync('.enablement/manifest.json'));
if (!validate(manifest)) {
    console.error(validate.errors);
}
```

### Python

```python
import jsonschema
import json

with open('runtime/schemas/trace/manifest.schema.json') as f:
    schema = json.load(f)
    
with open('output/customer-api/.enablement/manifest.json') as f:
    manifest = json.load(f)
    
jsonschema.validate(manifest, schema)
```

### CLI (ajv-cli)

```bash
# Install
npm install -g ajv-cli ajv-formats

# Validate manifest
ajv validate -s schemas/trace/manifest.schema.json \
             -d output/customer-api/.enablement/manifest.json

# Validate discovery trace
ajv validate -s schemas/trace/discovery-trace.schema.json \
             -d trace/discovery-trace.json
```

### Bash (with jq)

```bash
# Basic structure check
jq -e '.enablement.version and .discovery.capabilities' \
   output/customer-api/.enablement/manifest.json
```

## Schema Alignment with Model v3.0

These schemas are aligned with Enablement 2.0 v3.0:

- **No skills**: The model uses capability → feature → module discovery
- **enablement** object replaces deprecated "skill" object
- **discovery** object captures capability resolution
- **modules** include capability reference

## Related

- [Flow Generate Output](../flows/code/flow-generate-output.md) - Package structure
- [Discovery Guidance](../discovery/discovery-guidance.md) - Capability detection
- [Capability Index](../discovery/capability-index.yaml) - Source of truth

---

*Managed by C4E Team - Last updated: 2026-01-23*
