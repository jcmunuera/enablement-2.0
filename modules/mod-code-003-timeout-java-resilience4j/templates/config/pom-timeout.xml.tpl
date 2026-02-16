<!-- ╔═══════════════════════════════════════════════════════════════╗ -->
<!-- ║ DEPRECATED: Use dependencies.yaml instead                    ║ -->
<!-- ║ This file is kept for reference only. Maven dependencies     ║ -->
<!-- ║ are now declared in dependencies.yaml and consolidated by    ║ -->
<!-- ║ the Context Agent into generation-context.json.              ║ -->
<!-- ║ See ODEC-017 in DECISION-LOG.md                              ║ -->
<!-- ╚═══════════════════════════════════════════════════════════════╝ -->

<!-- Template: pom-timeout.xml.tpl -->
<!-- Output: pom.xml (merge into dependencies section) -->
<!-- Purpose: Resilience4j timeout dependencies -->

<!-- Resilience4j Spring Boot Starter -->
<dependency>
    <groupId>io.github.resilience4j</groupId>
    <artifactId>resilience4j-spring-boot3</artifactId>
    <version>2.1.0</version>
</dependency>

<!-- Spring Boot AOP (required for annotations) -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-aop</artifactId>
</dependency>

<!-- Actuator for metrics -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
