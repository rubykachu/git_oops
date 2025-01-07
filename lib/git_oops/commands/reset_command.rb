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
        display_current_log
        puts "\n#{@pastel.blue('ℹ')} Above is your current git log. Below are all available commits from git reflog:\n\n"

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

      def display_current_log
        puts @pastel.cyan("Current Git Log:")
        puts @pastel.cyan("---------------")

        command = %Q{git log --oneline --decorate --color=always | head -n 10}
        log_output = `#{command}`

        puts log_output
      end

      def fetch_commits
        limit = @options[:limit] || 20
        search = @options[:search]
        current_commit = `git rev-parse HEAD`.strip
        current_branch = `git rev-parse --abbrev-ref HEAD`.strip

        # Use a more detailed format that includes the full reflog information
        command = %Q{git reflog --format="%h (%gD) %gs"}
        command += " | grep -i '#{search}'" if search
        command += " | head -n #{limit}"

        result = `#{command}`
        commits = result.split("\n")

        # Mark current commit and format like git reflog
        commits.map do |commit|
          # Split by first space to get hash, then by closing parenthesis to get ref
          parts = commit.split(" ", 2)
          hash = parts[0]
          rest = parts[1]

          # Extract ref and message
          ref_start = rest.index("(") + 1
          ref_end = rest.index(")")
          ref = rest[ref_start...ref_end]
          message = rest[ref_end + 2..-1]

          # Format the commit line
          commit_line = if hash == current_commit
            head_info = @pastel.green("HEAD -> #{current_branch}")
            "#{hash} (#{head_info}, #{ref}) #{message}"
          else
            "#{hash} (#{ref}) #{message}"
          end

          [commit_line, hash]
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
