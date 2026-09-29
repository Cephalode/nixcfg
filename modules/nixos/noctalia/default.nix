# Noctalia v5 config — managed by the flake, no Home Manager.
#
# This module symlinks config.toml into ~/.config/noctalia/ via user
# systemd-tmpfiles (same pattern as the niri config symlink). noctalia itself
# is installed by the nixpkgs-native programs.noctalia in ../niri.nix, and
# niri spawns it via spawn-at-startup (systemd.enable = false there — the
# service races Wayland at login).
#
# Why the all-users `systemd.user.tmpfiles.rules` (not the per-user
# `.users.<name>` variant): %h resolves per user manager, this module is only
# imported by ./modules/nixos (graphical hosts), and the fleet is mid
# username-rename (hapalo=cephalode, loligo=sqibo) — keying the rule to a
# username would break on the next rename. Extra local users just get a
# noctalia config.toml in ~/.config, which is inert unless they run noctalia.
#
# Why not the BirdeeHub nix-wrapper-modules "noctalia-shell" wrapper: it is
# v4-era — it writes settings.json/colors.json and sets NOCTALIA_CONFIG_DIR /
# NOCTALIA_SETTINGS_FILE, and the v5 binary reads none of those (grep-verified
# against noctalia-shell source, Sep 2026). v5 reads every *.toml in its
# config dir and deep-merges them; runtime GUI edits land in
# $XDG_STATE_HOME/noctalia/settings.toml, which wins at runtime. Do not reach
# for the wrapper.

{ lib, ... }:
{
  systemd.user.tmpfiles.rules = [
    # L+ = always (re)point the symlink at the store path. Applied by each
    # user's systemd-tmpfiles at login and on activation.
    "L+ %h/.config/noctalia/config.toml - - - - ${./config.toml}"
  ];
}
