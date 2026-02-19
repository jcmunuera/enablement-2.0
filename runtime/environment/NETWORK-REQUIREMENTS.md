# Network Requirements for Code Generation with Compilation

**Version:** 1.0  
**Date:** 2026-01-14

---

## Overview

For Enablement 2.0 to compile generated Java code, specific network domains must be accessible from the Claude container environment.

---

## Required Domains

### Tier 1: Minimum for Maven Compilation

| Domain | Purpose | Required For |
|--------|---------|--------------|
| `repo1.maven.org` | Maven Central repository | Downloading dependencies |
| `repo.maven.apache.org` | Maven Central (alternate) | Fallback for dependencies |

### Tier 2: JDK Installation (if not pre-installed)

| Domain | Purpose | Required For |
|--------|---------|--------------|
| `github.com` | GitHub main site | Accessing release pages |
| `github-releases.githubusercontent.com` | GitHub release assets | Downloading JDK binaries |
| `objects.githubusercontent.com` | GitHub raw content | Downloading release files |

### Tier 3: Alternative JDK Sources

| Domain | Purpose | Required For |
|--------|---------|--------------|
| `download.java.net` | Oracle/OpenJDK official | Alternative JDK source |
| `cdn.azul.com` | Azul Zulu JDK | Alternative JDK source |
| `api.adoptium.net` | Adoptium API | JDK version discovery |

---

## Recommended Configuration

Add these domains to your Claude network configuration:

```
repo1.maven.org
repo.maven.apache.org
github.com
github-releases.githubusercontent.com
objects.githubusercontent.com
```

---

## Verification Script

Run this in a new Claude chat to verify network access:

```bash
echo "=== Network Verification for Enablement 2.0 ==="

# Test Maven Central
echo -n "Maven Central: "
curl -sI --max-time 5 https://repo1.maven.org/maven2/ 2>&1 | grep -q "200 OK" && echo "✅ OK" || echo "❌ BLOCKED"

# Test GitHub Releases
echo -n "GitHub Releases: "
curl -sI --max-time 5 https://github-releases.githubusercontent.com 2>&1 | grep -q "200\|301\|302" && echo "✅ OK" || echo "❌ BLOCKED"

# Test JDK availability
echo -n "JDK (javac): "
which javac >/dev/null 2>&1 && echo "✅ Installed" || echo "⚠️ Not installed (will download)"
```

---

## Compilation Strategy

### If Full Network Access Available

1. Download ECJ (Eclipse Compiler) from Maven Central
2. Use ECJ to compile without requiring JDK installation
3. Parse errors and auto-correct

```bash
# Download ECJ (2.3MB, one-time)
curl -L -o /home/claude/ecj.jar \
  "https://repo1.maven.org/maven2/org/eclipse/jdt/ecj/3.36.0/ecj-3.36.0.jar"

# Compile with ECJ
java -jar /home/claude/ecj.jar -source 17 -target 17 \
  $(find src/main/java -name '*.java')
```

### If Limited Network Access

1. Run syntax-check.sh (no network required)
2. Detect known LLM hallucinations
3. Flag for manual compilation by user

### If No Network Access

1. Run syntax-check.sh only
2. Document that compilation was not verified
3. User must compile locally

---

## Troubleshooting

### "host_not_allowed" Error

This means the domain is not in your Claude network configuration.

**Solution:** Add the domain to Settings → Features → Computer Use → Allowed Domains

### "Connection timeout"

The domain might be accessible but slow.

**Solution:** Retry or check if the service is up

### "403 Forbidden" (without x-deny-reason)

The remote server is rejecting requests.

**Solution:** Try alternative domain (e.g., `repo.maven.apache.org` instead of `repo1.maven.org`)

---

## Environment Check Results

Run `environment-check.sh` to get a full report of your compilation capabilities.

---

**END OF DOCUMENT**
