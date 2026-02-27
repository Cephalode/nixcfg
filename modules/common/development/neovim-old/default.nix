{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
  };

  outputs = { self, nixpkgs, ... }@inputs: let
    inherit (inputs.nixCats) utils;
    luaPath = ./.;
    forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;
    extra_pkg_config = {
      allowUnfree = true;
    };

    dependencyOverlays = [
      (utils.standardPluginOverlay inputs)
    ];
    categoryDefinitions = { pkgs, settings, categories, extra, name, mkPlugin, ... }@packageDef: {
      lspsAndRuntimeDeps = with pkgs; {
        general = [
          ripgrep
          fd
          fzf
          tree-sitter
          universal-ctags
        ];

        lint = [];
        debug = [];

        format = [
          stylua
          nodePackages.prettier
          nixfmt-rfc-style
        ];

        neonixdev = [
          lua-language-server
          marksman
          nixd
          pyright
          typescript-language-server
          zls
        ];
      };

      startupPlugins = with pkgs.vimPlugins; {
        debug = [];

        general = {
          always = [
            lze
            lzextras
            vim-repeat
            plenary-nvim
            (nvim-notify.overrideAttrs { doCheck = false; })
          ];

          extra = [
            oil-nvim
            nvim-web-devicons
          ];
        };
      };

      optionalPlugins = with pkgs.vimPlugins; {
        debug = {
          default = [
            nvim-dap
            nvim-dap-ui
            nvim-dap-virtual-text
          ];
        };

        lint = [
          nvim-lint
        ];
        format = [
          conform-nvim
        ];

        markdown = [
          markdown-preview-nvim
          obsidian-nvim
          # vim-pandoc
        ];

        neoixdev = [
          lazydev-nvim
        ];

        general = {
          blink = [
            blink-cmp
            blink-compat
            cmp-cmd-line
            colorful-menu-nvim
            luasnip
          ];

          treesitter = [
            nvim-treesitter-textobjects
            nvim-treesitter.withAllGrammars
          ];

          mini = [
            mini-pick
          ];

          always = [
            gitsigns-nvim
            lualine-nvim
            nvim-lspconfig
            nvim-surround
            vim-sleuth
            vim-fugitive
            vim-rhubarb
          ];

          extra = [
            comment-nvim
            fidget-nvim
            hlargs-nvim
            image-nvim
            indent-blankline-nvim
            neotree
            nui-nvim
            pomo-nvim
            smear-cursor-nvim
            vim-be-good
            vim-repeat
            vim-startuptime
            undotree
            which-key-nvim
          ];
        };
      };

      python3.libaries = {
        test = (_:[]);
      };
      extraLuaPackages = {
        general = [ (_:[]) ];
      };

      extraCats = {
        test = [
          [ "test" "default" ]
        ];
        debug = [
          [ "debug" "default" ]
        ];
      };

      packageDefinitions.replace = {
        nixCats = { pkgs, name, ... }@misc: {
          settings = {
            suffix-path = true;
            suffix-LD = true;
            aliases = [ "nvim" "vim" "vi" ];
            wrapRc = true;
            configDirName = "neovim";
            # neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;
            hosts.python3.enable = true;
            host.node.enable = true;
          };

          # Enables custom categories in categoryDefinitions
          categories = {
            markdown = true;
            general = true;
            lint = true;
            format = true;
            neonixdev = true;
            lspDebugMode = false;
          };
        };

        regularCats = { pkgs, ... }@misc: {
          settings = {
            suffix-path = true;
            suffix-LD = true;
            wrapRc = false;
            configDirName = "neovim";
            aliases = [ "testCat" ];
          };

          categories = {
            markdown = true;
            general = true;
            neonixdev = true;
            lint = true;
            format = true;
            lspDebugMode = false;
          };
          extra = {
            nixdExtras = {
              nixpkgs = ''import ${pkgs.path} {}'';
            };
          };
        };
      };

      defaultPackageName = "nvim";

    in
    forEachSystem (system: let
      nixCatsBuilder = utils.baseBuilder defaultPackageName;

      pkgs = import nixpkgs { inherit system; };

    in {
      packages = utils.mkAllWithDefault defaultPackage;

      devShells = {
        default = pkgs.mkShell {
          name = defaultPackageName;
          packages = [ defaultPackage ];
          inputsFrom = [ ];
          shellHook = ''
          '';
        };
      };
    }) // (let
      nixosModule = utils.mkNixosModules {
        moduleNamespace = [ defaultPackageName ];
        inherit defaultPackageName dependencyOverlays luaPath
          categoryDefinitions packageDefinitions extra_pkg_config nixpkgs;
      };
      nixosModule = utils.mkNixosModules {
        moduleNamespace = [ defaultPackageName ];
        inherit defaultPackageName dependencyOverlays luaPath
          categoryDefinitions packageDefinitions extra_pkg_config nixpkgs;
      };
    in {
      overlay = utils.makeOverlays luaPath {
        inherit nixpkgs dependencyOverlays extra_pkg_config;
      } categoryDefinitions packageDefinitions defaultPackageName;

      nixosModules.default = nixosModule;

  };
}
