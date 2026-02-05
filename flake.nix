{
  description = "kioku's dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, ... }:
    let
      mkHome = { system, username, modules }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = modules;
          extraSpecialArgs = { inherit username; };
        };
    in
    {
      homeConfigurations = {
        "ops@nix" = mkHome {
          system = "x86_64-linux";
          username = "ops";
          modules = [ ./hosts/nix.nix ];
        };
        "kioku@macbook" = mkHome {
          system = "x86_64-darwin";
          username = "kioku";
          modules = [ ./hosts/macbook.nix ];
        };
      };

      packages.x86_64-linux.configs =
        nixpkgs.legacyPackages.x86_64-linux.runCommand "dotfiles-configs" { } ''
          mkdir -p $out/.config/git

          cp ${./gitconfig} $out/.gitconfig
          cp ${./gitmessage} $out/.gitmessage
          cp ${./tmux.conf} $out/.tmux.conf
          cp ${./editorconfig} $out/.editorconfig
          cp -r ${./config/git}/* $out/.config/git/
        '';
    };
}
