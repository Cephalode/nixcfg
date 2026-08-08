{ pkgs, lib, config, inputs, ... }:
{
  config = lib.mkIf (pkgs.stdenv.isLinux) {
    environment.systemPackages = [
      (inputs.wrappers.lib.evalPackage [
        ./module.nix
        { inherit pkgs; }
      ])
    ];
  };
}
