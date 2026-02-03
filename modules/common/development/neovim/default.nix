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

            format = [
              stylua
              nodePackages.prettier
              nixfmt-rfc-style
            ];

            lsps = [
              gopls
              lua-language-server
              marksman
              nixd
              pyright
              typescript-language-server
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
          };

          optionalPlugins = with pkgs.vimPlugins; {
            general = [
              cmp-nvim-lsp
              nvim-lspconfig
              nvim-treesitter.withAllGrammars
              vim-tmux-navigator
            ];

            navigation = [
              mini-pick
              neo-tree-nvim
              oil-nvim
            ];

            markdown = [
              markdown-preview-nvim
              obsidian-nvim
              # vim-pandoc
            ];

            debug = [
              vim-startuptime
            ];

            utils = [
              plenary-nvim
            ];

            extras = [
              fidget-nvim
              image-nvim
              nui-nvim
              nvim-web-devicons
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
              add_nix_path = true;
              aliases = [
                "nvim"
                "vim"
                "vi"
              ];
              # neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;
            };
            # Enables custom categories in categoryDefinitions
            categories = {
              general = true;
              debug = true;
              format = true;
              lsps = true;
              utils = true;
              markdown = true;
              navigation = true;
              extras = true;
            };
          };
      };
    };
  };
}
