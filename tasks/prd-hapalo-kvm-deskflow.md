[PRD]
# PRD: Hapalo KVM-Aware Deskflow Client/Server Roles

## Overview

hapalo (NixOS, niri) sits behind an EVATEK 8K DP KVM switch together with metasepia (macOS). The KVM passes the physical keyboard (SteelSeries 1038:161E) and mouse (Logi Bolt receiver 046d:c53f → MX Master 3S) to exactly one host at a time and performs **no USB emulation** — devices fully de-enumerate from the inactive host and re-enumerate on the active one (verified via `udevadm monitor`; ~13 s gap observed between remove and re-add, ~1–2 s for full HID readiness after re-add).

Implement a NixOS module that makes hapalo's Deskflow role follow KVM input presence: **Logi Bolt receiver present → hapalo is the Deskflow server; absent → hapalo is a Deskflow client of metasepia**. Role selection is fully event-driven from local USB state — no shared state, no coordination protocol, no extra hardware.

## Background

- Deskflow (GPL-2.0, nixpkgs 1.26.0) is the upstream open-source core of Synergy; `deskflow-server`/`deskflow-client` are plain CLI daemons driven by a text config.
- Deskflow is network-protocol compatible with Synergy, so the metasepia side may run Synergy 3 or Deskflow; hapalo always runs `pkgs.deskflow`.
- hapalo runs niri (Wayland). Deskflow 1.26 Wayland input requires libei + InputCapture portal; the nixpkgs build links both. On hapalo the server role never injects input (it *has* the physical devices), and the client role receives input via libei/portal.
- metasepia is generally always on and is the fallback Deskflow server.
- lunalata is out of scope: apps there reject injected input, so Windows keeps physical input via the KVM (today's behavior, unchanged).

## Goal

Create `modules/nixos/devices/kvm-deskflow.nix` — a NixOS module that:

1. Installs `pkgs.deskflow`.
2. Detects KVM input presence via a udev rule on the Logi Bolt receiver VID:PID (`046d/c53f`), firing exactly once per switch (single USB device, not per-HID-interface like the keyboard).
3. Swaps hapalo between two systemd user units: `deskflow-server.service` (input present) and `deskflow-client.service` (input absent), mutually exclusive.
4. Runs everything as user services bound to `graphical-session.target` (niri session), consistent with the existing NixOS module conventions (cf. `services.synergy` upstream).

## Quality Gates

These commands must pass for every user story:

- `nix build .#nixosConfigurations.hapalo.config.system.build.toplevel` — Nix build succeeds
- `nix eval .#nixosConfigurations.hapalo.config.services.kvm-deskflow.enable` — evaluates to `true`

## User Stories

### US-001: NixOS module skeleton
**Description:** As a user, I want a NixOS module that installs Deskflow and exposes KVM-role options so the system is configurable from the flake.

**Acceptance Criteria:**
- [ ] Module file exists at `modules/nixos/devices/kvm-deskflow.nix`
- [ ] Module is imported by `modules/nixos/devices/default.nix`
- [ ] Options: `services.kvm-deskflow.enable` (bool, default false), `services.kvm-deskflow.triggerVid` / `triggerPid` (strings, defaults `046d` / `c53f`), `services.kvm-deskflow.peer` (string, host[:port] of metasepia, default `metasepia:24800`), `services.kvm-deskflow.serverConfigFile` (path)
- [ ] `environment.systemPackages = [ pkgs.deskflow ]`
- [ ] Firewall: `networking.firewall.allowedTCPPorts = [ 24800 ]` (server role must be reachable from metasepia)
- [ ] hapalo host config enables the module

### US-002: KVM input-presence trigger
**Description:** As a user, I want the KVM switch to automatically move hapalo between Deskflow server and client roles so input follows the physical switch with no manual step.

**Acceptance Criteria:**
- [ ] udev rule `ACTION=="add|remove", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c53f"` triggers the role swap
- [ ] The RUN helper runs as root, so it must delegate to the desktop user's user-manager (e.g. `systemctl --user -M <user>@` or `runuser -u <user> systemctl --user`); alternatively the add side uses `ENV{SYSTEMD_USER_WANTS}="deskflow-server.service"`
- [ ] add → start `deskflow-server.service`, stop `deskflow-client.service`; remove → the mirror
- [ ] Both units bind to `graphical-session.target`; nothing starts pre-login
- [ ] udev events with no active session are ignored gracefully
- [ ] A root-owned state file in `/run` records the last role for debugging
- [ ] Helper is a nix store path, referenced from the udev rule

### US-003: Boot-time role resolution
**Description:** As a user, I want hapalo to adopt the correct role at login when the KVM was switched while hapalo was off/asleep, so no stale role persists after boot.

**Acceptance Criteria:**
- [ ] A system-level oneshot runs when the graphical session comes up and resolves presence: trigger device found in `/sys/bus/usb/devices/` (walk `idVendor`/`idProduct` files) → server, else client
- [ ] Presence probe reads sysfs directly — no udev dependency, safe to run anytime
- [ ] Result applies via the same role-swap helper
- [ ] Resume from hibernate/sleep re-probes role (udev re-add events or re-run of the oneshot); covers the `sw` hibernate-swap to lunalata and back

### US-004: Deskflow server unit
**Description:** As a user, I want hapalo to run Deskflow as server when it physically holds the keyboard/mouse, so I can drive metasepia by moving the pointer off a screen edge.

**Acceptance Criteria:**
- [ ] `deskflow-server.service` (user) runs `${pkgs.deskflow}/bin/deskflow-server -c <serverConfigFile> --enable-crypto -n hapalo -f --debug INFO`
- [ ] `Restart=on-failure`, `RestartSec=2`
- [ ] Unit has `PartOf=graphical-session.target` and `After=graphical-session.target`
- [ ] Server config declares screens hapalo + metasepia and edge links (layout: hapalo left of metasepia; final layout lives in `serverConfigFile` in the flake)

### US-005: Deskflow client unit
**Description:** As a user, I want hapalo to act as Deskflow client when the input is on metasepia, so metasepia can drive hapalo.

**Acceptance Criteria:**
- [ ] `deskflow-client.service` (user) runs `${pkgs.deskflow}/bin/deskflow-client <peer> --enable-crypto -n hapalo -f --debug INFO`
- [ ] `Restart=on-failure`, `RestartSec=2`, `PartOf=graphical-session.target`
- [ ] TLS enabled (matching server `--enable-crypto`)

### US-006: TLS certificate bootstrap
**Description:** As a user, I want a TLS certificate available to the Deskflow units so `--enable-crypto` works without the Synergy GUI or a product key.

**Acceptance Criteria:**
- [ ] Idempotent ExecStartPre (or a `deskflow-tls-bootstrap.service`) generates `$XDG_STATE_HOME/deskflow/TLS/Synergy.pem` via `openssl req -x509 -newkey rsa:2048 -nodes -days 3650` if missing
- [ ] TLS dir permissions `0700`; generation runs as the session user
- [ ] Both units pass `--tls-cert` pointing at it
- [ ] No Deskflow GUI involved at any point (the upstream `services.synergy` module's GUI+key requirement is worked around by using openssl directly — Deskflow accepts self-signed PEM)

### US-007: Documentation
**Description:** As a user, I want the module and the KVM interaction documented so future maintainers understand the presence-detection design.

**Acceptance Criteria:**
- [ ] Module top comment explains: no-emulation KVM → VID:PID presence = role signal; why the Bolt receiver is the trigger (single device, fires once per switch)
- [ ] `hosts/nixos/hapalo/default.nix` comment references this PRD filename and explains the fallback role (client of metasepia)
- [ ] This PRD records the trigger VID:PID and observed enumeration timings

## Observations recorded from udev monitoring

- Remove burst: 59155.43→59155.96 (~530 ms full teardown of the `1-9` subtree)
- Re-add burst: subtree returns over ~5 s; full HID (mouse/kbd event nodes) ready ~1–2 s after subtree add
- Trigger candidates observed: `046d:c547` (dual HID + hiddev), `046d:c53f` (Bolt receiver; single device — preferred trigger), `1038:161e` (SteelSeries keyboard, multi-interface → would fire per interface)
- Two full remove→add cycles in the log (one per switch direction)

## Out of scope

- metasepia-side implementation (separate PRD: `prd-metasepia-kvm-deskflow.md`)
- lunalata/Windows client (physical-input constraint)
- ESP32 / 3.5 mm hardware trigger (software path proven sufficient)
- Barrier / Input Leap alternatives

## Dependencies

- nixpkgs deskflow 1.26.0 (`nix eval nixpkgs#deskflow.version` verified)
- hapalo niri session provides `graphical-session.target` (user session manager)
- Deployment via existing `update.sh` path
