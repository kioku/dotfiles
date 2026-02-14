# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# Launch nushell automatically for interactive shells
if [[ $- == *i* ]] && command -v nu > /dev/null 2>&1; then
    export SHELL=nu
    exec nu
fi

# If we reach here, nushell is not available - set up bash environment

# Cargo
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Local bin
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# Bun
export PATH="$HOME/.bun/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && . "$HOME/.bun/_bun"

# Source secrets if available
[ -f "$HOME/.secrets" ] && . "$HOME/.secrets"

# wt fallback binding (when running bash directly)
if command -v wt-core > /dev/null 2>&1 && [ -f "$HOME/.config/wt/wt.bash" ]; then
    . "$HOME/.config/wt/wt.bash"
fi
