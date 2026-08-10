{
  description = ''
    The Nix configuration flake for the Cephalode family of systems.

    This flake is based off the configuration of m3tam3re:
    - X: https://twitter.com/@m3tam3re
    - YouTube: https://www.youtube.com/@m3tam3re
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Fallback: pin to stable here so if unstable breaks a package,
    # we can quickly add an overlay pulling from stable.
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
    };
    zen-spaces = {
      url = "github:Cephalode/zen-spaces";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bedrock-on-linux = {
      url = "github:Cephalode/BedrockOnLinux";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wrappers = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      inherit (self) outputs;

      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      mkNixosHost = { host, moduleSet }: nixpkgs.lib.nixosSystem {
        specialArgs = { inherit outputs inputs; };
        modules = [ ./hosts/nixos/${host} moduleSet ];
      };
    in
    {
      packages = forAllSystems (system: {
        nvim = inputs.wrappers.lib.evalPackage [
          ./modules/common/development/neovim/module.nix
          { pkgs = import nixpkgs { inherit system; }; }
        ];
      });

      nixosConfigurations = {
        hapalo = mkNixosHost { host = "hapalo"; moduleSet = ./modules/nixos; };
        loligo = mkNixosHost { host = "loligo"; moduleSet = ./modules/nixos; };
        lunalata = mkNixosHost { host = "lunalata"; moduleSet = ./modules/common; };
      };

      darwinConfigurations = {
        metasepia = inputs.nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {
            inherit outputs inputs;
          };
          modules = [
            ./hosts/metasepia
            ./modules/macos
          ];
        };
      };
    };
}
