{ config, pkgs, ... }: {
  imports = [
    ../common
    ./kb.nix
    ./audio.nix
    ./wm
  ];

  programs = {
    zsh.enable = true;

    neovim = {
      enable = true;
      package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default; 
    };
  };

  users.defaultUserShell = pkgs.zsh;
}
