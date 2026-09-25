{
  config,
  pkgs,
  inputs,
  outputs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../.
  ];

  networking.hostName = "loligo";

  # Fingerprint unlock: login (greetd substacks it), noctalia's lock screen
  # (authenticates against "login" but drives the reader itself over D-Bus),
  # and sudo/polkit all route through this. Enroll with fprintd-enroll.
  # Scanner is a Broadcom 58200 (0a5c:5843) — needs the TOD driver, vanilla
  # libfprint doesn't claim it.
  services.fprintd = {
    enable = true;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-broadcom;
    };
  };

  # fprintd's D-Bus actions are polkit-gated (allow_active=yes), but the
  # session-active lookup is unreliable here and denies legit sessions.
  # wheel is trusted on this box anyway — allow explicitly.
  environment.etc."polkit-1/rules.d/49-fingerprint-wheel.rules".text = ''
    polkit.addRule(function(action, subject) {
      if (action.id.indexOf("net.reactivated.fprint") == 0 && subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  # Physical modifier row is Ctrl Fn Super Alt — the trailing Alt lands in
  # kanata's rmet slot; altLayout maps it to plain Alt (not Ctrl, as hapalo's
  # right Super needs) so roles match hapalo: physical Ctrl = Mod/Super,
  # physical Super = Ctrl.
  cephalode.keyboard.altLayout = true;

  # Zen twilight profile — synced via syncthing (modules/common/syncthing.nix)
  cephalode.zenProfilePath = "/home/sqibo/.zen/7r0v1cgu.Default Profile";
  cephalode.zenSpaceProfiles.enable = true;

  # ~/dev synced from metasepia hub (modules/nixos/syncthing.nix). Deploy repo
  # lives separately at ~/devel/nix so it never syncs over itself.
  cephalode.develSync.enable = true;

  # Hibernate: resume from the swap partition (nvme0n1p3)
  boot.kernelParams = [ "resume=UUID=62569a8c-85a6-4eb0-80fd-5297dbabe399" ];

  # Lid close: hibernate immediately (resume from the swap partition —
  # verified working; no RTC timer involved).
  # Power button short-press: suspend. Long-press stays ignore (spare binding).
  services.logind = {
    lidSwitch = "hibernate";
    powerKey = "suspend";
  };

  # Battery: cap charge at 80% (Latitude EC honors these; start stays at the
  # firmware default 50). Root-only sysfs write, re-applied at each boot.
  systemd.tmpfiles.rules = [
    "w /sys/class/power_supply/BAT0/charge_control_end_threshold - - - - 80"
  ];

  # Timing for the noctalia "Sleep" panel entry (suspend-then-hibernate):
  # RTC check every 30s, hibernate once the battery estimate is under 45m.
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = 30;
    HibernateThresholdSec = 45;
  };

  hardware.customNvidia = {
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  # Momentum True Wireless 4 earphone EQ — oratory1990 preset (2024-10-05,
  # GRAS rig, Harman In-Ear target) as a PipeWire filter-chain virtual sink:
  # -6.6 dB preamp (0.46774 linear) into a single stereo param_eq (5 bands,
  # both channels). Pure builtin biquads — no plugin packages. Shows up as
  # "Momentum TW 4 EQ"; priority.session makes it the default sink and its
  # playback follows the real output device.
  services.pipewire.extraConfig.pipewire."10-mtw4-eq" =
    let
      bands = [
        { type = "bq_lowshelf"; freq = 110.0; gain = 1.9; q = 0.71; }
        { type = "bq_peaking"; freq = 210.0; gain = -1.0; q = 1.4; }
        { type = "bq_peaking"; freq = 900.0; gain = 1.3; q = 2.0; }
        { type = "bq_peaking"; freq = 3500.0; gain = 6.5; q = 1.3; }
        { type = "bq_highshelf"; freq = 10000.0; gain = -1.0; q = 0.71; }
      ];
    in
    {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";
          args = {
            "node.description" = "Momentum TW 4 EQ";
            "filter.graph" = {
              nodes = [
                { type = "builtin"; name = "pre_l"; label = "linear";
                  control = { Mult = 0.46774; Add = 0.0; }; }
                { type = "builtin"; name = "pre_r"; label = "linear";
                  control = { Mult = 0.46774; Add = 0.0; }; }
                { type = "builtin"; name = "eq"; label = "param_eq";
                  config = { filters = bands; }; }
              ];
              links = [
                { output = "pre_l:Out"; input = "eq:In 1"; }
                { output = "pre_r:Out"; input = "eq:In 2"; }
              ];
              inputs = [ "pre_l:In" "pre_r:In" ];
              outputs = [ "eq:Out 1" "eq:Out 2" ];
            };
            "capture.props" = {
              "node.name" = "effect_input.mtw4_eq";
              "media.class" = "Audio/Sink";
              "priority.session" = 1010;
            };
            "playback.props" = {
              "node.name" = "effect_output.mtw4_eq";
              "node.passive" = true;
            };
          };
        }
      ];
    };

  # Toggle the Momentum TW 4 EQ: flips the default sink between the filter
  # chain and the raw hardware sink. Usage: eq [on|off|toggle|status]
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "eq" ''
      set -euo pipefail
      export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

      # First integer field on a wpctl status line is the object id.
      getid() { awk '{for(i=1;i<=NF;i++){x=$i; gsub(/\./,"",x); if(x ~ /^[0-9]+$/){print x; exit}}}'; }
      status="$(wpctl status)"
      # Filter-chain sinks are listed under "Filters:", hardware under "Sinks:".
      sinks="$(printf '%s\n' "$status" | sed -n '/Sinks:/,/Sources:/p')"
      filters="$(printf '%s\n' "$status" | sed -n '/Filters:/,/Streams:/p')"
      eq_id="$( { printf '%s\n%s\n' "$sinks" "$filters"; } | awk '/effect_input\.mtw4_eq/{print; exit}' | getid || true)"
      def_id="$( { printf '%s\n%s\n' "$sinks" "$filters"; } | awk '/\*/{print; exit}' | getid)"
      raw_id="$(printf '%s\n' "$sinks" | grep -v 'effect_input.mtw4_eq' | grep -v '\*' | getid | head -1 || true)"

      if [ -z "$eq_id" ]; then echo "eq: EQ sink not found" >&2; exit 1; fi
      case "''${1:-toggle}" in
        on)
          wpctl set-default "$eq_id"
          echo "EQ on (default sink = Momentum TW 4 EQ)" ;;
        off)
          if [ -z "$raw_id" ]; then echo "eq: no raw sink found" >&2; exit 1; fi
          wpctl set-default "$raw_id"
          echo "EQ bypassed (default sink = raw output)" ;;
        status)
          if [ "$def_id" = "$eq_id" ]; then echo "EQ active (default)"; else echo "EQ bypassed"; fi ;;
        toggle)
          if [ "$def_id" = "$eq_id" ]; then
            if [ -z "$raw_id" ]; then echo "eq: no raw sink found" >&2; exit 1; fi
            wpctl set-default "$raw_id"
            echo "EQ bypassed (default sink = raw output)"
          else
            wpctl set-default "$eq_id"
            echo "EQ on (default sink = Momentum TW 4 EQ)"
          fi ;;
        *) echo "usage: eq [on|off|toggle|status]" >&2; exit 1 ;;
      esac
    '')
  ];

  system.stateVersion = "25.05"; # Do not change
}