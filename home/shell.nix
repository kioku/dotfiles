{ config, pkgs, lib, ... }:
let
  isDarwin = pkgs.stdenv.isDarwin;
  nushellConfigDir =
    if isDarwin then "Library/Application Support/nushell"
    else ".config/nushell";
in
{
  home.packages = with pkgs; [
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
  ];

  # Linux: ~/.config/nushell/
  xdg.configFile."nushell/config.nu" = lib.mkIf (!isDarwin) {
    source = ../config/nushell/config.nu;
  };
  xdg.configFile."nushell/env.nu" = lib.mkIf (!isDarwin) {
    source = ../config/nushell/env.nu;
  };

  # macOS: ~/Library/Application Support/nushell/
  home.file."Library/Application Support/nushell/config.nu" = lib.mkIf isDarwin {
    source = ../config/nushell/config.nu;
  };
  home.file."Library/Application Support/nushell/env.nu" = lib.mkIf isDarwin {
    source = ../config/nushell/env.nu;
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

  # Completion files live outside Home Manager's file management so that
  # activation scripts can overwrite them without fighting HM symlinks.
  # On first activation, stubs are created so nushell can always start.
  # When the backing tool is available, real completions replace the stub.
  home.activation.generateCompletions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    NUSHELL_DIR="$HOME/${nushellConfigDir}"

    # Ensure directory exists
    mkdir -p "$NUSHELL_DIR"

    # Ensure stubs exist so nushell starts even without the tools
    if [ ! -f "$NUSHELL_DIR/git-completions.nu" ]; then
      echo "# Stub: regenerated at activation time if the tool is available." \
        > "$NUSHELL_DIR/git-completions.nu"
    fi
    if [ ! -f "$NUSHELL_DIR/jj-completions.nu" ]; then
      echo "# Stub: regenerated at activation time if the tool is available." \
        > "$NUSHELL_DIR/jj-completions.nu"
    fi

    # Generate real completions when tools are present
    if command -v git >/dev/null 2>&1; then
      # nushell ships a built-in git completions module via std; use it
      echo "use std/completions/git *" > "$NUSHELL_DIR/git-completions.nu"
    fi
    if command -v jj >/dev/null 2>&1; then
      jj util completion nushell > "$NUSHELL_DIR/jj-completions.nu"
    fi
  '';
}
