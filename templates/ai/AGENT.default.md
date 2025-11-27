# AI Agent Guidelines (AGENT.md)

## Project Overview

This is a Rust workspace for `webllm`.

## Project Structure

-   `crates/`: Contains the core workspace members.
-   `Justfile`: Command runner for setup and maintenance.
-   `.github/`: CI/CD workflows.

## Coding Standards

-   **Language:** Rust (2021 edition).
-   **Formatting:** Run `cargo fmt` on all changes.
-   **Linting:** Code must pass `cargo clippy`.
-   **Error Handling:** Prefer `thiserror` for libraries and `anyhow` for applications.
-   **Async:** Use `tokio` runtime where applicable.

## Development Workflow

1. **Setup:** Run `just setup` to install hooks.
2. **Testing:** Run `cargo test` for all crates.
3. **Commits:** Follow [Conventional Commits](https://www.conventionalcommits.org/).
