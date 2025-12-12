{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    alacritty
	firefox
	fuzzel
	mako
	waybar
  ];
}
