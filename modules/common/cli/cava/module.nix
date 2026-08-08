{ config, wlib, lib, pkgs, ... }:
{
  imports = [ wlib.wrapperModules.cava ];

  config.settings = {
    color = {
      foreground = "'#7ed0ff'";
      gradient = 1;
      gradient_color_1 = "'#004c6a'";
      gradient_color_2 = "'#7ed0ff'";
      gradient_color_3 = "'#c5e7ff'";
    };
  };
}
