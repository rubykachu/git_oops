# frozen_string_literal: true

require "thor"
require_relative "commands/reset_command"

module GitOops
  class CLI < Thor
    package_name "Git Oops"

    class_option :help, aliases: '-h', type: :boolean,
                description: 'Display usage information'

    desc "reset", "Restore deleted Git commits interactively"
    long_desc <<-LONGDESC
      `goops reset` will help you restore deleted Git commits in an interactive way.

      Examples:
        $ goops reset                    # Shows last 20 commits
        $ goops reset --limit 30         # Shows last 30 commits
        $ goops reset --search "fix"     # Search commits with "fix" in message
        $ goops reset --no-warning       # Skip warning messages

      You can combine options:
        $ goops reset --limit 50 --search "feature" --no-warning
    LONGDESC
    method_option :limit, type: :numeric, default: 20,
                 desc: "Number of commits to display (default: 20)"
    method_option :search, type: :string,
                 desc: "Search commits by keyword in commit message"
    method_option :no_warning, type: :boolean, default: false,
                 desc: "Skip warning messages before restoring"
    def reset
      GitOops::Commands::ResetCommand.new(options).execute
    end

    def self.exit_on_failure?
      true
    end
  end
end
