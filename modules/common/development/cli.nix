{
  pkgs,
  ...
}:
{
  environment = {
    systemPackages = with pkgs; [
      # TODO atuin

      # Terminal and Editor
      kitty vim

      # Navigation
      eza fd fzf ripgrep tree yazi zoxide

      # Build and languages
      bun nodejs_24 typst typst-live

      # Utils
      bat btop cmake diff-so-fancy dust file gh
      git gnumake grunt-cli jq killall pandoc pipx stow tldr
      tesseract unzip wget

        # Data & databases
      dolt

      # Languages (JVM)
      jdk

      # Languages (Rust)
      cargo rustc

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
