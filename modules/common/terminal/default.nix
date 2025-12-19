{ config, pkgs, lib, inputs, ... }: {
  imports = [
    ./languages.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      cursor-cli
      fastfetch
      fd
      fzf
      git
      ghostty
      ripgrep
      tldr
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

  programs = {
    zsh.enable = true;

    neovim = {
      enable = true;
      package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default; 
    };
  };

  users.defaultUserShell = pkgs.zsh;
}
