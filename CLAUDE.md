# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **personal Homebrew tap** providing a `brew setup` command to bootstrap a complete macOS development environment. The command installs tools, version managers (pyenv, jenv, nvm), language runtimes, and configures shell initialization.

## Architecture

### Key Files

- **`cmd/brew-setup.rb`** — The main entry point. Ruby script executed by `brew setup` that:
  - Runs `brew bundle` with the Brewfile
  - Configures `.zshrc` with pyenv/jenv/nvm initialization (with guards to prevent duplication)
  - Handles interactive prompts for Python, Java, Node.js versions
  - Manages Git identity and SSH key generation
  - Supports `--dry-run` mode to preview changes without making them

- **`dev-setup/Brewfile`** — Declarative definition of all packages and casks to install via Homebrew

### Design Patterns

- **Idempotent operations**: The script safely re-runs without duplication. Shell initialization checks for existing markers (`>>> brew-dev setup >>>`) before appending to `.zshrc`.
- **Dry-run support**: All functions check `DRY_RUN` constant before executing system commands
- **Interactive setup**: Uses helper methods `ask()` and `yes?()` for prompts with defaults
- **Error handling**: Validates Brewfile existence and aborts gracefully if `brew bundle` fails
- **Early returns**: Functions like `setup_java` and `setup_node` return early if prerequisites aren't met, avoiding cascading failures
- **Conditional execution**: Git and SSH setup check for existing configuration before prompting, avoiding redundant setup

## Development Commands

### Testing the Setup Script

Since this is a Homebrew tap, traditional testing requires proper Homebrew integration:

```bash
# Tap the repository locally for testing
brew tap premaluu/devtools /Users/amitvikram/coding/homebrew-devtools

# Run the setup command with dry-run to preview changes
brew setup --dry-run

# Run the actual setup
brew setup
```

### Testing Individual Functions

You can test specific functions by modifying the Ruby script directly or by running sections:

```bash
# Test just the dry-run output
ruby cmd/brew-setup.rb --dry-run

# Verify syntax
ruby -c cmd/brew-setup.rb
```

### Homebrew Compliance

The tap must pass Homebrew's style and audit checks:

```bash
brew style /Users/amitvikram/coding/homebrew-devtools
brew audit --tap premaluu/devtools
```

### CI/CD Testing

GitHub Actions automatically test the tap on multiple platforms:
- **ubuntu-22.04**, **macos-15-intel**, **macos-26** - Test matrix ensures cross-platform compatibility
- **brew test-bot** - Runs Homebrew's official testing suite including syntax checks and formula tests
- **pr-pull workflow** - Handles bottle publishing when PRs are labeled with `pr-pull`

Local testing mimics CI:
```bash
# Run the full test-bot suite locally
brew test-bot --only-tap-syntax
brew test-bot --only-formulae
```

## Key Implementation Notes

- **Shell initialization block**: Defined as `ZSHRC_BLOCK` constant to keep `.zshrc` configuration DRY and reproducible
- **JDK path handling**: Java setup uses Homebrew's standard OpenJDK paths (`/opt/homebrew/opt/openjdk@{version}`)
- **NVM initialization**: Sourced via the formula-provided script rather than the original nvm install location
- **SSH key generation**: Uses `ed25519` algorithm and adds to macOS keychain; automatically copies public key to clipboard for GitHub
- **Dry-run pattern**: Rather than conditionally executing, the code prints what _would_ happen, making the feature safer and more transparent
- **Ruby conventions**: Script uses `frozen_string_literal: true` and `$stdout.sync = true` for safety and immediate output
- **Helper functions**: `ask()` handles string input with defaults, `yes?()` handles boolean prompts with Y/n or y/N suffixes

## Common Changes

- **Adding packages**: Update `dev-setup/Brewfile` and verify with `brew bundle --dry-run --file=dev-setup/Brewfile`
- **Changing version defaults**: Update the `ask()` calls in `setup_python`, `setup_java` functions
- **Modifying shell init**: Edit `ZSHRC_BLOCK` constant (remember to preserve the marker comments)
- **New setup steps**: Add new `setup_*` functions and call them from the main `setup()` function