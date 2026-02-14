# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# Make wt (and other shell functions) available in non-interactive bash.
# Bash only sources .bashrc for interactive shells; non-interactive ones
# look at BASH_ENV instead.  Exporting it here means nushell (and every
# process it spawns) passes it through to child bash invocations.
export BASH_ENV="$HOME/.bash_env"

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
if command -v wt-core > /dev/null 2>&1; then
    eval "$(wt-core init bash)"
fi
