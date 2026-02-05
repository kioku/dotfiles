# dotfiles

Personal dotfiles for macOS and NixOS.

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
├── home/                  # Home Manager modules
│   ├── default.nix        # Common profile (username, homeDirectory, imports)
│   ├── shell.nix          # Nushell, starship, zoxide, atuin, CLI tools
│   ├── editor.nix         # Neovim
│   ├── git.nix            # Git, gh, delta, lazygit
│   ├── tmux.nix           # tmux
│   └── dev.nix            # Dev tooling (deno, just, btop, etc.)
├── hosts/                 # Per-machine profiles
│   ├── nix.nix            # NixOS server (ops@ax-foundry)
│   └── macbook.nix        # macOS (dormant — not active on current machine)
├── config/
│   ├── nvim/              # Neovim configuration (LazyVim-based)
│   │   ├── init.lua
│   │   └── lua/
│   │       ├── config/    # LazyVim config overrides
│   │       └── plugins/   # Custom plugin specs
│   ├── nushell/           # Nushell shell configuration
│   │   ├── config.nu
│   │   └── env.nu
│   ├── direnv/
│   │   └── direnv.toml    # Direnv configuration
│   ├── git/
│   │   └── ignore         # Global gitignore
│   ├── karabiner/         # Karabiner-Elements (macOS)
│   │   └── karabiner.json
│   └── starship.toml      # Prompt configuration
├── scripts/               # Utility scripts
├── Brewfile               # Homebrew packages (macOS)
├── setup.sh               # Setup script (macOS, without Nix)
├── flake.nix              # Nix flake (Home Manager + config export)
├── flake.lock             # Pinned flake inputs
├── tmux.conf              # Tmux configuration
├── gitconfig              # Git configuration
├── gitmessage             # Commit message template
├── editorconfig           # EditorConfig
├── bashrc                 # Bash config (launches nushell)
└── zshrc                  # Zsh config (launches nushell)
```

## Deployment

`setup.sh` and Home Manager are mutually exclusive at the point of activation
— a machine uses one or the other, never both simultaneously.

### macOS (without Nix) — current approach

```sh
./setup.sh
```

### NixOS / Linux with Nix

```sh
home-manager switch --flake github:kioku/dotfiles#ops@nix
```

### macOS with Nix (available, not active)

```sh
home-manager switch --flake ~/dotfiles#kioku@macbook
```

### Minimal server (no Nix)

Export only the essential config files (git, tmux, editorconfig) from a
Nix-capable machine, then deploy with rsync:

```sh
nix build github:kioku/dotfiles#configs
rsync -av result/ remote:~/
```

## Installation (macOS without Nix)

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
