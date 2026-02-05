{ config, pkgs, username, ... }: {
  imports = [
    ./shell.nix
    ./editor.nix
    ./git.nix
    ./tmux.nix
    ./dev.nix
  ];

  home.username = username;
  home.homeDirectory =
    if pkgs.stdenv.isDarwin then "/Users/${username}"
    else "/home/${username}";
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  xdg.configFile."starship.toml".source = ../config/starship.toml;
  xdg.configFile."direnv/direnv.toml".source = ../config/direnv/direnv.toml;
  home.file.".editorconfig".source = ../editorconfig;
}
