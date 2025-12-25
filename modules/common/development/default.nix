{ config, pkgs=, ... } :
{
  imports = [
    ./cli.nix
    ./languages.nix
  ];

  environment.systemPackages = with pkgs; [
    code-cursor
    chromium # to use @browser in Cursor
  ];
}
