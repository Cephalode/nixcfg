# Syncthing-based Zen profile sync (cookies, history, localStorage, sessions).
# Replaces zen-spaces' zen-sync (git/session-file reconciler), which deleted
# container definitions on apply and orphaned per-container cookie jars.
#
# Topology: hapalo <-> loligo <-> metasepia over Tailscale (tcp://<host>:22000).
# Folder "zen-profile" maps each machine's OWN zen twilight profile dir:
#   hapalo    /home/sqibo/.zen/0vkp3u7b.Default Profile
#   loligo    /home/sqibo/.zen/7r0v1cgu.Default Profile
#   metasepia ~/Library/Application Support/zen/Profiles/0wi5akoy.Default (twilight)
# Path is set per host (services.syncthing.settings.folders."zen-profile".path).
#
# nix-darwin's syncthing module only manages the LaunchAgent, not config —
# metasepia's devices/folders are provisioned once via local REST API
# (apikey from its config.xml). NixOS hosts are fully declarative.
{
  lib,
  pkgs,
  config,
  ...
}:
let
  # Device IDs — filled in after first daemon start on each machine.
  deviceIds = {
    hapalo = "PENDING";
    loligo = "PENDING";
    metasepia = "PENDING";
  };

  idsReady = !(builtins.any (id: id == "PENDING") (builtins.attrValues deviceIds));

  folderName = "zen-profile";
in
{
  options.cephalode.zenProfilePath = lib.mkOption {
    type = lib.types.str;
    default = "";
    description = "This host's zen twilight profile directory (syncthing folder path).";
  };

  config = lib.mkMerge [
    (lib.optionalAttrs pkgs.stdenv.isLinux {
      services.syncthing = {
        enable = true;
        user = "sqibo";
        group = "users";
        configDir = "/home/sqibo/.local/state/syncthing";
        dataDir = "/home/sqibo";
        overrideDevices = idsReady;
        overrideFolders = idsReady;
        settings = {
          options.urAccepted = -1;
          devices = lib.mapAttrs (name: id: {
            inherit id;
            autoAcceptFolders = true;
            addresses = [
              "tcp://${name}:22000"
              "dynamic+https://relays.syncthing.net/endpoint"
            ];
          }) (if idsReady then deviceIds else { });
          folders = lib.optionalAttrs idsReady {
            ${folderName} = {
              label = folderName;
              path = config.cephalode.zenProfilePath;
              devices = builtins.attrNames deviceIds;
              ignorePerms = false;
              versioning = {
                type = "trashcan";
                params.cleanoutDays = "30";
              };
            };
          };
        };
      };
    })

    # nix-darwin: daemon only; config provisioned via REST (see header).
    (lib.optionalAttrs pkgs.stdenv.isDarwin {
      services.syncthing.enable = true;
    })
  ];
}
