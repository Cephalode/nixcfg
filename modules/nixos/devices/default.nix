{
  ...
}:
{
  imports = [
    ./audio.nix
    ./keyboard.nix
    ./video.nix
  ];

  # USB devices
  services = {
    devmon.enable = true;
    gvfs.enable = true;
    udisks2.enable = true;
  };

  zramSwap.enable = true;
}
