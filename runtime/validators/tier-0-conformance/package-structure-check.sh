#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# Tier-0: Package Structure Validation
# ═══════════════════════════════════════════════════════════════════════════════
# Validates that the generation package has the required structure per
# flow-generate-output.md specification.
#
# Usage: ./package-structure-check.sh <package_dir>
# ═══════════════════════════════════════════════════════════════════════════════

PACKAGE_DIR="${1:-.}"
PASS=0
FAIL=0

check_dir() {
    local dir="$1"
    local desc="$2"
    if [ -d "$PACKAGE_DIR/$dir" ]; then
        echo "  ✅ PASS: $desc ($dir/)"
        ((PASS++))
    else
        echo "  ❌ FAIL: $desc ($dir/) - MISSING"
        ((FAIL++))
    fi
}

check_file() {
    local file="$1"
    local desc="$2"
    local required="${3:-true}"
    if [ -f "$PACKAGE_DIR/$file" ]; then
        echo "  ✅ PASS: $desc"
        ((PASS++))
    elif [ "$required" = "true" ]; then
        echo "  ❌ FAIL: $desc - MISSING"
        ((FAIL++))
    else
        echo "  ⚠️  SKIP: $desc (optional)"
    fi
}

echo "═══════════════════════════════════════════════════════════════════════════════"
echo "TIER-0: PACKAGE STRUCTURE CHECK"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo "Package: $PACKAGE_DIR"
echo ""

echo ">>> Mandatory Directories"
check_dir "input" "Input directory"
check_dir "output" "Output directory"
check_dir "trace" "Trace directory"
check_dir "validation" "Validation directory"

echo ""
echo ">>> Input Files"
check_file "input/prompt.md" "Prompt file" "false"
check_file "input/prompt.txt" "Prompt file (alt)" "false"

echo ""
echo ">>> Trace Files"
check_file "trace/discovery-trace.json" "Discovery trace"
check_file "trace/generation-context.json" "Generation context"

echo ""
echo ">>> Validation Scripts"
check_file "validation/run-all.sh" "Master validation script"
check_dir "validation/scripts" "Validation scripts directory"

echo ""
echo ">>> Output Structure"
# Find the project directory
PROJECT_DIR=$(find "$PACKAGE_DIR/output" -maxdepth 1 -type d ! -name output | head -1)
if [ -n "$PROJECT_DIR" ]; then
    PROJECT_NAME=$(basename "$PROJECT_DIR")
    echo "  Project: $PROJECT_NAME"
    check_file "output/$PROJECT_NAME/pom.xml" "Maven POM"
    check_dir "output/$PROJECT_NAME/src/main/java" "Java sources"
    check_dir "output/$PROJECT_NAME/src/main/resources" "Resources"
else
    echo "  ❌ FAIL: No project directory found in output/"
    ((FAIL++))
fi

echo ""
echo "═══════════════════════════════════════════════════════════════════════════════"
echo "RESULT: $PASS PASS, $FAIL FAIL"
echo "═══════════════════════════════════════════════════════════════════════════════"

if [ $FAIL -eq 0 ]; then
    echo "✅ PACKAGE STRUCTURE VALID"
    exit 0
else
    echo "❌ PACKAGE STRUCTURE INVALID"
    exit 1
fi
