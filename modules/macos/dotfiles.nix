# modules/macos/dotfiles.nix
#
# Nix-managed dotfiles for macOS.
# Config files live in ./configs/ and are symlinked into ~/.config/ at activation.
# To modify any config, edit the files in configs/ and run `darwin-rebuild switch`.

{ pkgs, ... }:

let
  configs = ./configs;
  user = "sqibo";
  configHome = "/Users/${user}/.config";
in
{
  system.activationScripts.dotfiles.text = ''
    echo "Setting up nix-managed dotfiles..."

    # Ensure directories exist
    for dir in git starship kitty tmux aerospace karabiner zsh scripts; do
      mkdir -p "${configHome}/$dir"
    done

    # Git
    ln -sfn ${configs}/git/config   ${configHome}/git/config
    ln -sfn ${configs}/git/template ${configHome}/git/template

    # Starship
    ln -sfn ${configs}/starship.toml ${configHome}/starship/starship.toml

    # Kitty
    ln -sfn ${configs}/kitty.conf       ${configHome}/kitty/kitty.conf
    ln -sfn ${configs}/kitty-theme.conf ${configHome}/kitty/current-theme.conf

    # Tmux (remove stale regular file if present, then symlink)
    rm -f ${configHome}/tmux/tmux.conf
    ln -sfn ${configs}/tmux.conf ${configHome}/tmux/tmux.conf

    # Aerospace
    ln -sfn ${configs}/aerospace.toml ${configHome}/aerospace/aerospace.toml

    # Karabiner
    ln -sfn ${configs}/karabiner.json ${configHome}/karabiner/karabiner.json

    # Zsh
    ln -sfn ${configs}/zsh/.zshenv  ${configHome}/zsh/.zshenv
    ln -sfn ${configs}/zsh/.zshrc   ${configHome}/zsh/.zshrc
    ln -sfn ${configs}/zsh/aliases  ${configHome}/zsh/aliases
    ln -sfn ${configs}/zsh/functions ${configHome}/zsh/functions

    # Scripts
    chmod +x ${configs}/scripts/on
    ln -sfn ${configs}/scripts/on ${configHome}/scripts/on

    # Remove legacy ~/.zshrc symlink (old dotfiles repo, references /Users/omerxx)
    if [ -L "/Users/${user}/.zshrc" ]; then
      echo "  Removing legacy ~/.zshrc symlink"
      rm -f "/Users/${user}/.zshrc"
    fi

    echo "Dotfiles setup complete."
  '';
}
