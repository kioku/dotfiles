{ pkgs, ... }: {
  imports = [ ../home ];

  # Karabiner: macOS-only. Under Home Manager this becomes a read-only
  # symlink into the Nix store — Karabiner-Elements can no longer write
  # to it in place. Config changes must go through the repo.
  xdg.configFile."karabiner/karabiner.json".source =
    ../config/karabiner/karabiner.json;

  home.packages = with pkgs; [
    colima
    podman
  ];
}
