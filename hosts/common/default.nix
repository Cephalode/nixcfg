# Common configuration for all hosts

{ lib, inputs, outputs, ... }: {
  imports = [ ../../modules/common ];

  users.users = {
    sqibo = {
      isNormalUser = true;
      description = "Main user.";
      extraGroups = [ "wheel" "networkmanager" "audio" ];
    };
  };
  
  environment.variables = {
    XDG_CONFIG_HOME = "$HOME/.config";
	ZDOTDIR = "$XDG_CONFIG_HOME/zsh";
  };

  nix.settings.trusted-users = [ "root" "sqibo" ];

  nixpkgs.config.allowUnfree = true;
}
