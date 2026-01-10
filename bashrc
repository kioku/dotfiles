# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# User specific aliases and functions
# source .bash_exports
. "$HOME/.cargo/env"

. "$HOME/.local/bin/env"

# Source secrets if available
[ -f "$HOME/.secrets" ] && . "$HOME/.secrets"
