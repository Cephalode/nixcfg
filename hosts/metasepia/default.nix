{ config, pkgs, inputs, outputs, lib, ... }:
{
  imports = [
    ../common
    ../../modules/macos
  ];

  system.defaults = {
    dock = {
      autohide = true;
      autohide-delay = 0.00;
      orientation = "left";
      persistent-apps = [
      ];
      scroll-to-open = true; # Scroll on a dock app to show all windows
      show-recents = false;
    };

    finder = {
      FXPreferredViewStyle = "clmv";
      FXEnableExtensionChangeWarning = false;
    };

    loginwindow = {
      GuestEnabled = false;
    };

    NSGlobalDomain.AppleInterfaceStyle = "Dark";
    NSGlobalDomain.KeyRepeat = 2;
    LaunchServices.LSQuarantine = false;
  };
}
