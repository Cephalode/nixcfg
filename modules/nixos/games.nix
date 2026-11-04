{ config, pkgs, ... }:

{
  # Tools from Percepto's "How I Set Up my Linux for Maximum Gaming"
  # (https://youtu.be/bYsvNgA-tEE), wired NixOS-style. Nobara (video 00:18)
  # is a distro choice and doesn't apply; ProtonDB (01:57) is a website.
  environment.systemPackages = with pkgs; [
    deluge
    lutris # Game launcher  TODO: Use flatpak with bottles
    protonup-qt # GUI for custom Proton versions
    winetricks

    heroic # Epic/GOG/Amazon launcher (video 01:43)
    prismlauncher # Minecraft launcher (instance manager)
    adwsteamgtk # Steam Adwaita theme — run once to apply (video 01:33)
    protonplus # Proton version manager (video 05:59)
    gpu-screen-recorder-ui # GPU Screen Recorder (video 06:25); nixpkgs wraps
    # its backend for the NVENC driver path, same problem as OBS on hapalo.
    overlayed # Discord voice overlay (video 06:54)

    # Perf overlay (video 03:11). The 64-bit wrapper + layer ship here; the
    # 32-bit layer goes on the GL driver path below.
    mangohud
  ];

  programs = {
    gamemode.enable = true;

    gamescope = {
      enable = true;
      capSysNice = true; # let gamescope raise its priority (video 05:21)
    };

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      # dedicatedServer.openFirewall = true;
      # GE-Proton out of the box (video 01:57/05:59) — the Nix-native
      # alternative to what ProtonPlus/protonup-qt fetch by hand.
      extraCompatPackages = [ pkgs.proton-ge-bin ];
      gamescopeSession.enable = true; # "Steam (gamescope)" login session
    };
  };

  hardware.graphics = {
    enable = true; # Vulkan/GL ICDs system-wide (MDPro4, games generally)
    enable32Bit = true; # Required for epic
    # 32-bit MangoHUD Vulkan layer: the 32-bit loader only scans
    # /run/opengl-driver-32 (its SYSCONFDIR), not XDG_DATA_DIRS where the
    # 64-bit layer in systemPackages is found.
    extraPackages32 = [ pkgs.pkgsi686Linux.mangohud ];
  };

  # System-wide MangoHUD defaults (videos 03:11, 03:43): overlay items plus a
  # frame limiter. Display runs 165 Hz → cap at 160, method "early" (cap
  # before present, lower input lag). Per-user ~/.config/MangoHud/MangoHud.conf
  # wins over this file; per-game override, e.g.:
  #   MANGOHUD_CONFIG=fps_limit=141 mangohud %command%
  environment.etc."MangoHud.conf".text = ''
    fps
    frame_timing
    gpu_stats
    gpu_temp
    cpu_stats
    cpu_temp
    vram
    ram
    fps_limit=160
    fps_limit_method=early
  '';

  # Kernel tuning from the video: swappiness (07:08) and inotify watches +
  # instances (08:22). Watch/instance values pin what kernel 6.18 already
  # ships as defaults — declared here so they survive kernel bumps.
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "fs.inotify.max_user_watches" = 524288;
    "fs.inotify.max_user_instances" = 524288;
  };

  # Set up esync (speeds up games)
  # systemd.extraConfig = "DefaultLimitNOFILE=524288"; # this currently does not work
  # Targets the real login user (was pinned to "sqibo", the legacy fallback
  # account after the 2026-09-24 rename).
  security.pam.loginLimits = [{
    domain = config.cephalode.nixosUser;
    type = "hard";
    item = "nofile";
    value = "524288";
  }];
}
