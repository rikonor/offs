#!/usr/bin/env bash

# Output file
OUTPUT_FILE="templates/ai/llms.txt"
COMMIT_CHANGES=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --commit)
            COMMIT_CHANGES=true
            shift
            ;;
    esac
done

echo "🤖 Generating $OUTPUT_FILE..."

# 1. Header & Project Info
echo "# webllm" > "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "> A Rust workspace for web-based LLM interactions." >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Extract description from README if available, otherwise use default
if [ -f "README.md" ]; then
    # Take the first non-empty line that isn't a header
    DESC=$(grep -v "^#" README.md | grep -v "^$" | head -n 1)
    if [ ! -z "$DESC" ]; then
        echo "$DESC" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
fi

# 2. Project Structure (Crates)
echo "## Project Structure" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "This project is a Rust workspace containing the following crates:" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Find all Cargo.toml files in crates/ directory
for crate_toml in crates/*/Cargo.toml; do
    if [ -f "$crate_toml" ]; then
        CRATE_DIR=$(dirname "$crate_toml")
        CRATE_NAME=$(basename "$CRATE_DIR")

        # Try to extract description from Cargo.toml
        # This is a simple grep; a real TOML parser would be better but this avoids dependencies
        CRATE_DESC=$(grep "^description =" "$crate_toml" | cut -d '"' -f 2)

        if [ -z "$CRATE_DESC" ]; then
            CRATE_DESC="No description provided."
        fi

        echo "- **$CRATE_NAME** (\`$CRATE_DIR\`): $CRATE_DESC" >> "$OUTPUT_FILE"
    fi
done
echo "" >> "$OUTPUT_FILE"

# 3. Development Commands (Justfile)
echo "## Development Commands" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Use \`just\` to run the following commands:" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Extract commands from Justfile
# Looks for lines starting with a name followed by colon, ignoring private ones and aliases
if [ -f "Justfile" ]; then
    grep "^[a-z]" Justfile | grep ":" | grep -v "\[private\]" | grep -v "^alias" | while read -r line; do
        CMD_NAME=$(echo "$line" | cut -d ':' -f 1 | tr -d ' ')
        # Find the comment above the command
        CMD_DESC=$(grep -B 1 "^$CMD_NAME:" Justfile | head -n 1 | grep "^#" | sed 's/^# //')

        # Only list commands that have a description (comment)
        if [ ! -z "$CMD_NAME" ] && [ ! -z "$CMD_DESC" ]; then
             echo "- \`just $CMD_NAME\`: $CMD_DESC" >> "$OUTPUT_FILE"
        fi
    done
fi
echo "" >> "$OUTPUT_FILE"

# 4. Coding Standards Summary
echo "## Coding Standards (Strict)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "- **Language:** Rust (2021 edition)" >> "$OUTPUT_FILE"
echo "- **Formatting:** \`cargo fmt\` (checked in CI)" >> "$OUTPUT_FILE"
echo "- **Linting:** \`cargo clippy -- -D warnings\` (NO warnings allowed)" >> "$OUTPUT_FILE"
echo "- **Error Handling:** Use \`thiserror\` (libs) / \`anyhow\` (apps). No \`unwrap()\`." >> "$OUTPUT_FILE"
echo "- **Testing:** Unit tests required for new features." >> "$OUTPUT_FILE"

echo "✅ Generated $OUTPUT_FILE"

# Check for changes
if git diff --quiet "$OUTPUT_FILE"; then
    echo "ℹ️  No changes detected in $OUTPUT_FILE"
else
    echo "📝 Changes detected in $OUTPUT_FILE"
    if [ "$COMMIT_CHANGES" = true ]; then
        echo "💾 Committing changes..."
        git add "$OUTPUT_FILE"
        git commit -m "chore: update llms.txt context"
        echo "✅ Committed changes to $OUTPUT_FILE"
    else
        echo "ℹ️  Skipping commit (use --commit to auto-commit)"
    fi
fi
