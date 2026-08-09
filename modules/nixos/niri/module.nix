{ config, wlib, lib, pkgs, ... }:
let
  configKdl = builtins.readFile ./config.kdl;
in
{
  imports = [ wlib.wrapperModules.niri ];

  # Use raw content override — bypasses wrapper's structured KDL generation
  # which would duplicate layout/binds nodes from config.settings defaults
  config."config.kdl".content = configKdl;
}
