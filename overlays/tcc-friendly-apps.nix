# Adhoc-resign notarized app bundles (Raycast) so nix-darwin activation can
# manage them: TCC SystemPolicyAppBundles denies even root writes into
# notarized+hardened bundles when the touching binary is unentitled (agent/SSH
# context can't be prompted). Adhoc-signed bundles (like Zen, Discord nix
# builds) are writable. Resigning demotes Raycast to the same class.
# Trade-off: upstream notarization/Gatekeeper assession is lost; app still runs
# (adhoc) — same as every other nix-shipped .app.
_final: _prev: {
  raycast = _prev.raycast.overrideAttrs (old: {
    postInstall =
      (old.postInstall or "")
      + ''
        /usr/bin/codesign --force --deep -s - "$out/Applications/Raycast.app" || true
      '';
    # sandbox can't reach codesign entitlements; run relaxed
    __noChroot = true;
  });
}
