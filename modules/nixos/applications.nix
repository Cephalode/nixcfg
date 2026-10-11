{ pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    teams-for-linux
    # ponytail: from fresh nixpkgs — pinned rev ships 0.0.32, peers run 0.0.45
    inputs.nixpkgs-fresh.legacyPackages.${pkgs.system}.t3code
    wl-clipboard # wl-copy / wl-paste
    cliphist # clipboard history daemon + picker backend (niri Ctrl+Shift+V)
  ];
}
