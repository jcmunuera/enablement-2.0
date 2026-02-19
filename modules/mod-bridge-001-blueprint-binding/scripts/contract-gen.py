#!/usr/bin/env python3
"""
contract-gen.py — Generate OpenAPI 3.0 specs from DDD aggregate definitions.

Part of mod-bridge-001-blueprint-binding.
Follows policies: contract-generation.md + fusion-api-rest.ddd-bdd binding.

Usage:
  python3 contract-gen.py <design-output-dir> <bridge-output-dir> [<context-map.yaml>]
"""

import yaml, os, sys, re, copy

# ═══════════════════════════════════════════════════════════
# CONFIGURATION (from binding: fusion-api-rest.ddd-bdd)
# ═══════════════════════════════════════════════════════════

STATE_CHANGE_VERBS = {
    'block', 'unblock', 'reactivate', 'pause', 'resume', 'cancel',
    'activate', 'deactivate', 'suspend', 'approve', 'reject', 'close',
    'archive', 'restore', 'enable', 'disable', 'lock', 'unlock'
}
CREATE_VERBS = {'create', 'execute', 'submit', 'register', 'initiate', 'open'}
DELETE_VERBS = {'delete', 'remove'}
UPDATE_VERBS = {'update', 'modify', 'edit', 'change'}

# Queries that target a specific sub-resource (not the main entity)
SUB_RESOURCE_PATTERNS = {
    'transaction': 'transactions',
    'movement': 'movements',
    'history': 'history',
    'detail': 'details',
}

# Queries that access a specific field/aspect of an entity
FIELD_QUERY_PATTERNS = {
    'pin': 'pin',
    'balance': 'balance',
    'status': 'status',
    'summary': 'summary',
}

TYPE_MAP = {
    'String': {'type': 'string'},
    'string': {'type': 'string'},
    'UUID': {'type': 'string', 'format': 'uuid'},
    'Integer': {'type': 'integer'},
    'int': {'type': 'integer'},
    'Long': {'type': 'integer', 'format': 'int64'},
    'Boolean': {'type': 'boolean'},
    'boolean': {'type': 'boolean'},
    'Date': {'type': 'string', 'format': 'date'},
    'LocalDate': {'type': 'string', 'format': 'date'},
    'DateTime': {'type': 'string', 'format': 'date-time'},
    'Money': {'$ref': '#/components/schemas/Money'},
    'BigDecimal': {'type': 'number'},
    'Decimal': {'type': 'number'},
    'Double': {'type': 'number', 'format': 'double'},
}


def pluralize(word):
    """Simple English pluralization."""
    if word.endswith('s') or word.endswith('x') or word.endswith('z'):
        return word + 'es'
    elif word.endswith('y') and word[-2] not in 'aeiou':
        return word[:-1] + 'ies'
    elif word.endswith('s'):
        return word
    else:
        return word + 's'


def to_camel(kebab):
    """kebab-case to CamelCase."""
    return ''.join(w.capitalize() for w in kebab.split('-'))


def map_type(type_name):
    """Map DDD type to OpenAPI schema."""
    if type_name in TYPE_MAP:
        return copy.deepcopy(TYPE_MAP[type_name])
    if type_name.startswith('List<') or type_name.startswith('Set<'):
        inner = type_name[type_name.index('<')+1:-1]
        return {'type': 'array', 'items': map_type(inner)}
    if type_name.startswith('Enum'):
        return {'type': 'string'}
    # Assume it's a reference to another schema
    return {'$ref': f'#/components/schemas/{type_name}'}


def extract_verb(command_id):
    """Extract the verb from a command ID like 'block-card' → 'block'."""
    return command_id.split('-')[0]


def detect_query_type(query_id, query_data, aggregate_id, id_field_name):
    """
    Classify a query and determine its path.
    Returns: (path_suffix, params, is_paginated)
    """
    q_id = query_id.lower()
    q_parts = q_id.split('-')
    verb = q_parts[0]
    
    # Check for sub-resource patterns (e.g., list-card-transactions → /cards/{id}/transactions)
    for pattern, sub_path in SUB_RESOURCE_PATTERNS.items():
        if pattern in q_id:
            return (f'/{{{id_field_name}}}/{sub_path}', 
                    [path_param(id_field_name)], True)
    
    # Check for field-specific queries (e.g., retrieve-card-pin → /cards/{id}/pin)
    for pattern, sub_path in FIELD_QUERY_PATTERNS.items():
        if pattern in q_id and verb in ('get', 'retrieve', 'fetch', 'read'):
            return (f'/{{{id_field_name}}}/{sub_path}',
                    [path_param(id_field_name)], False)
    
    # List queries → resource root with pagination
    if verb in ('list', 'search', 'find'):
        return ('', [], True)
    
    # Get single entity → /{id}
    if verb in ('get', 'retrieve', 'fetch', 'read'):
        # Check if there's an ID in inputs
        inputs = query_data.get('input', [])
        has_id = any('id' in inp.get('name', '').lower() for inp in inputs)
        if has_id or 'by-id' in q_id:
            return (f'/{{{id_field_name}}}', [path_param(id_field_name)], False)
        else:
            # Singleton query (e.g., get-global-position) — no ID needed
            return ('', [], False)
    
    # Default: treat as list
    return ('', [], True)


def path_param(name):
    return {'name': name, 'in': 'path', 'required': True, 'schema': {'type': 'string'}}


def query_param(name, required=False, type_name='string'):
    schema = map_type(type_name) if type_name != 'string' else {'type': 'string'}
    return {'name': name, 'in': 'query', 'required': required, 'schema': schema}


def pagination_params():
    return [
        {'name': 'page', 'in': 'query', 'required': False, 'schema': {'type': 'integer', 'default': 0}},
        {'name': 'size', 'in': 'query', 'required': False, 'schema': {'type': 'integer', 'default': 20}},
    ]


def build_entity_schema(entities, value_objects):
    """Build OpenAPI schemas from entities and value objects."""
    schemas = {}
    
    for entity in entities:
        name = entity.get('name', to_camel(entity.get('id', 'Unknown')))
        props = {}
        required = []
        
        # Identity field
        identity = entity.get('identity', {})
        if identity:
            id_name = identity.get('field', 'id')
            props[id_name] = map_type(identity.get('type', 'String'))
            if identity.get('description'):
                props[id_name]['description'] = identity['description']
        
        # Attributes
        for attr in entity.get('attributes', []):
            attr_name = attr['name']
            prop = map_type(attr.get('type', 'String'))
            if attr.get('description'):
                prop['description'] = attr['description']
            props[attr_name] = prop
            if attr.get('required', False):
                required.append(attr_name)
        
        schema = {'type': 'object', 'properties': props}
        if required:
            schema['required'] = required
        schemas[name] = schema
    
    for vo in value_objects:
        name = vo.get('name', to_camel(vo.get('id', 'Unknown')))
        props = {}
        for attr in vo.get('attributes', vo.get('fields', [])):
            attr_name = attr['name']
            type_name = attr.get('type', 'String')
            prop = map_type(type_name)
            if attr.get('description'):
                prop['description'] = attr['description']
            if attr.get('constraints'):
                # Enum constraints
                values = [v.strip() for v in attr['constraints'].split(',')]
                prop = {'type': 'string', 'enum': values}
            props[attr_name] = prop
        
        if props:
            schemas[name] = {'type': 'object', 'properties': props}
    
    return schemas


def generate_openapi(ctx_id, agg_data, ctx_description=''):
    """Generate OpenAPI spec for one bounded context."""
    
    paths = {}
    schemas = {}
    error_codes = []
    
    for agg in agg_data.get('aggregates', []):
        agg_id = agg['id']
        agg_name = agg.get('name', to_camel(agg_id))
        
        # Determine resource path
        resource_word = agg_id  # e.g., "card", "periodic-transfer"
        resource_plural = pluralize(resource_word)
        base_path = f'/{resource_plural}'
        
        # Find root entity and its ID field
        root_entity_id = agg.get('root_entity', None)
        entities = agg.get('entities', [])
        root_entity = None
        for e in entities:
            if e.get('is_root') or e.get('id') == root_entity_id:
                root_entity = e
                break
        if not root_entity and entities:
            root_entity = entities[0]
        
        # Determine ID field name
        id_field_name = f'{agg_id}Id'
        if root_entity:
            identity = root_entity.get('identity', {})
            if identity.get('field'):
                id_field_name = identity['field']
        
        entity_schema_name = root_entity.get('name', agg_name) if root_entity else agg_name
        
        # Build schemas from entities and VOs
        entity_schemas = build_entity_schema(entities, agg.get('value_objects', []))
        schemas.update(entity_schemas)
        
        # ─── COMMANDS → ENDPOINTS ───
        for cmd in agg.get('commands', []):
            cmd_id = cmd['id']
            cmd_name = cmd.get('name', to_camel(cmd_id))
            verb = extract_verb(cmd_id)
            description = cmd.get('description', '')[:120]
            
            # Build request schema from inputs
            req_props = {}
            req_required = []
            for inp in cmd.get('input', []):
                inp_name = inp['name']
                # Skip the entity ID for state-change commands (it goes in path)
                if verb in STATE_CHANGE_VERBS and inp_name == id_field_name:
                    continue
                prop = map_type(inp.get('type', 'String'))
                if inp.get('description'):
                    prop['description'] = inp['description']
                req_props[inp_name] = prop
                if inp.get('required', True):
                    req_required.append(inp_name)
            
            if verb in CREATE_VERBS:
                path = base_path
                method = 'post'
                responses = {
                    '201': {
                        'description': f'{entity_schema_name} created',
                        'content': {'application/json': {'schema': {'$ref': f'#/components/schemas/{entity_schema_name}'}}}
                    },
                    '400': {
                        'description': 'Validation or business rule error',
                        'content': {'application/json': {'schema': {'$ref': '#/components/schemas/ErrorResponse'}}}
                    }
                }
                endpoint = {
                    'operationId': cmd_id,
                    'summary': description or f'Create {entity_schema_name}',
                    'tags': [agg_name],
                    'responses': responses
                }
                if req_props:
                    req_schema_name = f'{cmd_name}Request'
                    schemas[req_schema_name] = {'type': 'object', 'properties': req_props}
                    if req_required:
                        schemas[req_schema_name]['required'] = req_required
                    endpoint['requestBody'] = {
                        'required': True,
                        'content': {'application/json': {'schema': {'$ref': f'#/components/schemas/{req_schema_name}'}}}
                    }
                paths.setdefault(path, {})[method] = endpoint
                
            elif verb in STATE_CHANGE_VERBS:
                action = verb
                path = f'{base_path}/{{{id_field_name}}}/{action}'
                method = 'post'
                endpoint = {
                    'operationId': cmd_id,
                    'summary': description or f'{verb.title()} {entity_schema_name}',
                    'tags': [agg_name],
                    'parameters': [path_param(id_field_name)],
                    'responses': {
                        '200': {
                            'description': f'{entity_schema_name} {action}ed',
                            'content': {'application/json': {'schema': {'$ref': f'#/components/schemas/{entity_schema_name}'}}}
                        },
                        '400': {
                            'description': 'Business rule violation',
                            'content': {'application/json': {'schema': {'$ref': '#/components/schemas/ErrorResponse'}}}
                        },
                        '404': {
                            'description': f'{entity_schema_name} not found',
                            'content': {'application/json': {'schema': {'$ref': '#/components/schemas/ErrorResponse'}}}
                        }
                    }
                }
                if req_props:
                    req_schema_name = f'{cmd_name}Request'
                    schemas[req_schema_name] = {'type': 'object', 'properties': req_props}
                    endpoint['requestBody'] = {
                        'required': True,
                        'content': {'application/json': {'schema': {'$ref': f'#/components/schemas/{req_schema_name}'}}}
                    }
                paths.setdefault(path, {})[method] = endpoint
                
            elif verb in DELETE_VERBS:
                path = f'{base_path}/{{{id_field_name}}}'
                method = 'delete'
                endpoint = {
                    'operationId': cmd_id,
                    'summary': description or f'Delete {entity_schema_name}',
                    'tags': [agg_name],
                    'parameters': [path_param(id_field_name)],
                    'responses': {
                        '204': {'description': 'Deleted'},
                        '404': {
                            'description': 'Not found',
                            'content': {'application/json': {'schema': {'$ref': '#/components/schemas/ErrorResponse'}}}
                        }
                    }
                }
                paths.setdefault(path, {})[method] = endpoint
        
        # ─── QUERIES → ENDPOINTS ───
        for q in agg.get('queries', []):
            q_id = q['id']
            q_name = q.get('name', to_camel(q_id))
            description = q.get('description', '')[:120]
            
            suffix, params, is_paginated = detect_query_type(
                q_id, q, agg_id, id_field_name
            )
            
            path = base_path + suffix
            
            # Add query input params (excluding IDs already in path)
            path_param_names = {p['name'] for p in params}
            for inp in q.get('input', []):
                if inp['name'] not in path_param_names:
                    params.append(query_param(
                        inp['name'], 
                        required=inp.get('required', False),
                        type_name=inp.get('type', 'string')
                    ))
            
            if is_paginated:
                params.extend(pagination_params())
            
            # Response schema
            if is_paginated:
                response_schema = {'$ref': '#/components/schemas/PagedResponse'}
            else:
                response_schema = {'$ref': f'#/components/schemas/{entity_schema_name}'}
            
            endpoint = {
                'operationId': q_id,
                'summary': description or q_name,
                'tags': [agg_name],
                'responses': {
                    '200': {
                        'description': description or 'Success',
                        'content': {'application/json': {'schema': response_schema}}
                    }
                }
            }
            if params:
                endpoint['parameters'] = params
            
            # Add 404 for single-entity queries (not lists)
            if not is_paginated and suffix and '{' in suffix:
                endpoint['responses']['404'] = {
                    'description': 'Not found',
                    'content': {'application/json': {'schema': {'$ref': '#/components/schemas/ErrorResponse'}}}
                }
            
            # Handle path collision: if GET already exists on this path
            if path in paths and 'get' in paths[path]:
                existing = paths[path]['get']
                # Keep the one that's more specific (has path params or is a list)
                # If both are different queries on same path, need disambiguation
                print(f"    WARNING: GET path collision on {path}: "
                      f"{existing['operationId']} vs {q_id}. Keeping both as separate paths.")
                # Add distinguishing suffix
                if suffix == '':
                    # This is the base path — make it unique by appending query purpose
                    alt_suffix = '/' + q_id.split('-')[-1]  # e.g., /summary, /total
                    path = base_path + alt_suffix
            
            paths.setdefault(path, {})['get'] = endpoint
        
        # ─── ERROR CODES from invariants ───
        for inv in agg.get('invariants', []):
            if inv.get('enforced_by') == 'query-validation':
                continue
            code = inv['id'].upper().replace('-', '_')
            error_codes.append(code)
    
    # ─── STANDARD SCHEMAS ───
    schemas['Money'] = {
        'type': 'object',
        'properties': {
            'amount': {'type': 'number', 'description': 'Monetary amount'},
            'currency': {'type': 'string', 'description': 'ISO 4217 currency code'}
        },
        'required': ['amount', 'currency']
    }
    schemas['ErrorResponse'] = {
        'type': 'object',
        'required': ['code', 'message'],
        'properties': {
            'code': {
                'type': 'string',
                'description': 'Error code. Possible values: ' + ', '.join(sorted(error_codes)) if error_codes else 'Error code'
            },
            'message': {'type': 'string', 'description': 'Human-readable error description'}
        }
    }
    schemas['PagedResponse'] = {
        'type': 'object',
        'properties': {
            'content': {'type': 'array', 'items': {'type': 'object'}},
            'page': {'type': 'integer'},
            'size': {'type': 'integer'},
            'totalElements': {'type': 'integer'},
            'totalPages': {'type': 'integer'}
        }
    }
    
    # ─── ASSEMBLE ───
    openapi = {
        'openapi': '3.0.3',
        'info': {
            'title': f'{ctx_id.replace("-", " ").title()} API',
            'description': ctx_description,
            'version': '1.0.0'
        },
        'paths': dict(sorted(paths.items())),
        'components': {'schemas': dict(sorted(schemas.items()))}
    }
    
    return openapi, error_codes


def main():
    if len(sys.argv) < 3:
        print("Usage: contract-gen.py <design-output-dir> <bridge-output-dir> [context-map.yaml]")
        sys.exit(1)
    
    design_dir = sys.argv[1]
    output_dir = sys.argv[2]
    ctxmap_file = sys.argv[3] if len(sys.argv) > 3 else os.path.join(design_dir, 'bounded-context-map.yaml')
    
    # Load context map for descriptions
    ctx_descriptions = {}
    if os.path.exists(ctxmap_file):
        with open(ctxmap_file) as f:
            ctxmap = yaml.safe_load(f)
        for sd in ctxmap.get('subdomains', []):
            for bc in sd.get('bounded_contexts', []):
                ctx_descriptions[bc['id']] = bc.get('description', '')
    
    # Find all build contexts (directories with aggregate-definitions.yaml)
    contexts = []
    for entry in sorted(os.listdir(design_dir)):
        agg_path = os.path.join(design_dir, entry, 'aggregate-definitions.yaml')
        if os.path.isdir(os.path.join(design_dir, entry)) and os.path.exists(agg_path):
            contexts.append(entry)
    
    print(f"Contract generation for {len(contexts)} contexts")
    print()
    
    total_endpoints = 0
    total_schemas = 0
    
    for ctx_id in contexts:
        agg_file = os.path.join(design_dir, ctx_id, 'aggregate-definitions.yaml')
        with open(agg_file) as f:
            agg_data = yaml.safe_load(f)
        
        ctx_out = os.path.join(output_dir, ctx_id)
        os.makedirs(ctx_out, exist_ok=True)
        
        desc = ctx_descriptions.get(ctx_id, '')
        openapi, error_codes = generate_openapi(ctx_id, agg_data, desc)
        
        out_file = os.path.join(ctx_out, 'openapi-spec.yaml')
        with open(out_file, 'w') as f:
            yaml.dump(openapi, f, default_flow_style=False, sort_keys=False, allow_unicode=True)
        
        n_endpoints = sum(
            len([m for m in methods if m in ('get','post','put','delete','patch')])
            for methods in openapi['paths'].values()
        )
        n_schemas = len(openapi['components']['schemas'])
        total_endpoints += n_endpoints
        total_schemas += n_schemas
        
        # Print endpoint details
        print(f"  {ctx_id}: {n_endpoints} endpoints, {n_schemas} schemas, {len(error_codes)} error codes")
        for path, methods in sorted(openapi['paths'].items()):
            for m in ('get', 'post', 'put', 'delete'):
                if m in methods:
                    print(f"    {m.upper():6} {path:50} {methods[m].get('operationId','')}")
    
    print(f"\n  TOTAL: {total_endpoints} endpoints, {total_schemas} schemas across {len(contexts)} contexts")


if __name__ == '__main__':
    main()
