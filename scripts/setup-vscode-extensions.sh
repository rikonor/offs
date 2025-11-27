#!/usr/bin/env bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if running in VS Code
if [ "$TERM_PROGRAM" != "vscode" ]; then
    echo -e "${BLUE}ℹ️  Not running in VS Code (TERM_PROGRAM='$TERM_PROGRAM'). Skipping VS Code extension setup.${NC}"
    exit 0
fi

echo "Checking VS Code extensions..."

# Check if code command is available
if ! command -v code > /dev/null; then
    echo -e "${YELLOW}⚠️  'code' command not found. Skipping extension check.${NC}"
    echo "   (You might need to install the 'code' command in PATH from VS Code)"
    exit 0
fi

# Check if jq is available
if ! command -v jq > /dev/null; then
    echo -e "${YELLOW}⚠️  'jq' not found. Skipping extension check.${NC}"
    exit 0
fi

EXTENSIONS_FILE=".vscode/extensions.json"

if [ ! -f "$EXTENSIONS_FILE" ]; then
    echo "No extensions.json found. Skipping."
    exit 0
fi

# Get installed extensions
INSTALLED_EXTENSIONS=$(code --list-extensions | tr '[:upper:]' '[:lower:]')

# Get recommended extensions
RECOMMENDED_EXTENSIONS=$(jq -r '.recommendations[]' "$EXTENSIONS_FILE" | tr '[:upper:]' '[:lower:]')

MISSING_EXTENSIONS=()

for ext in $RECOMMENDED_EXTENSIONS; do
    if ! echo "$INSTALLED_EXTENSIONS" | grep -q "^$ext$"; then
        MISSING_EXTENSIONS+=("$ext")
    fi
done

if [ ${#MISSING_EXTENSIONS[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ All recommended VS Code extensions are installed.${NC}"
    exit 0
fi

echo -e "${YELLOW}⚠️  The following recommended VS Code extensions are missing:${NC}"
for ext in "${MISSING_EXTENSIONS[@]}"; do
    echo "   - $ext"
done

echo ""
read -p "Would you like to install them now? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    for ext in "${MISSING_EXTENSIONS[@]}"; do
        echo "Installing $ext..."
        if code --install-extension "$ext"; then
            echo -e "${GREEN}Successfully installed $ext${NC}"
        else
            echo -e "${RED}Failed to install $ext${NC}"
        fi
    done
    echo -e "${GREEN}✅ VS Code extension setup complete.${NC}"
else
    echo "Skipping extension installation."
fi
