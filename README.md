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
# Basic usage - shows last 20 commits
goops reset

# Show more commits
goops reset --limit 30

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

- `--limit NUMBER` - Number of commits to display (default: 20)
- `--search KEYWORD` - Search commits by keyword
- `--no-warning` - Skip warning messages

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/TOMOSIA-VIETNAM/git_oops.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
