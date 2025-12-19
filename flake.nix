{
  description = ''
    The Nix configuration flake for the Cephalode family of systems.

    This flake is based off the configuration of m3tam3re:
    - X: https://twitter.com/@m3tam3re
    - YouTube: https://www.youtube.com/@m3tam3re
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    nvim = {
      url = "path:./modules/common/terminal/nixCats";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
        flake = false;
      };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nix-darwin, nix-homebrew, homebrew-core, homebrew-cask, nvim, ... }@inputs:
    let
      inherit (self) outputs;
      systems = [
        "x86_64-linux" # Laptop/Desktop
        "aarch64-darwin" # Mac
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      nixosConfigurations = {
        loligo = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [ 
            ./hosts/nixos/loligo 
          ];
        };

        hapalo = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./hosts/nixos/hapalo
          ];
        };
      };

      darwinConfigurations = {
        metasepia = nix-darwin.lib.darwinSystem {
          specialArgs = { inherit self inputs outputs; };
          modules = [
            ./hosts/metasepia
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                enable = true;
                # enableRosetta = true;
                user = "sqibo";
                autoMigrate = true;
              };
            }
          ];
        };
      };
    };
}
