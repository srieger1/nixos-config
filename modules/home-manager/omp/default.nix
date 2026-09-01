{
  config,
  pkgs,
  inputs,
  ...
}:
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
      #advisor = "openrouter/z-ai/glm-5.2:free:high";
      advisor = "openrouter/z-ai/glm-5.3-flash:high";
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

  # Alternative model configs: `omp --config <file>` layers an overlay on top
  # of the base nix-config.yml (modelRoles override, everything else such as
  # memory/mnemopi settings is inherited). Launch via the omp-* wrappers below.
  ompClaude = (pkgs.formats.yaml { }).generate "omp-claude.yml" {
    modelRoles = {
      default = "anthropic/claude-sonnet-5:high";
      advisor = "anthropic/claude-sonnet-5:high";
      smol = "anthropic/claude-haiku-4.5:medium";
      tiny = "anthropic/claude-haiku-4.5:medium";
    };
  };

  # ollama runs on host gpu4 (tailscale). No separate smol/tiny roles: they
  # are pinned to the default model so prewalk/plan-yolo stay on qwen too.
  ompGpu4 = (pkgs.formats.yaml { }).generate "omp-gpu4-qwen3.8.yml" {
    modelRoles = {
      default = "ollama/qwen3.8:27b-128k";
      advisor = "ollama/qwen3.8:27b-128k";
      smol = "ollama/qwen3.8:27b-128k";
      tiny = "ollama/qwen3.8:27b-128k";
    };
  };

  ompLocalAi = (pkgs.formats.yaml { }).generate "omp-local-ai.yml" {
    modelRoles = {
      #default = "lm-studio/qwen/qwen3-30b-a3b-2507";
      default = "lm-studio/google/gemma-4-e4b";
    };
    advisor.enabled = false;
    autolearn.enabled = false;
  };

  # Launcher wrappers: exec plain `omp` with the extra overlay plus the
  # provider endpoint env vars (OLLAMA_HOST / LM_STUDIO_BASE_URL are how
  # omp reaches these local providers; no baseUrl config key exists).
  ompClaudeBin = pkgs.writeShellScriptBin "omp-claude" ''
    exec omp --config ${ompClaude} "$@"
  '';
  ompGpu4Bin = pkgs.writeShellScriptBin "omp-gpu4" ''
    export OLLAMA_HOST=http://gpu4:11434
    exec omp --config ${ompGpu4} "$@"
  '';
  ompLocalAiBin = pkgs.writeShellScriptBin "omp-local-ai" ''
    export LM_STUDIO_BASE_URL=http://localhost:1234/v1
    exec omp --config ${ompLocalAi} "$@"
  '';

  ompConfigPath = "${config.home.homeDirectory}/.omp/agent/nix-config.yml";
in
{
  home.packages = [
    inputs.llm-agents-nix.packages.${pkgs.stdenv.hostPlatform.system}.omp
    ompClaudeBin
    ompGpu4Bin
    ompLocalAiBin
  ];

  home.file.".omp/agent/nix-config.yml".source = ompConfig;

  home.sessionVariables.PI_CONFIG_FILES = ompConfigPath;
}
