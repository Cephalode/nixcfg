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

    # REPLACED by modules/common/syncthing.nix: full-profile sync (cookies,
    # history, storage) over the Tailscale mesh. The git reconciler deleted
    # container definitions on apply, orphaning per-container cookie jars.
    sync = {
      enable = false;
      repo = "/home/sqibo/devel/nix";
      stateFile = "zen-state.json";
      interval = "5m";
    };
  };
}
