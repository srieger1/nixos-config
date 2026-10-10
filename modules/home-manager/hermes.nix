# hermes.nix
#
# hermes-agent (NousResearch) as CLI + desktop app, with its gateway daemon
# for the matrix bridge. The gateway daemon runs as a user service; the
# interactive `hermes gateway setup` (Matrix credentials) is done once and
# its runtime keys survive the settings deep-merge — never put credentials
# in declarative `settings` (nix store is world-readable).

{ inputs, ... }:
{
  imports = [ inputs.hermes-agent.homeManagerModules.default ];

  programs.hermes-agent = {
    enable = true;
    desktop.enable = true;
  };

  services.hermes-agent = {
    enable = true;
    gateway.enable = true;
    settings.model = {
      default = "gpt-oss:20b";
      provider = "custom";
      base_url = "http://localhost:11434/v1";
    };
  };
}
