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
      fastfetch
      fd
      fzf
      gh
      git
      killall
      kitty
      lolcat
      ripgrep
      tldr
      tree
      unzip
      uwufetch
      vim
      wget
      yazi
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
