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
          lspsAndRuntimeDeps = {
            general = with pkgs; [
              ripgrep
              fd
              fzf
              tree-sitter
            ];

            lsps = with pkgs; [
              gopls
              lua-language-server
              marksman
              nix-doc
              nixd
              zls
            ];
          };

          startupPlugins = with pkgs.vimPlugins; {
            general = [
              # plugin loader / manager must be available immediately
              lze
              lzextras
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
              vim-pandoc
            ];

            navigation = [
              mini-pick
              oil-nvim
            ];

            extra = [
              fidget-nvim
              image-nvim
              vim-repeat
              smear-cursor-nvim
              vim-be-good
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
            categories = {
              # Enables custom categories in categoryDefinitions
              general = true;
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
