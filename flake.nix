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
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      inherit (self) outputs;

      # Inputs for NixOS GUI hosts (hapalo, loligo)
      guiNixosInputs = { inherit (inputs) nixpkgs nixpkgs-stable noctalia zen-browser; };
      # Inputs for NixOS WSL host (lunalata) — no noctalia (no GUI)
      wslNixosInputs = { inherit (inputs) nixpkgs nixpkgs-stable zen-browser nixos-wsl; };
      # Inputs for macOS host (metasepia)
      darwinInputs = { inherit (inputs) nixpkgs nix-homebrew homebrew-core homebrew-cask zen-browser; };
    in
    {
      nixosConfigurations = {
        loligo = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit outputs;
            inputs = guiNixosInputs;
          };
          modules = [
            ./hosts/nixos/loligo
            ./modules/nixos
          ];
        };

        lunalata = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit outputs;
            inputs = wslNixosInputs;
          };
          modules = [
            ./hosts/nixos/lunalata
            ./modules/common
          ];
        };

        hapalo = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit outputs;
            inputs = guiNixosInputs;
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
