{
  pkgs,
  ...
}:
{
  environment = {
    systemPackages = with pkgs; [
      # TODO atuin
      # TODO nodejs

      # Terminal and Editor
      kitty claude-code cursor-cli opencode vim

      # Navigation
      eza fd fzf ripgrep tree yazi zoxide

      # Build and languages
      bun typst typst-live

      # Utils
      bat btop diff-so-fancy dust gh git
      gnumake killall tldr unzip wget

      # Misc
      fastfetch lolcat uwufetch
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
