# Justfile

set dotenv-load := true

# List available recipes
default:
    @just --list

# Check if pre-commit hooks are installed (internal)
[private]
check-hooks:
    @if [ ! -f .git/hooks/pre-commit ]; then \
        echo "⚠️  Pre-commit hooks not detected. Run 'just setup' to configure them."; \
    fi

# Setup development environment
setup:
    #!/usr/bin/env bash
    echo "Setting up development environment..."
    if ! command -v pre-commit > /dev/null; then
        echo "pre-commit not found. Attempting to install..."
        if command -v brew > /dev/null; then
            echo "Installing via Homebrew..."
            brew install pre-commit
        else
            echo "Installing via pip..."
            pip install pre-commit
        fi
    fi
    pre-commit install
    echo "Setup complete! Pre-commit hooks are installed."

# Build the project
alias b := build
build: check-hooks
    cargo build

# Run tests
alias t := test
test: check-hooks
    cargo test

# Check formatting
fmt-check:
    cargo fmt --all -- --check

# Format code
fmt:
    cargo fmt --all

# Lint with Clippy
lint:
    cargo clippy --all-targets --all-features -- -D warnings

# Run all checks (fmt, lint, test)
alias c := check
check: check-hooks fmt-check lint test

# Run the application
# Example: just run https://example.com --model gpt-4
alias r := run
run +args: check-hooks
    cargo run -- {{args}}

# Clean build artifacts
clean:
    cargo clean

# Generate documentation
doc:
    cargo doc --no-deps --open

# Watch for changes and run check
watch:
    cargo watch -x check
