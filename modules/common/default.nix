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
    equibop
    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
  ];
}
