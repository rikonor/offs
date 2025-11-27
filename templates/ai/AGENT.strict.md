# AI Agent Guidelines (AGENT.md) - STRICT MODE

## Project Overview

This is a Rust workspace for `webllm`.

## Project Structure

-   `crates/`: Contains the core workspace members.
-   `Justfile`: Command runner for setup and maintenance.
-   `.github/`: CI/CD workflows.

## Coding Standards (STRICT)

-   **Language:** Rust (2021 edition).
-   **Formatting:** Run `cargo fmt` on all changes.
-   **Linting:** Code must pass `cargo clippy -- -D warnings`. NO WARNINGS ALLOWED.
-   **Documentation:** All public items MUST have documentation comments.
-   **Tests:** All new features MUST include unit tests.
-   **Error Handling:** Prefer `thiserror` for libraries and `anyhow` for applications. `unwrap()` is FORBIDDEN in production code.
-   **Async:** Use `tokio` runtime where applicable.

## Development Workflow

1. **Setup:** Run `just setup` to install hooks.
2. **Testing:** Run `cargo test` for all crates.
3. **Commits:** Follow [Conventional Commits](https://www.conventionalcommits.org/).
