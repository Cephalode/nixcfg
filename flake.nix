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
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      inherit (self) outputs;

      nixosInputs = {
        inherit (inputs)
          nixpkgs
          nixpkgs-stable

          neovim-nightly-overlay
          nvf
          noctalia
          zen-browser
          ;
      };

      darwinInputs = {
        inherit (inputs)
          nixpkgs
          nix-darwin
          nix-homebrew
          homebrew-core
          homebrew-cask

          neovim-nightly-overlay
          nvf
          zen-browser
          ;
      };
    in
    {
      nixosConfigurations = {
        loligo = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit outputs;
            inputs = nixosInputs;
          };
          modules = [
            ./hosts/nixos/loligo
            ./modules/nixos
          ];
        };

        hapalo = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit outputs;
            inputs = nixosInputs;
          };
          modules = [
            ./hosts/nixos/hapalo
            ./modules/nixos
          ];
        };
      };

      darwinConfigurations = {
        metasepia = inputs.nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {
            inherit outputs;
            inputs = darwinInputs;
          };
          modules = [
            ./hosts/metasepia
            ./modules/macos
          ];
        };
      };
    };
}
