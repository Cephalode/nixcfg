{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ inputs.nixCats.nixosModules.default ];

  nixCats = {
    enable = true;
  };
}
