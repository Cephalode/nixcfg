{
  pkgs,
  inputs,
  lib,
  system,
  ...
}:
{
  imports = [
    ./cli
    ./development
    ./security
  ] ++ lib.optionals (system == "x86_64-linux" || system == "aarch64-linux") [
    inputs.zen-spaces.nixosModules.default
  ];

  environment.systemPackages = with pkgs; [
    discord
    discordo
    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".twilight
  ];
} // lib.optionalAttrs (system == "x86_64-linux" || system == "aarch64-linux") {
  programs.zen-spaces = {
    enable = true;
    user = "sqibo";
    profileName = "0vkp3u7b.Default Profile";

    # Bidirectional sync: ~/devel/nix carries zen-state.json as the shared
    # source of truth. Browser edits get committed+pushed back (5 min cycle);
    # repo edits (any machine) apply to this machine's browser.
    sync = {
      enable = true;
      repo = "/home/sqibo/devel/nix";
      stateFile = "zen-state.json";
      interval = "5m";
    };
  };
}
