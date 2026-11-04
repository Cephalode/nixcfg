# Common configuration for all hosts

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
      # macOS account is `cephalode` (renamed from sqibo); NixOS hosts keep `sqibo`.
      trusted-users =
        [ "root" ]
        ++ lib.optional pkgs.stdenv.isDarwin "cephalode"
        ++ lib.optional pkgs.stdenv.isLinux "sqibo";
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
