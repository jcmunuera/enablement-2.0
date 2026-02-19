#!/bin/bash
# ==============================================================================
# COMPILATION-SETUP.SH - Setup compilation environment for Enablement 2.0
# ==============================================================================
# Version: 1.0
# Purpose: Verify and setup Java compilation capabilities
#
# Usage: source compilation-setup.sh
# Returns: Sets COMPILATION_MODE variable (full|ecj|syntax-only)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="/home/claude/.enablement-tools"
ECJ_JAR="$TOOLS_DIR/ecj-3.36.0.jar"
ECJ_URL="https://repo1.maven.org/maven2/org/eclipse/jdt/ecj/3.36.0/ecj-3.36.0.jar"

# Create tools directory
mkdir -p "$TOOLS_DIR"

echo "=== Enablement 2.0 Compilation Setup ==="
echo ""

# ==============================================================================
# 1. Check Java Runtime
# ==============================================================================
echo -n "Checking Java Runtime... "
if java -version 2>&1 | grep -q "version"; then
    JAVA_VERSION=$(java -version 2>&1 | head -1 | awk -F'"' '{print $2}')
    echo "✅ Java $JAVA_VERSION"
    HAS_JRE=true
else
    echo "❌ Java not found"
    HAS_JRE=false
fi

# ==============================================================================
# 2. Check JDK (javac)
# ==============================================================================
echo -n "Checking JDK (javac)... "
if which javac >/dev/null 2>&1; then
    JAVAC_VERSION=$(javac -version 2>&1 | awk '{print $2}')
    echo "✅ javac $JAVAC_VERSION"
    HAS_JDK=true
else
    echo "⚠️ Not installed"
    HAS_JDK=false
fi

# ==============================================================================
# 3. Check Maven
# ==============================================================================
echo -n "Checking Maven... "
if which mvn >/dev/null 2>&1; then
    MVN_VERSION=$(mvn -version 2>&1 | head -1 | awk '{print $3}')
    echo "✅ Maven $MVN_VERSION"
    HAS_MAVEN=true
else
    echo "⚠️ Not installed"
    HAS_MAVEN=false
fi

# ==============================================================================
# 4. Check Maven Central Access
# ==============================================================================
echo -n "Checking Maven Central... "
MAVEN_CENTRAL_STATUS=$(curl -sI --max-time 5 https://repo1.maven.org/maven2/ 2>&1 | head -1)
if echo "$MAVEN_CENTRAL_STATUS" | grep -q "200 OK"; then
    echo "✅ Accessible"
    HAS_MAVEN_CENTRAL=true
elif echo "$MAVEN_CENTRAL_STATUS" | grep -q "host_not_allowed"; then
    echo "❌ Blocked (add repo1.maven.org to allowed domains)"
    HAS_MAVEN_CENTRAL=false
else
    echo "⚠️ Unknown status: $MAVEN_CENTRAL_STATUS"
    HAS_MAVEN_CENTRAL=false
fi

# ==============================================================================
# 5. Check/Download ECJ
# ==============================================================================
echo -n "Checking ECJ Compiler... "
if [ -f "$ECJ_JAR" ]; then
    echo "✅ Already installed"
    HAS_ECJ=true
elif [ "$HAS_MAVEN_CENTRAL" = true ] && [ "$HAS_JRE" = true ]; then
    echo "Downloading..."
    if curl -sL -o "$ECJ_JAR" "$ECJ_URL" 2>/dev/null; then
        # Verify download
        if [ -s "$ECJ_JAR" ] && java -jar "$ECJ_JAR" -version 2>&1 | grep -q "Eclipse"; then
            echo "   ✅ ECJ installed successfully"
            HAS_ECJ=true
        else
            echo "   ❌ Download failed or corrupted"
            rm -f "$ECJ_JAR"
            HAS_ECJ=false
        fi
    else
        echo "   ❌ Download failed"
        HAS_ECJ=false
    fi
else
    echo "⚠️ Cannot download (no Maven Central access)"
    HAS_ECJ=false
fi

# ==============================================================================
# 6. Determine Compilation Mode
# ==============================================================================
echo ""
echo "=== Compilation Capability ==="

if [ "$HAS_JDK" = true ] && [ "$HAS_MAVEN" = true ] && [ "$HAS_MAVEN_CENTRAL" = true ]; then
    COMPILATION_MODE="full"
    echo "Mode: FULL (Maven + JDK)"
    echo "  ✅ Can run: mvn compile"
    echo "  ✅ Can run: mvn test"
    echo "  ✅ Can detect all compilation errors"
elif [ "$HAS_ECJ" = true ]; then
    COMPILATION_MODE="ecj"
    echo "Mode: ECJ (Eclipse Compiler)"
    echo "  ✅ Can compile Java source files"
    echo "  ✅ Can detect compilation errors"
    echo "  ⚠️ Cannot run Maven tests"
elif [ "$HAS_JRE" = true ]; then
    COMPILATION_MODE="syntax-only"
    echo "Mode: SYNTAX-ONLY"
    echo "  ✅ Can run syntax-check.sh"
    echo "  ✅ Can detect known hallucinations"
    echo "  ⚠️ Cannot verify full compilation"
else
    COMPILATION_MODE="none"
    echo "Mode: NONE"
    echo "  ❌ No validation possible"
fi

export COMPILATION_MODE
export ECJ_JAR
export HAS_JDK
export HAS_ECJ
export HAS_MAVEN_CENTRAL

echo ""
echo "COMPILATION_MODE=$COMPILATION_MODE"
echo "=== Setup Complete ==="

# ==============================================================================
# Helper Functions
# ==============================================================================

# Compile with ECJ
compile_with_ecj() {
    local project_dir="$1"
    local source_dir="$project_dir/src/main/java"
    local target_dir="$project_dir/target/classes"
    
    if [ ! -f "$ECJ_JAR" ]; then
        echo "ERROR: ECJ not available"
        return 1
    fi
    
    mkdir -p "$target_dir"
    
    echo "Compiling with ECJ..."
    java -jar "$ECJ_JAR" \
        -source 17 \
        -target 17 \
        -d "$target_dir" \
        -warn:none \
        $(find "$source_dir" -name "*.java") 2>&1
    
    return $?
}

# Compile with Maven
compile_with_maven() {
    local project_dir="$1"
    
    echo "Compiling with Maven..."
    cd "$project_dir"
    mvn compile -q 2>&1
    
    return $?
}

# Auto-select compilation method
compile_project() {
    local project_dir="$1"
    
    case "$COMPILATION_MODE" in
        full)
            compile_with_maven "$project_dir"
            ;;
        ecj)
            compile_with_ecj "$project_dir"
            ;;
        syntax-only)
            echo "Running syntax check only..."
            "$SCRIPT_DIR/../validators/tier-2-technology/code-projects/java-spring/syntax-check.sh" "$project_dir"
            ;;
        *)
            echo "No compilation available"
            return 1
            ;;
    esac
}

export -f compile_with_ecj
export -f compile_with_maven
export -f compile_project
