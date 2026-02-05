{ pkgs, ... }: {
  home.packages = with pkgs; [
    git
    gh
    delta
    lazygit
  ];

  home.file.".gitconfig".source = ../gitconfig;
  home.file.".gitmessage".source = ../gitmessage;
  xdg.configFile."git/ignore".source = ../config/git/ignore;
}
