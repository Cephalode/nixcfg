{
  pkgs,
  ...
}:
{
  environment = {
  systemPackages = with pkgs; [
    # Navigation
    eza fd fzf ripgrep tree yazi zoxide

    # Build and languages
    bun nodejs_24 typst typst-live

    # Languages
    go lua python3 typescript zig
    # ponytail: zig also serves as C compiler (faster than gcc/clang)

    # Utils
    bat cmake diff-so-fancy dust file gh 
    gnumake grunt-cli jq killall pandoc pipx stow 
    tailscale tldr tesseract unzip wget

      # Data & databases
    dolt

    # Languages (JVM)
    jdk

    # Languages (Rust)
    cargo rustc

    # Mail
    aerc gnupg oama davmail

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
