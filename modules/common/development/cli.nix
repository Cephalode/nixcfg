{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  environment = {
    systemPackages = with pkgs; [
      bat
      btop
      cursor-cli
      fastfetch
      fd
      fzf
      git
      killall
      kitty
      ripgrep
      tldr
      tree
      unzip
      uwufetch
      vim
      wget
    ];
    variables = {
      XDG_CONFIG_HOME = "$HOME/.config";
      ZDOTDIR = "$XDG_CONFIG_HOME/zsh";
    };
  };
}
