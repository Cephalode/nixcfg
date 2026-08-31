{ lib, ... }:
{
  # Runs as root during activation, BEFORE system.checks (the .DS_Store
  # touch test) and the applications rsync. Removes stale NOTARIZED bundles
  # whose TCC SystemPolicyAppBundles protection denies even root the touch
  # when invoked from an unentitled context (agent/SSH). Adhoc-resigned
  # replacements (overlays/tcc-friendly-apps.nix) then rsync in cleanly.
  # NOTE: generic activationScripts render AFTER checks (fixed order:
  # preActivation → checks → … → applications) — must hook preActivation.
  system.activationScripts.preActivation.text = lib.mkAfter ''
    app="/Applications/Nix Apps/Raycast.app"
    if [ -d "$app" ] && ! /usr/bin/codesign -dv "$app" 2>&1 | grep -q "flags=.*adhoc"; then
      echo "purging stale notarized bundle: $app" >&2
      rm -rf "$app"
    fi
  '';
}
