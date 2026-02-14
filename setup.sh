#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ------------------------------------------------------------------------------
# Prerequisite checks
# ------------------------------------------------------------------------------

check_command() {
    local cmd="$1"
    local install_hint="$2"
    if command -v "$cmd" > /dev/null 2>&1; then
        info "$cmd: $(command -v "$cmd")"
        return 0
    else
        warn "$cmd: not found - $install_hint"
        return 1
    fi
}

check_prerequisites() {
    info "Checking prerequisites..."
    echo

    local missing=0

    # Required
    check_command "brew" "Install from https://brew.sh" || missing=$((missing + 1))
    check_command "nu" "brew install nushell" || missing=$((missing + 1))
    check_command "starship" "brew install starship" || missing=$((missing + 1))
    check_command "zoxide" "brew install zoxide" || missing=$((missing + 1))
    check_command "nvim" "brew install neovim" || missing=$((missing + 1))

    # Optional but recommended
    echo
    info "Optional tools:"
    check_command "tmux" "brew install tmux" || true
    check_command "fnm" "brew install fnm" || true
    check_command "bun" "brew install bun" || true
    check_command "cargo" "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh" || true
    check_command "wt-core" "cargo install wt-core" || true

    echo
    if [[ $missing -gt 0 ]]; then
        error "$missing required tool(s) missing. Install them and re-run."
        return 1
    fi

    info "All required prerequisites found."
    return 0
}

# ------------------------------------------------------------------------------
# Symlink helpers
# ------------------------------------------------------------------------------

create_symlink() {
    local src="$1"
    local dest="$2"

    # Create parent directory if needed
    mkdir -p "$(dirname "$dest")"

    if [[ -L "$dest" ]]; then
        local current_target
        current_target=$(readlink "$dest")
        if [[ "$current_target" == "$src" ]]; then
            info "Already linked: $dest"
            return 0
        else
            warn "Removing old symlink: $dest -> $current_target"
            rm "$dest"
        fi
    elif [[ -e "$dest" ]]; then
        warn "Backing up existing file: $dest -> $dest.backup"
        mv "$dest" "$dest.backup"
    fi

    ln -s "$src" "$dest"
    info "Linked: $dest -> $src"
}

# ------------------------------------------------------------------------------
# Setup functions
# ------------------------------------------------------------------------------

setup_symlinks() {
    info "Creating symlinks..."
    echo

    # Nushell config
    local nushell_config_dir="$HOME/Library/Application Support/nushell"
    create_symlink "$DOTFILES_DIR/config/nushell/config.nu" "$nushell_config_dir/config.nu"
    create_symlink "$DOTFILES_DIR/config/nushell/env.nu" "$nushell_config_dir/env.nu"
    create_symlink "$DOTFILES_DIR/config/nushell/git-completions.nu" "$nushell_config_dir/git-completions.nu"
    create_symlink "$DOTFILES_DIR/config/nushell/jj-completions.nu" "$nushell_config_dir/jj-completions.nu"

    # Starship
    create_symlink "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml"

    # Git
    create_symlink "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"
    create_symlink "$DOTFILES_DIR/gitmessage" "$HOME/.gitmessage"
    create_symlink "$DOTFILES_DIR/gitignore_global" "$HOME/.gitignore_global"

    # EditorConfig
    create_symlink "$DOTFILES_DIR/editorconfig" "$HOME/.editorconfig"

    # Karabiner
    create_symlink "$DOTFILES_DIR/config/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"

    # Direnv
    create_symlink "$DOTFILES_DIR/config/direnv/direnv.toml" "$HOME/.config/direnv/direnv.toml"

    # Shell configs (both launch nushell for interactive sessions)
    create_symlink "$DOTFILES_DIR/bashrc" "$HOME/.bashrc"
    create_symlink "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"

    # Tmux
    create_symlink "$DOTFILES_DIR/tmux.conf" "$HOME/.tmux.conf"

    # Neovim (symlink entire config directory)
    create_symlink "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"

    echo
    info "Symlinks complete."
}

setup_secrets() {
    local secrets_file="$HOME/.secrets.nu"

    if [[ -f "$secrets_file" ]]; then
        info "Secrets file exists: $secrets_file"
    else
        info "Creating empty secrets file: $secrets_file"
        cat > "$secrets_file" << 'EOF'
# ~/.secrets.nu
# Add your API keys and secrets here
# This file is sourced by nushell but not tracked in git
#
# Example:
# $env.SOME_API_KEY = "your-key-here"
EOF
        chmod 600 "$secrets_file"
        info "Created $secrets_file (mode 600)"
    fi
}

setup_wt_core() {
    info "Ensuring wt-core is installed..."

    if command -v wt-core > /dev/null 2>&1; then
        info "wt-core already installed: $(command -v wt-core)"
        return 0
    fi

    if ! command -v cargo > /dev/null 2>&1; then
        warn "cargo not found; skipping wt-core install"
        warn "Install Rust/cargo, then run: cargo install wt-core"
        return 0
    fi

    info "Installing wt-core from crates.io..."
    if cargo install wt-core; then
        info "wt-core installed successfully"
    else
        warn "wt-core install failed; continuing with stub binding"
    fi
}

setup_nushell_completions() {
    local completions_dir
    if [[ "$(uname)" == "Darwin" ]]; then
        completions_dir="$HOME/Library/Application Support/nushell"
    else
        completions_dir="$HOME/.config/nushell"
    fi

    mkdir -p "$completions_dir"

    # Check if completions exist
    if [[ ! -f "$completions_dir/git-completions.nu" ]]; then
        warn "git-completions.nu not found in $completions_dir"
    fi

    if [[ ! -f "$completions_dir/jj-completions.nu" ]]; then
        warn "jj-completions.nu not found in $completions_dir"
        warn "Generate with: jj util completion nushell > $completions_dir/jj-completions.nu"
    fi

    # Generate wt-core Nu binding (or a startup-safe stub if wt-core is absent)
    local wt_nu="$completions_dir/wt.nu"

    # Migrate from older symlink-based setup.
    if [[ -L "$wt_nu" ]]; then
        rm -f "$wt_nu"
    fi

    if command -v wt-core > /dev/null 2>&1; then
        wt-core init nu > "$wt_nu"
        info "Generated wt-core Nushell binding: $wt_nu"
    else
        cat > "$wt_nu" << 'EOF'
# Stub: generated when wt-core is not available.
def wt [...args: string] {
  print "wt-core is not installed; install wt-core to enable wt commands."
}
EOF
        warn "wt-core not found; wrote stub binding to $wt_nu"
    fi
}

setup_ai_tools() {
    info "Setting up AI coding tools..."
    echo

    # Claude Code
    if command -v claude > /dev/null 2>&1; then
        info "Claude Code already installed: $(command -v claude)"
    else
        info "Installing Claude Code..."
        curl -fsSL https://claude.ai/install.sh | bash
    fi

    # Check for Node.js (required for npm packages)
    if ! command -v node > /dev/null 2>&1; then
        warn "Node.js not found. Install via fnm first:"
        warn "  fnm install --lts && fnm use --lts"
        return 1
    fi

    # Codex CLI
    if command -v codex > /dev/null 2>&1; then
        info "Codex already installed: $(command -v codex)"
    else
        info "Installing Codex..."
        npm install -g @openai/codex
    fi

    # pi coding agent
    if command -v pi > /dev/null 2>&1; then
        info "pi already installed: $(command -v pi)"
    else
        info "Installing pi coding agent..."
        npm install -g @mariozechner/pi-coding-agent
    fi

    echo
    info "AI tools setup complete."
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

main() {
    echo
    echo "=========================================="
    echo "  Dotfiles Setup"
    echo "=========================================="
    echo

    check_prerequisites || exit 1
    echo

    setup_symlinks
    echo

    setup_secrets
    echo

    setup_wt_core
    echo

    setup_nushell_completions
    echo

    setup_ai_tools
    echo

    echo "=========================================="
    info "Setup complete!"
    echo "=========================================="
    echo
    info "Next steps:"
    echo "  1. Review/edit ~/.secrets.nu with your API keys"
    echo "  2. Restart your shell or run: exec nu"
    echo
}

main "$@"
