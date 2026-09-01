# Unified Keybind Scheme

A unified modifier scheme across Linux (NixOS), macOS, and Windows, mediated by kanata.

## Philosophy

Different OSes use different modifier keys for the same actions:
- **macOS**: Cmd+C copies, Cmd+V pastes
- **Linux/Windows**: Ctrl+C copies, Ctrl+V pastes

Instead of fighting muscle memory on each platform, kanata remaps keys at the
keyboard level so **the same physical key always produces the same
role**, regardless of OS.

## Modifier Roles

| Modifier | Role | Used for |
|----------|------|----------|
| None / Shift | Regular input | Typing, normal keyboard use |
| Meta / Cmd / Win | System commands | Copy, paste, cut, close app, new tab, save |
| Alt / Option | Navigation | Word movement (Opt+←/→), line jumps |
| Ctrl | Workspace switching | Move between workspaces, send windows to workspaces |
| Meh (Ctrl+Alt+Meta) | Window management | Tiling focus, resize, move windows |
| Hyper (Meh+Shift) | Window management extended | Move windows between workspaces, layout presets |
| Meta+Ctrl | System control & services | Media, brightness, power, app launcher *(TODO)* |
| Meta+Alt | Text manipulation & input | Snippets, transforms, emoji, input method *(TODO)* |
| Ctrl+Alt | Environment & layout presets | Workspace layouts, monitor profiles, mode switching *(TODO)* |

## The Ctrl ↔ Super Swap (Linux & Windows)

On macOS, system commands use Cmd (Meta). On Linux and Windows, they use Ctrl.
To unify the experience, kanata **swaps Ctrl and Super/Win** on Linux and Windows:

| Physical key | macOS sends | Linux/Win sends | Role |
|-------------|-------------|-----------------|------|
| Left Ctrl | Ctrl (native) | **Super/Win** | Workspace switching |
| Left Super/Win | Cmd/Meta (native) | **Ctrl** | System commands |
| Right Super/Win | — | **Ctrl** | System commands |
| Right Ctrl | Ctrl (native) | **Super/Win** | Workspace switching |

On macOS, no swap is needed — Cmd is already the system command key.

## Meh and Hyper Keys

| Physical key | Tap | Hold | Works on |
|-------------|-----|------|----------|
| Caps Lock | Esc | Meh (Ctrl+Alt+Meta) | All platforms |
| Enter | Return | Meh (Ctrl+Alt+Meta) | All platforms |
| Meh + Shift | — | Hyper (Ctrl+Alt+Meta+Shift) | All platforms |

Meh and Hyper are used for window manager shortcuts:
- **aerospace** (macOS): `alt-ctrl-cmd` = Meh, `alt-ctrl-cmd-shift` = Hyper
- **niri** (NixOS): these arrive as Ctrl+Alt+Super key combos

## Keyboard Layout per Platform

### Physical Modifier Swap (Linux & Windows only)

```
Physical Left Ctrl   → Left Super/Win   (workspace switching)
Physical Left Super  → Left Ctrl         (system commands)
Physical Right Super → Right Ctrl         (system commands)
Physical Right Ctrl   → Right Super/Win   (workspace switching)
```

On macOS, physical keys send their native values (no swap needed).

### Full defsrc / deflayer (Linux & Windows)

```
(defsrc
  caps ret
  lctl lmet rmet rctl
)

(deflayer main
  @hyc @hyr
  lmet lctl lctl rmet      ← swapped modifiers
)
```

### Full defsrc / deflayer (macOS)

```
(defsrc
  caps ret
)

(deflayer main
  @hyc @hyr
)
```

## Quick Reference: Role → Physical Key per Platform

| Role | Physical key | macOS sends | Linux/Win sends |
|------|-------------|-------------|-----------------|
| System commands | Meta/Cmd or Ctrl key | Cmd/Meta | Ctrl |
| Workspace | Ctrl or Super/Win key | Ctrl | Super/Win |
| Navigation | Alt/Option key | Alt/Option | Alt |
| Shift | Shift key | Shift | Shift |
| Window mgmt | Caps or Enter (hold) | Ctrl+Alt+Cmd | Ctrl+Alt+Super |
| Window mgmt+ | Caps or Enter + Shift | Ctrl+Alt+Cmd+Shift | Ctrl+Alt+Super+Shift |

## Platform-Specific Notes

### macOS
- Uses `kanata-with-cmd` (default build blocks the Cmd key)
- Excludes `Karabiner DriverKit VirtualHIDKeyboard` from input processing
- Karabiner-elements must stay installed (provides VirtualHIDKeyboard output driver)
- Must grant Accessibility and Input Monitoring permissions after first run
- Caps Lock must NOT be remapped in System Preferences → Keyboard → Modifier Keys

### Linux (NixOS)
- Uses `services.kanata` nixos module with uinput for output
- No modifier swap conflicts — Ctrl and Super are remapped cleanly
- niri keybinds using `Mod` (Super) are naturally triggered by physical Ctrl key
- Requires uinput kernel module and udev rules

### Windows
- Deploys to `C:\Users\Sqibo\kanata\` on lunalata (binaries from kanata v1.12.0 release zip)
- Uses `kanata_windows_gui_winIOv2_x64.exe` (GUI build = no console window; winIOv2 driver)
- Autostart: scheduled task `Kanata` (/sc onlogon /rl HIGHEST) runs `start-kanata.cmd`
- Managed via `ssh lunalata` (same box as hapalo: `sw` hibernate-swaps between OSes)
- The Win key sends Ctrl (system commands), physical Ctrl sends Win (workspace)

## Files

| Platform | Config file | Module |
|----------|-------------|--------|
| NixOS | `modules/nixos/devices/keyboard.nix` | `services.kanata` |
| macOS | `modules/macos/kanata.nix` | `launchd.agents.kanata` |
| Windows | `windows/kanata/kanata.kbd` | Scheduled task `Kanata` → `start-kanata.cmd` |
