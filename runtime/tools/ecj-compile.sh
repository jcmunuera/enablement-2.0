#!/bin/bash
# ==============================================================================
# ECJ-COMPILE.SH - Compile Java without JDK using Eclipse Compiler
# ==============================================================================
# Version: 1.0
# Purpose: Compile Java source files using ECJ (Eclipse Compiler for Java)
#          This works with JRE only - no JDK installation required.
#
# Usage: ./ecj-compile.sh <project-directory>
# Returns: 0 if compilation succeeds, 1 if errors found
# ==============================================================================

set -e

PROJECT_DIR="${1:-.}"
ECJ_DIR="/home/claude/.enablement-tools"
ECJ_JAR="$ECJ_DIR/ecj-3.36.0.jar"
ECJ_URL="https://repo1.maven.org/maven2/org/eclipse/jdt/ecj/3.36.0/ecj-3.36.0.jar"

# Detect source directory
if [ -d "$PROJECT_DIR/src/main/java" ]; then
    SOURCE_DIR="$PROJECT_DIR/src/main/java"
elif [ -d "$PROJECT_DIR/src" ]; then
    SOURCE_DIR="$PROJECT_DIR/src"
else
    echo "ERROR: Cannot find source directory in $PROJECT_DIR"
    exit 1
fi

TARGET_DIR="$PROJECT_DIR/target/classes"

echo "=== ECJ Compilation ==="
echo "Project: $PROJECT_DIR"
echo "Source:  $SOURCE_DIR"
echo ""

# ==============================================================================
# 1. Ensure ECJ is available
# ==============================================================================
mkdir -p "$ECJ_DIR"

if [ ! -f "$ECJ_JAR" ]; then
    echo "Downloading ECJ compiler..."
    if curl -sL -o "$ECJ_JAR" "$ECJ_URL" 2>/dev/null; then
        # Verify download
        if [ ! -s "$ECJ_JAR" ]; then
            echo "ERROR: ECJ download failed (empty file)"
            rm -f "$ECJ_JAR"
            exit 1
        fi
        echo "✅ ECJ downloaded successfully"
    else
        echo "ERROR: Cannot download ECJ from Maven Central"
        echo "       Check network access to repo1.maven.org"
        exit 1
    fi
else
    echo "✅ ECJ already available"
fi

# ==============================================================================
# 2. Find all Java source files
# ==============================================================================
JAVA_FILES=$(find "$SOURCE_DIR" -name "*.java" -type f)
FILE_COUNT=$(echo "$JAVA_FILES" | wc -l)

if [ -z "$JAVA_FILES" ]; then
    echo "ERROR: No Java files found in $SOURCE_DIR"
    exit 1
fi

echo "Found $FILE_COUNT Java files"
echo ""

# ==============================================================================
# 3. Compile with ECJ
# ==============================================================================
mkdir -p "$TARGET_DIR"

echo "Compiling..."
echo ""

# Run ECJ compiler
# -source 17: Java 17 source compatibility
# -target 17: Java 17 bytecode
# -d: Output directory for .class files
# -warn:none: Suppress warnings (we only care about errors)
# -proceedOnError: Show all errors, not just first

COMPILE_OUTPUT=$(java -jar "$ECJ_JAR" \
    -source 17 \
    -target 17 \
    -d "$TARGET_DIR" \
    -warn:none \
    -proceedOnError \
    $JAVA_FILES 2>&1) || true

# ==============================================================================
# 4. Parse and report results
# ==============================================================================

# Count errors
ERROR_COUNT=$(echo "$COMPILE_OUTPUT" | grep -c "error:" || echo "0")

if [ "$ERROR_COUNT" -eq 0 ] && [ -z "$(echo "$COMPILE_OUTPUT" | grep -i error)" ]; then
    echo "==========================================="
    echo "✅ COMPILATION SUCCESSFUL"
    echo "   Compiled $FILE_COUNT files"
    echo "   Output: $TARGET_DIR"
    echo "==========================================="
    exit 0
else
    echo "==========================================="
    echo "❌ COMPILATION FAILED"
    echo "   Found $ERROR_COUNT error(s)"
    echo "==========================================="
    echo ""
    echo "--- Compilation Errors ---"
    echo "$COMPILE_OUTPUT" | grep -E "^[0-9]+\.|error:|ERROR" | head -50
    echo ""
    
    # Format errors for auto-correction
    echo "--- Errors for Auto-Correction ---"
    echo "$COMPILE_OUTPUT" | grep -E "\.java:[0-9]+" | while read -r line; do
        # Extract file:line:message
        FILE=$(echo "$line" | grep -oE "[^ ]+\.java" | head -1)
        LINE_NUM=$(echo "$line" | grep -oE ":[0-9]+" | head -1 | tr -d ':')
        MESSAGE=$(echo "$line" | sed 's/.*error: //')
        echo "FILE: $FILE"
        echo "LINE: $LINE_NUM"
        echo "ERROR: $MESSAGE"
        echo "---"
    done
    
    exit 1
fi
