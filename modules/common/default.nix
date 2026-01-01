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
    discordo
    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
  ];
}
