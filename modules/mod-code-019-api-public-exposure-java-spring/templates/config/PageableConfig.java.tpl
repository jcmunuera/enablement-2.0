// Template: PageableConfig.java.tpl
// Output: {{basePackagePath}}/infrastructure/web/PageableConfig.java
// Purpose: Configure pagination defaults per ADR-001

package {{basePackage}}.infrastructure.web;

import org.springframework.context.annotation.Configuration;
import org.springframework.data.web.config.EnableSpringDataWebSupport;

/**
 * Configuration for pagination support per ADR-001.
 * Enables Spring Data's Pageable resolver for controller method parameters.
 * 
 * Configuration values are in application.yml:
 * - spring.data.web.pageable.default-page-size: 20
 * - spring.data.web.pageable.max-page-size: 100
 * - spring.data.web.pageable.one-indexed-parameters: false
 */
@Configuration
@EnableSpringDataWebSupport
public class PageableConfig {
    // Configuration is driven by application.yml properties
}
