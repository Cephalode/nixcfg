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
    inputs.omdrop-nix.nixosModules.default
    inputs.openwhispr.nixosModules.default
  ];

  # Voice-to-text dictation (OpenWhispr). Upstream module also wires
  # ydotoold + uinput for Wayland auto-paste under niri.
  programs.openwhispr = {
    enable = true;
    users = [ "cephalode" ];
  };

  networking.hostName = "hapalo";

  # AirDrop (omdrop): OWL radio backend + omdrop CLI/receiver. Intel iwlwifi
  # means exclusive mode — Wi-Fi drops while the machine is visible.
  programs.omdrop.enable = true;

  # Upstream ships this in its own module: udev must not give awdl0 a MAC of
  # its own, or the phone is sent a link-local awdl0 doesn't have and never
  # connects. g4bri3lDev's module omits it.
  systemd.network.links."10-omdrop-owl-awdl0" = {
    matchConfig.OriginalName = "awdl0";
    linkConfig.MACAddressPolicy = "none";
  };

  # Run prebuilt dynamically-linked binaries (opencode)
  programs.nix-ld.enable = true;
  system.stateVersion = "25.05"; # Do not change

  # Primary account was renamed sqibo -> cephalode (live usermod, 2026-09-24);
  # declared here so activation stops dropping it from /etc/passwd (2026-09-25
  # ssh lockout after an undeclared-account switch). uid pinned to the existing
  # 1000 (syncthing's configured user + home-dir ownership).
  cephalode.nixosUser = "cephalode";
  cephalode.nixosUid = 1000;

  # Legacy account kept as console fallback after the rename (drop when
  # nothing needs it); uid pinned clear of cephalode's 1000.
  users.users.sqibo = {
    isNormalUser = true;
    description = "Legacy account (renamed to cephalode 2026-09-24).";
    uid = 1001;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  # Zen twilight profile — synced via syncthing (modules/common/syncthing.nix)
  cephalode.zenProfilePath = "/home/sqibo/.zen/0vkp3u7b.Default Profile";

  # Power button: owned by powerbtn.nix daemon (short press = sw, hold = poweroff).
  # logind must ignore the key globally — its only sources here are the ACPI buttons.
  services.logind.settings.Login.HandlePowerKey = "ignore";

  environment.systemPackages = with pkgs; [
    # NVIDIA EGL leaves Bambu Studio's 3D viewport blank under Wayland.
    # Wrap the cached package with the Nixpkgs Mesa/Zink workaround.
    (symlinkJoin {
      name = "bambu-studio-nvidia";
      paths = [ bambu-studio ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/bambu-studio \
          --set __GLX_VENDOR_LIBRARY_NAME mesa \
          --set __EGL_VENDOR_LIBRARY_FILENAMES /run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json \
          --set MESA_LOADER_DRIVER_OVERRIDE zink \
          --set GALLIUM_DRIVER zink
      '';
    })
    cmus
    google-chrome
    # OBS with NVENC: obs dlopens libnvidia-encode by soname, but driver libs
    # live only in /run/opengl-driver/lib (never on the global loader path).
    # Wrap OBS itself instead of setting LD_LIBRARY_PATH system-wide.
    (symlinkJoin {
      name = "obs-studio-nvenc";
      paths = [ obs-studio ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/obs \
          --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib
      '';
    })
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
      def_id="$( { printf '%s\n%s\n' "$sinks" "$filters"; } | awk '/\*/{print; exit}' | getid)"
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

  # 2026-09-18 hard-reset crash (SIGBUS storm -> instant power loss, no kernel
  # trace): log MCE/EDAC hardware-error precursors so a failing DIMM/CPU/PSU
  # leaves evidence before the next one.
  hardware.rasdaemon.enable = true;

  # RTX 3080 millisecond transient spikes trip the PSU's over-current
  # protection (instant power-off with zero kernel trace — 2026-09-18 and
  # 2026-09-26 crashes right at game launch; standby LED latches on until
  # AC is pulled). Clamp the board limit: spikes scale with it, ~3-5% perf
  # cost. nvidia-smi has no nixpkgs option; boot-time oneshot is enough —
  # the limit persists until the next reboot.
  systemd.services.nvidia-power-limit = {
    description = "Clamp GPU power limit to 325W (PSU OCP mitigation)";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/nvidia-smi -pl 325";
    };
  };

  # SMB server — browse hapalo's filesystem from the iPhone Files app:
  # Files → ⋯ → "Connect to Server" → smb://hapalo (login: cephalode).
  # homes = each user's own /home. iOS speaks SMB2/3; pinned as the floor.
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "server min protocol" = "SMB2";
      };
      homes = {
        browseable = "yes";
        "read only" = "no";
        "valid users" = "%S";
      };
    };
  };

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
              # ponytail: pin to GA102 HDMI — unpinned, WirePlumber auto-connects
              # and re-latches the fifine SC3 after replug/profile churn.
              "node.target" = "alsa_output.pci-0000_08_00.1.hdmi-stereo";
            };
          };
        }
      ];
    };

  # 2026-10-14: WirePlumber's stored profile for the SC3 drifted to input-only,
  # dropping the analog output sink entirely -> DT 900s went silent. Pin the
  # profile every time the device appears. Input must be ANALOG — iec958 is the
  # S/PDIF port, always silent (peak 0) and it ate the mic until 2026-10-15.
  services.pipewire.wireplumber.extraConfig."51-dt900-sc3" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          { "device.name" = "alsa_card.usb-MV-SILICON_fifine_SC3_20190808-00"; }
        ];
        actions."update-props" = {
          # ponytail: 2026-10-15 Cephalode confirmed SC3 is mic-only — pin
          # input-only so its phantom output sink can never re-latch the
          # EQ chain (the silence bug). Analog input stays mandatory: iec958
          # is the dead S/PDIF port.
          "device.profile" = "input:analog-stereo";
        };
      }
    ];
  };
}
