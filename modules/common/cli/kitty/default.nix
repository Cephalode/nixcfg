{ pkgs, lib, config, inputs, ... }:
{
  config = {
    environment.systemPackages = [
      (inputs.wrappers.lib.evalPackage [
        ./module.nix
        { inherit pkgs; }
      ])
    ];
  };
}
