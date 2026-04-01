# AI workloads and tools configuration for macOS
# Includes local LLMs, ML development tools, and AI-related utilities
# Note: Common agent tools are in modules/common/development/agents.nix

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ddgr           # DuckDuckGo CLI for web search (preferred over web_search)
    himalaya       # Email CLI for Gmail read/search
    openclaw       # OpenClaw Gateway agent infrastructure
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "openclaw-2026.2.26"
  ];
}
