# frozen_string_literal: true

require "tty-prompt"
require "pastel"

module GitOops
  module Commands
    class ResetCommand
      def initialize(options)
        @options = options
        @prompt = TTY::Prompt.new
        @pastel = Pastel.new
      end

      def execute
        commits = fetch_commits
        return if commits.empty?

        begin
          selected_commit = select_commit(commits)
          return unless selected_commit

          handle_restore(selected_commit)
        rescue TTY::Reader::InputInterrupt
          puts "\n#{@pastel.blue('ℹ')} Operation cancelled. No changes were made."
          exit 0
        end
      end

      private

      def fetch_commits
        limit = @options[:limit] || 20
        search = @options[:search]
        current_commit = `git rev-parse HEAD`.strip

        command = "git reflog --format='%h - %s [%ar]'"
        command += " | grep -i '#{search}'" if search
        command += " | head -n #{limit}"

        result = `#{command}`
        commits = result.split("\n")

        # Mark current commit
        commits.map.with_index do |commit, index|
          hash = commit.split(" ").first
          if hash == current_commit
            ["#{commit} #{@pastel.green('(current)')} [#{index + 1}/#{commits.length}]", hash]
          else
            ["#{commit} [#{index + 1}/#{commits.length}]", hash]
          end
        end
      end

      def select_commit(commits)
        choices = commits.map do |commit_info, hash|
          { name: commit_info, value: hash }
        end

        selected = @prompt.select(
          "Select a commit to restore:",
          choices,
          per_page: 10,
          filter: true,
          show_help: :always,
          help: "(Use ↑/↓ to navigate, type to filter)"
        )

        current_commit = `git rev-parse HEAD`.strip
        if selected == current_commit
          puts "\n#{@pastel.blue('ℹ')} Selected commit is the current HEAD. No changes needed."
          return nil
        end

        selected
      end

      def handle_restore(hash)
        unless @options[:no_warning]
          return unless confirm_restore
        end

        if @prompt.yes?("Do you want to save the current state before restoring?")
          backup_current_state
        end

        restore_commit(hash)
      end

      def confirm_restore
        @prompt.yes?(@pastel.yellow("⚠️  WARNING: You are about to reset your code. This action can be undone with git reflog.\nDo you want to continue?"))
      end

      def backup_current_state
        timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
        branch_name = "backup_#{timestamp}"
        system("git branch #{branch_name}")
        puts @pastel.green("✅ Current state saved to branch: #{branch_name}")
      end

      def restore_commit(hash)
        if system("git reset --hard #{hash}")
          puts @pastel.green("✅ Successfully restored commit #{hash}")
        else
          puts @pastel.red("❌ Failed to restore commit #{hash}")
        end
      end
    end
  end
end
