# Agent and AI tools - tools used by OpenClaw agent for assisting Sqibo
# Note: macOS-specific agent tools are in modules/macos/ai.nix

{
  inputs,
  pkgs,
  ...}:
{
  environment.systemPackages = with pkgs; [
    claude-code    # Anthropic's Claude Code agent
    opencode       # AI coding assistant
  ];
}
