{
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ../common
    ./niri.nix
    ./kb.nix
    ./audio.nix
    ./video.nix
  ];

  programs = {
    zsh.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;
}
