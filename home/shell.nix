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
  xdg.configFile."nushell/git-completions.nu" = lib.mkIf (!isDarwin) {
    source = ../config/nushell/git-completions.nu;
  };
  xdg.configFile."nushell/jj-completions.nu" = lib.mkIf (!isDarwin) {
    source = ../config/nushell/jj-completions.nu;
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
  home.file."Library/Application Support/nushell/jj-completions.nu" = lib.mkIf isDarwin {
    source = ../config/nushell/jj-completions.nu;
  };

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

  # Regenerate shell completions from installed tools. The repo ships stubs
  # so nushell always starts, but real completions are richer.
  home.activation.generateCompletions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    NUSHELL_DIR="$HOME/${nushellConfigDir}"
    if command -v jj >/dev/null 2>&1; then
      jj util completion nushell > "$NUSHELL_DIR/jj-completions.nu"
    fi
  '';
}
