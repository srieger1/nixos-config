{ config, pkgs, inputs, ... }:
let
  ompConfig = (pkgs.formats.yaml { }).generate "oh-my-pi-config.yml" {
    modelRoles = {
      ## anthropic high:
      #default = "anthropic/claude-opus-5:high";
      #advisor = "anthropic/claude-opus-4-8:high";
      ## anthropic medium (used until 8/2026)
      #default = "anthropic/claude-sonnet-5:high";
      #advisor = "anthropic/claude-sonnet-4.5:high";
      #tiny = "anthropic/claude-haiku-4-5:medium";
      #smol = "anthropic/claude-haiku-4-5:medium";
      default = "openrouter/z-ai/glm-5.3-flash:high";
      advisor = "openrouter/z-ai/glm-5.2:free:high";
      tiny = "openrouter/nvidia/nemotron-3.5-lightning:free:high";
      smol = "openrouter/google/gemma-4-26b-a4b-it:free:high";
    };
    advisor.enabled = true;
    autolearn.enabled = true;
    memory.backend = "mnemopi";
    mnemopi.polyphonicRecall = true;
    mnemopi.enhancedRecall = true;
    mnemopi.autoRetain = false;
    mnemopi.recallLimit = 24;
    mnemopi.proactiveLinking = true;
    providers.memoryModel = "online";
  };

  ompConfigPath = "${config.home.homeDirectory}/.omp/agent/nix-config.yml";
in
{
  home.packages = [
    inputs.llm-agents-nix.packages.${pkgs.stdenv.hostPlatform.system}.omp
  ];

  home.file.".omp/agent/nix-config.yml".source = ompConfig;

  home.sessionVariables.PI_CONFIG_FILES = ompConfigPath;
}
