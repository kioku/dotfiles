{ pkgs, ... }: {
  home.packages = with pkgs; [
    deno
    just
    hyperfine
    cloc
    glow
    btop
    nmap
  ];
}
