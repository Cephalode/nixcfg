{ config, pkgs, inputs, ... }:
{
  nixpkgs.config.allowUnfree = true; # Allow closed source software

  # Packages from Nix
  environment.systemPackages = with pkgs; [
    aerospace
    btop
    cursor-cli
    code-cursor
    fzf
    hub
    jq
    mkalias # Allows apps in /Applications/Nix to show up in Raycast
    neovim
    tmux
    tree-sitter # Neovim plugin
    uwufetch
    xdg-ninja # Checks home folder for unnecessary dotfiles
  ];

  fonts.packages = [
  ];
}

