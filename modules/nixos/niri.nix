{ pkgs, ... }:
{
  # ponytail: nixpkgs now ships programs.noctalia natively (nixos/modules/programs/wayland/noctalia.nix)
  # — no need to import inputs.noctalia.nixosModules.default (it would re-declare the same option).
  environment = {
    systemPackages = with pkgs; [
      alacritty
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
    # programs.niri's portal config would otherwise route FileChooser to gnome/nautilus
    config.niri."org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
  };

  # termfilechooser reads config only from $XDG_CONFIG_HOME (SYSCONFDIR is a store path)
  systemd.user.tmpfiles.rules = [
    "L %h/.config/xdg-desktop-portal-termfilechooser/config - - - - ${./configs/xdg-desktop-portal-termfilechooser/config}"
  ];

  systemd.defaultUnit = "graphical.target";
}
