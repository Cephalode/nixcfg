# Hosts

## NixOS

### Hapalo (Gaming PC)
- Named after the blue-ringed octopus clade (hapalochlaena)
due to its colorful RGB and deadly performance
- Runs NixOS and dual boots with Windows for games that do not support Linux

#### Lunalata (Windows Gaming)
- Named after the second half of the greater blue-ringed octopus' name (hapalochlaena lunalata)
- This is the Hapalo machine when dual-booted into Windows
- TODO: NixOS WSL System flake implementation

#### Specs
- CPU: AMD Ryzen 7 5800X
- GPU: Nvidia RTX 3080
    - 10GB VRAM
    - Low Hash rate
    - EVGA FTW3
- RAM: 32GB 3200 MHz
    - 4*8GB (two dual channel sets)
    - Running at 2866 MHz because 3200 MHz is too unstable and crashes

### Loligo (Laptop)
- Named after the common squid (loligo vulgaris)
since this is a run-of-the-mill but portable machine as common squids are pretty small
- Runs solely on NixOS.

#### Specs
- CPU: Intel i5-1250P
    - 12 Cores (4 performance (4.4 GHz), 8 efficiency cores (3.3 GHz))
    - 16 Threads (2 threads per performance cores?)
    - 12 MB cache
- GPU 1: Intel Iris Xe (Integrated)
- GPU 2: Nvidia MX550 (Discrete)
- RAM: 16GB
- Display: 14" 1920x1080

## MacOS (Nix Darwin)
### Metasepia (Mac Mini)
- Named after the flamboyant cuttlefish (metasepia pfefferi)
due to "sepia" being also the name of cuttlefish ink (hints at creativity)
- Planned to turn into a 24/7 Clawdbot machine
- Can be viewed as the meta version of the next device; Sepia
- TODO: Metasepia clade has been moved into Ascarosepion clade in 2023 (rename required)
#### Specs
- CPU/GPU: M4
    - 10 core CPU, 10 core GPU
- Unified Memory: 16GB


# Non-host devices
These will not be in the hosts directory for this flake but may be referenced by name.

## Sepia (iPad)
- Named after the common cuttlefish (sepia officinalis)
since iPads are more creative machines and sepia is also the name of the ink cuttlefishes produce, which is widely used by artists

## Idiosepius (iPhone Air)
- Named after the two-toned pygmy squid (idiosepius pygmaeus)
because it's light and fits the naming scheme with the other Apple products.

## Onycho (Bambu Lab P2S)
- Named after the hooked squid clade (onychoteuthidae)
since this machine a useful tool, similar to these squids' hooked clubs
- Plans to move to dev mode to use Orca Slicer on it


# How to run
```
./update.sh
```
You will be prompted to enter your sudo password. The script simply calls one single nix-rebuild command:
```bash
sudo nixos-rebuild switch --flake .#$HOSTNAME
```

or the following for MacOS on Nix Darwin:
```bash
sudo nix-darwin switch --flake .#$HOSTNAME
```


# Future systems

## Apple devices
Since all my Apple devices have sepia/sepius in their names,
future devices should also follow this for consistency.
- One thing to note however, idiosepius is a clade of squid,
unlike sepia and metasepia, which are cuttlefish (a specific type of squid)
Might be in need of a change,
where everything is in the clade sepiidae (cuttlefish),
but idiosepiidae ar esome of the closest relatives to cuttlefish

### Possible names
Sepiidae:
- Sepia
- ~~Metasepia~~ Ascarosepion
    - Ascarosepion tullbergi (Paintpot cuttlefish) fits well
    - Lots have aggressive names aside from a few
- Acanthosepion
    - Closest relative to ascarosepion
    - Most have weird names
- Aurosepina
    - Only includes the arabian cuttlefish, aurosepina arabica
- Decorisepia
    - Something related to decoration?
    - Australian cuttlefish?
- Digitosepia
    - Something finger related?
- Doratosepion
- Erythalassa
    - loses sepia naming scheme
    - only includes the trident cuttlefish, erythalassa trygonina
- Hemisepius
    - Only the hemisepius typicus
- Lusepia
    - Only the lusepia hieronis
- Rhombosepion
    - Includes elegant and pink cuttlefishes
- Sepiella
    - Spineless cuttlefishes
    - Foldables if any ever come out?
- Spathidosepion
    - Mysterious clade that are only known from found cuttlebones

## Printers
Since my first P2S is called onycho; 
named after the onychoteuthis, the clade of hooked squids,
future printers can also be part of the same clade.
- There seems to be only 10 confirmed species.
- The clade gonatidae also has hooks
- The colossal squid (the biggest cephalopod)
is the only hooked squid from it's family (cranchiidae)
- Seems like only two are given common names,
the common and boreal clubhook squids

### Possible names
- Banksii
    - Common clubhook squid
    - Generic machine (Ender 3 or A1 if I ever get one?)
- Borealijaponica
    - Boreal clubhook squid
    - Cool name and origin
- Compacta
    - Small but can print large volumes?

## Non-Mac Computers
So either computers running Windows, Linux, or in some alternate universe, BSD.
- Probably okay to name after any cephalopods
#TODO
