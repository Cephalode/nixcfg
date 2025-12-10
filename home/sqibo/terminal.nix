{ config, pkgs, ... }: {

  home.packages = with pkgs; [
    # CLI tools
	fzf
	ripgrep
	tree
	zoxide
  ];

  programs = {
	zsh = {
	  enable = true;
	  shellAliases = {
	    cp = "cp -iv";
	    mv = "mv -iv";
	    rm = "rm -iv";
		ls = "ls -a --color=auto";
		hist = "history | grep";
		history = "history | fzf";

		update = "sudo nixos-rebuild switch --flake ~/Dev/nix#$(hostname)";
		golden = "echo 0.61803398875";
	  };
	};

	alacritty.enable = true;
	ghostty.enable = true;
	zoxide = {
	  enable = true;
	  enableZshIntegration = true;
	  options = [ "--cmd cd" ];
	};
  }; 
}
