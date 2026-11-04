{ lib, ... }:
{
  # Account name differs per host: loligo/lunalata = sqibo, hapalo renamed to
  # cephalode 2026-09-24 (live usermod). Must be declared — the activation user
  # reconciler DROPS undeclared accounts from /etc/passwd on every switch
  # (2026-09-25 hapalo ssh lockout).
  options.cephalode.nixosUser = lib.mkOption {
    type = lib.types.str;
    default = "sqibo";
    description = "Primary NixOS login user; shared user declaration and sudo rules key off this.";
  };
  options.cephalode.nixosUid = lib.mkOption {
    type = lib.types.nullOr lib.types.int;
    default = null;
    description = "Pin the uid (hapalo: 1000 — the home dir is already owned by it).";
  };

}
