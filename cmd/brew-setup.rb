#!/usr/bin/env ruby
# frozen_string_literal: true

$stdout.sync = true

ZSHRC_BLOCK = <<~ZSH
  # >>> brew-dev setup >>>
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"

  export PATH="$HOME/.jenv/bin:$PATH"
  eval "$(jenv init -)"

  export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
  # <<< brew-dev setup <<<
ZSH

DRY_RUN = ARGV.include?("--dry-run")

def setup
  if DRY_RUN
    puts "🔍 Dry run mode - no changes will be made\n\n"
  end

  puts "🍺 Bootstrapping dev environment..."

  tap_repo = `brew --repo premaluu/devtools`.strip
  brewfile = File.join(tap_repo, "dev-setup", "Brewfile")

  abort("❌ Brewfile not found at #{brewfile}") unless File.exist?(brewfile)

  if DRY_RUN
    puts "📦 Would run: brew bundle --file=#{brewfile}"
    puts "   Packages to install:"
    File.read(brewfile).each_line do |line|
      next if line.strip.empty? || line.start_with?("#")
      puts "     - #{line.strip}"
    end
    puts
  else
    system("brew", "bundle", "--file=#{brewfile}") ||
      abort("❌ brew bundle failed")
  end

  setup_zshrc
  setup_python
  setup_java
  setup_node
  setup_git

  if DRY_RUN
    puts "✅ Dry run completed. No changes were made."
  else
    puts "✅ Dev setup completed. Restart your terminal."
  end
end

def ask(prompt, default)
  print "#{prompt} [#{default}]: "
  input = $stdin.gets&.strip

  return default if input.nil? || input.empty?

  input
end

def yes?(prompt, default: true)
  suffix = default ? "[Y/n]" : "[y/N]"
  print "#{prompt} #{suffix}: "
  input = $stdin.gets&.strip&.downcase

  return default if input.nil? || input.empty?

  %w[y yes].include?(input)
end

def setup_zshrc
  zshrc = File.join(Dir.home, ".zshrc")
  File.write(zshrc, "") unless File.exist?(zshrc)

  return if File.read(zshrc).include?(">>> brew-dev setup >>>")

  if DRY_RUN
    puts "🧩 Would update ~/.zshrc with pyenv/jenv/nvm initialization"
  else
    File.open(zshrc, "a") do |f|
      f.puts
      f.puts ZSHRC_BLOCK
    end
    puts "🧩 ~/.zshrc updated"
  end
end

def setup_python
  puts "\n🐍 Python"
  version = ask("Python version", "3.12.4")
  if DRY_RUN
    puts "   Would install Python #{version} via pyenv"
    puts "   Would set Python #{version} as global"
  else
    system "pyenv", "install", "-s", version
    system "pyenv", "global", version
  end
end

def setup_java
  puts "\n☕ Java"
  version = ask("Java version (17 or 21)", "21")
  jdk_path = "/opt/homebrew/opt/openjdk@#{version}"

  unless Dir.exist?(jdk_path)
    puts "   ⚠️  JDK #{version} not found at #{jdk_path}"
    return
  end

  if DRY_RUN
    puts "   Would add JDK #{version} to jenv"
    puts "   Would set Java #{version} as global"
  else
    system "jenv", "add", jdk_path
    system "jenv", "global", version
  end
end

def setup_node
  puts "\n🟢 Node.js"

  install_lts = yes?("Install Node.js LTS?")

  if DRY_RUN
    if install_lts
      puts "   Would install Node.js LTS via nvm"
    else
      puts "   Skipping Node.js installation"
    end
    return
  end

  return unless install_lts

  nvm_script = "/opt/homebrew/opt/nvm/nvm.sh"

  return unless File.exist?(nvm_script)

  system(
    "bash",
    "-c",
    "source #{nvm_script} && nvm install --lts && nvm use --lts",
  )
end

def setup_git
  puts "\n🔧 Git Configuration"

  current_name = `git config --global user.name`.strip
  current_email = `git config --global user.email`.strip

  if current_name.empty? || current_email.empty?
    puts "Let's configure your Git identity."
    name = ask("Git Config Name", "Your Name")
    email = ask("Git Config Email", "you@example.com")

    if DRY_RUN
      puts "   Would set Git user.name to: #{name}"
      puts "   Would set Git user.email to: #{email}"
    else
      system("git", "config", "--global", "user.name", name)
      system("git", "config", "--global", "user.email", email)
    end
  else
    puts "✅ Git identity already configured (#{current_name} <#{current_email}>)"
  end

  setup_ssh
end

def setup_ssh
  ssh_key_path = File.join(Dir.home, ".ssh", "id_ed25519")

  if File.exist?(ssh_key_path)
    puts "✅ SSH key found at #{ssh_key_path}"
  else
    puts "\n🔑 SSH Key"
    generate_key = yes?("Generate a new SSH key for GitHub?", default: true)

    if DRY_RUN
      if generate_key
        puts "   Would generate SSH key at #{ssh_key_path}"
        puts "   Would add key to keychain"
        puts "   Would display public key for GitHub"
      else
        puts "   Skipping SSH key generation"
      end
      return
    end

    return unless generate_key

    email = `git config --global user.email`.strip
    system("ssh-keygen", "-t", "ed25519", "-C", email, "-f", ssh_key_path, "-N", "")
    system("ssh-add --apple-use-keychain #{ssh_key_path} 2>/dev/null")
    puts "✅ SSH key generated."
  end

  return unless File.exist?(ssh_key_path)

  puts "\n📋 Here is your public SSH key (copy to GitHub):"
  system("pbcopy < #{ssh_key_path}.pub")
  puts "---------------------------------------------------"
  puts File.read("#{ssh_key_path}.pub")
  puts "---------------------------------------------------"
  puts "🔗 Add it here: https://github.com/settings/keys"
  puts "(Copied to clipboard 📋)"
end

setup
