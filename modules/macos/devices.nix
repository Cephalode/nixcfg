{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    jack2
  ];
}
