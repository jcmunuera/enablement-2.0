<!-- ╔═══════════════════════════════════════════════════════════════╗ -->
<!-- ║ DEPRECATED: Use dependencies.yaml instead                    ║ -->
<!-- ║ This file is kept for reference only. Maven dependencies     ║ -->
<!-- ║ are now declared in dependencies.yaml and consolidated by    ║ -->
<!-- ║ the Context Agent into generation-context.json.              ║ -->
<!-- ║ See ODEC-017 in DECISION-LOG.md                              ║ -->
<!-- ╚═══════════════════════════════════════════════════════════════╝ -->

<!-- Template: pom-jpa.xml.tpl -->
<!-- Output: pom.xml (merge into dependencies section) -->
<!-- Purpose: JPA persistence dependencies -->

<!-- Spring Data JPA -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>

<!-- PostgreSQL Driver -->
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <scope>runtime</scope>
</dependency>

<!-- H2 for testing -->
<dependency>
    <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
    <scope>test</scope>
</dependency>

<!-- Testcontainers for integration tests -->
<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>junit-jupiter</artifactId>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>postgresql</artifactId>
    <scope>test</scope>
</dependency>
