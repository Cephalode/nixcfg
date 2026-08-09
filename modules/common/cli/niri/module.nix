{ config, wlib, lib, pkgs, ... }:
let
  configKdl = builtins.readFile ./config.kdl;
in
{
  imports = [ wlib.wrapperModules.niri ];

  config.settings.extraConfig = configKdl;
}
