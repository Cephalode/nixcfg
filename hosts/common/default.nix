# Common configuration for all hosts

{ lib, inputs, outputs, ... }: {
  imports = [ ../../modules/common ];

  users.users = {
    sqibo = {
      isNormalUser = true;
      description = "Main user.";
      extraGroups = [ "wheel" "networkmanager" "audio" "seat" ];
    };
  };

  nix.settings = {
    trusted-users = [ "root" "sqibo" ];
    experimental-features = [ "nix-command" "flakes"];
  };

  nixpkgs.config.allowUnfree = true;
}
