<!-- ╔═══════════════════════════════════════════════════════════════╗ -->
<!-- ║ DEPRECATED: Use dependencies.yaml instead                    ║ -->
<!-- ║ This file is kept for reference only. Maven dependencies     ║ -->
<!-- ║ are now declared in dependencies.yaml and consolidated by    ║ -->
<!-- ║ the Context Agent into generation-context.json.              ║ -->
<!-- ║ See ODEC-017 in DECISION-LOG.md                              ║ -->
<!-- ╚═══════════════════════════════════════════════════════════════╝ -->

<!-- ═══════════════════════════════════════════════════════════════════════════════
     Template: pom-circuitbreaker.xml.tpl
     Module: mod-code-001-circuit-breaker-java-resilience4j
     Purpose: POM dependencies for circuit breaker pattern
     Usage: Merge into existing pom.xml <dependencies> section
     ═══════════════════════════════════════════════════════════════════════════════ -->

<!-- Resilience4j Circuit Breaker -->
<dependency>
    <groupId>io.github.resilience4j</groupId>
    <artifactId>resilience4j-spring-boot3</artifactId>
    <version>${resilience4j.version}</version>
</dependency>

<!-- AOP support for @CircuitBreaker, @Retry, @TimeLimiter annotations -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-aop</artifactId>
</dependency>

<!-- Actuator for resilience metrics -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>

<!-- Add to <properties> section -->
<!-- <resilience4j.version>2.2.0</resilience4j.version> -->