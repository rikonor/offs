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
setup: setup-git-user setup-hooks setup-gpg
    @echo "Setup complete! Development environment is ready."
    @echo "Run 'just verify-signing' to test your commit signing configuration."

# Verify commit signing works
verify-signing:
    #!/usr/bin/env bash
    echo "🧪 Testing commit signing..."
    echo "Creating a temporary commit..."
    touch .signing-test
    git add .signing-test
    # Use --no-verify to skip pre-commit hooks for this test
    git commit -m "chore: verify signing" --quiet --no-verify

    echo ""
    echo "🔍 Verifying signature..."
    if git verify-commit HEAD; then
        echo ""
        echo "✨ SUCCESS! Your commit was signed and verified."
        echo "Here are the details:"
        git show --show-signature -s HEAD
    else
        echo ""
        echo "❌ FAILURE! The commit was not properly signed."
    fi

    echo ""
    echo "🧹 Cleaning up..."
    git reset --soft HEAD~1
    rm .signing-test
    git reset HEAD .signing-test
    echo "Done."

# Configure git user identity
[private]
setup-git-user:
    #!/usr/bin/env bash
    echo "Configuring git user identity..."
    if [ -z "$(git config --get user.name)" ]; then
        read -p "Enter your git user name: " git_name
        git config user.name "$git_name"
        echo "✅ Set git user.name to '$git_name'"
    else
        echo "✅ git user.name is already set to '$(git config --get user.name)'"
    fi

    if [ -z "$(git config --get user.email)" ]; then
        read -p "Enter your git user email: " git_email
        git config user.email "$git_email"
        echo "✅ Set git user.email to '$git_email'"
    else
        echo "✅ git user.email is already set to '$(git config --get user.email)'"
    fi

# Install and configure pre-commit hooks
[private]
setup-hooks:
    #!/usr/bin/env bash
    echo "Configuring pre-commit hooks..."
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
    pre-commit install --hook-type commit-msg
    pre-commit install --hook-type post-commit
    echo "✅ Pre-commit hooks installed."

# Configure GPG signing
[private]
setup-gpg:
    #!/usr/bin/env bash
    # Check for GPG signing
    if [ "$(git config --get commit.gpgsign)" != "true" ]; then
        echo ""
        echo "🔒 Security Check: Signed commits are required for this repository."
        echo "Your 'commit.gpgsign' config is currently not set to 'true'."
        read -p "Would you like to enable automatic commit signing for this repository? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git config commit.gpgsign true
            echo "✅ Enabled commit signing (git config commit.gpgsign true)"

            # Check if they actually have a key configured
            if [ -z "$(git config --get user.signingkey)" ]; then
                echo ""
                echo "⚠️  Missing Signing Key"
                echo "You have enabled signing, but you don't have a key configured yet."
                echo "We can walk you through the commands to generate a new SSH key and configure git to use it."
                echo ""
                echo "This process will:"
                echo "1. Generate a new SSH key (ed25519) specifically for signing"
                echo "2. Configure git to use SSH for signing"
                echo "3. Set this new key as your signing key"
                echo ""
                read -p "Would you like to generate a new SSH signing key now? (y/n) " -n 1 -r
                echo ""
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    echo ""
                    echo "Step 1: Generating SSH key..."
                    ssh-keygen -t ed25519 -C "git-signing-key" -f ~/.ssh/id_ed25519_signing_$(date +%s)

                    # Find the private key (no extension)
                    KEY_PATH=$(ls -t ~/.ssh/id_ed25519_signing_* | grep -v "\.pub$" | head -1)
                    PUB_KEY_PATH="${KEY_PATH}.pub"

                    echo ""
                    echo "Step 2: Configuring git to use SSH for signing..."
                    git config gpg.format ssh
                    echo "✅ git config gpg.format ssh"

                    echo ""
                    echo "Step 3: Setting the signing key..."
                    git config user.signingkey "$PUB_KEY_PATH"
                    echo "✅ git config user.signingkey $PUB_KEY_PATH"

                    echo ""
                    echo "Step 4: Configuring allowed signers (for local verification)..."
                    touch ~/.ssh/allowed_signers
                    # Remove existing entry for this email if present to avoid duplicates
                    sed -i.bak "/$(git config --get user.email)/d" ~/.ssh/allowed_signers
                    echo "$(git config --get user.email) $(cat $PUB_KEY_PATH)" >> ~/.ssh/allowed_signers
                    git config gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
                    echo "✅ Configured ~/.ssh/allowed_signers"

                    echo ""
                    echo "🎉 Success! Your signing key is generated and configured."
                    echo "IMPORTANT: You must now add this public key to your GitHub/GitLab account:"
                    echo ""
                    cat "$PUB_KEY_PATH"
                    echo ""
                    echo "Copy the line above and add it as a 'Signing Key' (NOT an Authentication Key) in your account settings."
                else
                    echo "Okay, please remember to configure a signing key manually."
                    echo "See: https://docs.github.com/en/authentication/managing-commit-signature-verification"
                fi
            fi
        else
            echo "⚠️  Warning: You will not be able to commit without signing enabled."
        fi
    else
        echo "✅ Commit signing is already enabled."
        if [ -z "$(git config --get user.signingkey)" ]; then
             echo "⚠️  However, you don't have a signing key configured!"
             echo "Please run 'just unset-gpg' and then 'just setup' to re-configure it properly."
        fi
    fi

# Disable GPG signing (revert)
unset-gpg:
    #!/usr/bin/env bash
    echo "Disabling automatic commit signing for this repository..."
    git config --unset commit.gpgsign
    echo "✅ Disabled commit signing (git config --unset commit.gpgsign)"
    echo "Note: Your signing key configuration (user.signingkey) has been preserved."

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
