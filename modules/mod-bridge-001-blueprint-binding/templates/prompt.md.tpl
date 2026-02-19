# Service: {{context_name}}

{{context_description}}

**Blueprint:** {{blueprint_id}}
**Building block:** {{building_block_id}}
**Tech stack:** {{tech_stack_id}}

---

## Domain Model

### Aggregate: {{aggregate_name}}
{{aggregate_description}}

**Entity:** {{entity_name}}
Fields:
{{#each entity_fields}}
- {{name}}: {{type}}{{#if description}} — {{description}}{{/if}}
{{/each}}

{{#if value_objects}}
**Value Objects:**
{{#each value_objects}}
- {{name}}: {{fields_summary}}
{{/each}}
{{/if}}

{{#if state_machine}}
**State Machine:**
States: {{state_machine.states}}
Transitions: {{state_machine.transitions}}
Terminal: {{state_machine.terminal_states}}
{{/if}}

---

## API Contract

See attached: `openapi-spec.yaml`

Summary of endpoints:
{{#each endpoints}}
- {{method}} {{path}} — {{description}}
{{/each}}

---

## Business Logic Specification

The following BDD scenarios define the expected behavior of this service.
Implement business logic that satisfies ALL scenarios.

```gherkin
{{bdd_scenarios_full_content}}
```

---

## Capabilities

The following capabilities are pre-resolved and MUST be applied:

| Capability | Source | Notes |
|-----------|--------|-------|
{{#each capabilities}}
| {{id}} | {{source}} | {{reason}} |
{{/each}}

{{#if tech_defaults.patterns}}
### Implementation Variants
{{#each tech_defaults.patterns}}
- {{@key}}: {{this}}
{{/each}}
{{/if}}

Additional capabilities may be discovered from this prompt by CODE discovery.

---

## Integration Context

{{#if upstream_dependencies}}
### Upstream dependencies (this service calls):
{{#each upstream_dependencies}}
- **{{name}}** ({{relationship_type}}): {{description}}
{{/each}}
{{/if}}

{{#if downstream_dependents}}
### Downstream dependents (call this service):
{{#each downstream_dependents}}
- **{{name}}**: {{description}}
{{/each}}
{{/if}}

{{#if domain_events}}
### Domain Events:
{{#each domain_events}}
- **{{name}}** — {{description}}
{{/each}}
{{/if}}
