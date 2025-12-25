{
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ../common
    ./kb.nix
    ./audio.nix
    ./wm
  ];

  programs = {
    zsh.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;
}
