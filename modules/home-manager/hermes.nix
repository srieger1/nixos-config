 # hermes.nix
 #
 # hermes-agent (NousResearch) as CLI + desktop app, with its gateway daemon.
 # The upstream module manages config.yaml via deep-merge: nix owns the keys
 # set here, runtime (`hermes config set`, TUI/desktop panes — and the
 # interactive `hermes gateway setup`) owns the rest. That is also why there
 # is no `gateway setup` for us: the CLI refuses it while HERMES_MANAGED is
 # set ("managed by home-manager"). Everything the wizard would write has to
 # be declared here or via `environmentFiles`.
 #
 # Secrets rule: `settings.*` lands in cleartext in config.yaml and the nix
 # store is world-readable — non-secret config goes in `settings`, secret
 # values (Matrix access token, provider API keys) go in `environmentFiles`
 # (runtime path, .env is written at activation, 0600). sops-nix is only
 # wired for cardassia, so until caladan gets it the env file is a plain
 # 0600 file in ~/.config/private — same trust level as the SSH keys there.

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

     # Model + provider selection (all non-secret, lives in config.yaml):
     # `default` is switchable at runtime (`hermes model`), nix just sets
     # the default. `provider: "auto"` resolves from available credentials;
     # `custom` pins the local ollama. `providers.<name>` registers named
     # OpenAI-compatible endpoints (base_url + key_env) for per-call choice.
     settings = {
       model = {
         default = "gpt-oss:20b";
         provider = "custom";
         base_url = "http://localhost:11434/v1";
       };
       providers = {
         openrouter = {
           base_url = "https://openrouter.ai/api/v1";
           key_env = "OPENROUTER_API_KEY";
         };
       };
     };

     # Secrets via .env at activation (0600), never in the store:
     # - MATRIX_*: activates the matrix channel (required: HOMESERVER,
     #   ACCESS_TOKEN, USER_ID; ALLOWED_USERS gates who may talk to it).
     #   Get the token once via Element → Settings → Help → Access Token,
     #   or `hermes auth` on an unmanaged install; device id pins E2EE.
     # - OPENROUTER_API_KEY: unlocks provider "openrouter" above.
     environmentFiles = [ "/home/flex/.config/private/hermes.env" ];
   };
 }
