# 🍺 Homebrew Dev Tools (`brew setup`)

A **personal Homebrew tap** that provides a native `brew setup` command to **bootstrap a full development environment** on macOS using **pyenv, jenv, and nvm**, with interactive version selection.

This setup is:
- 🚀 One-command driven
- 🔁 Reproducible
- 🧼 Homebrew-style compliant
- 🧑‍💻 Designed for long-term personal use across multiple Macs

---

## ✨ Features

- Native Homebrew command: `brew setup`
- Installs tools via a versioned `Brewfile`
- Language version management using:
  - **pyenv** (Python)
  - **jenv** (Java)
  - **nvm** (Node.js)
- Interactive prompts for choosing language versions
- Interactive Git configuration (User/Email/SSH)
- Safe, idempotent `.zshrc` configuration
- Apple Silicon compatible
- Fully passes `brew style` and `brew audit`
- **Dry run mode**: Preview changes with `brew setup --dry-run`

---

## 📦 What gets installed

### Via Homebrew
- Core tools (git, curl, jq, etc.)
- `pyenv`
- `jenv`
- `nvm`
- Java distributions (OpenJDK 17, 21)
- Dev tools (Docker, kubectl, terraform, etc.)
- GUI apps (Warp, VS Code, iTerm2)

> The exact list is defined in the [`Brewfile`](./dev-setup/Brewfile).

---
# 🍎 Fresh macOS Setup Guide (Apple Silicon)

Follow these steps on a **brand new Mac** to bootstrap your full development environment using Homebrew and `brew setup`.

---

## 1️⃣ Install Xcode Command Line Tools

```bash
xcode-select --install
```

## 2️⃣ Install Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
## 3️⃣ Add Homebrew to Your Shell (Apple Silicon)
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
eval "$(/opt/homebrew/bin/brew shellenv)"
```

## 4️⃣ Verify Homebrew Installation
```bash
brew --version
brew doctor
```
Ensure there are no critical errors before continuing.

## 5️⃣ Tap the Dev Tools Repository
```bash
brew tap premaluu/devtools
```

## 6️⃣ Run the Development Environment Setup
```bash
brew setup
```
This command will:

- Install all tools defined in the Brewfile
- Configure pyenv, jenv, and nvm
- Prompt you to select language versions interactively
- Configure Git identity and generate SSH keys
- Safely update your .zshrc

## 7️⃣ Restart Your Terminal
Close and reopen your terminal after the first run so all environment changes take effect.
---

## 📷 Screenshots
<img width="794" height="465" alt="Screenshot 2025-12-14 at 7 28 32 PM" src="https://github.com/user-attachments/assets/6a36aa49-a1c7-4a40-8e97-1820327e7da5" />

