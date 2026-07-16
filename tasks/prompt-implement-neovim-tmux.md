# Implementation task: Neovim (nix-wrapper-modules) + tmux session persistence

You are working in `~/devel/nix`, a Nix flake that manages four systems:

- **NixOS**: `hapalo`, `loligo` (GUI desktops), `lunalata` (WSL, headless)
- **nix-darwin**: `metasepia` (aarch64-darwin Mac)

The authoritative spec for this task is **`tasks/plan-neovim-nix-wrapper-modules.md`**.
Read it in full before writing any code. It has two workstreams:
(A) rebuild the Neovim setup on top of `BirdeeHub/nix-wrapper-modules`,
(B) fix tmux plugins and add session persistence across reboots.
This prompt tells you how to execute it; where this prompt and the plan
conflict, the plan wins, and note the conflict in your final report.

## Hard constraints

1. **Cross-platform:** everything under `modules/common/` is imported by both
   NixOS and nix-darwin. Only use options that exist on BOTH platforms there
   (`environment.systemPackages`, `environment.variables`,
   `programs.tmux.{enable,extraConfig}`). No home-manager. No
   `services.*`, `launchd.*`, or `systemd.*` in common modules.
2. **Editor config stays in Lua.** Nix declares which plugins/binaries exist;
   all behavior (setup calls, keymaps, options) lives in Lua files under a
   normal Neovim config directory. Do not encode keymaps or plugin settings
   in Nix. Do not use nixvim.
3. Preserve existing behavior unless the plan says to change it. Do not
   reformat or restructure unrelated files.
4. Commit at the end of each phase with a conventional-commit message
   (`feat:`, `fix:`, `refactor:`). Never commit a phase whose verification
   step fails.

## Reference material

- Plan: `tasks/plan-neovim-nix-wrapper-modules.md` (read first).
- Upstream docs: https://birdeehub.github.io/nix-wrapper-modules/wrapperModules/neovim.html
- **Official template — crib from it heavily.** Initialize it into a scratch
  directory (NOT the repo):
  `mkdir -p /tmp/nwm-template && cd /tmp/nwm-template && nix flake init -t 'github:BirdeeHub/nix-wrapper-modules#neovim'`
  Its `module.nix` shows: the `specMods`/`specCollect` recipe for per-spec
  `runtimePkgs`, the `settings.cats` export, and spec ordering. Its
  `init.lua` shows: the nixInfo bootstrap shim, lze handler registration
  (`auto_enable`, `for_cat`, `nixInfo.lze.lsp`), the lzextras LSP handler
  pattern, and the treesitter main-branch attach autocmd.
- Current state to replace: `modules/common/development/neovim.nix` +
  `modules/common/development/neovim/init.lua` (port its options, oil,
  mini.pick, obsidian-vault-detection, and LSP keymaps into the new layout).

## Workstream A — Neovim

Execute Phases 0–5 exactly as written in the plan. Condensed:

**Phase 0 — flake plumbing.** Add input
`wrappers = { url = "github:BirdeeHub/nix-wrapper-modules"; inputs.nixpkgs.follows = "nixpkgs"; }`.
The flake currently passes *filtered* input sets per host
(`guiNixosInputs`/`wslNixosInputs`/`darwinInputs` in `flake.nix`) — `wrappers`
must reach **all four hosts**. Preferred: delete the filtering and pass
`inputs` whole (also fixes a latent bug: `hosts/metasepia/default.nix` reads
`inputs.self.rev`, which is silently `null` because `self` isn't in
`darwinInputs`). Add a `packages.<system>.nvim` flake output wired to
`evalPackage` so `nix run .#nvim` tests the editor without a system rebuild.

**Phase 1 — parity skeleton.** Create
`modules/common/development/neovim/{default.nix,module.nix,nvim/}` per the
plan's layout section. `default.nix` installs
`inputs.wrappers.lib.evalPackage [ ./module.nix { inherit pkgs; } ]` into
`environment.systemPackages` and owns `EDITOR`/`MANPAGER` (move them out of
`cli.nix`). `module.nix` imports `wlib.wrapperModules.neovim`, sets
`settings.config_directory = ./nvim`, `settings.aliases = [ "vi" "vim" ]`,
the `runtimePkgs` specMods recipe, and parity specs (lze/lzextras,
treesitter, oil, mini, obsidian lazy, lspconfig + lua-language-server/nixd/
marksman as that spec's runtimePkgs). Port the old `init.lua` into
`nvim/init.lua` with the template's nixInfo shim on top.
Required cleanups in this phase: remove `vim` from `cli.nix` (collides with
the `vim` alias); remove the three global LSP servers from
`modules/common/development/neovim.nix`'s package list; then delete that old
file entirely and make sure `development/default.nix` imports `./neovim`.

**Phase 2 — Lua restructure + lze.** Split into
`lua/{options,keymaps}.lua` and `lua/plugins/*.lua` per the plan's tree.
Register the template's three lze handlers. Add the read-only
`settings.cats` option in `module.nix`. Mark non-startup plugins
`lazy = true` in Nix with matching lze triggers in Lua.

**Phase 3 — LSP + completion.** blink.cmp (+ friendly-snippets) lazy on
`DeferredUIEnter`; lzextras LSP handler with the shared `on_attach` keymaps
listed in the plan (picker-backed maps use mini.pick/mini.extra, NOT
telescope/snacks); one `specs.lang.<name>` per language carrying its own
`runtimePkgs`, exactly per the plan's table (lua, nix, markdown, ts, python,
rust, go, zig, c). Each server gets a small lze spec gated by
`for_cat = "lang.<name>"` — check how nested spec names surface in
`settings.cats` (it maps over top-level specs; you may need
`specs."lang.lua"` style flat names or a flattened cats export; pick one and
be consistent).

**Phase 4 — extras.** conform.nvim, nvim-lint, gitsigns, which-key,
nvim-surround, mini.pairs, todo-comments, fidget, undotree,
mini.statusline, colorscheme-as-nix-option, obsidian vault path from Nix.
For the vault path: add an option in `default.nix`
(`development.neovim.obsidianVault`, nullable string) and pass it through as
an extra module in the evalPackage list:
`evalPackage [ ./module.nix { inherit pkgs; info.obsidian_vault = cfg.obsidianVault; } ]`.
Set it on metasepia to the iCloud path found in the old init.lua; Lua falls
back to the existing candidate-detection when the info value is nil.

**Phase 5 — polish.** `development.neovim.impureConfig` bool option that
switches `settings.config_directory` to the absolute repo-checkout path
(home prefix via `pkgs.stdenv.isDarwin`: `/Users/sqibo` vs `/home/sqibo`).
Update `README.md` with the layout and the fast-iteration workflow.

### Workstream A verification (run after every phase)

```sh
nix flake lock                      # after Phase 0 only
nix build .#nvim                    # or: nix run .#nvim
nix build .#darwinConfigurations.metasepia.system            # full darwin eval+build
nix eval --raw .#nixosConfigurations.hapalo.config.system.build.toplevel.drvPath
nix eval --raw .#nixosConfigurations.lunalata.config.system.build.toplevel.drvPath
```

(NixOS hosts are x86_64-linux, so on the Mac only *eval* them — the two
`nix eval` lines must succeed even though a build can't run there.)

Manual smoke test via `nix run .#nvim` after Phases 1, 3, 4:
`-` opens oil; `<leader>ff`/`<leader>fg` pick/grep; open a `.nix` file →
nixd attaches (`:LspInfo`) and completion menu appears while typing;
`gd`/`K`/`<leader>rn` work; `:checkhealth` has no errors from our plugins;
`:lua nixInfo.lze.debug.display(nixInfo.plugins)` shows the expected
start/lazy split (Phase 2+).

### Known gotchas

- nixpkgs-unstable ships nvim-treesitter's **main branch**: there is no
  `require("nvim-treesitter.configs")`. Use the template's FileType-autocmd
  attach pattern.
- Spec ordering: the main init.lua is spec `INIT_MAIN`; specs run after it
  unless `before = [ "INIT_MAIN" ]`.
- `pluginDeps` defaults to `"startup"`, so nixpkgs plugin `dependencies`
  (e.g. plenary for obsidian-nvim) come along automatically — don't add them
  manually.
- `vimPlugins.obsidian-nvim` is the maintained community fork; it integrates
  with blink.cmp automatically. Don't configure an nvim-cmp source for it.

## Workstream B — tmux

Follow the plan's "Workstream B" section exactly; the target file is
`modules/common/development/tmux.nix`. Summary of the required end state:

1. Plugins `sensible`, `yank`, `resurrect`, `continuum` (that order) loaded
   via generated `run-shell ${plugin.rtp}` lines at the END of
   `extraConfig` — nix-darwin's `programs.tmux` has no `plugins` option, so
   this generation is the cross-platform mechanism. Delete the dead
   `environment.systemPackages` tmuxPlugins block.
2. Plugin options set BEFORE the run-shell lines, continuum loaded last and
   after `status-right`:
   `@resurrect-capture-pane-contents on`, `@resurrect-strategy-nvim session`,
   `@continuum-restore on`, `@continuum-save-interval 10`.
   Do NOT set `@continuum-boot` (leave server start manual).
3. Replace the macOS-only `copy-pipe-and-cancel "pbcopy"` binding — tmux-yank
   handles clipboard per-platform (`y` in copy-mode-vi).
4. Consolidate the macOS dotfiles config: fold the keepers from
   `modules/macos/configs/tmux.conf` into `extraConfig`
   (base-index 1 + pane-base-index 1, renumber-windows, the window-status
   dot indicators + styles, pane-border styles), then delete that file and
   remove its symlink block from `modules/macos/dotfiles.nix` (also drop
   `tmux` from that file's mkdir loop). **Prefix key: adopt the backtick
   prefix** (`unbind C-b; set -g prefix \`; bind \` send-prefix`) on all
   hosts, since that's what the macOS config actively used — and call this
   decision out in your final report so the user can veto it.
   Keep `bind r source-file /etc/tmux.conf` (extraConfig lands in
   /etc/tmux.conf on both OSes; the old `~/.config/tmux/tmux.conf` reload
   binding from the dotfiles version is the one to drop).

### Workstream B verification

Eval checks as above, then on this machine after `darwin-rebuild switch`:
start `tmux`, split some panes, press `prefix + Ctrl-s` → status line
confirms save and `~/.local/share/tmux/resurrect/` (or `~/.tmux/resurrect/`)
gains a file; `tmux kill-server`; start `tmux` again → layout restores
automatically (continuum). Verify `y` in copy-mode puts text on the system
clipboard.

## Final report

List: commits made; every file deleted or moved; the two decisions to
confirm (backtick prefix; colorscheme chosen); any deviation from the plan
and why; the verification commands you ran with their outcomes; anything you
could not verify (e.g. NixOS runtime behavior — eval-only on this machine)
flagged explicitly as unverified.
