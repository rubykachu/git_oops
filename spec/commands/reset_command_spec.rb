# frozen_string_literal: true

require "spec_helper"

RSpec.describe GitOops::Commands::ResetCommand do
  let(:options) { {} }
  let(:command) { described_class.new(options) }
  let(:prompt) { instance_double(TTY::Prompt) }

  before do
    allow(TTY::Prompt).to receive(:new).and_return(prompt)
    allow(prompt).to receive(:yes?).and_return(true)
    allow(prompt).to receive(:select).and_return("abc1234")
  end

  describe "#execute" do
    before do
      # Create some test commits
      system("echo 'test1' > file1.txt")
      system("git add file1.txt")
      system("git commit -m 'add file1.txt' --quiet")
      @commit1 = `git rev-parse HEAD`.strip

      system("echo 'test2' > file2.txt")
      system("git add file2.txt")
      system("git commit -m 'add file2.txt' --quiet")
      @commit2 = `git rev-parse HEAD`.strip
    end

    context "when no commits exist" do
      before do
        allow(command).to receive(:`).with(/git reflog/).and_return("")
      end

      it "returns early without error" do
        expect { command.execute }.not_to raise_error
      end
    end

    context "with default options" do
      it "displays current log" do
        expect { command.execute }.to output(/Current Git Log:/).to_stdout
      end

      it "shows branch information" do
        expect { command.execute }.to output(/Branch:/).to_stdout
      end
    end

    context "with custom log limit" do
      let(:options) { { log_limit: 1 } }

      it "respects the log limit" do
        output = capture_stdout { command.execute }
        commit_lines = output.scan(/[a-f0-9]{7}/).count
        expect(commit_lines).to be <= 1
      end
    end

    context "when restoring a commit" do
      before do
        allow(prompt).to receive(:select).and_return(@commit1)
      end

      it "creates backup branch when requested" do
        allow(prompt).to receive(:yes?).and_return(true)
        expect { command.execute }.to output(/Current state saved to branch/).to_stdout
      end

      it "restores the selected commit" do
        allow(prompt).to receive(:yes?).and_return(false)
        expect { command.execute }.to output(/Successfully restored commit/).to_stdout
        expect(`git rev-parse HEAD`.strip).to eq(@commit1)
      end
    end

    context "when searching commits" do
      let(:options) { { search: "file1" } }

      it "filters commits by search term" do
        output = capture_stdout { command.execute }
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
end
