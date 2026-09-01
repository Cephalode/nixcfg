# Syncthing-based Zen profile sync (cookies, history, localStorage, sessions).
# Replaces zen-spaces' zen-sync (git/session-file reconciler), which deleted
# container definitions on apply and orphaned per-container cookie jars.
#
# Topology: metasepia (mac, always online) is the HUB + INTRODUCER; hapalo,
# loligo and lunalata (WSL, when the box runs Windows) are leaves that only
# need to reach the hub. Folder "zen-profile" maps each machine's OWN zen
# twilight profile dir (set per host via cephalode.zenProfilePath):
#   hapalo    /home/sqibo/.zen/0vkp3u7b.Default Profile
#   loligo    /home/sqibo/.zen/7r0v1cgu.Default Profile
#   metasepia ~/Library/Application Support/zen/Profiles/0wi5akoy.Default (twilight)
#   lunalata  (pending — fill in after first boot on the Windows side)
#
# nix-darwin has no syncthing module at this pin — metasepia's LaunchAgent
# lives in modules/macos/syncthing.nix and its config (devices + shared
# folder + introducer) is provisioned via local REST API.
{
  lib,
  config,
  ...
}:
let
  # Device IDs (from each machine's first daemon start)
  ids = {
    hapalo = "5UUBFW5-IIE3S32-MFDX36H-D53XMQA-66WIAMA-H4TVMN4-HIT5JGP-DUXHHQJ";
    loligo = "ZG3BTKO-P4Y5DJS-6GKVH53-YGHB2GD-A5VYD7D-NZXL3AW-GVZ7SNU-4ZXB6QI";
    metasepia = "F2THTLF-VNBHSBQ-DIPKKCV-D3C72S4-7AYPMJY-BPQB4M5-6JESKB2-CRR25AU";
    lunalata = "PENDING";
  };

  knownIds = removeAttrs ids [ "lunalata" ];
  folderName = "zen-profile";

  # Leaves connect only to the hub; hub is the introducer, so full mesh
  # forms automatically once lunalata is added on both sides.
  hubDevice = name: id: {
    inherit id;
    addresses = [ "tcp://${name}:22000" ];
    introducer = name == "metasepia";
  };
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
      # Declarative source of truth on the NixOS leaves
      overrideDevices = true;
      overrideFolders = true;
      settings = {
        options.urAccepted = -1;
        devices = lib.mapAttrs hubDevice knownIds;
        folders = {
          ${folderName} = {
            label = folderName;
            path = config.cephalode.zenProfilePath;
            devices = [ "metasepia" ];
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
