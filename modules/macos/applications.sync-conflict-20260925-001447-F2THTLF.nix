{
  inputs,
  pkgs,
  ...
}:
{
  # NOTE: no karabiner package here — kanata (kanata.nix) is the remapper.
  # Karabiner's VirtualHIDDevice driver stack under /Library/Application
  # Support/org.pqrs/ is NOT nix-managed; it was provisioned once and
  # persists. Kanata needs it as its output backend; kanata.nix boots out
  # only Karabiner's remapping engine, not the driver.
  environment.systemPackages = with pkgs; [
    aerospace
    duti
    mas
    mkalias
    notesmd-cli
    obsidian
    raycast
    sox
  ];
  homebrew = {
    taps = [
    ];
    brews = [
    ];
    casks = [
      "anki"
      "beeper"
      "kitty"
    ];
    masApps = {
    };
  };
}
