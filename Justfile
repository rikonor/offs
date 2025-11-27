# Justfile

set dotenv-load := true

# List available recipes
default:
    @just --list

# Build the project
alias b := build
build:
    cargo build

# Run tests
alias t := test
test:
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
check: fmt-check lint test

# Run the application
# Example: just run https://example.com --model gpt-4
alias r := run
run +args:
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
