# typed: false
# frozen_string_literal: true

module Homebrew
  ZSHRC_BLOCK = <<~ZSH
    # >>> brew-dev setup >>>
    # pyenv
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"

    # jenv
    export PATH="$HOME/.jenv/bin:$PATH"
    eval "$(jenv init -)"

    # nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
    # <<< brew-dev setup <<<
  ZSH

  def dev
    puts "🍺 Starting personal dev environment setup..."

    brewfile = File.expand_path("../Brewfile", __dir__)
    raise "❌ Brewfile not found" unless File.exist?(brewfile)

    system "brew", "bundle", "--file=#{brewfile}" ||
      raise("❌ brew bundle failed")

    setup_zshrc
    choose_and_setup_python
    choose_and_setup_java
    choose_and_setup_node

    puts "✅ Dev environment setup completed"
  end

  # ---------- helpers ----------

  def ask(prompt, default = nil)
    print default ? "#{prompt} [#{default}]: " : "#{prompt}: "
    input = STDIN.gets&.strip
    input.nil? || input.empty? ? default : input
  end

  def ask_yes_no(prompt, default: true)
    suffix = default ? "[Y/n]" : "[y/N]"
    print "#{prompt} #{suffix}: "
    input = STDIN.gets&.strip&.downcase

    return default if input.nil? || input.empty?
    %w[y yes].include?(input)
  end

  # ---------- setup steps ----------

  def setup_zshrc
    zshrc = File.join(Dir.home, ".zshrc")
    File.write(zshrc, "") unless File.exist?(zshrc)

    content = File.read(zshrc)
    return if content.include?(">>> brew-dev setup >>>")

    File.open(zshrc, "a") { |f| f.puts "\n#{ZSHRC_BLOCK}" }
    puts "🧩 ~/.zshrc updated"
  end

  def choose_and_setup_python
    puts "\n🐍 Python setup"
    version = ask("Enter Python version to install", "3.12.4")

    system "pyenv", "install", "-s", version
    system "pyenv", "global", version

    puts "✔ Python #{version} set globally"
  end

  def choose_and_setup_java
    puts "\n☕ Java setup"
    version = ask("Choose Java version (17 / 21)", "21")

    jdk_path = "/opt/homebrew/opt/openjdk@#{version}"
    unless Dir.exist?(jdk_path)
      puts "⚠️ JDK #{version} not found via brew"
      return
    end

    system "jenv", "add", jdk_path
    system "jenv", "global", version

    puts "✔ Java #{version} set globally"
  end

  def choose_and_setup_node
    puts "\n🟢 Node.js setup"
    return unless ask_yes_no("Install Node.js LTS?", default: true)

    nvm_script = "/opt/homebrew/opt/nvm/nvm.sh"
    return unless File.exist?(nvm_script)

    system %(bash -c 'source #{nvm_script} && nvm install --lts && nvm use --lts')
    puts "✔ Node.js LTS installed"
  end
end
