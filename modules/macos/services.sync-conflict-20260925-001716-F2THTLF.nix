# macOS services configuration

{ config, pkgs, ... }:

let
  user = "sqibo";
  home = "/Users/${user}";
  picordDir = "${home}/devel/picord";
in
{
  # Tailscale: nix-managed CLI + daemon (was disabled for the MAS app, which
  # is no longer installed). CLI also in common/development/cli.nix.
  services.tailscale = {
    enable = true;
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
    ensureUsers = [
      { name = user; ensureClauses.superuser = true; }
    ];
    ensureDatabases = [ "inkwell" ];
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

  # ── DavMail (O365 -> IMAP/SMTP gateway, reachable over Tailscale) ──
  environment.systemPackages = [ pkgs.davmail ];
  launchd.user.agents.davmail = {
    serviceConfig = {
      Label = "nix.davmail";
      ProgramArguments = [
        "${pkgs.davmail}/bin/davmail"
        "${home}/.config/davmail/davmail.properties"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "${home}/.local/state/davmail/davmail.out.log";
      StandardErrorPath = "${home}/.local/state/davmail/davmail.err.log";
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
