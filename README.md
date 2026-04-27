# 🍺 Homebrew Dev Tools (`brew setup`)

[![CI Status](https://github.com/premaluu/homebrew-devtools/workflows/CI/badge.svg)](https://github.com/premaluu/homebrew-devtools/actions)

A **personal Homebrew tap** that provides a native `brew setup` command to **bootstrap a full development environment** on macOS using **pyenv, jenv, and nvm**, with interactive version selection.

This setup is:
- 🚀 **One-command driven** — Get a complete dev environment with a single `brew setup` call
- 🔁 **Reproducible** — Run again to skip already-configured tools and add new ones
- 🧼 **Homebrew-style compliant** — Passes all Homebrew style and audit checks
- 🧑‍💻 **Designed for long-term personal use** — Easily reproduce across multiple Macs

---

## ⚡ Quick Start

> **💡 New to macOS or setting up a fresh machine?** Skip to [Fresh macOS Setup Guide](#-fresh-macos-setup-guide-apple-silicon) below.

```bash
# Preview what will be installed (no changes made)
brew setup --dry-run

# Run the full setup
brew setup
```

The setup command will:
- Install all tools defined in the Brewfile
- Configure pyenv, jenv, and nvm
- Prompt you to select language versions
- Configure Git identity and generate SSH keys
- Safely update your `.zshrc`

---

## 📋 Requirements

- **macOS** (Apple Silicon or Intel)
- **Homebrew** installed
- **Xcode Command Line Tools** installed
- **zsh** shell (default on macOS)

---

## ✨ Features

- **Native Homebrew command**: `brew setup` — integrates seamlessly with your Homebrew workflow
- **Language version management** via industry-standard tools:
  - **pyenv** — Python version management
  - **jenv** — Java version management  
  - **nvm** — Node.js version management
- **Interactive prompts** — Choose language versions, Git config, and SSH keys during setup
- **Safe, idempotent** — Supports re-running without duplication; `.zshrc` uses markers to prevent config duplication
- **Dry-run mode** — Preview all changes with `brew setup --dry-run` before committing them
- **Apple Silicon compatible** — Optimized for modern Macs
- **Fully Homebrew compliant** — Passes `brew style` and `brew audit`

---

## 📦 What Gets Installed

The exact packages and casks are defined in [`dev-setup/Brewfile`](./dev-setup/Brewfile).

### Core Tools
- `curl`, `wget` — HTTP clients
- `jq` — JSON processor
- `tree` — Directory tree viewer

### Version Managers
- `pyenv` — Python version management
- `jenv` — Java version management
- `nvm` — Node.js version management

### Java Distributions
- `openjdk@17` — OpenJDK 17
- `openjdk@21` — OpenJDK 21

### Build Tools
- `maven` — Java build tool

### GUI Applications (Casks)
- `iterm2` — Enhanced terminal emulator
- `visual-studio-code` — Code editor
- `warp` — Modern terminal

### Optional Packages (Commented Out)
The Brewfile includes optional packages that can be enabled by uncommenting:
- `docker`, `kubectl`, `terraform` — DevOps tools
- `fzf`, `ripgrep`, `bat`, `eza` — CLI UX enhancements

> 💡 **Customization**: Edit [`dev-setup/Brewfile`](./dev-setup/Brewfile) before running setup to add or remove packages.

---

## 🍎 Fresh macOS Setup Guide (Apple Silicon)

Follow these steps on a **brand new Mac** to get your full development environment running.

### 1️⃣ Install Xcode Command Line Tools

```bash
xcode-select --install
```

### 2️⃣ Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 3️⃣ Add Homebrew to Your Shell

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### 4️⃣ Verify Homebrew Installation

```bash
brew --version
brew doctor
```

Ensure there are no critical errors before continuing.

### 5️⃣ Tap This Repository

```bash
brew tap premaluu/devtools
```

### 6️⃣ Preview the Setup (Optional)

See what will be installed without making any changes:

```bash
brew setup --dry-run
```

### 7️⃣ Run the Setup

```bash
brew setup
```

### 8️⃣ Restart Your Terminal

Close and reopen your terminal so all environment changes take effect.

---

## ℹ️ How It Works

### Idempotent Design

The setup script is **safe to run multiple times**. It:
- Skips already-installed packages
- Checks for existing `.zshrc` configuration markers to avoid duplication
- Validates SSH keys before regenerating them

### Language Version Selection

During setup, you'll be prompted to choose:
- **Python version** (default: 3.12.4) — Installed via `pyenv`
- **Java version** (default: 21) — Managed via `jenv`
- **Node.js LTS** — Optionally installed via `nvm`

Each language manager tracks and allows easy switching between installed versions.

### Git & SSH Setup

The script:
- Prompts for your Git identity if not already configured
- Generates an `ed25519` SSH key (if one doesn't exist)
- Automatically adds the key to macOS Keychain
- Copies your public key to clipboard for easy GitHub setup

---

## 🔄 Updating Your Setup

To update packages or add new ones:

1. Edit [`dev-setup/Brewfile`](./dev-setup/Brewfile)
2. Run `brew setup` again — it will install only new packages

To update language versions:

```bash
pyenv versions                    # List available Python versions
pyenv install 3.13.1              # Install a new version
pyenv global 3.13.1               # Set as default
```

---

## ❓ FAQ & Troubleshooting

### Can I customize what gets installed?

Yes! Edit [`dev-setup/Brewfile`](./dev-setup/Brewfile) before running `brew setup`. Common packages are commented out and can be uncommented.

### What if I already have Python/Java/Node installed?

The setup script will detect existing installations via pyenv/jenv/nvm and skip installing to those managers. If you had them installed directly, you can use the version managers to install new versions.

### How do I switch between Python versions?

```bash
pyenv versions              # See installed versions
pyenv global 3.12.4         # Switch globally
pyenv local 3.13.1          # Switch for current directory
```

Same pattern applies to Java and Node via `jenv` and `nvm`.

### I need to re-run setup — will it duplicate my `.zshrc`?

No. The setup script uses markers (`>>> brew-dev setup >>>`) in `.zshrc` to detect existing configurations and won't duplicate them.

### What if `brew setup` isn't recognized?

Ensure the tap is properly installed:

```bash
brew tap premaluu/devtools
which brew-setup.rb              # Should return a path
```

If still not found, restart your terminal.

---

## 🛠️ Development

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
- **ubuntu-22.04**, **macos-15-intel**, **macos-26** — Test matrix ensures cross-platform compatibility
- **brew test-bot** — Runs Homebrew's official testing suite including syntax checks and formula tests
- **pr-pull workflow** — Handles bottle publishing when PRs are labeled with `pr-pull`

Local testing mimics CI:
```bash
# Run the full test-bot suite locally
brew test-bot --only-tap-syntax
brew test-bot --only-formulae
```

---

## 🤝 Contributing

Contributions are welcome! This is a personal project but feel free to:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Make your changes** and ensure they pass Homebrew compliance checks
4. **Test thoroughly** on both Intel and Apple Silicon Macs
5. **Submit a pull request**

### Development Guidelines

- Follow Homebrew's [Ruby style guide](https://docs.brew.sh/Ruby-for-Homebrew/)
- Ensure all changes are idempotent and safe to re-run
- Test with `--dry-run` flag before making actual changes
- Update this README if you modify user-facing behavior

---

## 📝 Changelog

### Recent Changes
- **Added dry-run flag** — Preview changes without executing them
- **Interactive git setup** — Prompts for user/email and generates SSH keys
- **Improved shell initialization** — Added guards to prevent `.zshrc` duplication

---

## 📷 Screenshots

<img width="794" height="465" alt="brew setup in action" src="https://github.com/user-attachments/assets/6a36aa49-a1c7-4a40-8e97-1820327e7da5" />

---

## 📄 License

This project is personal software. Feel free to use and modify for your own setup needs.
