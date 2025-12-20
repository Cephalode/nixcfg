# Common configuration for all hosts

{ lib, inputs, outputs, ... }: {
  nix.settings = {
    trusted-users = [ "root" "sqibo" ];
    experimental-features = [ "nix-command" "flakes"];
  };

  nixpkgs.config.allowUnfree = true;
}
