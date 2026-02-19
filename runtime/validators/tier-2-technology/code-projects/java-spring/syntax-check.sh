#!/bin/bash
# ==============================================================================
# SYNTAX-CHECK.SH - Java Syntax Validation without Maven
# ==============================================================================
# Version: 1.1
# Updated: 2026-01-23
# Purpose: Detect known LLM hallucinations and syntax errors without requiring
#          a full Maven build (which needs JDK and network access)
# Changes: Semicolon check is now warning-only (builder pattern false positives)
#
# Usage: ./syntax-check.sh <project-directory>
# Returns: 0 if all checks pass, 1 if errors found
# Output: List of errors with file:line:issue format for auto-correction
# ==============================================================================

# Note: Not using 'set -e' to handle errors manually

PROJECT_DIR="${1:-.}"
ERRORS_FOUND=0
ERROR_LOG=""

log_error() {
    local file="$1"
    local line="$2"
    local issue="$3"
    local suggestion="$4"
    
    ERRORS_FOUND=$((ERRORS_FOUND + 1))
    ERROR_LOG="$ERROR_LOG\n❌ $file:$line: $issue"
    if [ -n "$suggestion" ]; then
        ERROR_LOG="$ERROR_LOG\n   ↳ Suggestion: $suggestion"
    fi
}

echo "=== Java Syntax Validation (No Maven Required) ==="
echo "Project: $PROJECT_DIR"
echo ""

# ==============================================================================
# 1. KNOWN LLM HALLUCINATIONS
# ==============================================================================

echo "--- Checking for Known LLM Hallucinations ---"

# HALLUCINATION-001: String.replace with 3 arguments
echo -n "Checking HALLUCINATION-001 (String.replace with 3 args)... "
while IFS= read -r file; do
    # Look for patterns like: .replace("x", "y", index) or .replace("x", "y", 3)
    while IFS=: read -r line_num content; do
        if echo "$content" | grep -qE '\.replace\s*\(\s*"[^"]*"\s*,\s*"[^"]*"\s*,\s*[^)]+\)'; then
            log_error "$file" "$line_num" "String.replace() with 3 arguments does not exist in Java" \
                "Use substring() or DateTimeFormatter for timestamp parsing"
        fi
    done < <(grep -n '\.replace\s*(' "$file" 2>/dev/null || true)
done < <(find "$PROJECT_DIR" -name "*.java" -type f 2>/dev/null)

if [ $ERRORS_FOUND -eq 0 ]; then
    echo "PASS"
else
    echo "FAIL ($ERRORS_FOUND found)"
fi

# HALLUCINATION-002: @Transactional with System API
PREV_ERRORS=$ERRORS_FOUND
echo -n "Checking HALLUCINATION-002 (@Transactional with System API)... "
# Find files in adapter/out/systemapi that have @Transactional
while IFS= read -r file; do
    if grep -q "systemapi\|SystemApi\|system-api" "$file" 2>/dev/null; then
        while IFS=: read -r line_num content; do
            if echo "$content" | grep -qE '@Transactional'; then
                log_error "$file" "$line_num" "@Transactional used with System API persistence" \
                    "Remove @Transactional - HTTP calls don't support local transactions"
            fi
        done < <(grep -n '@Transactional' "$file" 2>/dev/null || true)
    fi
done < <(find "$PROJECT_DIR" -path "*/adapter/out/*" -name "*.java" -type f 2>/dev/null)

if [ $ERRORS_FOUND -eq $PREV_ERRORS ]; then
    echo "PASS"
else
    echo "FAIL ($((ERRORS_FOUND - PREV_ERRORS)) found)"
fi

# ==============================================================================
# 2. BASIC SYNTAX CHECKS
# ==============================================================================

echo ""
echo "--- Basic Syntax Checks ---"

# 2.1 Package declaration
PREV_ERRORS=$ERRORS_FOUND
echo -n "Checking package declarations... "
while IFS= read -r file; do
    if ! head -20 "$file" | grep -qE '^\s*package\s+[a-z]'; then
        log_error "$file" "1" "Missing or invalid package declaration" \
            "Add 'package com.xxx.yyy;' at the start of the file"
    fi
done < <(find "$PROJECT_DIR" -name "*.java" -type f 2>/dev/null)

if [ $ERRORS_FOUND -eq $PREV_ERRORS ]; then
    echo "PASS"
else
    echo "FAIL ($((ERRORS_FOUND - PREV_ERRORS)) found)"
fi

# 2.2 Class/Interface/Enum/Record declaration
PREV_ERRORS=$ERRORS_FOUND
echo -n "Checking type declarations... "
while IFS= read -r file; do
    if ! grep -qE '(public|private|protected)?\s*(class|interface|enum|record)\s+[A-Z]' "$file" 2>/dev/null; then
        log_error "$file" "?" "Missing class/interface/enum/record declaration"
    fi
done < <(find "$PROJECT_DIR" -name "*.java" -type f 2>/dev/null)

if [ $ERRORS_FOUND -eq $PREV_ERRORS ]; then
    echo "PASS"
else
    echo "FAIL ($((ERRORS_FOUND - PREV_ERRORS)) found)"
fi

# 2.3 Brace balance
PREV_ERRORS=$ERRORS_FOUND
echo -n "Checking brace balance... "
while IFS= read -r file; do
    OPEN=$(grep -o "{" "$file" 2>/dev/null | wc -l)
    CLOSE=$(grep -o "}" "$file" 2>/dev/null | wc -l)
    if [ "$OPEN" -ne "$CLOSE" ]; then
        log_error "$file" "EOF" "Unbalanced braces (open=$OPEN, close=$CLOSE)"
    fi
done < <(find "$PROJECT_DIR" -name "*.java" -type f 2>/dev/null)

if [ $ERRORS_FOUND -eq $PREV_ERRORS ]; then
    echo "PASS"
else
    echo "FAIL ($((ERRORS_FOUND - PREV_ERRORS)) found)"
fi

# 2.4 Parenthesis balance
PREV_ERRORS=$ERRORS_FOUND
echo -n "Checking parenthesis balance... "
while IFS= read -r file; do
    OPEN=$(grep -o "(" "$file" 2>/dev/null | wc -l)
    CLOSE=$(grep -o ")" "$file" 2>/dev/null | wc -l)
    if [ "$OPEN" -ne "$CLOSE" ]; then
        log_error "$file" "EOF" "Unbalanced parentheses (open=$OPEN, close=$CLOSE)"
    fi
done < <(find "$PROJECT_DIR" -name "*.java" -type f 2>/dev/null)

if [ $ERRORS_FOUND -eq $PREV_ERRORS ]; then
    echo "PASS"
else
    echo "FAIL ($((ERRORS_FOUND - PREV_ERRORS)) found)"
fi

# ==============================================================================
# 3. COMMON MISTAKES
# ==============================================================================

echo ""
echo "--- Common Mistakes ---"

# 3.1 Unclosed string literals (basic check)
PREV_ERRORS=$ERRORS_FOUND
echo -n "Checking for obvious string issues... "
while IFS= read -r file; do
    # Check for lines with odd number of quotes (excluding escaped quotes)
    while IFS=: read -r line_num content; do
        # Remove escaped quotes for counting
        clean_line=$(echo "$content" | sed 's/\\"/X/g')
        quote_count=$(echo "$clean_line" | grep -o '"' | wc -l)
        if [ $((quote_count % 2)) -ne 0 ]; then
            # Could be a false positive (multi-line string), but flag it
            log_error "$file" "$line_num" "Possible unclosed string literal"
        fi
    done < <(grep -n '"' "$file" 2>/dev/null | head -100 || true)
done < <(find "$PROJECT_DIR" -name "*.java" -type f 2>/dev/null)

if [ $ERRORS_FOUND -eq $PREV_ERRORS ]; then
    echo "PASS"
else
    echo "WARN ($((ERRORS_FOUND - PREV_ERRORS)) possible issues)"
fi

# 3.2 Missing semicolons - SKIPPED
# Note: This check has too many false positives with builder patterns, lambdas, 
# and interface method declarations. If the code compiles (checked separately),
# semicolons are correct. Removing this check to avoid noise.
echo -n "Checking for missing semicolons... "
echo "SKIPPED (handled by compiler)"

# ==============================================================================
# SUMMARY
# ==============================================================================

echo ""
echo "==========================================="
if [ $ERRORS_FOUND -eq 0 ]; then
    echo "✅ SYNTAX CHECK PASSED"
    echo "   All $(find "$PROJECT_DIR" -name "*.java" -type f 2>/dev/null | wc -l) Java files validated"
    exit 0
else
    echo "❌ SYNTAX CHECK FAILED"
    echo "   Found $ERRORS_FOUND issues"
    echo ""
    echo "--- Error Details ---"
    echo -e "$ERROR_LOG"
    echo ""
    echo "==========================================="
    exit 1
fi
