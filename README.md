# dotfiles

Personal dotfiles for macOS.

## Current Setup

- **Shell**: Nushell
- **Prompt**: Starship (pure preset)
- **Editor**: Neovim with LazyVim
- **Navigation**: zoxide
- **Node management**: fnm

## Structure

```
dotfiles/
├── config/
│   ├── nushell/       # Nushell shell configuration
│   │   ├── config.nu
│   │   └── env.nu
│   ├── git/
│   │   └── ignore     # Global gitignore
│   └── starship.toml  # Prompt configuration
├── scripts/           # Utility scripts
├── setup.sh           # Setup script
├── gitconfig          # Git configuration
├── gitmessage         # Commit message template
└── bashrc             # Bash fallback config
```

## Installation

### Prerequisites

Install via Homebrew:

```sh
brew install nushell starship zoxide neovim
brew install fnm bun  # optional
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

## Secrets

API keys and credentials are stored in `~/.secrets.nu` which is sourced by nushell but not tracked in git. Example:

```nu
$env.SOME_API_KEY = "your-key-here"
```

## Legacy Configs

Legacy vim, tmux, zsh, and prezto configs are preserved in the `archive/legacy-configs` branch.

## Neovim

Neovim configuration uses LazyVim and is managed separately at `~/.config/nvim/`.
