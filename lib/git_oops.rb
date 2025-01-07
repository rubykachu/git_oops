# frozen_string_literal: true

require_relative "git_oops/version"
require_relative "git_oops/cli"

module GitOops
  class Error < StandardError; end

  # Check if git is installed
  def self.git_installed?
    system("which git > /dev/null 2>&1")
  end

  # Check if current directory is a git repository
  def self.git_repository?
    system("git rev-parse --git-dir > /dev/null 2>&1")
  end
end
