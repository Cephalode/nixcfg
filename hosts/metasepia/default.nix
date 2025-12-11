{
    description = "Sqibo's nix-darwin system flake";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
        nix-darwin.url = "github:nix-darwin/nix-darwin/master";
        nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
        nix-homebrew.url = "github:zhaofengli/nix-homebrew";

        # Optional: Declarative tap management
        homebrew-core = {
            url = "github:homebrew/homebrew-core";
            flake = false;
        };
        homebrew-cask = {
            url = "github:homebrew/homebrew-cask";    
            flake = false;
        };
    };

    outputs = inputs@{ 
        self, 
        nix-darwin, 
        nixpkgs, 
        nix-homebrew, 
        homebrew-core, 
        homebrew-cask,
    }:
    let
        configuration = { pkgs, config, ... }: {
            nixpkgs.config.allowUnfree = true; # Allow closed source software

			# Packages from Nix
            environment.systemPackages = with pkgs; [
                aerospace
                btop
				cursor-cli
				code-cursor
                fzf
				hub
				jq
                mkalias # Allows apps in /Applications/Nix to show up in Raycast
                tmux
				tree-sitter # Neovim plugin
                uwufetch
                xdg-ninja # Checks home folder for unnecessary dotfiles 
            ];
    
            # Packages from brew
            homebrew = {
                enable = true;
                taps = [
                ];
                brews = [
                    "mas" # mac appstore cli
                    "sox" # reroute audio
                    "bob" # neovim version manager (using it to access vim.pack in v0.12 nightly)
					"nvm" # node version manager
                ];
                casks = [
					"bambu-studio"
					"beeper" # the nix package does not support aarch64
                    "discord"
                    "ghostty"
                    "karabiner-elements"
                    "obs"
                    "obsidian"
					"raycast"
					"mactex"
                ];
                masApps = { # Mac Appstore apps
                };
    
                onActivation = {
                    autoUpdate = true;
                    # cleanup = "zap"; # Has issues with aerospace
                    upgrade = true;
                };
                global = {
                    brewfile = true;
                };
            };
            fonts.packages = [
            ];
    
            system.activationScripts.applications.text = let
                env = pkgs.buildEnv {
                    name = "system-applications";
                    paths = config.environment.systemPackages;
                    pathsToLink = "/Applications";
                };
            in
                pkgs.lib.mkForce ''
                    # Set up applications.
                    echo "setting up /Applications..." >&2
                    rm -rf /Applications/Nix\ Apps
                    mkdir -p /Applications/Nix\ Apps
                    find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
                    while read -r src; do
                        app_name=$(basename "$src")
                        echo "copying $src" >&2
                        ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
                    done
                '';

            system.defaults = {
                dock = {
                    autohide = true;
					autohide-delay = 0.00;
					orientation = "left";
                    persistent-apps = [
                    ];
					scroll-to-open = true;	# Scroll on a dock app to show all windows
					show-recents = false;

                }; 
                finder = { 
					FXPreferredViewStyle = "clmv";
					FXEnableExtensionChangeWarning = false;
				};
                loginwindow = {
                    GuestEnabled = false;

				};
                NSGlobalDomain.AppleInterfaceStyle = "Dark";
                NSGlobalDomain.KeyRepeat = 2;
				LaunchServices.LSQuarantine = false;
            };


			# Programs
			programs.zsh = {
			    enable = true;
				enableAutosuggestions = true;
				enableBashCompletion = true;
				enableCompletion = true;
				enableFastSyntaxHighlighting = true;
				enableFzfCompletion = true;
				enableFzfGit = true;
				enableFzfHistory = true;
				enableGlobalCompInit = false;
				enableSyntaxHighlighting = false;
				# interactiveShellInit = "";
				# loginShellInit = "";
				# promptInit = "";
				# shellInit = "";
				variables = {
				    XDG_CONFIG_HOME="$HOME/.config";
					ZDOTDIR="$XDG_CONFIG_HOME/zsh";
				};
			};

            nix.settings.experimental-features = "nix-command flakes"; # Enable flakes
            system.primaryUser = "sqibo"; # Sets user
            system.configurationRevision = self.rev or self.dirtyRev or null; # Sets git hash
            system.stateVersion = 6;
            nixpkgs.hostPlatform = "aarch64-darwin"; # Architecture
        }; 
    in
    {
        # Build darwin flake using:
        # $ sudo darwin-rebuild switch
        darwinConfigurations."sqibo-mac" = nix-darwin.lib.darwinSystem {
            modules = [ 
                configuration
                nix-homebrew.darwinModules.nix-homebrew
                {
                    nix-homebrew = {
                        enable = true;
                        # enableRosetta = true;
                        user = "sqibo";
                        autoMigrate = true;
                    };
                }
            ];
        };
    };
}
