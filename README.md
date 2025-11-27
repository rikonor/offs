# offs

> Oh For Fucks Sake - A Rust workspace for web-based LLM interactions.

## Development Setup

To set up the development environment, including pre-commit hooks, run:

```bash
just setup
```

This will install `pre-commit` (if not already installed) and configure the git
hooks.

### Resetting the Environment

If you need to reset your local environment to a clean state (simulating a fresh
clone), you can use:

```bash
# Reset to main branch
just reset

# Reset to a specific tag, branch, or commit
just reset v1.0.0
```

**Warning:** This is a destructive action that will discard all uncommitted
changes and untracked files.

## Contributing

We follow [Conventional Commits](https://www.conventionalcommits.org/) for
commit messages.
