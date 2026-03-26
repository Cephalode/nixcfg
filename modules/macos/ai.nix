# AI workloads and tools configuration for macOS
# Includes local LLMs, ML development tools, and AI-related utilities

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ddgr
    openclaw
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "openclaw-2026.2.26"
  ];
}
