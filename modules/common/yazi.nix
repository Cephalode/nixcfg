# modules/common/yazi.nix
#
# Yazi opener config, fleet-wide: audio files are queued into a running cmus
# instance via cmus-remote (`o` / Enter on an audio file in yazi). Everything
# else keeps yazi's default openers (rules are prepended).
#
# yazi only reads config from XDG_CONFIG_HOME — it ignores XDG_CONFIG_DIRS, so
# /etc/xdg doesn't work. Instead: file shipped at /etc/yazi/yazi.toml via
# environment.etc and selected with YAZI_CONFIG_HOME (checked first by yazi).
# Edit the toml in configs/ and rebuild; the symlink into ~/.config approach
# was dropped so there's exactly one source of truth.

{ pkgs, ... }:
{
  environment.etc."yazi/yazi.toml".source = ./configs/yazi/yazi.toml;
  environment.variables.YAZI_CONFIG_HOME = "/etc/yazi";
}
