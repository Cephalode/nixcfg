{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./development
  ];

  environment.systemPackages = with pkgs; [
    discord
    discordo
    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
    bambu-studio
  ];
}
