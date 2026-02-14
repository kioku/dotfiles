# .zshrc

# Launch nushell automatically for interactive shells
if [[ $- == *i* ]] && command -v nu > /dev/null 2>&1; then
    export SHELL=nu
    exec nu
fi

# If we reach here, nushell is not available - set up zsh environment

# Cargo
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Local bin (Claude Code)
export PATH="$HOME/.local/bin:$PATH"
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# Bun
export PATH="$HOME/.bun/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && . "$HOME/.bun/_bun"

# .NET
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH"

# Source secrets if available
[ -f "$HOME/.secrets" ] && . "$HOME/.secrets"

# wt fallback binding (when running zsh directly)
if command -v wt-core > /dev/null 2>&1 && [ -f "$HOME/.config/wt/wt.zsh" ]; then
    . "$HOME/.config/wt/wt.zsh"
fi
