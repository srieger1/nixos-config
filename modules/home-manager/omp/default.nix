overlay = (pkgs.formats.yaml { }).generate "oh-my-pi-config.yml" {
modelRoles = {
default = "anthropic/claude-opus-5:high";
advisor = "anthropic/claude-opus-4-8:high";
tiny = "anthropic/claude-haiku-4-5:medium";
smol = "anthropic/claude-haiku-4-5:medium";
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

overlayPath = "${config.home.homeDirectory}/.omp/agent/nix-config.yml";
in
{
home.packages = [
oh-my-pi
];

home.file.".omp/agent/nix-config.yml".source = overlay;

home.sessionVariables.PI_CONFIG_FILES = overlayPath;
