{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    python3
    zig # Zig and C compiler (faster than any other C compiler)

    nixfmt-rfc-style # nix formatter
  ];
}
