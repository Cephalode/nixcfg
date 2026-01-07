{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./development
    ./security
  ];

  environment.systemPackages = with pkgs; [
    discord
    discordo
    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
  ];
}
