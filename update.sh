#!/usr/bin/env bash
sudo nixos-rebuild switch $1 --flake .#$HOSTNAME
