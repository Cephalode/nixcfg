{ config, wlib, lib, pkgs, ... }:
let
  noctaliaTheme = builtins.readFile ./noctalia.conf;
in
{
  imports = [ wlib.wrapperModules.kitty ];

  config = {
    font.name = "jetbrains-mono";

    settings = {
      disable_ligatures = "never";
      enable_audio_bell = false;
      remember_window_size = "yes";
      window_border_width = "10pt";
      hide_window_decorations = "yes";
      confirm_os_window_close = 0;
      background_opacity = "0.75";
      background_blur = 16;
      dynamic_background_opacity = "yes";
    };

    keybindings = {
      "shift+enter" = "send_text all \\e\\r";
    };

    extraConfig = noctaliaTheme;
  };
}
