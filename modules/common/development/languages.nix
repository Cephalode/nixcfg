{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    lua
    go
    python3
    typescript
    zig # Zig and C compiler (faster than any other C compiler)
  ];
}
