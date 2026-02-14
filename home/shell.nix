{ config, pkgs, lib, aperturePkg ? null, ... }:
let
  isDarwin = pkgs.stdenv.isDarwin;
  nushellConfigDir =
    if isDarwin then "Library/Application Support/nushell"
    else ".config/nushell";

  wtCore = pkgs.rustPlatform.buildRustPackage rec {
    pname = "wt-core";
    version = "0.1.0";

    src = pkgs.fetchFromGitHub {
      owner = "kioku";
      repo = "wt-core";
      rev = "v${version}";
      hash = "sha256-f+LjAoD071qvBjLsBxyuwfQIK6tk93MjYpjniZ5El4o=";
    };

    cargoHash = "sha256-6NqH9lFqHUT+UubMRgkZvkqKza397Gb/yaEHTiEt4kI=";
    doCheck = false;

    meta = with lib; {
      description = "Portable Git worktree lifecycle manager";
      homepage = "https://github.com/kioku/wt-core";
      license = licenses.mit;
      platforms = platforms.unix;
    };
  };
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
      wtCore
    ])
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

    # --- wt-core Nushell binding ---
    if command -v wt-core >/dev/null 2>&1; then
      wt-core init nu > "$WT_NU"
    else
      cat > "$WT_NU" <<'EOF'
# Stub: generated when wt-core is not available.
def wt [...args: string] {
  print "wt-core is not installed; install wt-core to enable wt commands."
}
EOF
    fi
  '';
}
