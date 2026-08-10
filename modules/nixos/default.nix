{
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ../common
    ./devices
    ./niri.nix
    ./niri
    ./security.nix
    ./games.nix
    ./applications.nix
    ./physical.nix
  ];

  programs = {
    zsh.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;
}
