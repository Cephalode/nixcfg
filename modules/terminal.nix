{ config, pkgs, lib, inputs, ... }: {

  environment.systemPackages = with pkgs; [
	clang
	fastfetch
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
  }; 

  users.defaultUserShell = pkgs.zsh;
}
