# AirPlay receiver — metasepia (mac) sends system audio to hapalo's PipeWire.
# The Mac needs nothing installed: pick "hapalo" in macOS Sound settings (or
# per-app via the volume slider). ~2s AirPlay latency is normal.
#
# The upstream NixOS module runs shairport-sync as a SYSTEM service, but this
# box's PulseAudio server is PipeWire inside the user session
# (/run/user/$UID/pulse) — a system-level shairport can't connect
# ("failed to connect to the pulseaudio context -- Connection refused").
# So: module off, user-level unit instead.
#
# mDNS: shairport-sync 5.x (tinysvcmdns build) only announces on IPv6 link-local
# when avahi is absent, which macOS ignores. services.avahi.enable = true makes
# it register over IPv4 and appear in the Mac's sound output list.
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

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };

  # nqptp = AirPlay 2 timing daemon; shairport-sync only opens its AirPlay 2
  # port (7000) when it's up. Binds privileged UDP 319/320 -> system service.
  systemd.services.nqptp = {
    description = "nqptp (AirPlay 2 timing)";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.nqptp}/bin/nqptp";
      DynamicUser = true;
      AmbientCapabilities = "CAP_NET_BIND_SERVICE";
      CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };

  systemd.user.services.shairport-sync = {
    description = "AirPlay receiver (shairport-sync)";
    after = [ "nqptp.service" "pipewire.service" "pipewire-pulse.service" ];
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
