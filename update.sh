#!/usr/bin/env bash

os="$(uname -s)"

# $1 can be used for adding --upgrade
if [[ "$os" == "Linux" ]]; then
  nixos-rebuild switch $1 --flake .#$HOSTNAME --elevate=sudo
elif [[ "$os" == "Darwin" ]]; then
  sudo darwin-rebuild switch $1 --flake .#$HOSTNAME
fi
