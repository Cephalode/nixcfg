{ inputs, config, pkgs, lib, ... }:
let
  myNixCats = import ../../../../nvim { inherit inputs; };
in
{
  environment.systemPackages = with pkgs; [
    myNixCats.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Language servers
    python313Packages.pylsp-mypy
    lua-language-server
    typescript-language-server
    nil # Nix language server
  ];
}

