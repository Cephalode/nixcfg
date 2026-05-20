# macOS services configuration

{ config, pkgs, ... }:

let
  user = "sqibo";
  home = "/Users/${user}";
  picordDir = "${home}/devel/picord";
in
{
  # Tailscale: disabled in favor of the Mac App Store version
  # (nix tailscaled doesn't properly advertise IngressEnabled for Funnel)
  # See applications.nix → masApps → Tailscale
  services.tailscale = {
    enable = false;
    package = pkgs.tailscale;
  };

  # ── PostgreSQL ──────────────────────────────────────────────────
  # Replaces brew postgresql@16 service.
  # Data lives in /opt/homebrew/var/postgresql@16 — if you want to
  # keep the old data, set dataDir to that path BEFORE running
  # `darwin-rebuild switch` for the first time, or run:
  #   pg_dumpall -f ~/pg_backup.sql   (with brew PG still running)
  #   then restore after switching.
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    dataDir = "${home}/.local/share/postgresql";
  };

  # ── Valkey (Redis-compatible) ──────────────────────────────────
  # Replaces brew valkey service.
  launchd.user.agents.valkey = {
    serviceConfig = {
      Label = "nix.valkey";
      ProgramArguments = [
        "${pkgs.valkey}/bin/valkey-server"
        "--dir"
        "${home}/.local/share/valkey"
        "--loglevel"
        "warning"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/tmp/valkey.out.log";
      StandardErrorPath = "/tmp/valkey.err.log";
      EnvironmentVariables = {
        PATH = "${pkgs.valkey}/bin:/usr/bin:/bin";
      };
    };
  };

  # ── Picord (pi coding agent daemon) ────────────────────────────
  launchd.user.agents.picord = {
    serviceConfig = {
      Label = "com.venthezone.picord";
      ProgramArguments = [
        "/bin/bash"
        "-c"
        "if tmux has-session -t picord 2>/dev/null; then tmux kill-session -t picord; fi; tmux new-session -d -s picord 'set -a && source ${picordDir}/.env && set +a && cd ${picordDir} && exec /opt/homebrew/bin/node /opt/homebrew/lib/node_modules/@mariozechner/pi-coding-agent/dist/cli.js -e ${picordDir}/src/index.ts --no-session'"
      ];
      WorkingDirectory = picordDir;
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "${picordDir}/debug/picord-launchd-stdout.log";
      StandardErrorPath = "${picordDir}/debug/picord-launchd-stderr.log";
      EnvironmentVariables = {
        PATH = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${home}/.nix-profile/bin";
        SHELL = "/bin/bash";
      };
    };
  };
}
