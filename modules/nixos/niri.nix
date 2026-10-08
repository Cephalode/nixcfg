{ pkgs, ... }:
let
  # ponytail: pinned on the Aug-2026 nixpkgs lock — 0.8.2 has the Steam
  # instant-closing-menus bug (focused OR popups), fixed by add27951 in 0.8.3
  # (verified live on hapalo). Drop this pin when the nixpkgs input is updated.
  xwayland-satellite = pkgs.xwayland-satellite.overrideAttrs (oa: rec {
    version = "0.8.3";
    src = pkgs.fetchFromGitHub {
      owner = "Supreeeme";
      repo = "xwayland-satellite";
      tag = "v${version}";
      hash = "sha256-eFEjCCniMCKeWU0PcZNv+tDYe08SLFPjRplyPY8OFt4=";
    };
    cargoHash = "sha256-gMGFvnbxM3hD5fmkSimaFd87GEf6BXFe/MGjoS6VNVU=";
    # overrideAttrs alone does not reach the vendored-deps sub-derivation —
    # rebuild it explicitly with the same hash.
    cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
      inherit (oa) pname;
      inherit src version;
      hash = cargoHash;
    };
  });
in
{
  # ponytail: nixpkgs now ships programs.noctalia natively (nixos/modules/programs/wayland/noctalia.nix)
  # — no need to import inputs.noctalia.nixosModules.default (it would re-declare the same option).
  environment = {
    systemPackages = with pkgs; [
      alacritty
      zrythm
      firefox
      mako
      swaylock
      xwayland-satellite

      xdg-desktop-portal-gtk
    ];
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
      SDL_VIDEODRIVER = "wayland";
    };
  };

  programs.niri.enable = true;

  console.colors = [
    "062a2a" # 0 black (dark teal background)
    "ef4444" # 1 red
    "22c55e" # 2 green
    "eab308" # 3 yellow
    "60a5fa" # 4 blue
    "a78bfa" # 5 magenta
    "2dd4bf" # 6 cyan (teal accent)
    "e5e7eb" # 7 white (light text)

    "0b3a3a" # 8 bright black (slightly lighter teal)
    "f87171" # 9 bright red
    "4ade80" # 10 bright green
    "facc15" # 11 bright yellow
    "93c5fd" # 12 bright blue
    "c4b5fd" # 13 bright magenta
    "5eead4" # 14 bright cyan (brighter teal)
    "ffffff" # 15 bright white
  ];

  services = {
    dbus.enable = true;
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --theme 'container=black;border=cyan;title=white;text=white;prompt=white;input=white;action=cyan;button=cyan' --cmd niri-session";
          user = "greeter";
        };
      };
    };
    seatd.enable = true;
  };

  programs.noctalia = {
    enable = true;
    # systemd service fails — Wayland isn't ready when systemd starts it.
    # niri spawns noctalia via spawn-at-startup in config.kdl instead.
    systemd.enable = false;
  };

  security.polkit.enable = true;

  # System-wide dark mode — apps read this via org.freedesktop.appearance.color-scheme
  programs.dconf = {
    enable = true;
    profiles.user.databases = [{
      settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
    }];
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-termfilechooser
    ];
    config.common = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "niri" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "niri" ];
      "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
    };
    # programs.niri generates niri-portals.conf (default=gnome;gtk) which BEATS
    # portals.conf under XDG_CURRENT_DESKTOP=niri. ScreenCast/Screenshot MUST
    # stay on gnome here: niri ships no portal backend — it implements
    # org.gnome.Mutter.ScreenCast on the bus and xdg-desktop-portal-gnome is its
    # intended consumer (niri wiki screen-sharing path). Only FileChooser needs
    # an override (gnome would route it to nautilus instead of termfilechooser).
    config.niri."org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
  };

  # termfilechooser reads config only from $XDG_CONFIG_HOME (SYSCONFDIR is a store path)
  # and exec's `cmd` via `sh -c` with a PATH that lacks the package's share dir —
  # so bake the wrapper's absolute store path in at build time (substituteAll).
  systemd.user.tmpfiles.rules = [
    "L+ %h/.config/xdg-desktop-portal-termfilechooser/config - - - - ${pkgs.replaceVars ./configs/xdg-desktop-portal-termfilechooser/config {
      wrapper = "${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh";
    }}"
  ];

  systemd.defaultUnit = "graphical.target";
}
