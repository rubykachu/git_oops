# Git Oops

A friendly tool to help recover deleted Git commits safely and conveniently.

## Installation

Install the gem by running:

```bash
gem install git_oops
```

## Usage

The main command is `goops reset`, which helps you interactively restore deleted Git commits:

```bash
# Basic usage - shows last 20 commits from reflog
goops reset

# Show more commits from reflog
goops reset --limit 30

# Show more commits in current log
goops reset --log-limit 10

# Search commits by keyword
goops reset --search "fix"

# Skip warning messages
goops reset --no-warning
```

### Features

- 🔍 Interactive commit selection with arrow keys
- 🔎 Search commits by keyword
- 💾 Option to backup current state before restoring
- ⚠️ Safety warnings to prevent accidental data loss
- 🎨 Colored output for better readability

### Options

- `--limit NUMBER` - Number of commits to display from reflog (default: 20)
- `--log-limit NUMBER` - Number of commits to display in current log (default: 5)
- `--search KEYWORD` - Search commits by keyword
- `--no-warning` - Skip warning messages

## Development Guide

### Setup Development Environment

```bash
git clone https://github.com/rubykachu/git_oops.git
cd git_oops
bin/setup
```

### Debug

1. Add `require 'pry'` to your code
2. Insert breakpoint with `binding.pry`
3. Run gem with `bundle exec exe/goops reset`

### Test Changes Without Reinstalling

```bash
# Run directly from source
bundle exec exe/goops reset [options]

# Or create alias for development
alias gdev="bundle exec exe/goops"
gdev reset [options]
```

### Release Process

1. Update version in `lib/git_oops/version.rb`
2. Update `CHANGELOG.md`
3. Run release script:
```bash
bin/release
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rubykachu/git_oops.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
