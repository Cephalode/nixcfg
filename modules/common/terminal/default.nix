{ config, pkgs, lib, inputs, ... }: {

  environment = {
    systemPackages = with pkgs; [
      clang
      cursor-cli
      fastfetch
      fzf
      git
      ghostty
      ripgrep
      tmux
      tree
      unzip
      vim
      wget

      # Neovim Language Servers
      lua-language-server
      typescript-language-server
      nil # Nix language server
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
