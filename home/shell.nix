{ config, pkgs, lib, aperturePkg ? null, wtCorePkg ? null, ... }:
let
  isDarwin = pkgs.stdenv.isDarwin;
  nushellConfigDir =
    if isDarwin then "Library/Application Support/nushell"
    else ".config/nushell";
in
{
  home.packages =
    (with pkgs; [
      nushell
      starship
      zoxide
      atuin
      bat
      eza
      fd
      fzf
      ripgrep
      jq
      tree
    ])
    ++ lib.optional (wtCorePkg != null) wtCorePkg
    ++ lib.optional (aperturePkg != null) aperturePkg;

  # Linux: ~/.config/nushell/
  xdg.configFile."nushell/config.nu" = lib.mkIf (!isDarwin) {
    source = ../config/nushell/config.nu;
  };
  xdg.configFile."nushell/env.nu" = lib.mkIf (!isDarwin) {
    source = ../config/nushell/env.nu;
  };
  xdg.configFile."nushell/git-completions.nu" = lib.mkIf (!isDarwin) {
    source = ../config/nushell/git-completions.nu;
  };

  # macOS: ~/Library/Application Support/nushell/
  home.file."Library/Application Support/nushell/config.nu" = lib.mkIf isDarwin {
    source = ../config/nushell/config.nu;
  };
  home.file."Library/Application Support/nushell/env.nu" = lib.mkIf isDarwin {
    source = ../config/nushell/env.nu;
  };
  home.file."Library/Application Support/nushell/git-completions.nu" = lib.mkIf isDarwin {
    source = ../config/nushell/git-completions.nu;
  };

  xdg.configFile."atuin/config.toml".source = ../config/atuin/config.toml;

  home.file.".bashrc".source = ../bashrc;
  home.file.".zshrc".source = ../zshrc;

  # Ensure ~/.secrets.nu exists (sourced by env.nu, contains real secrets
  # so it must live outside the Nix store).
  home.activation.ensureSecrets = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f "$HOME/.secrets.nu" ]; then
      touch "$HOME/.secrets.nu"
      chmod 600 "$HOME/.secrets.nu"
    fi
  '';

  # Runtime-generated Nushell integrations live outside Home Manager's
  # declarative file set so activation can refresh them based on installed
  # tools (jj, wt-core) without fighting HM-managed symlinks.
  home.activation.generateRuntimeIntegrations = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    NUSHELL_DIR="$HOME/${nushellConfigDir}"
    WT_NU="$NUSHELL_DIR/wt.nu"

    # Ensure directory exists
    mkdir -p "$NUSHELL_DIR"

    # Migrate from older symlink-based setup: generated files must be regular
    # files owned in $HOME, not symlinks into tracked dotfiles paths.
    if [ -L "$WT_NU" ]; then
      rm -f "$WT_NU"
    fi

    # --- JJ completion ---
    if [ ! -f "$NUSHELL_DIR/jj-completions.nu" ]; then
      echo "# Stub: regenerated at activation time if the tool is available." \
        > "$NUSHELL_DIR/jj-completions.nu"
    fi

    if command -v jj >/dev/null 2>&1; then
      jj util completion nushell > "$NUSHELL_DIR/jj-completions.nu"
    fi

    # --- Resolve wt-core binary ---
    # Prefer the Nix store path (available at build time), but fall back to
    # any wt-core on PATH (e.g. installed via cargo) so the bindings are
    # generated even when the Nix package isn't wired up.
    WT_CORE=""
    ${if wtCorePkg != null then ''
      WT_CORE="${wtCorePkg}/bin/wt-core"
    '' else ''
      if command -v wt-core >/dev/null 2>&1; then
        WT_CORE="$(command -v wt-core)"
      fi
    ''}

    # --- wt-core Nushell binding ---
    if [ -n "$WT_CORE" ]; then
      "$WT_CORE" init nu > "$WT_NU"
    else
      cat > "$WT_NU" <<'EOF'
# Stub: generated when wt-core is not available.
def wt [...args: string] {
  print "wt-core is not installed; install wt-core to enable wt commands."
}
EOF
    fi

    # --- wt-core Bash binding (for non-interactive shells via BASH_ENV) ---
    BASH_ENV_FILE="$HOME/.bash_env"
    if [ -n "$WT_CORE" ]; then
      "$WT_CORE" init bash > "$BASH_ENV_FILE"
    else
      echo "# Stub: wt-core not available." > "$BASH_ENV_FILE"
    fi

    # --- Agent-safe editor defaults ---
    # Non-interactive bash without a TTY is almost certainly an agent
    # subprocess. Override EDITOR/VISUAL/GIT_EDITOR to a no-op so that
    # git and other tools never block waiting for a human.
    cat >> "$BASH_ENV_FILE" <<'EDITOR_GUARD'

# Agent-safe editor: default to no-op when there is no terminal
if [ ! -t 0 ]; then
    export EDITOR="true"
    export VISUAL="true"
    export GIT_EDITOR="true"
fi
EDITOR_GUARD
  '';
}
