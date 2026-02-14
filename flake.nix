{
  description = "kioku's dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # TODO: consume when macOS profile becomes active
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    aperture.url = "github:kioku/aperture";
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, aperture, ... }:
    let
      mkHome = { system, username, modules }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = modules;
          extraSpecialArgs = {
            inherit username;
            aperturePkg = aperture.packages.${system}.default;
          };
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
          system = "aarch64-darwin";
          username = "kioku";
          modules = [ ./hosts/macbook.nix ];
        };
      };

      packages = let
        mkConfigs = system:
          nixpkgs.legacyPackages.${system}.runCommand "dotfiles-configs" { } ''
            mkdir -p $out/.config/git

            cp ${./gitconfig} $out/.gitconfig
            cp ${./gitmessage} $out/.gitmessage
            cp ${./tmux.conf} $out/.tmux.conf
            cp ${./editorconfig} $out/.editorconfig
            cp -r ${./config/git}/* $out/.config/git/
          '';
      in nixpkgs.lib.genAttrs
        [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ]
        (system: { configs = mkConfigs system; });
    };
}
