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
├── gitconfig          # Git configuration
├── gitignore_global   # Legacy global gitignore
├── gitmessage         # Commit message template
├── bashrc             # Bash fallback config
├── zshrc              # Zsh config (launches nushell)
├── zshenv             # Zsh environment
├── zprofile           # Zsh profile
└── scripts/           # Utility scripts
```

## Installation

### Prerequisites

- [Nushell](https://www.nushell.sh/)
- [Starship](https://starship.rs/)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- [fnm](https://github.com/Schniz/fnm)

### Setup

1. Clone the repository:
   ```sh
   git clone https://github.com/kioku/dotfiles.git ~/dotfiles
   ```

2. Create symlinks for nushell config:
   ```sh
   ln -sf ~/dotfiles/config/nushell/config.nu ~/Library/Application\ Support/nushell/config.nu
   ln -sf ~/dotfiles/config/nushell/env.nu ~/Library/Application\ Support/nushell/env.nu
   ```

3. Create symlinks for other configs:
   ```sh
   ln -sf ~/dotfiles/config/starship.toml ~/.config/starship.toml
   ln -sf ~/dotfiles/config/git/ignore ~/.config/git/ignore
   ln -sf ~/dotfiles/gitconfig ~/.gitconfig
   ```

4. Create secrets file (not tracked):
   ```sh
   touch ~/.secrets.nu
   # Add your API keys and secrets to this file
   ```

## Secrets

API keys and credentials are stored in `~/.secrets.nu` which is sourced by nushell but not tracked in git. Example:

```nu
$env.SOME_API_KEY = "your-key-here"
```

## Legacy Configs

Legacy vim, tmux, and prezto configs are preserved in the `archive/legacy-configs` branch.

## Neovim

Neovim configuration uses LazyVim and is managed separately at `~/.config/nvim/`.
