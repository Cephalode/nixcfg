#!/usr/bin/env bash

os="$(uname -s)"

if [[ "$os" == "Linux" ]]; then
  sudo nixos-rebuild switch $1 --flake .#$HOSTNAME
elif [[ "$os" == "Darwin" ]]; then
  sudo darwin-rebuild switch $1 --flake .#$HOSTNAME
fi
