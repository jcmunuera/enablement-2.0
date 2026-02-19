#!/bin/bash
# ==============================================================================
# COMPILE.SH - Unified compilation with automatic fallback
# ==============================================================================
# Version: 1.0
# Purpose: Compile Java project using best available method
#
# Strategy:
#   1. Maven compile (if JDK + Maven Central available)
#   2. ECJ compile (if JRE + Maven Central available, no JDK needed)
#   3. Syntax check (if no network, detects known hallucinations)
#
# Usage: ./compile.sh <project-directory> [--max-attempts N]
# Returns: 0 if compilation succeeds, 1 if errors found
# ==============================================================================

set -e

PROJECT_DIR="${1:-.}"
MAX_ATTEMPTS="${2:-3}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║           ENABLEMENT 2.0 - CODE COMPILATION                              ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "Project: $PROJECT_DIR"
echo ""

# ==============================================================================
# 1. Detect Environment
# ==============================================================================
echo "--- Environment Detection ---"

# Check JDK
HAS_JDK=false
if which javac >/dev/null 2>&1; then
    JAVAC_VERSION=$(javac -version 2>&1 | awk '{print $2}')
    echo "JDK (javac): ✅ $JAVAC_VERSION"
    HAS_JDK=true
else
    echo "JDK (javac): ❌ Not installed"
fi

# Check JRE
HAS_JRE=false
if which java >/dev/null 2>&1; then
    JAVA_VERSION=$(java -version 2>&1 | head -1 | awk -F'"' '{print $2}')
    echo "JRE (java):  ✅ $JAVA_VERSION"
    HAS_JRE=true
else
    echo "JRE (java):  ❌ Not installed"
fi

# Check Maven
HAS_MAVEN=false
if which mvn >/dev/null 2>&1; then
    MVN_VERSION=$(mvn -version 2>&1 | head -1 | awk '{print $3}')
    echo "Maven:       ✅ $MVN_VERSION"
    HAS_MAVEN=true
else
    echo "Maven:       ❌ Not installed"
fi

# Check Maven Central access
HAS_NETWORK=false
MAVEN_STATUS=$(curl -sI --max-time 5 "https://repo1.maven.org/maven2/" 2>&1 | head -1)
if echo "$MAVEN_STATUS" | grep -q "200 OK"; then
    echo "Maven Central: ✅ Accessible"
    HAS_NETWORK=true
elif echo "$MAVEN_STATUS" | grep -q "host_not_allowed"; then
    echo "Maven Central: ❌ Blocked (add repo1.maven.org to allowed domains)"
else
    echo "Maven Central: ⚠️ Status unknown"
fi

echo ""

# ==============================================================================
# 2. Select Compilation Method
# ==============================================================================
echo "--- Selecting Compilation Method ---"

if [ "$HAS_JDK" = true ] && [ "$HAS_MAVEN" = true ] && [ "$HAS_NETWORK" = true ]; then
    METHOD="maven"
    echo "Selected: MAVEN (full compilation with dependency resolution)"
elif [ "$HAS_JRE" = true ] && [ "$HAS_NETWORK" = true ]; then
    METHOD="ecj"
    echo "Selected: ECJ (Eclipse Compiler - no JDK required)"
elif [ "$HAS_JRE" = true ]; then
    METHOD="syntax"
    echo "Selected: SYNTAX-CHECK (no network, limited validation)"
else
    echo "ERROR: No compilation method available"
    echo "       Need at least JRE installed"
    exit 1
fi

echo ""

# ==============================================================================
# 3. Execute Compilation with Retry Loop
# ==============================================================================
ATTEMPT=1
SUCCESS=false

while [ $ATTEMPT -le $MAX_ATTEMPTS ] && [ "$SUCCESS" = false ]; do
    echo "═══════════════════════════════════════════════════════════════════════════"
    echo "  ATTEMPT $ATTEMPT of $MAX_ATTEMPTS"
    echo "═══════════════════════════════════════════════════════════════════════════"
    echo ""
    
    case "$METHOD" in
        maven)
            echo "Running: mvn compile -q"
            cd "$PROJECT_DIR"
            if mvn compile -q 2>&1 | tee /tmp/compile-output.txt; then
                SUCCESS=true
                echo ""
                echo "✅ Maven compilation successful"
            else
                ERRORS=$(cat /tmp/compile-output.txt)
                echo ""
                echo "❌ Maven compilation failed"
            fi
            ;;
            
        ecj)
            echo "Running: ECJ compiler"
            if "$SCRIPT_DIR/ecj-compile.sh" "$PROJECT_DIR" 2>&1 | tee /tmp/compile-output.txt; then
                SUCCESS=true
            else
                ERRORS=$(cat /tmp/compile-output.txt)
            fi
            ;;
            
        syntax)
            echo "Running: Syntax check (no network available)"
            VALIDATOR_DIR="$SCRIPT_DIR/../validators/tier-2-technology/code-projects/java-spring"
            if [ -f "$VALIDATOR_DIR/syntax-check.sh" ]; then
                if "$VALIDATOR_DIR/syntax-check.sh" "$PROJECT_DIR" 2>&1 | tee /tmp/compile-output.txt; then
                    SUCCESS=true
                    echo ""
                    echo "⚠️ Syntax check passed (full compilation not verified)"
                else
                    ERRORS=$(cat /tmp/compile-output.txt)
                fi
            else
                echo "ERROR: syntax-check.sh not found"
                exit 1
            fi
            ;;
    esac
    
    # If failed and more attempts available, try to fix
    if [ "$SUCCESS" = false ] && [ $ATTEMPT -lt $MAX_ATTEMPTS ]; then
        echo ""
        echo "--- Attempting Auto-Fix ---"
        echo ""
        echo "Errors detected. In a real flow, the agent would:"
        echo "1. Parse the error messages"
        echo "2. Read the affected files"
        echo "3. Apply fixes using str_replace"
        echo "4. Re-run compilation"
        echo ""
        echo "For now, errors must be fixed manually."
        echo ""
        
        # In a real implementation, we would call the agent to fix errors here
        # For now, we just increment attempt and exit
        break
    fi
    
    ATTEMPT=$((ATTEMPT + 1))
done

# ==============================================================================
# 4. Final Report
# ==============================================================================
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════╗"
if [ "$SUCCESS" = true ]; then
    echo "║  ✅ COMPILATION SUCCESSFUL                                               ║"
    echo "╚══════════════════════════════════════════════════════════════════════════╝"
    exit 0
else
    echo "║  ❌ COMPILATION FAILED                                                   ║"
    echo "╚══════════════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Errors need to be fixed manually or by the agent."
    echo "See output above for error details."
    exit 1
fi
