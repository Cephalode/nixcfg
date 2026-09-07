# AirPlay receiver — metasepia (mac) sends system audio to hapalo's PipeWire.
# The Mac needs nothing installed: pick "hapalo" in macOS Sound settings (or
# per-app via the volume slider). ~2s AirPlay latency is normal.
#
# The upstream NixOS module runs shairport-sync as a SYSTEM service, but this
# box's PulseAudio server is PipeWire inside the user session
# (/run/user/$UID/pulse) — a system-level shairport can't connect
# ("failed to connect to the pulseaudio context -- Connection refused").
# So: module off, user-level unit instead.
{
  pkgs,
  lib,
  ...
}:
let
  shairport = pkgs.shairport-sync-airplay2;
  conf = pkgs.writeText "shairport-sync.conf" ''
    general = {
      name = "hapalo";
      interpolation = "soxr";
    };
  '';
in
{
  services.shairport-sync.enable = false;

  systemd.user.services.shairport-sync = {
    description = "AirPlay receiver (shairport-sync)";
    after = [ "pipewire.service" "pipewire-pulse.service" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${shairport}/bin/shairport-sync -c ${conf}";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };

  networking.firewall = {
    allowedUDPPorts = [ 5353 319 320 6000 6001 ];
    allowedTCPPorts = [ 7000 7100 ];
  };
}
