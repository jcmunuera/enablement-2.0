# Validation - skill-041-add-api-exposure-java-spring

## Usage

```bash
./validate.sh /path/to/project [api-layer]
```

## Checks

1. REST controllers exist with @RestController
2. Pagination support (PageResponse, Pageable)
3. HATEOAS assemblers (for experience/domain layers)
4. OpenAPI dependencies
5. Compilation success
