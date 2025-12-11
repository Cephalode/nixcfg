{ config, pkgs, lib, inputs, ... }: {

  environment.systemPackages = with pkgs; [
    # CLI tools
	clang
	fzf
	ghostty
	ripgrep
	tree
	vim
  ];

  programs = {
	zsh.enable = true;

	neovim = {
	  enable = true;
	  package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default; 
	};

	alacritty.enable = true;

  }; 

  users.defaultUserShell = pkgs.zsh;
}
