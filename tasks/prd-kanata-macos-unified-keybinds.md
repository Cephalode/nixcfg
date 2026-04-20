[PRD]
# PRD: Kanata macOS Module — Unified Keybind Scheme

## Overview

Implement a nix-darwin module for kanata on macOS that establishes a unified keybind scheme across Linux, macOS, and Windows machines. The module replaces karabiner-elements for key remapping while retaining its VirtualHIDKeyboard driver for output. It mirrors the existing NixOS kanata config in `modules/nixos/devices/keyboard.nix` and adapts it for macOS.

## Goal

Create `modules/macos/kanata.nix` — a nix-darwin module that:
1. Installs kanata and runs it as a launchd agent
2. Configures the unified keybind scheme (Caps-as-Meh, home row mods, toggleable layers)
3. Excludes the karabiner VirtualHIDKeyboard from input processing to prevent loops
4. Keeps karabiner-elements installed (required for its VirtualHIDKeyboard driver)

## Quality Gates

These commands must pass for every user story:
- `nix build .#darwinConfigurations.metasepia` — Nix build succeeds
- `nix build .#darwinConfigurations.metasepia` — No evaluation errors

## User Stories

### US-001: Create kanata nix-darwin module
**Description:** As a user, I want a nix-darwin module that installs and configures kanata so that my unified keybind scheme works on macOS.

**Acceptance Criteria:**
- [ ] Module file exists at `modules/macos/kanata.nix`
- [ ] Module is imported by `modules/macos/default.nix`
- [ ] Module adds `kanata` to `environment.systemPackages`
- [ ] Module creates a launchd agent that runs kanata with `--cfg` and `--no-wait`
- [ ] Kanata config file is generated from nix (stored in nix store)
- [ ] Module is auto-enabled (consistent with other macOS modules)

### US-002: Configure unified keybind scheme
**Description:** As a user, I want the same keybind scheme on macOS that I have on NixOS, so my muscle memory transfers between machines.

**Acceptance Criteria:**
- [ ] Caps Lock → Meh (Esc on tap, Ctrl+Alt+Cmd on hold) — matches NixOS
- [ ] Enter → Meh (Return on tap, Ctrl+Alt+Cmd on hold) — matches NixOS
- [ ] Home row mods: a→Ctrl, s→Alt, d→Shift, f→Cmd, j→Cmd, k→Shift, l→Alt, ;→Ctrl
- [ ] Backslash key enters switch layer (hold to toggle home row mods)
- [ ] 1 key switches to main layer (home row mods enabled)
- [ ] 2 key switches to base layer (home row mods disabled)
- [ ] `defcfg` includes `process-unmapped-keys yes`
- [ ] `defcfg` excludes `Karabiner DriverKit VirtualHIDKeyboard`

### US-003: Document modifier role assignments
**Description:** As a user, I want the modifier role assignments documented in the kanata config so I can reference the scheme when configuring aerospace and other tools.

**Acceptance Criteria:**
- [ ] Config comments document all modifier roles (Meh, Hyper, Meta, Alt, Ctrl)
- [ ] Config documents future roles for Meta+Ctrl, Meta+Alt, Ctrl+Alt as boilerplate
- [ ] Config documents home row mod toggle instructions

### US-004: Update module dependencies
**Description:** As a user, I want karabiner-elements retained with proper documentation so it's clear why it's still needed.

**Acceptance Criteria:**
- [ ] `modules/macos/applications.nix` has a comment explaining karabiner-elements is retained for its VirtualHIDKeyboard driver
- [ ] Build succeeds with all module imports

## Functional Requirements

- FR-1: The module must generate a valid kanata.kbd config file
- FR-2: The kanata launchd agent must start at login and restart on failure
- FR-3: The kanata config must exclude the karabiner VirtualHIDKeyboard from input processing
- FR-4: The `process-unmapped-keys yes` option must be set to allow aerospace keybinds to work
- FR-5: The module must mirror the NixOS kanata layout (same keys, same aliases, same structure)
- FR-6: The launchd agent must log to `/tmp/kanata.out.log` and `/tmp/kanata.err.log`

## Non-Goals

- Removing karabiner-elements (it's required for the VirtualHIDKeyboard driver)
- Configuring aerospace keybinds via nix (the existing `~/.config/aerospace/aerospace.toml` is sufficient)
- Adding device-specific `macos-dev-names-include` entries (user should run `kanata --list` and add manually)
- Implementing Meta+Ctrl, Meta+Alt, Ctrl+Alt keybind layers (boilerplate comments only)

## Technical Considerations

- kanata on macOS uses CGEventTap for input and karabiner VirtualHIDKeyboard for output
- The launchd agent runs under the user's session (important for accessibility permissions)
- User must manually grant Accessibility and Input Monitoring permissions in System Preferences after first run
- Caps Lock must NOT be remapped in macOS System Preferences → Keyboard → Modifier Keys (kanata handles it)
- The module depends on karabiner-elements' VirtualHIDKeyboard driver being available at runtime
- The `wait4path /nix/store` wrapper in nix-darwin's launchd ensures the nix store is available before kanata starts

## Success Metrics

- `nix build .#darwinConfigurations.metasepia` succeeds
- Kanata runs as a launchd agent after `darwin-rebuild switch`
- Home row mods and Meh key work identically to the NixOS configuration
[/PRD]