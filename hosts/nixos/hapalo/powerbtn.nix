{ pkgs, lib, ... }:
let
  python = pkgs.python3.withPackages (ps: [ ps.evdev ]);
  powerbtn = pkgs.stdenv.mkDerivation {
    name = "powerbtn";
    src = ./.;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/bin
      install -m444 powerbtn.py $out/bin/powerbtn.py
    '';
  };
in
{
  # Power button daemon: short press -> sw (hibernate + boot Windows), hold >= 2s -> poweroff.
  # logind HandlePowerKey=ignore (hapalo default.nix); the daemon matches only the
  # ACPI power-button devices (PNP0C0C/LNXPWRBN phys) so keyboards are untouched.
  systemd.services.powerbtn = {
    description = "Power button handler (short=sw, long=poweroff)";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${python}/bin/python ${powerbtn}/bin/powerbtn.py";
      Restart = "always";
      RestartSec = "5";
    };
  };
}
