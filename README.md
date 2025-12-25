# Hosts ## NixOS

### Hapalo (Gaming PC)
- Named after the blue-ringed octopus (hapalochlaena) due to colorful RGB and deadly performance
- Runs NixOS and dual boots with Windows for games that do not support Linux.

### Loligo (Laptop)
- Named after the common squid (loligo vulgaris) since this is a run-of-the-mill but portable machine as common squids are pretty small.
- Will most likely only run NixOS.

# Non-host devices
These will not be in the hosts directory but may be referenced by name.

## Sepia (iPad)
- Named after the common cuttlefish (sepia officinalis) since iPads are more creative machines and sepia is also the name of the ink cuttlefishes produce, which is widely used by artists.
- Will only run iPadOS.

# How to run
`./update.sh`
You will be prompted to enter your sudo password. The script simply calls one single nix-rebuild command:
`sudo nixos-rebuild switch --flake .#$HOSTNAME`

or the following for MacOS on Nix Darwin:
`sudo nix-darwin switch --flake .#$HOSTNAME`
