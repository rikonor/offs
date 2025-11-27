# Justfile

# List available recipes
default:
    @just --list

# Build the project
build:
    cargo build

# Run tests
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
check: fmt-check lint test

# Run the application (example: just run "https://example.com")
run url:
    cargo run -- {{url}}
