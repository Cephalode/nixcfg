#!/usr/bin/env bash

os="$(uname -s)"

# $1 can be used for adding --upgrade
if [[ "$os" == "Linux" ]]; then
  nixos-rebuild switch $1 --flake .#$HOSTNAME --elevate=sudo
elif [[ "$os" == "Darwin" ]]; then
  if [ "$(launchctl managername)" != "Aqua" ]; then
    echo "tmux session is in Background (started from SSH)." >&2
    echo "Run 'tmux kill-server' from a local terminal, then restart tmux." >&2
    exit 1
  fi
  sudo darwin-rebuild switch $1 --flake .#$HOSTNAME
fi
