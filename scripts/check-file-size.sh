#!/usr/bin/env bash
set -e

# Default threshold
THRESHOLD=300

# Parse arguments
FILES=()
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --threshold) THRESHOLD="$2"; shift ;;
        -*) echo "Unknown parameter passed: $1"; exit 1 ;;
        *) FILES+=("$1") ;;
    esac
    shift
done

if [ ${#FILES[@]} -eq 0 ]; then
    exit 0
fi

EXIT_CODE=0
declare -a FILE_DATA

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        LINES=$(wc -l < "$file" | tr -d ' ')
        FILE_DATA+=("$LINES $file")

        if [ "$LINES" -gt "$THRESHOLD" ]; then
            echo "❌ Error: File '$file' has $LINES lines, which exceeds the limit of $THRESHOLD lines."
            echo "   Please refactor this file to be smaller to maintain AI agent manageability."
            EXIT_CODE=1
        fi
    fi
done

exit $EXIT_CODE
