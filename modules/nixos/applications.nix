{ pkgs, inputs, ... }:

let
  # ponytail: 0.0.45 sets dontPatchELF, so vendored node-pty prebuilds ship with
  # no libstdc++ rpath — electron dlopens pty.node, gets ERR_DLOPEN_FAILED, the
  # backend server exits 1 in a respawn loop, and the window never opens.
  # (CLI "t3" worked because plain nodejs links libstdc++.)
  # Patch in .unwrapped, not the symlinkJoin — there the files are read-only
  # store symlinks and patchelf silently no-ops.
  fresh = inputs.nixpkgs-fresh.legacyPackages.${pkgs.system};
  t3code-unwrapped-fixed = fresh.t3code.unwrapped.overrideAttrs (old: {
    postFixup = (old.postFixup or "") + pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isLinux ''
      for f in $(find "$out/libexec/t3code" -path "*node-pty/prebuilds/linux-*/pty.node"); do
        ${pkgs.patchelf}/bin/patchelf --add-rpath "${pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc ]}" "$f"
      done
    '';
  });
  t3code-fixed = fresh.t3code.override { t3code-unwrapped = t3code-unwrapped-fixed; };
in

{
  environment.systemPackages = with pkgs; [
    beeper
    teams-for-linux
    t3code-fixed
    wl-clipboard # wl-copy / wl-paste
    cliphist # clipboard history daemon + picker backend (niri Ctrl+Shift+V)
    wtype # virtual keyboard input — `wtype -m capslock` clears a stuck Caps Lock over SSH
  ];
}
