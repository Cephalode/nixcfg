# AI Configuration for OpenClaw
#
# z.ai GLM-4-7B Setup:
# - Set ZAI_API_KEY environment variable with your z.ai API key
# - The provider is configured in ~/.openclaw/openclaw.json
# - Default model: zai/glm-4-7b
# - Base URL: https://api.z.ai/v1
#
# Other available providers:
# - ollama: Local models (gemma4:e2b by default)
# - pi-coding-agent: For pi coding agent integration

{ inputs, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ddgr
    himalaya
    ollama
    openclaw
    pi-coding-agent
  ];
  homebrew.brews = [
    "lume"
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "openclaw-2026.4.2"
  ];
}
