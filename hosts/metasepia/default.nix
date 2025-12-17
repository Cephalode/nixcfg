{ self, config, pkgs, inputs, outputs, lib, ... }: {
  imports = [
    ../common
    ../../modules/macos
  ];

  networking.hostName = "metasepia";
  nixpkgs.hostPlatform = "aarch64-darwin"; # Architecture

  nix.package = pkgs.nixVersions.nix_2_30;

  system = {
    primaryUser = "sqibo"; # Sets user
    configurationRevision = self.rev or self.dirtyRev or null; # Sets git hash

    defaults = {
      dock = {
        autohide = true;
        autohide-delay = 0.00;
        orientation = "left";
        persistent-apps = [
        ];

        scroll-to-open = true;	# Scroll on a dock app to show all windows
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

    stateVersion = 6;
  };
}
