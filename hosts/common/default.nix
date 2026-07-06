# Common configuration for all hosts

let
  user = "sqibo";
in
{
  lib,
  pkgs,
  inputs,
  outputs,
  ...
}:
{
  nix = {
    settings = {
      trusted-users = [ "root" user ];
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };

    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    }
    // lib.optionalAttrs pkgs.stdenv.isDarwin {
      interval = [{ Weekday = 0; Hour = 3; }];
    }
    // lib.optionalAttrs pkgs.stdenv.isLinux {
      dates = "weekly";
    };
  };

  nixpkgs.config.allowUnfree = true;
}
