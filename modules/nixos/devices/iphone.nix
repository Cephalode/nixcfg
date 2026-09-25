# iPhone over USB as a filesystem (libimobiledevice stack).
# Plug in, tap "Trust", then:
#   ifuse ~/mnt/iphone          # document sandbox (Files-visible storage)
#   ifuse --documents <appid> . # a specific app's documents
#   fusermount -u ~/mnt/iphone  # unmount
# CLI tools: ideviceinfo, idevice_id, idevicesyslog (libimobiledevice).
# gvfs (devices/default.nix) also exposes afc:// URIs to GUI file managers.
{ pkgs, ... }:
{
  services.usbmuxd.enable = true;
  environment.systemPackages = with pkgs; [
    ifuse
    libimobiledevice
  ];
}
