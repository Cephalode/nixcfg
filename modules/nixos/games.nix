{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Game launchers
    # heroic
    lutris

    protonup-qt # GUI for custom Proton versions
  ];

  programs = {
    gamemode.enable = true;

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      # dedicatedServer.openFirewall = true;
    };
  };

  hardware.graphics.enable32Bit = true; # Required for epic

  # Sets up esync (speeds up games)
  systemd.extraConfig = "DefaultLimitNOFILE=524288";
  security.pam.loginLimits = [{
    domain = "sqibo";
    type = "hard";
    item = "nofile";
    value = "524288";
  }];
}
