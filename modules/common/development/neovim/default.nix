{
  inputs,
  ...
}:
let
  utils = inputs.nixCats.utils;
in
{
  imports = [
    inputs.nixCats.nixosModules.default
  ];
  config = {
    nixCats = {
      enable = true;
      nixpkgs_version = inputs.nixpkgs;
      addOverlays = [
        (utils.standardPluginOverlay inputs)
      ];
      packageNames = [ "myNixModuleNvim" ];

      luaPath = ./.;

      categoryDefinitions.replace = (
        {
          pkgs,
          settings,
          categories,
          extra,
          name,
          mkPlugin,
          ...
        }@packageDef:
        {
          lspsAndRuntimeDeps = with pkgs; {
            general = [
              ripgrep
              fd
              fzf
              tree-sitter
            ];

            lsps = [
              gopls
              lua-language-server
              marksman
              nixd
              zls
            ];
            extras = [
              nix-doc
            ];
          };

          startupPlugins = with pkgs.vimPlugins; {
            general = [
              lze
              lzextras
            ];

            debug = [
              vim-startuptime
            ];

            navigation = [
              mini-pick
              oil-nvim
            ];
          };

          optionalPlugins = with pkgs.vimPlugins; {
            general = [
              nvim-lspconfig
              nvim-treesitter.withAllGrammars
              vim-tmux-navigator
            ];

            markdown = [
              markdown-preview-nvim
              obsidian-nvim
              plenary-nvim
              # vim-pandoc
            ];

            extra = [
              fidget-nvim
              image-nvim
              pomo-nvim
              smear-cursor-nvim
              vim-be-good
              vim-repeat
            ];
          };
        }
      );

      packageDefinitions.replace = {
        myNixModuleNvim =
          { pkgs, name, ... }:
          {
            settings = {
              suffix-path = true;
              suffix-LD = true;
              wrapRc = true;
              # unwrappedCfgPath = "/path/to/config";
              aliases = [
                "nvim"
                "vim"
                "vi"
              ];
              # neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;
            };
            categories = { # Enables custom categories in categoryDefinitions
              general = true;
              debug = true;
              lsps = true;
              markdown = true;
              navigation = true;
              extra = true;
            };
          };
      };
    };
  };
}
