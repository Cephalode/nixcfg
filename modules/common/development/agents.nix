{
  inputs,
  pkgs,
  ...}: 
{
  environment.systemPackages = with pkgs; [
    claude-code cursor-cli opencode
  ];
}
