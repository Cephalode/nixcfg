[PRD]
# PRD: Metasepia KVM-Aware Deskflow Server/Client Roles (macOS)

## Overview

metasepia (macOS, nix-darwin, aarch64) is the always-on host behind the EVATEK KVM switch shared with hapalo. When the KVM routes the keyboard/mouse to metasepia, metasepia must run Deskflow as **server**; when switched away, it must drop to **client** of hapalo. Detection mirrors hapalo's design: the KVM does no USB emulation, so the Logi Bolt receiver (`046d:c53f`) appearing/disappearing over USB is the role signal. No extra hardware, no coordination protocol.

## Background

- Deskflow is not packaged for darwin in nixpkgs (`meta.platforms = lib.platforms.linux`), so per package policy: Homebrew cask fallback (`brew install --cask deskflow`) — first Homebrew exception to be recorded in `modules/macos/homebrew.nix`.
- macOS USB attach/detach observation: launchd cannot watch USB directly; use a small IOKit-notify daemon (IOServiceAddMatchingNotification on `IOUSBHostDevice`, match on VendorID 0x046d / ProductID 0xC53F) that calls the swap script on transitions. Pure-Swift single-file daemon, built via nix `swift` stdenv or shipped as a script using `ioreg` polling fallback (see US-002).
- Deskflow macOS requires Accessibility (and possibly Input Monitoring) permission for the app — a one-time manual TCC grant; TCC cannot be granted from nix.
- metasepia is the fallback Deskflow server (always on), so its *client* role only matters while hapalo holds the input.
- Existing convention: macOS modules live in `modules/macos/`, auto-enabled, launchd agents defined nix-side (`services.launchd.user.agents`), cf. existing kanata module.

## Goal

Create `modules/macos/kvm-deskflow.nix` — a nix-darwin module that:

1. Installs Deskflow via Homebrew cask.
2. Runs a USB-watch daemon (launchd agent) that detects Bolt receiver presence.
3. Swaps between `deskflow-server` and `deskflow-client` launchd agents, mutually exclusive.
4. Resolves the correct role at load/login by probing current USB state.

## Quality Gates

These commands must pass for every user story:

- `nix build .#darwinConfigurations.metasepia` — build succeeds
- `nix eval .#darwinConfigurations.metasepia.config.services.kvm-deskflow.enable` — `true`

## User Stories

### US-001: nix-darwin module skeleton
**Description:** As a user, I want a nix-darwin module that installs Deskflow and exposes options so the whole system is managed from the flake.

**Acceptance Criteria:**
- [ ] Module file exists at `modules/macos/kvm-deskflow.nix`, imported by `modules/macos/default.nix`
- [ ] Options: `services.kvm-deskflow.enable` (bool, default false), `services.kvm-deskflow.triggerVid`/`triggerPid` (defaults `046d`/`c53f`), `services.kvm-deskflow.peer` (default `hapalo:24800`), `services.kvm-deskflow.serverConfigFile` (path in flake)
- [ ] Homebrew cask `deskflow` added in `modules/macos/homebrew.nix` with a comment noting the nixpkgs darwin gap (package policy exception)
- [ ] metasepia host config enables the module

### US-002: USB presence watcher
**Description:** As a user, I want metasepia to notice the moment the KVM attaches/detaches the keyboard/mouse so role swaps are as instant as the Linux side.

**Acceptance Criteria:**
- [ ] `kvm-watch` daemon: IOKit matching notifications on `IOUSBHostDevice` filtered to VendorID `0x046d`, ProductID `0xC53F`; on matched/terminated → run swap script with `present|absent`
- [ ] Shipped via `launchd.user.agents.kvm-watch` (`RunAtLoad: true`, `KeepAlive: true`)
- [ ] Fallback path documented: if the Swift daemon is deferred, a 2 s `ioreg -r -c IOUSBHostDevice | grep -i 'idVendor.*46d'`-style poll loop in a shell script is acceptable for v1
- [ ] Debounce: transitions within 500 ms coalesce (KVM enumeration burst)
- [ ] Daemon logs transitions to syslog/unified logging with reason

### US-003: Role swap
**Description:** As a user, I want the server/client agents to swap atomically so there is never a moment with two servers or zero.

**Acceptance Criteria:**
- [ ] Swap script: `present` → `launchctl kickstart -k gui/$(id -u)/kvm-deskflow-server` + `launchctl bootout gui/$(id -u)/kvm-deskflow-client`; `absent` → mirror
- [ ] State file `~/Library/Application Support/kvm-deskflow/state` records last role (debugging)
- [ ] Script is idempotent; repeated same-role events are no-ops
- [ ] Sleep/wake re-probes presence on wake (launchd `WatchPaths`/sleep-wake hook or daemon loop)

### US-004: Deskflow server agent
**Description:** As a user, I want metasepia to serve input to hapalo when it holds the keyboard/mouse.

**Acceptance Criteria:**
- [ ] `launchd.user.agents.kvm-deskflow-server`: Program `/opt/homebrew/bin/deskflow-server` (or cask binary path — resolve at implementation; verify with `brew --prefix deskflow`), args `-c <serverConfigFile> --enable-crypto -n metasepia -f --debug INFO`
- [ ] `KeepAlive: false` (started/stopped by swap script only)
- [ ] Server config lists screens metasepia + hapalo, mirrored edge links (metasepia right of hapalo — mirror of hapalo's config)
- [ ] Server config file lives in the flake as a path option

### US-005: Deskflow client agent
**Description:** As a user, I want metasepia to be drivable from hapalo when the input is there.

**Acceptance Criteria:**
- [ ] `launchd.user.agents.kvm-deskflow-client`: runs deskflow client against `peer` with `--enable-crypto -n metasepia -f --debug INFO`
- [ ] `KeepAlive: false`; lifecycle owned by the swap script
- [ ] TLS on (mirrors hapalo)

### US-006: TLS certificate
**Description:** As a user, I want a self-signed TLS cert for metasepia's Deskflow so `--enable-crypto` works without the Synergy GUI.

**Acceptance Criteria:**
- [ ] Idempotent generation into `~/Library/Application Support/deskflow/TLS/Synergy.pem` (`openssl req -x509 -newkey rsa:2048 -nodes -days 3650`) via ExecStartPre-equivalent (wrapper script before exec)
- [ ] `chmod 700` on the TLS dir
- [ ] Both agents pass `--tls-cert`

### US-007: Accessibility/TCC prerequisites
**Description:** As a user, I want the manual permission steps documented and verified once, so the client role can inject input on macOS.

**Acceptance Criteria:**
- [ ] README/module comment lists the exact manual grants: System Settings → Privacy & Security → Accessibility → Deskflow (and Input Monitoring if the client role fails to move the pointer)
- [ ] Document that TCC grants cannot be automated from nix (macOS restriction)
- [ ] Document expected first-run prompt behavior and how to verify (`tccutil` query or manual test: switch KVM to hapalo, move pointer across edge to metasepia screen)

### US-008: Boot-time role resolution
**Description:** As a user, I want the correct role at login/boot regardless of when the KVM last switched.

**Acceptance Criteria:**
- [ ] `kvm-watch` RunAtLoad performs an initial sysfs-equivalent probe (`ioreg`) and applies the role before entering the notify loop
- [ ] Covers: metasepia asleep during a switch, reboot during switch-away, fresh boot with input already attached

## Observations (shared with hapalo PRD)

- Trigger: Logi Bolt receiver `046d:c53f` (single USB device — one event per switch, unlike the multi-interface keyboard)
- KVM performs no USB emulation: full de-enumeration/enumeration each switch (~530 ms teardown; ~1–2 s to usable HID)

## Out of scope

- hapalo side (see `prd-hapalo-kvm-deskflow.md`)
- lunalata/Windows (physical input constraint)
- Scripting the KVM itself (3.5 mm/ESP32 path, deferred)

## Dependencies

- Homebrew (existing on metasepia per `modules/macos/homebrew.nix`)
- hapalo module deployed and firewall open on 24800 (hapalo PRD)
- Screen-name agreement between both server configs (`hapalo`, `metasepia`)
