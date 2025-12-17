{ config, pkgs, lib, ... }:
{
  environment = {
    systemPackages = with pkgs; [
      alacritty
      firefox
      fuzzel
      mako
      swaylock
      waybar
      xwayland-satellite

      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
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
          command = ''
          ${pkgs.tuigreet}/bin/tuigreet 
          --time --remember \
          --theme 'container=black;border=cyan;title=white;text=white;prompt=white;input=white;action=cyan;button=cyan'\
          --cmd ${pkgs.niri}/bin/niri
          '';
          user = "greeter";
        };
      };
    };
    seatd.enable = true;
  };

  security.polkit.enable = true;

  xdg.portal = {
    enable = true;
    config.common.default = [ "gtk" ];

    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
  };

  systemd.defaultUnit = "graphical.target";
}
