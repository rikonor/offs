#!/usr/bin/env bash

echo "🤖 Setting up AI Context Files..."

# Setup llms.txt
# Note: llms.txt is now a committed file in templates/ai/llms.txt
# We do not copy it to root to avoid duplication, as agents can read it from templates/
echo "ℹ️  Using shared llms.txt from templates/ai/llms.txt"

# Setup AGENTS.md
if [ ! -f "AGENTS.md" ]; then
    echo ""
    echo "Select an AI Agent Guideline profile:"
    echo "1) Default (Standard Rust practices)"
    echo "2) Strict (No warnings, mandatory docs/tests)"
    echo "3) Skip AGENTS.md creation"

    read -p "Enter choice [1-3]: " choice

    case $choice in
        1)
            cp templates/ai/AGENTS.default.md AGENTS.md
            echo "✅ Created AGENTS.md (Default profile)"
            ;;
        2)
            cp templates/ai/AGENTS.strict.md AGENTS.md
            echo "✅ Created AGENTS.md (Strict profile)"
            ;;
        3)
            echo "ℹ️  Skipping AGENTS.md creation"
            ;;
        *)
            echo "❌ Invalid choice. Defaulting to Standard profile."
            cp templates/ai/AGENTS.default.md AGENTS.md
            echo "✅ Created AGENTS.md (Default profile)"
            ;;
    esac
else
    echo "ℹ️  AGENTS.md already exists (skipping)"
fi

echo "✨ AI Context setup complete!"
