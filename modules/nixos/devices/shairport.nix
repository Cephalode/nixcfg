# AirPlay receiver — metasepia (mac) sends system audio to hapalo's PipeWire.
# The Mac needs nothing installed: pick "hapalo" in macOS Sound settings (or
# per-app via the volume slider). ~2s AirPlay latency is normal.
{
  pkgs,
  ...
}:
{
  services.shairport-sync = {
    enable = true;
    openFirewall = true;
    package = pkgs.shairport-sync-airplay2;
    settings = {
      general = {
        name = "hapalo";
        interpolation = "soxr";
      };
      session-control = {
        # Release the output when the sender stops so local audio is never blocked.
        "run_this_after_exit_forced_kill" = "no";
      };
    };
  };
}
