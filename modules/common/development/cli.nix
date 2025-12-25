{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    ./neovim.nix
    ./tmux.nix
  ];

  environment = {
    systemPackages = with pkgs; [
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
      vim
      wget
    ];
    variables = {
      XDG_CONFIG_HOME = "$HOME/.config";
      ZDOTDIR = "$XDG_CONFIG_HOME/zsh";
    };
  };
}
