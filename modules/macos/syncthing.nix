# Syncthing daemon for metasepia (Zen profile sync — see
# modules/common/syncthing.nix for topology). nix-darwin@d5bd9cd has no
# syncthing module, so the LaunchAgent is declared by hand.
# Config lives in ~/Library/Application Support/Syncthing (provisioned
# via REST API once, like any GUI-managed syncthing).
{
  pkgs,
  lib,
  ...
}:
{
  environment.systemPackages = [ pkgs.syncthing ];

  launchd.user.agents.syncthing = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.syncthing}/bin/syncthing"
        "--no-browser"
        "--no-restart"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/tmp/syncthing.stdout.log";
      StandardErrorPath = "/tmp/syncthing.stderr.log";
    };
  };
}
