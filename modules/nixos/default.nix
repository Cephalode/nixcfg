{
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ../common
    ./devices
    ./niri.nix
    ./niri
    ./security.nix
    ./games.nix
    ./applications.nix
    ./physical.nix
    ./syncthing.nix
  ];

  programs = {
    zsh.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;

  xdg.mime.defaultApplications = {
    "text/html" = "zen-twilight.desktop";
    "text/xml" = "zen-twilight.desktop";
    "application/xhtml+xml" = "zen-twilight.desktop";
    "x-scheme-handler/http" = "zen-twilight.desktop";
    "x-scheme-handler/https" = "zen-twilight.desktop";
  };

  # Electron apps (Discord) can end up with a broken XDG lookup env and fall
  # back to scanning every .desktop file, which picks Firefox. A user-level
  # mimeapps.list takes priority over every other location and fixes this.
  # Keep in sync with xdg.mime.defaultApplications above.
  systemd.user.services.mimeapps-override = {
    description = "Install user-level default-browser override (zen twilight)";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p %h/.config
      cat > %h/.config/mimeapps.list <<EOF
[Default Applications]
text/html=zen-twilight.desktop
text/xml=zen-twilight.desktop
application/xhtml+xml=zen-twilight.desktop
x-scheme-handler/http=zen-twilight.desktop
x-scheme-handler/https=zen-twilight.desktop

[Added Associations]
text/html=zen-twilight.desktop;firefox.desktop
x-scheme-handler/http=zen-twilight.desktop;firefox.desktop
x-scheme-handler/https=zen-twilight.desktop;firefox.desktop
EOF
    '';
  };

  # Let the agent run nixos-rebuild's privileged tail without a password
  # (nixos-rebuild-ng --elevate=sudo: profile set + switch-to-configuration).
  # Mirrors hapalo's rules — update.sh there already uses --elevate=sudo.
  security.sudo.extraRules = [
    {
      users = [ "sqibo" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nix-env *";
          options = [ "NOPASSWD" "SETENV" ];
        }
        {
          command = "/nix/store/*-nixos-system-*/bin/switch-to-configuration *";
          options = [ "NOPASSWD" "SETENV" ];
        }
        {
          command = "/run/current-system/sw/bin/systemd-run *";
          options = [ "NOPASSWD" "SETENV" ];
        }
        {
          command = "/nix/store/*/bin/nix-env *";
          options = [ "NOPASSWD" "SETENV" ];
        }
        {
          command = "/run/current-system/sw/bin/env -i PATH=* systemd-run *";
          options = [ "NOPASSWD" "SETENV" ];
        }
      ];
    }
  ];
}
