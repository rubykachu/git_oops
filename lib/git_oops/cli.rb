# frozen_string_literal: true

require "thor"
require_relative "commands/reset_command"

module GitOops
  class CLI < Thor
    desc "reset", "Restore deleted Git commits interactively"
    method_option :limit, type: :numeric, default: 20, desc: "Number of commits to display"
    method_option :search, type: :string, desc: "Search commits by keyword"
    method_option :no_warning, type: :boolean, default: false, desc: "Skip warning messages"
    def reset
      GitOops::Commands::ResetCommand.new(options).execute
    end

    def self.exit_on_failure?
      true
    end
  end
end
