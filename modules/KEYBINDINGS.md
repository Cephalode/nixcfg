# Unified Keybind Scheme

A unified modifier scheme across Linux (NixOS), macOS, and Windows, mediated by kanata.

## Philosophy

Different OSes use different modifier keys for the same actions:
- **macOS**: Cmd+C copies, Cmd+V pastes
- **Linux/Windows**: Ctrl+C copies, Ctrl+V pastes

Instead of fighting muscle memory on each platform, kanata remaps keys at the
keyboard level so **the same physical finger position always produces the same
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

## Home Row Mods

Home row keys act as modifiers when held, normal letters when tapped.
The pattern is identical on all platforms; only the OS key name differs:

| Finger | Left hand role | macOS sends | Linux/Win sends |
|--------|---------------|-------------|-----------------|
| a (hold) | Workspace | Ctrl (lctl) | **Super/Win (lmet)** |
| s (hold) | Navigation | Alt/Option (lalt) | Alt (lalt) |
| d (hold) | Shift | Shift (lsft) | Shift (lsft) |
| f (hold) | System commands | Cmd/Meta (lmet) | **Ctrl (lctl)** |
| j (hold) | System commands | Cmd/Meta (rmet) | **Ctrl (rctl)** |
| k (hold) | Shift | Shift (rsft) | Shift (rsft) |
| l (hold) | Navigation | Alt/Option (ralt) | Alt (ralt) |
| ; (hold) | Workspace | Ctrl (rctl) | **Super/Win (rmet)** |

The **f and a columns are swapped** between macOS and Linux/Win so that:
- f always triggers "system commands" (Cmd on macOS, Ctrl on Linux/Win)
- a always triggers "workspace switching" (Ctrl on macOS, Super/Win on Linux/Win)

## Meh and Hyper Keys

| Physical key | Tap | Hold | Works on |
|-------------|-----|------|----------|
| Caps Lock | Esc | Meh (Ctrl+Alt+Meta) | All platforms |
| Enter | Return | Meh (Ctrl+Alt+Meta) | All platforms |
| Meh + Shift | — | Hyper (Ctrl+Alt+Meta+Shift) | All platforms |

Meh and Hyper are used for window manager shortcuts:
- **aerospace** (macOS): `alt-ctrl-cmd` = Meh, `alt-ctrl-cmd-shift` = Hyper
- **niri** (NixOS): these arrive as Ctrl+Alt+Super key combos

## Layer Toggle

| Key combo | Action |
|-----------|--------|
| Hold `\\`, then `1` | Enable home row mods (main layer) |
| Hold `\\`, then `2` | Disable home row mods (base layer) |

All modifier key swaps (Ctrl↔Super on Linux/Win) remain active in both layers.

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
       1    2
  caps a    s    d    f    j    k    l    ;    ret  \
  lctl lmet rmet rctl
)

(deflayer main
       _    _
  @hyc @aM  @sA  @dS  @fC  @jC  @kS  @lA  @;M  @hyr @lay
  lmet lctl lctl rmet      ← swapped modifiers
)
```

### Full defsrc / deflayer (macOS)

```
(defsrc
       1    2
  caps a    s    d    f    j    k    l    ;    ret  \
)

(deflayer main
       _    _
  @hyc @aC  @sA  @dS  @fM  @jM  @kS  @lA  @;C  @hyr @lay
                                    ← no swap, native Cmd/Meta
)
```

## Quick Reference: Role → Physical Key per Platform

| Role | Physical key (all platforms) | macOS sends | Linux/Win sends |
|------|------------------------------|-------------|-----------------|
| System commands | Pinky bottom-left (f, j) | Cmd/Meta | Ctrl |
| Workspace | Pinky top-left (a, ;) | Ctrl | Super/Win |
| Navigation | Ring finger (s, l) | Alt/Option | Alt |
| Shift | Middle finger (d, k) | Shift | Shift |
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
- Use `kanata_winIOv2.exe` for best compatibility
- May need administrator privileges or input monitoring permission
- Uncomment and configure `windows-interception-keyboard-hwids` in defcfg if needed
- The Win key sends Ctrl (system commands), physical Ctrl sends Win (workspace)

## Files

| Platform | Config file | Module |
|----------|-------------|--------|
| NixOS | `modules/nixos/devices/keyboard.nix` | `services.kanata` |
| macOS | `modules/macos/kanata.nix` | `launchd.agents.kanata` |
| Windows | `windows/kanata/kanata.kbd` | Manual — run `kanata_winIOv2.exe -c kanata.kbd` |