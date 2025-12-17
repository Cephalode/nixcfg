{ config, pkgs, lib, inputs, ... }: {
  imports = [
    ./languages.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      cursor-cli
      fastfetch
      fzf
      git
      killall
      kitty
      ripgrep
      tmux
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
