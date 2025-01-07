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
        $ goops reset                    # Shows last 20 commits from reflog
        $ goops reset --limit 30         # Shows last 30 commits from reflog
        $ goops reset --log-limit 10     # Shows last 10 commits in current log
        $ goops reset --search "fix"     # Search commits with "fix" in message
        $ goops reset --no-warning       # Skip warning messages

      You can combine options:
        $ goops reset --limit 50 --log-limit 8 --search "feature" --no-warning
    LONGDESC
    method_option :limit, type: :numeric, default: 20,
                 desc: "Number of commits to display from reflog (default: 20)"
    method_option :log_limit, type: :numeric, default: 5,
                 desc: "Number of commits to display in current log (default: 5)"
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
