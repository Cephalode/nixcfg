{
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ../common
    ./wm
    ./kb.nix
    ./audio.nix
    ./video.nix
  ];

  programs = {
    zsh.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;
}
