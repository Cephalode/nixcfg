{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./development
  ];

  environment.systemPackages = with pkgs; [
    equicord
    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
  ];
}
