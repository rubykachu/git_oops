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

        selected_commit = select_commit(commits)
        return unless selected_commit

        handle_restore(selected_commit)
      end

      private

      def fetch_commits
        limit = @options[:limit] || 20
        search = @options[:search]

        command = "git reflog --format='%h - %s [%ar]'"
        command += " | grep -i '#{search}'" if search
        command += " | head -n #{limit}"

        result = `#{command}`
        result.split("\n")
      end

      def select_commit(commits)
        @prompt.select("Select a commit to restore:", commits, per_page: 10)
      end

      def handle_restore(commit)
        hash = commit.split(" ").first

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
