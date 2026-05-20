# Common configuration for all hosts

let
  user = "sqibo";
in
{
  lib,
  inputs,
  outputs,
  ...
}:
{
  nix.settings = {
    trusted-users = [
      "root"
      user
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  nixpkgs.config.allowUnfree = true;
}
