{ config, wlib, lib, pkgs, ... }:
let
  configKdl = builtins.readFile ./config.kdl;
  noctaliaKdl = builtins.readFile ./noctalia.kdl;
in
{
  imports = [ wlib.wrapperModules.niri ];

  config.settings.extraConfig = configKdl + "\n" + noctaliaKdl;
}
