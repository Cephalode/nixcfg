{
  pkgs,
  ...
}:
{
  environment = {
    systemPackages = with pkgs; [
      bat
      btop
      bun
      claude-code
      cursor-cli
      diff-so-fancy
      fastfetch
      fd
      fzf
      gh
      git
      gnumake
      killall
      kitty
      lolcat
      # nodejs
      opencode
      ripgrep
      tldr
      tree
      unzip
      uwufetch
      vim
      wget
      yazi
      zoxide
    ];
    variables = {
      XDG_CONFIG_HOME = "$HOME/.config";
      ZDOTDIR = "$XDG_CONFIG_HOME/zsh";
    };
  };

  fonts.packages = with pkgs.nerd-fonts; [
    jetbrains-mono
  ];
}
