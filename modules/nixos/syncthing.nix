# Syncthing-based Zen profile sync (cookies, history, localStorage, sessions).
# Replaces zen-spaces' zen-sync (git/session-file reconciler), which deleted
# container definitions on apply and orphaned per-container cookie jars.
#
# Topology: hapalo <-> loligo <-> metasepia over Tailscale (tcp://<host>:22000).
# Folder "zen-profile" maps each machine's OWN zen twilight profile dir:
#   hapalo    /home/sqibo/.zen/0vkp3u7b.Default Profile
#   loligo    /home/sqibo/.zen/7r0v1cgu.Default Profile
#   metasepia ~/Library/Application Support/zen/Profiles/0wi5akoy.Default (twilight)
# Path is set per host (cephalode.zenProfilePath).
#
# Device IDs are filled in after first daemon start on each machine; until
# then overrideDevices/overrideFolders stay off so nothing is overwritten.
# nix-darwin has no syncthing module at this pin — metasepia's LaunchAgent
# lives in modules/macos/syncthing.nix and its config is provisioned via
# local REST API (apikey from its config.xml).
{
  lib,
  config,
  ...
}:
let
  deviceIds = {
    hapalo = "PENDING";
    loligo = "PENDING";
    metasepia = "PENDING";
  };

  idsReady = !(lib.any (id: id == "PENDING") (lib.attrValues deviceIds));

  folderName = "zen-profile";
in
{
  options.cephalode.zenProfilePath = lib.mkOption {
    type = lib.types.str;
    default = "";
    description = "This host's zen twilight profile directory (syncthing folder path).";
  };

  config = lib.mkIf (config.cephalode.zenProfilePath != "") {
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
  };
}
