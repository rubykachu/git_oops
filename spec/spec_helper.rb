# frozen_string_literal: true

require "git_oops"
require "fileutils"
require "tmpdir"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Setup test git repository
  config.around(:each) do |example|
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        system("git init --quiet")
        system("git config --local user.name 'Test User'")
        system("git config --local user.email 'test@example.com'")
        example.run
      end
    end
  end
end
