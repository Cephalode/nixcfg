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
              gopls
              lua-language-server
              nixd
            ];
          };

          startupPlugins = {
            general = with pkgs.vimPlugins; [
              oil-nvim
              mini-pick
              nvim-treesitter.withAllGrammars
              nvim-lspconfig
              render-markdown-nvim
            ];
          };

          optionalPlugins = {
            general = [ ];
          };

          sharedLibraries = {
            general = with pkgs; [
              # libgit2
            ];
          };

          environmentVariables = {
            test = {
              CATTESTVAR = "It worked!";
            };
          };

          extraWrapperArgs = {
            test = [
              ''--set CATTESTVAR2 "It worked again!"''
            ];
          };

          python3.libraries = {
            test = (_: [ ]);
          };

          extraLuaPackages = {
            test = [ (_: [ ]) ];
          };
        }
      );

      packageDefinitions.replace = {
        # These are the names of your packages
        # you can include as many as you wish.
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
              general = true;
            };
          };
      };
    };
  };
}
