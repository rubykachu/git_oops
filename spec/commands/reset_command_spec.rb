# frozen_string_literal: true

require "spec_helper"

RSpec.describe GitOops::Commands::ResetCommand do
  let(:options) { {} }
  let(:command) { described_class.new(options) }
  let(:prompt) { instance_double(TTY::Prompt) }
  let(:commit1) { "abc1234" }
  let(:commit2) { "def5678" }

  before do
    allow(TTY::Prompt).to receive(:new).and_return(prompt)
    allow(prompt).to receive(:yes?).and_return(true)
    allow(prompt).to receive(:select).and_return(commit1)

    # Mock all git commands
    allow(command).to receive(:`).with("git rev-list --count HEAD").and_return("2\n")
    allow(command).to receive(:`).with("git rev-parse --abbrev-ref HEAD").and_return("main\n")
    allow(command).to receive(:`).with(/git log --oneline/).and_return(
      "#{commit1} add file1.txt\n#{commit2} add file2.txt\n"
    )
    allow(command).to receive(:`).with("git rev-parse HEAD").and_return(commit2)

    # Mock git reflog with proper format
    reflog_output = <<~REFLOG
      #{commit2} (HEAD@{0}) commit: add file2.txt
      #{commit1} (HEAD@{1}) commit: add file1.txt
    REFLOG
    allow(command).to receive(:`).with(/git reflog/).and_return(reflog_output)

    # Mock system commands
    allow(command).to receive(:system).with(/git reset --hard/).and_return(true)
    allow(command).to receive(:system).with(/git branch/).and_return(true)
  end

  describe "#execute" do
    context "when no commits exist" do
      before do
        allow(command).to receive(:`).with(/git reflog/).and_return("")
        allow(command).to receive(:`).with("git rev-list --count HEAD").and_return("0\n")
        allow(command).to receive(:`).with(/git log --oneline/).and_return("")
        allow(command).to receive(:`).with("git rev-parse HEAD").and_return("")
      end

      it "returns early without error" do
        expect { command.execute }.not_to raise_error
      end
    end

    context "with default options" do
      it "displays current log" do
        output = strip_ansi(capture_stdout { command.execute })
        expect(output).to include("Current Git Log:")
      end

      it "shows branch information" do
        output = strip_ansi(capture_stdout { command.execute })
        expect(output).to include("Branch: main")
      end
    end

    context "with custom log limit" do
      let(:options) { { log_limit: 1 } }

      it "respects the log limit" do
        allow(command).to receive(:`).with(/git log --oneline/).and_return("#{commit1} add file1.txt\n")
        output = strip_ansi(capture_stdout { command.execute })
        commit_lines = output.scan(/add file\d\.txt/).count
        expect(commit_lines).to eq(1)
      end
    end

    context "when restoring a commit" do
      before do
        allow(prompt).to receive(:select).and_return(commit1)
      end

      it "creates backup branch when requested" do
        allow(prompt).to receive(:yes?).with(/WARNING/).and_return(true)
        allow(prompt).to receive(:yes?).with(/save the current state/).and_return(true)
        output = strip_ansi(capture_stdout { command.execute })
        expect(output).to include("Current state saved to branch")
      end

      it "restores the selected commit" do
        allow(prompt).to receive(:yes?).with(/WARNING/).and_return(true)
        allow(prompt).to receive(:yes?).with(/save the current state/).and_return(false)
        output = strip_ansi(capture_stdout { command.execute })
        expect(output).to include("Successfully restored commit")
      end
    end

    context "when searching commits" do
      let(:options) { { search: "file1" } }

      it "filters commits by search term" do
        filtered_reflog = "#{commit1} (HEAD@{1}) commit: add file1.txt\n"
        allow(command).to receive(:`).with(/git reflog/).and_return(filtered_reflog)
        allow(command).to receive(:`).with(/git log --oneline/).and_return("#{commit1} add file1.txt\n")

        output = strip_ansi(capture_stdout { command.execute })
        expect(output).to include("file1.txt")
        expect(output).not_to include("file2.txt")
      end
    end
  end

  private

  def capture_stdout
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end

  def strip_ansi(string)
    string.gsub(/\e\[\d+m/, '')
  end
end
