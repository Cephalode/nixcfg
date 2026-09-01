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

    keybindings =
      {
        "shift+enter" = "send_text all \\e\\r";
      }
      # NixOS only: with the kanata Ctrl<->Super swap, the mac Cmd-position key
      # emits Ctrl and the corner Ctrl emits Super. Map mac terminal muscle
      # memory onto those emissions. copy_or_interrupt copies when a selection
      # exists, else sends a real ^C so TUIs (REPLs, pagers, fzf) keep working.
      // (lib.optionalAttrs pkgs.stdenv.isLinux {
        "ctrl+c" = "copy_or_interrupt"; # mac Cmd+C
        "ctrl+v" = "paste_from_clipboard"; # mac Cmd+V
        "super+c" = "copy_or_interrupt"; # mac Ctrl+C (SIGINT position)
        "super+v" = "paste_from_clipboard"; # mac corner Ctrl+V
      });

    extraConfig = noctaliaTheme;
  };
}
