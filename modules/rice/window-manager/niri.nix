{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    alacritty
	fuzzel
	mako
	waybar
  ];
}
