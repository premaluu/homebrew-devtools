# typed: false
# frozen_string_literal: true

module Homebrew
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

  def dev
    puts "🍺 Bootstrapping dev environment..."

    brewfile = File.expand_path("../Brewfile", __dir__)
    raise "Brewfile not found" unless File.exist?(brewfile)

    system(
      "brew",
      "bundle",
      "--file=#{brewfile}",
    ) || raise("❌ brew bundle failed")

    setup_zshrc
    setup_python
    setup_java
    setup_node

    puts "✅ Dev setup completed. Restart your terminal."
  end

  # ---------- helpers ----------

  def ask(prompt, default)
    print "#{prompt} [#{default}]: "
    input = $stdin.gets&.strip

    (input.blank? ? default : input)
  end

  def yes?(prompt, default: true)
    suffix = default ? "[Y/n]" : "[y/N]"
    print "#{prompt} #{suffix}: "
    input = $stdin.gets&.strip&.downcase

    return default if input.blank?

    %w[y yes].include?(input)
  end

  # ---------- setup steps ----------

  def setup_zshrc
    zshrc = File.join(Dir.home, ".zshrc")
    File.write(zshrc, "") unless File.exist?(zshrc)

    return if File.read(zshrc).include?(">>> brew-dev setup >>>")

    File.open(zshrc, "a") do |f|
      f.puts
      f.puts ZSHRC_BLOCK
    end

    puts "🧩 ~/.zshrc updated"
  end

  def setup_python
    puts "\n🐍 Python"
    version = ask("Python version", "3.12.4")

    system "pyenv", "install", "-s", version
    system "pyenv", "global", version
  end

  def setup_java
    puts "\n☕ Java"
    version = ask("Java version (17 or 21)", "21")

    jdk_path = "/opt/homebrew/opt/openjdk@#{version}"
    return unless Dir.exist?(jdk_path)

    system "jenv", "add", jdk_path
    system "jenv", "global", version
  end

  def setup_node
    puts "\n🟢 Node.js"
    return unless yes?("Install Node.js LTS?")

    nvm_script = "/opt/homebrew/opt/nvm/nvm.sh"
    return unless File.exist?(nvm_script)

    system %Q(
      bash -c 'source #{nvm_script} && nvm install --lts && nvm use --lts'
    )
  end
end

