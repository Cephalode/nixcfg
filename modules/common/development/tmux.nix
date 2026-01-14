{ config, pkgs, ... }:
{
  environment.systemPackages =
    (with pkgs; [
      tmux
    ])
    ++ (with pkgs.tmuxPlugins; [

    ]);
}
