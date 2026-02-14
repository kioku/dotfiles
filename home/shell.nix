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
  xdg.configFile."nushell/wt.nu" = lib.mkIf (!isDarwin) {
    source = ../config/nushell/wt.nu;
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
  home.file."Library/Application Support/nushell/wt.nu" = lib.mkIf isDarwin {
    source = ../config/nushell/wt.nu;
  };
  home.file."Library/Application Support/nushell/git-completions.nu" = lib.mkIf isDarwin {
    source = ../config/nushell/git-completions.nu;
  };

  xdg.configFile."atuin/config.toml".source = ../config/atuin/config.toml;
  xdg.configFile."wt/wt.bash".source = ../config/wt/wt.bash;
  xdg.configFile."wt/wt.zsh".source = ../config/wt/wt.zsh;

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

  # JJ completion lives outside Home Manager's file management so activation
  # can overwrite it with `jj util completion nushell` when jj is installed.
  # A stub is created on first activation so nushell always starts.
  home.activation.generateCompletions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    NUSHELL_DIR="$HOME/${nushellConfigDir}"

    # Ensure directory exists
    mkdir -p "$NUSHELL_DIR"

    # Ensure a stub exists so nushell starts even without jj.
    if [ ! -f "$NUSHELL_DIR/jj-completions.nu" ]; then
      echo "# Stub: regenerated at activation time if the tool is available." \
        > "$NUSHELL_DIR/jj-completions.nu"
    fi

    # Generate real jj completions when the tool is present
    if command -v jj >/dev/null 2>&1; then
      jj util completion nushell > "$NUSHELL_DIR/jj-completions.nu"
    fi
  '';
}
