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

  # Space-profile folders, mirroring the hub's REST-provisioned folders
  # (metasepia hosts the dirs; leaves sync under ~/.zen/<dir>).
  spaceProfiles = [
    { id = "zen-Personal"; dir = "jbnrnnnm.Personal"; }
    { id = "zen-Dev";      dir = "jbnrnnnm.Dev"; }
    { id = "zen-Work A";   dir = "55nr2ihj.Work A"; }
    { id = "zen-Work B";   dir = "ra5bay4m.Work B"; }
    { id = "zen-School";   dir = "hh82guxj.School"; }
  ];

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

  options.cephalode.zenSpaceProfiles.enable = lib.mkEnableOption "Sync the 5 space-profile dirs (Personal/Dev/Work A/Work B/School) from the metasepia hub";

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
        folders = lib.mkMerge [
          {
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
          }
          (lib.mkIf config.cephalode.zenSpaceProfiles.enable (lib.listToAttrs (map (p: {
            name = p.id;
            value = {
              label = "zen ${p.dir}";
              path = "/home/sqibo/.zen/${p.dir}";
              devices = [ "metasepia" ];
              ignorePerms = false;
              versioning = {
                type = "trashcan";
                params.cleanoutDays = "30";
              };
            };
          }) spaceProfiles)))
        ];
      };
    };
  };
}
