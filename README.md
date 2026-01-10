# dotfiles

Personal dotfiles for macOS.

## Current Setup

- **Shell**: Nushell
- **Prompt**: Starship (pure preset)
- **Editor**: Neovim with LazyVim
- **Multiplexer**: tmux
- **Navigation**: zoxide
- **Node management**: fnm

## Structure

```
dotfiles/
├── config/
│   ├── nvim/              # Neovim configuration (LazyVim-based)
│   │   ├── init.lua
│   │   └── lua/
│   │       ├── config/    # LazyVim config overrides
│   │       └── plugins/   # Custom plugin specs
│   ├── nushell/           # Nushell shell configuration
│   │   ├── config.nu
│   │   └── env.nu
│   ├── git/
│   │   └── ignore         # Global gitignore
│   └── starship.toml      # Prompt configuration
├── scripts/               # Utility scripts
├── Brewfile               # Homebrew packages
├── setup.sh               # Setup script
├── tmux.conf              # Tmux configuration
├── gitconfig              # Git configuration
├── gitmessage             # Commit message template
├── bashrc                 # Bash config (launches nushell)
└── zshrc                  # Zsh config (launches nushell)
```

## Installation

### Prerequisites

Install via Homebrew:

```sh
brew install nushell starship zoxide neovim tmux
brew install fnm bun  # optional
```

Or install everything from the Brewfile:

```sh
brew bundle install --file=~/dotfiles/Brewfile
```

### Setup

1. Clone the repository:
   ```sh
   git clone https://github.com/kioku/dotfiles.git ~/dotfiles
   ```

2. Run the setup script:
   ```sh
   ~/dotfiles/setup.sh
   ```

The script will:
- Check for required prerequisites
- Create symlinks (backing up existing files)
- Set up the secrets file

## Neovim

The Neovim configuration is based on [LazyVim](https://www.lazyvim.org/) with custom plugins:

- **codecompanion.nvim**: AI assistant with Copilot backend
- **LSP overrides**: Deno/TypeScript conflict resolution (denols vs tsserver)
- **lazygit**: Nushell-compatible editor integration

Plugin lock files (`lazy-lock.json`, `lazyvim.json`) are gitignored as they're machine-specific.

On first launch, lazy.nvim will bootstrap and install all plugins automatically.

## Secrets

API keys and credentials are stored in `~/.secrets.nu` which is sourced by nushell but not tracked in git. Example:

```nu
$env.SOME_API_KEY = "your-key-here"
```

## Brewfile

The `Brewfile` captures the complete set of Homebrew packages, casks, and cargo tools installed on this system. Use it to replicate the full development environment:

```sh
# Install everything
brew bundle install --file=~/dotfiles/Brewfile

# Check what would be installed
brew bundle check --file=~/dotfiles/Brewfile
```

## Legacy Configs

Legacy vim, zsh, and prezto configs are preserved in the `archive/legacy-configs` branch.
