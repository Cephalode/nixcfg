{ pkgs, inputs, ... }:
{
  imports = [
    inputs.noctalia.nixosModules.default
  ];

  services.noctalia-shell.enable = true;

  environment.systemPackages = with pkgs; [
    #inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
