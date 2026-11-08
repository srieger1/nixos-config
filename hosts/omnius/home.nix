# omnius home-manager config for flex.
#
# Two user services (flex has `linger = true`, so they run at boot without
# a login session):
# - paseo daemon: the agent control surface paseo clients (desktop, iOS,
#   web, CLI) connect to; it spawns the agent CLIs (system packages: omp,
#   claude-code, pi-coding-agent, opencode).
# - hermes gateway: Matrix channel moved here from caladan (this is the
#   permanent isolated-VM home decided 2026-10-10; caladan's gateway goes
#   away). Same Matrix env file pattern as caladan: secrets live OUTSIDE
#   the repo in ~/.config/private/hermes.env (0600), copied there once.
{
  config,
  pkgs,
  inputs,
  ...
}:
{
  home.username = "flex";
  home.homeDirectory = "/home/flex";
  home.stateVersion = "26.11";
  programs.home-manager.enable = true;

  imports = [ inputs.hermes-agent.homeManagerModules.default ];

  programs.hermes-agent = {
    enable = true;
    desktop.enable = false; # headless server — CLI + gateway only
  };

  services.hermes-agent = {
    enable = true;
    gateway.enable = true;

    # Same model/provider layout as caladan's hermes.nix, but NO local ollama
    # fallback: omnius has no ollama (no GPU), and caladan sits in the
    # hs-fulda tailnet while omnius is in the private one — unreachable.
    # Re-add later as fallback_model = [{ provider = "custom"; model =
    # "..."; base_url = "http://<gpu-node>:11434/v1"; }] once a GPU node
    # (candidate: deep-thought, WoL + 7900XTX) joins the private tailnet.
    settings = {
      model = {
        default = "z-ai/glm-5.3-flash";
        provider = "openrouter";
        base_url = "https://openrouter.ai/api/v1";
      };
      providers = {
        openrouter = {
          base_url = "https://openrouter.ai/api/v1";
          key_env = "OPENROUTER_API_KEY";
        };
      };
    };

    # Secrets via .env at activation (0600), never in the store:
    # - MATRIX_* (HOMESERVER, ACCESS_TOKEN, USER_ID, ...): activates the
    #   matrix channel; copied from caladan's ~/.config/private/hermes.env
    #   since the gateway MOVES here (same Matrix account, one gateway).
    # - OPENROUTER_API_KEY: unlocks provider "openrouter" above.
    environmentFiles = [ "/home/flex/.config/private/hermes.env" ];
  };

  systemd.user.services.paseo-daemon = {
    Unit = {
      Description = "Paseo daemon (coding agent control surface)";
      After = [ "network-online.target" ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = "${pkgs.paseo}/bin/paseo daemon run";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}
