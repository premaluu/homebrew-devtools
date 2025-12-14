# typed: false
# frozen_string_literal: true

module Homebrew
  def dev
    puts "🍺 Starting personal dev environment setup..."

    brewfile = "#{ENV["HOME"]}/dev-setup/Brewfile"

    unless File.exist?(brewfile)
      raise "❌ Brewfile not found at #{brewfile}"
    end

    system "brew bundle --file=#{brewfile}" or
      raise "❌ Brew bundle failed"

    puts "✅ Dev environment setup completed"
  end
end
