{ config, wlib, lib, pkgs, ... }:
{
  imports = [ wlib.wrapperModules.atuin ];

  config.settings = {
    style = "compact";
    enter_accept = true;
    sync.records = true;
  };
}
