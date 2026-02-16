#!/bin/sh
# naming-conventions-check.sh
# Validates naming conventions (classes, packages)
# Version: 1.2 - POSIX compatible (works with sh on Mac)

SERVICE_DIR="${1:-.}"

ERRORS=0
WARNINGS=0

# Simple output functions (no color codes for maximum compatibility)
pass() { echo "✅ PASS: $1"; }
fail() { echo "❌ FAIL: $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo "⚠️  WARN: $1"; WARNINGS=$((WARNINGS + 1)); }

# Check Java class names are PascalCase
if [ -d "$SERVICE_DIR/src/main/java" ]; then
    BAD_CLASSES=$(find "$SERVICE_DIR/src/main/java" -name "*.java" -type f -exec basename {} \; 2>/dev/null | grep -E '^[a-z]' | head -3)
    
    if [ -z "$BAD_CLASSES" ]; then
        pass "Java classes follow PascalCase convention"
    else
        warn "Some classes may not follow PascalCase convention: $BAD_CLASSES"
    fi
fi

# Check package names are lowercase
if [ -d "$SERVICE_DIR/src/main/java" ]; then
    # List all directory names and check for uppercase
    BAD_PACKAGES=$(find "$SERVICE_DIR/src/main/java" -type d 2>/dev/null | xargs -I {} basename {} | grep '[A-Z]' | head -3)
    
    if [ -z "$BAD_PACKAGES" ]; then
        pass "Package names are lowercase"
    else
        warn "Some package names may contain uppercase letters: $BAD_PACKAGES"
    fi
fi

# Check for common naming patterns
if [ -d "$SERVICE_DIR/src/main/java" ]; then
    # Controllers should end with Controller (check in controller/ and rest/ dirs)
    # Exclude common non-controller files like Advice, Handler, Config
    CONTROLLER_FILES=$(find "$SERVICE_DIR/src/main/java" -type f -name "*.java" 2>/dev/null | grep -E "/(controller|rest)/" | grep -v -E "(Advice|Handler|Config)\.java$")
    
    NON_STANDARD=""
    if [ -n "$CONTROLLER_FILES" ]; then
        NON_STANDARD=$(echo "$CONTROLLER_FILES" | xargs -I {} basename {} | grep -v "Controller\.java$" | head -3)
    fi
    
    if [ -z "$NON_STANDARD" ]; then
        pass "Controllers follow naming convention (*Controller.java)"
    else
        warn "Some controllers don't end with 'Controller': $NON_STANDARD"
    fi
    
    # Services should end with Service
    SERVICE_FILES=$(find "$SERVICE_DIR/src/main/java" -type f -name "*.java" -path "*/service/*" 2>/dev/null)
    
    NON_STANDARD=""
    if [ -n "$SERVICE_FILES" ]; then
        NON_STANDARD=$(echo "$SERVICE_FILES" | xargs -I {} basename {} | grep -v "Service\.java$" | head -3)
    fi
    
    if [ -z "$NON_STANDARD" ]; then
        pass "Services follow naming convention (*Service.java)"
    else
        warn "Some services don't end with 'Service': $NON_STANDARD"
    fi
fi

if [ $ERRORS -eq 0 ]; then
    exit 0
else
    exit 1
fi
