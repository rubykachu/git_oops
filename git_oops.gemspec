# frozen_string_literal: true

require_relative "lib/git_oops/version"

Gem::Specification.new do |spec|
  spec.name = "git_oops"
  spec.version = GitOops::VERSION
  spec.authors = ["Minh Tang Q."]
  spec.email = ["minh.tang1@tomosia.com"]

  spec.summary = "A friendly tool to help recover deleted Git commits safely and conveniently"
  spec.description = "git_oops provides an interactive interface to help users recover deleted Git commits safely. It features a user-friendly selection interface, commit preview, and safety measures to prevent data loss."
  spec.homepage = "https://github.com/rubykachu/git_oops"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.5.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/rubykachu/git_oops"
  spec.metadata["changelog_uri"] = "https://github.com/rubykachu/git_oops/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[
          bin/
          test/
          spec/
          features/
          .git
          .github
          .gitignore
          .rspec
          .rubocop.yml
          Gemfile
          Rakefile
          git_oops-*.gem
          *.gemspec
        ])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_dependency "tty-prompt", "~> 0.23.1"  # For interactive CLI
  spec.add_dependency "pastel", "~> 0.8.0"       # For colored output
  spec.add_dependency "thor", "~> 1.3.0"         # For CLI command structure

  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rubocop", "~> 1.59"
end
