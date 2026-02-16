    /**
     * Fallback for {{methodName}} when circuit breaker is open or call fails.
     * 
     * @param throwable the exception that triggered the fallback
     * @return fallback response (null or empty depending on return type)
     */
    private {{returnType}} {{methodName}}Fallback({{parameters}}, Throwable throwable) {
        log.warn("Circuit breaker fallback triggered for {{methodName}}: {}", throwable.getMessage());
        {{#if returnType.isOptional}}
        return Optional.empty();
        {{else if returnType.isList}}
        return Collections.emptyList();
        {{else if returnType.isVoid}}
        // void method - just log
        {{else}}
        return null;
        {{/if}}
    }
