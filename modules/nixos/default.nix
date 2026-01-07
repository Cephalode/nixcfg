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
    ./security.nix
    ./games.nix
    ./applications.nix
  ];

  programs = {
    zsh.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;
}
