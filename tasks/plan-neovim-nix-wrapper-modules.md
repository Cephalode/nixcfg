# Plan: Neovim via BirdeeHub/nix-wrapper-modules

Replace the hand-rolled `wrapNeovimUnstable` setup in
`modules/common/development/neovim.nix` with the neovim wrapper module from
[BirdeeHub/nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules).

**Goals**

- All editor configuration stays in **Lua**, laid out as a normal
  `~/.config/nvim`-style directory (init.lua + lua/ modules). Nix only declares
  *which plugins and binaries exist*; Lua decides *how they behave*.
- Works identically on **NixOS** (hapalo, loligo, lunalata) and **nix-darwin**
  (metasepia). The wrapper produces a plain derivation installed via
  `environment.systemPackages`, which exists on both platforms — no
  home-manager, no platform branches.
- LSP + autocomplete + oil.nvim + mini.pick + obsidian.nvim + treesitter,
  formatting, linting, git signs, and general QoL plugins.
- LSP servers/formatters ride inside the neovim wrapper's PATH
  (`runtimePkgs`) instead of polluting global `environment.systemPackages`
  (today: `lua-language-server`, `nixd`, `marksman` are global).
- Lazy loading via [lze](https://github.com/BirdeeHub/lze) +
  [lzextras](https://github.com/BirdeeHub/lzextras) so startup stays fast.

**Non-goals:** nixvim / nix-expressed keymaps; a separate standalone flake
(everything lives in this repo); per-host editor differences beyond the
Obsidian vault path.

---

## How the wrapper module works (reference)

- Add input `wrappers.url = "github:BirdeeHub/nix-wrapper-modules"` (with
  `inputs.nixpkgs.follows = "nixpkgs"`).
- A "wrapper module" imports `wlib.wrapperModules.neovim` and sets:
  - `settings.config_directory = ./nvim;` — a real nvim config dir, loaded
    exactly like `~/.config/nvim`. Can be flipped to an **impure path** for
    instant-reload editing (see Phase 5).
  - `specs.<name>` — plugins (single, or DAG-ordered lists). Fields per spec:
    `data` (plugin drv), `lazy` (puts it in `pack/*/opt`, loaded later with
    `packadd` — lze drives this), `enable`, `before`/`after` (ordering vs.
    other specs and vs. the main init.lua, named `INIT_MAIN`).
  - `info.<whatever>` — arbitrary nix values readable from Lua via
    `require(vim.g.nix_info_plugin_name)(default, "info", "key", ...)`.
  - A `specMods` + `specCollect` recipe (from the official template) adds a
    `runtimePkgs` field to each spec, so a disabled spec also drops its
    binaries.
- Build/install: `inputs.wrappers.lib.evalPackage [ ./module.nix { inherit pkgs; } ]`
  returns a package. `pluginDeps` defaults to `"startup"`, so nixpkgs plugin
  `dependencies` (e.g. plenary for obsidian.nvim) are pulled in automatically.
- Official template to crib from: `nix flake init -t github:BirdeeHub/nix-wrapper-modules#neovim`
  (docs: https://birdeehub.github.io/nix-wrapper-modules/wrapperModules/neovim.html).

---

## Target layout

```
modules/common/development/neovim/
├── default.nix       # NixOS/darwin module: evalPackage → systemPackages; options
├── module.nix        # the wrapper module: specs, runtimePkgs, settings, info
└── nvim/             # settings.config_directory — pure Lua, normal nvim layout
    ├── init.lua      # bootstrap: nixInfo shim, lze handlers, requires below
    └── lua/
        ├── options.lua        # vim.opt.* (port from current init.lua)
        ├── keymaps.lua        # global, non-plugin keymaps
        └── plugins/
            ├── init.lua       # nixInfo.lze.load { require("plugins.x"), ... }
            ├── oil.lua
            ├── pick.lua       # mini.pick (+ other mini modules)
            ├── treesitter.lua
            ├── lsp.lua        # lspconfig + lzextras lsp handler, per-server specs
            ├── completion.lua # blink.cmp
            ├── format.lua     # conform.nvim
            ├── lint.lua       # nvim-lint
            ├── git.lua        # gitsigns
            ├── obsidian.lua
            └── ui.lua         # which-key, fidget, statusline, colorscheme
```

`modules/common/development/neovim.nix` (current file) is deleted at the end;
the directory above replaces it and `default.nix` in the dev module list stays
pointed at `./neovim`.

---

## Phase 0 — flake plumbing

1. Add to `flake.nix` inputs:
   ```nix
   wrappers = {
     url = "github:BirdeeHub/nix-wrapper-modules";
     inputs.nixpkgs.follows = "nixpkgs";
   };
   ```
2. Thread `wrappers` into **all** host input sets (`guiNixosInputs`,
   `wslNixosInputs`, `darwinInputs`). *Better:* drop the filtered input sets
   and pass `inputs` whole — this class of "forgot to thread an input" bug is
   why `configurationRevision` is silently null on metasepia today.
3. (Optional but recommended) expose the editor as a flake package for fast
   iteration without a system rebuild:
   ```nix
   packages = forAllSystems (system: {
     nvim = inputs.wrappers.lib.evalPackage [
       ./modules/common/development/neovim/module.nix
       { pkgs = import nixpkgs { inherit system; config.allowUnfree = true; }; }
     ];
   });
   ```
   Then `nix run .#nvim` tests the editor standalone on any host.

**Verify:** `nix flake lock` succeeds; `nix flake check` / `nix eval` of one
host still evaluates.

## Phase 1 — skeleton with parity

Create `module.nix` + `default.nix` + `nvim/` and reach parity with the
current setup before adding anything new.

`default.nix` (installed by both OSes — this is the whole cross-platform
story):

```nix
{ pkgs, inputs, ... }:
{
  environment.systemPackages = [
    (inputs.wrappers.lib.evalPackage [ ./module.nix { inherit pkgs; } ])
  ];
  environment.variables = { EDITOR = "nvim"; MANPAGER = "nvim +Man!"; };
}
```

(Move `EDITOR`/`MANPAGER` here from `cli.nix` so the editor module owns them.)

`module.nix` starts small:

```nix
{ config, wlib, lib, pkgs, options, ... }:
{
  imports = [ wlib.wrapperModules.neovim ];

  settings.config_directory = ./nvim;
  settings.aliases = [ "vi" "vim" ];   # replaces viAlias/vimAlias

  # template recipe: give every spec a runtimePkgs field
  specMods = { ... }: {
    options.runtimePkgs = options.runtimePkgs // {
      description = "packages on nvim's PATH, dropped if the spec is disabled";
    };
  };
  runtimePkgs = config.specCollect (acc: v: acc ++ (v.runtimePkgs or [ ])) [ ];

  specs.core = with pkgs.vimPlugins; [ lze lzextras ];
  specs.treesitter = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
  specs.oil = pkgs.vimPlugins.oil-nvim;
  specs.mini = pkgs.vimPlugins.mini-nvim;
  specs.obsidian = { lazy = true; data = pkgs.vimPlugins.obsidian-nvim; };
  specs.lsp = {
    data = pkgs.vimPlugins.nvim-lspconfig;
    runtimePkgs = with pkgs; [ lua-language-server nixd marksman ];
  };
}
```

`nvim/init.lua`: port the existing `neovim/init.lua` mostly as-is (options,
oil, treesitter autocmd, LSP keymaps, mini.pick maps, obsidian vault
detection), plus the template's **nixInfo bootstrap shim** at the top so the
config also loads outside nix (graceful fallback when
`vim.g.nix_info_plugin_name` is unset).

**Cleanups landed in this phase:** remove `vim` from `cli.nix` (it currently
collides with the wrapper's `vim` alias); remove `lua-language-server`,
`nixd`, `marksman` from global packages (they move into specs); delete the old
`neovim.nix` once the new module builds.

**Verify:** `nix run .#nvim` opens; `-` opens oil; `<leader>ff` picks files;
`:LspInfo` shows nixd attach on a .nix file; `:checkhealth` clean. Then
`darwin-rebuild build` and `nixos-rebuild build --flake .#hapalo` both
evaluate.

## Phase 2 — Lua restructure + lazy loading (lze)

1. Split `init.lua` into `lua/options.lua`, `lua/keymaps.lua`,
   `lua/plugins/*.lua` per the target layout. `init.lua` becomes: nixInfo
   shim → `require("options")` → `require("keymaps")` →
   register lze handlers → `require("plugins")`.
2. Register the template's lze handlers in init.lua:
   - `auto_enable` — spec auto-disables if nix didn't install the plugin
     (keeps Lua files inert when a spec is turned off in nix).
   - `for_cat` — gate specs on `settings.cats` (see below).
   - `nixInfo.lze.lsp` — lzextras' LSP handler (used in Phase 3).
3. In `module.nix`, export which top-level specs are enabled (template
   recipe), so Lua can branch on it:
   ```nix
   options.settings.cats = lib.mkOption {
     readOnly = true;
     type = lib.types.attrsOf lib.types.bool;
     default = builtins.mapAttrs (_: v: v.enable) config.specs;
   };
   ```
4. Mark everything not needed at startup `lazy = true` in nix and give each a
   trigger in its Lua spec: `event = "DeferredUIEnter"` (gitsigns, which-key,
   surround…), `ft` (obsidian on markdown), `cmd`, or `keys`.

**Verify:** `nix run .#nvim`, `:lua nixInfo.lze.debug.display(nixInfo.plugins)`
shows start vs. lazy split; lazy plugins load on their triggers; startup time
via `vim-startuptime` or `nvim --startuptime`.

## Phase 3 — LSP + autocomplete, per-language

1. **Completion: blink.cmp** (`pkgs.vimPlugins.blink-cmp`) — spec lazy on
   `DeferredUIEnter`; sources `lsp, path, buffer` (+ obsidian integration is
   automatic in the maintained fork); `signature.enabled = true`;
   `friendly-snippets` for snippet expansion. This replaces "completeopt only"
   today.
2. **LSP via lzextras handler** (template pattern): one `nvim-lspconfig` spec
   defines the shared `on_attach` (keymaps: `gd`, `gr`, `gI`, `K`,
   `<leader>rn`, `<leader>ca`, `<leader>ds` → mini.pick equivalents) and the
   `lsp` handler; then **one tiny lze spec per server**, each gated with
   `for_cat` so disabling the nix spec disables the Lua too.
3. **Per-language specs in nix**, each carrying its own tools:

   | spec | plugins | runtimePkgs |
   |---|---|---|
   | `lang.lua` | lazydev-nvim | lua-language-server, stylua |
   | `lang.nix` | — | nixd, nixfmt |
   | `lang.markdown` | — | marksman |
   | `lang.ts` | — | typescript-language-server, biome (or prettierd+eslint) |
   | `lang.python` | — | basedpyright, ruff |
   | `lang.rust` | — | rust-analyzer, rustfmt |
   | `lang.go` | — | gopls, gofumpt |
   | `lang.zig` | — | zls |
   | `lang.c` | — | clang-tools |

   This mirrors `modules/common/development/languages.nix` — keep the two
   lists adjacent or cross-reference them.

**Verify:** open a file of each language: completion menu appears, `gd`
works, `:LspInfo` shows the right server; disable one `specs.lang.*` in nix,
rebuild, confirm both the server binary and its Lua config are gone.

## Phase 4 — the "many other tools"

All lazy, all with `auto_enable = true` so nix stays the on/off switch:

- **conform.nvim** — format on `<leader>f` + optional format-on-save;
  `formatters_by_ft` keyed off `nixInfo` cats (stylua, nixfmt, biome, ruff…).
- **nvim-lint** — `BufWritePost` linting where LSP doesn't cover it.
- **gitsigns.nvim** — hunk signs, `]c`/`[c`, stage/reset/blame maps.
- **which-key.nvim** — discoverability for the leader groups.
- **nvim-surround**, **mini.pairs** (or autopairs), **todo-comments.nvim**,
  **fidget.nvim** (LSP progress), **undotree**.
- **mini.pick** stays the picker (files/grep/buffers/help); add
  `mini.extra` pickers (LSP symbols, diagnostics) instead of adding
  telescope/snacks.
- **Statusline:** mini.statusline (already shipping mini-nvim) — no lualine
  needed.
- **Colorscheme:** declare as a nix option (template pattern:
  `options.settings.colorscheme` + a `specs.colorscheme` that installs the
  matching plugin), read it in Lua via `nixInfo`. Candidate: match the teal
  console palette in `modules/nixos/niri.nix`.
- **obsidian.nvim** — keep vault autodetection, but pass the per-host vault
  path from nix instead of hardcoding both candidates in Lua:
  `info.obsidian_vault = "...";` set per host (metasepia → iCloud path,
  others → `~/notes`), Lua falls back to detection when unset.

**Verify:** each plugin's trigger fires; `nvim --startuptime` still fast
(~<60ms); which-key shows all leader groups.

## Phase 5 — polish & rollout

1. **Impure dev mode** for instant Lua reload without rebuilds:
   ```nix
   options.development.neovim.impureConfig = lib.mkOption {
     type = lib.types.bool; default = false;
     description = "Load nvim config from the repo checkout instead of the store.";
   };
   # in module.nix:
   settings.config_directory =
     if cfg.impureConfig
     then "/Users/sqibo/devel/nix/modules/common/development/neovim/nvim"  # per-OS home prefix
     else ./nvim;
   ```
   (Home prefix differs on darwin/linux — derive from `pkgs.stdenv.isDarwin`.)
2. Delete `modules/common/development/neovim.nix`; ensure
   `development/default.nix` imports `./neovim`.
3. Roll out host by host: `nix run .#nvim` → `darwin-rebuild switch`
   (metasepia) → `nixos-rebuild switch` on hapalo → loligo/lunalata.
4. Update README with the layout and the "edit Lua fast" workflow
   (flip `impureConfig`, or `nix run .#nvim` after edits — no host rebuild).

---

---

# Workstream B: tmux plugins + session persistence across reboot

## Current state (verified)

- `modules/common/development/tmux.nix` installs `tmuxPlugins.resurrect` and
  `tmuxPlugins.continuum` into `environment.systemPackages` — **they are
  never loaded**. tmux plugins only activate via `run-shell <plugin>/….tmux`
  lines in tmux.conf, so today there is no session persistence at all.
- The copy binding is macOS-only (`copy-pipe-and-cancel "pbcopy"`) — broken
  on the three NixOS hosts.
- **Two competing tmux configs on macOS.** nix-darwin's `programs.tmux`
  wraps tmux with `-f /etc/tmux.conf` (verified in nix-darwin source), so the
  wrapped tmux *only* reads `extraConfig`. Meanwhile `macos/dotfiles.nix`
  symlinks `configs/tmux.conf` → `~/.config/tmux/tmux.conf`, which the
  wrapped tmux never reads — it only applies if some other tmux binary runs.
  The two even contradict each other (prefix `` ` `` vs default `C-b`,
  different status styles). One must become the single source of truth.
- nix-darwin's `programs.tmux` has `extraConfig` but **no `plugins` option**
  (NixOS's does have one). So the cross-platform mechanism is to generate the
  `run-shell` lines ourselves inside `extraConfig` from a shared plugin list
  — same file works on all four hosts.

## Design

Rewrite `modules/common/development/tmux.nix` (stays in `modules/common`, so
it applies to NixOS + darwin identically):

```nix
{ pkgs, lib, ... }:
let
  plugins = with pkgs.tmuxPlugins; [
    sensible    # sane defaults (escape-time, focus-events, …)
    yank        # cross-platform clipboard (replaces the pbcopy binding)
    resurrect   # save/restore sessions, panes, layouts to disk
    continuum   # periodic autosave + auto-restore on server start; MUST load last
  ];
  loadPlugins = lib.concatMapStringsSep "\n" (p: "run-shell ${p.rtp}") plugins;
in
{
  programs.tmux = {
    enable = true;
    extraConfig = ''
      # …existing config (history, panes, status line, …) unchanged…

      # ── Session persistence ──────────────────────────────
      set -g @resurrect-capture-pane-contents 'on'
      set -g @resurrect-strategy-nvim 'session'   # restore nvim via :mksession
      set -g @continuum-restore 'on'              # auto-restore when server starts
      set -g @continuum-save-interval '10'        # autosave every 10 min

      # ── Load plugins (options above must precede these) ──
      ${loadPlugins}
    '';
  };
}
```

Details that matter:

- **Ordering:** `@resurrect-*` / `@continuum-*` options must be set *before*
  the `run-shell` lines; continuum must be the **last** plugin loaded and
  must come *after* `status-right` is set (it hooks its autosave into the
  status-right interpolation).
- **Reboot persistence:** resurrect writes state to disk
  (`~/.local/share/tmux/resurrect/`), continuum autosaves every 10 min and
  restores the last save when the tmux server next starts — this is what
  survives a reboot. Optionally add `set -g @continuum-boot 'on'` to
  auto-start the tmux server at login (launchd on macOS, systemd elsewhere);
  decide per taste — without it, restore happens on first manual `tmux`.
- **Clipboard:** delete the `copy-pipe-and-cancel "pbcopy"` binding;
  tmux-yank picks `pbcopy`/`wl-copy`/`xclip` per platform automatically
  (`y` in copy-mode-vi).
- **Cleanups:** remove the dead `environment.systemPackages` tmuxPlugins
  block; `bind r source-file /etc/tmux.conf` stays correct since extraConfig
  lands in `/etc/tmux.conf` on both OSes.

## Steps

1. Consolidate configs: fold anything worth keeping from
   `macos/configs/tmux.conf` (prefix choice, base-index 1, renumber-windows,
   window dots, border styles) into `extraConfig`, then delete that file and
   its symlink block in `macos/dotfiles.nix`. Decide the prefix conflict
   (`` ` `` from dotfiles vs default `C-b` in extraConfig) — one answer for
   all hosts.
2. Rewrite `tmux.nix` per the design above.
3. Rebuild one host; run `tmux`, create a throwaway session layout,
   `prefix + Ctrl-s` (manual resurrect save) and check
   `~/.local/share/tmux/resurrect/` has a save file.
4. `tmux kill-server`, start `tmux` again → session layout comes back
   (continuum auto-restore). That's the reboot-survival path.
5. Verify `y` yanks to the system clipboard on both a NixOS host and
   metasepia; roll out to remaining hosts.

---

## Risks / notes

- **nvim-treesitter main branch:** nixpkgs-unstable now ships the `main`
  rewrite; the template's `FileType` attach autocmd is the correct pattern
  (current init.lua already has the fallback). Don't use the old
  `nvim-treesitter.configs` API in new code.
- **obsidian.nvim:** nixpkgs `vimPlugins.obsidian-nvim` tracks the maintained
  community fork; it auto-integrates with blink.cmp. Its `dependencies`
  (plenary) are pulled automatically by `pluginDeps`.
- **Darwin build of grammars:** `withAllGrammars` compiles fine on
  aarch64-darwin but is ~200 grammars; if eval/build time annoys, switch to
  `withPlugins (p: [ ... ])` with the ~15 languages actually used.
- **Multiple nvim installs** (if one is ever wanted per-project): the wrapper
  supports `settings.dont_link = true` + distinct `binName`/`aliases`. Not
  needed now; documented for later.
- **lze/lzextras versions:** nixpkgs copies are fine to start; if we want
  bleeding edge, add `plugins-lze`/`plugins-lzextras` flake inputs and the
  template's `pluginsFromPrefix` helper.
