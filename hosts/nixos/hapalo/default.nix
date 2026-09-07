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
    ./powerbtn.nix
  ];

  networking.hostName = "hapalo";
  system.stateVersion = "25.05"; # Do not change

  # Zen twilight profile — synced via syncthing (modules/common/syncthing.nix)
  cephalode.zenProfilePath = "/home/sqibo/.zen/0vkp3u7b.Default Profile";

  # Power button: owned by powerbtn.nix daemon (short press = sw, hold = poweroff).
  # logind must ignore the key globally — its only sources here are the ACPI buttons.
  services.logind.powerKey = "ignore";

  environment.systemPackages = with pkgs; [
    google-chrome
    inputs.bedrock-on-linux.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.grok-build.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Hibernate-swap to Windows (also the power button's short-press action).
    # Arms BootNext 0000 + an RTC wakealarm, then hibernates: the RTC fires the
    # box back on and firmware consumes BootNext -> boots Windows. Without the
    # wakealarm nothing powers the box back on until someone presses the button.
    (writeShellScriptBin "sw" ''
      set -euo pipefail

      # efivarfs and wakealarm writes need root; route through the NOPASSWD
      # systemd-run bridge (plain `sudo tee` is NOT covered by the rules)
      sudo -n /run/current-system/sw/bin/systemd-run --wait --pipe --quiet ${pkgs.efibootmgr}/bin/efibootmgr --bootnext 0000
      # RTC wake ~150s out: enough margin for the hibernate image write.
      # Compute the epoch in sw (transient units have a minimal PATH — no date)
      # and pass a literal to the root shell.
      alarm=$(( $(date +%s) + 150 ))
      sudo -n /run/current-system/sw/bin/systemd-run --wait --pipe --quiet ${pkgs.bash}/bin/bash -c "echo $alarm > /sys/class/rtc/rtc0/wakealarm"
      # Hibernate through the root bridge: polkit denies hibernate from SSH
      # sessions (no local seat); root bypasses it. Fire-and-forget — the box
      # powers off mid-unit by design.
      sudo -n /run/current-system/sw/bin/systemd-run --collect ${pkgs.systemd}/bin/systemctl hibernate
    '')
    (writeShellScriptBin "eq" ''
      # Toggle the DT 900 Pro X EQ: flips the default sink between the filter
      # chain and the raw hardware sink. Usage: eq [on|off|toggle|status]
      set -euo pipefail
      export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

      # First integer field on a wpctl status line is the object id.
      getid() { awk '{for(i=1;i<=NF;i++){x=$i; gsub(/\./,"",x); if(x ~ /^[0-9]+$/){print x; exit}}}'; }
      status="$(wpctl status)"
      # Filter-chain sinks are listed under "Filters:", hardware under "Sinks:".
      sinks="$(printf '%s\n' "$status" | sed -n '/Sinks:/,/Sources:/p')"
      filters="$(printf '%s\n' "$status" | sed -n '/Filters:/,/Streams:/p')"
      eq_id="$( { printf '%s\n%s\n' "$sinks" "$filters"; } | awk '/effect_input\.dt900_eq/{print; exit}' | getid || true)"
      def_id="$(printf '%s\n' "$status" | awk '/\*/{print; exit}' | getid)"
      raw_id="$(printf '%s\n' "$sinks" | grep -v 'effect_input.dt900_eq' | grep -v '\*' | getid | head -1 || true)"

      if [ -z "$eq_id" ]; then echo "eq: EQ sink not found" >&2; exit 1; fi
      case "''${1:-toggle}" in
        on)
          wpctl set-default "$eq_id"
          echo "EQ on (default sink = DT 900 Pro X EQ)" ;;
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
            echo "EQ on (default sink = DT 900 Pro X EQ)"
          fi ;;
        *) echo "usage: eq [on|off|toggle|status]" >&2; exit 1 ;;
      esac
    '')
  ];

  boot.loader.limine = {
    secureBoot.enable = true;
    maxGenerations = 3;
    extraEntries = ''
      /Windows
        protocol: efi
        path: boot():/EFI/Microsoft/Boot/bootmgfw.efi 
    '';
  };

  boot.kernelParams = [
    "resume=UUID=b260e841-ed40-4868-82a2-b2ea8f0e896f"
    "resume_offset=43235328"
  ];

  hardware.customNvidia = {
    open = false;
  };

  # DT 900 Pro X headphone EQ — oratory1990 preset (2024-04-09 KEMAR rig) as a
  # PipeWire filter-chain virtual sink: -5.3 dB preamp (0.54325 linear) into a
  # single stereo param_eq (8 bands, both channels). Pure builtin biquads — no
  # plugin packages. Shows up as "DT 900 Pro X EQ"; priority.session makes it
  # the default sink and its playback follows the real output device.
  services.pipewire.extraConfig.pipewire."10-dt900-eq" =
    let
      bands = [
        { type = "bq_peaking"; freq = 47.0; gain = -2.1; q = 0.6; }
        { type = "bq_lowshelf"; freq = 105.0; gain = 5.5; q = 0.71; }
        { type = "bq_peaking"; freq = 220.0; gain = -2.4; q = 0.5; }
        { type = "bq_peaking"; freq = 2600.0; gain = -1.8; q = 2.5; }
        { type = "bq_peaking"; freq = 3800.0; gain = 2.2; q = 1.4; }
        { type = "bq_peaking"; freq = 6350.0; gain = -5.5; q = 2.0; }
        { type = "bq_peaking"; freq = 9000.0; gain = 1.0; q = 2.0; }
        { type = "bq_highshelf"; freq = 11000.0; gain = 1.0; q = 0.71; }
      ];
    in
    {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";
          args = {
            "node.description" = "DT 900 Pro X EQ";
            "filter.graph" = {
              nodes = [
                { type = "builtin"; name = "pre_l"; label = "linear";
                  control = { Mult = 0.54325; Add = 0.0; }; }
                { type = "builtin"; name = "pre_r"; label = "linear";
                  control = { Mult = 0.54325; Add = 0.0; }; }
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
              "node.name" = "effect_input.dt900_eq";
              "media.class" = "Audio/Sink";
              "priority.session" = 1010;
            };
            "playback.props" = {
              "node.name" = "effect_output.dt900_eq";
              "node.passive" = true;
            };
          };
        }
      ];
    };
}
