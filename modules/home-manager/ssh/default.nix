# Declaratively places ~/.ssh/config from an external, non-repo path — same
# "outside the repo, --impure read" idiom flake.nix's `privateFor` uses for
# host secrets, because flexos is a public repo and this config discloses
# internal HS Fulda network layout (not credentials, but not public either).
#
# Source of truth: a small private git repo, self-hosted as a bare repo at
# cardassia3:/root/git/flexos-private.git, cloned to
# ~/.config/flexos-private-sync on each host. `update.sh` pulls it alongside
# the flexos flake itself, so caladan/giedi-prime stay in sync the same way
# they already sync the flake — one `git pull`, no separate sync tool.
#
# Bootstrap on a new host:
#   git clone cardassia3:git/flexos-private.git ~/.config/flexos-private-sync
#
# Absent (e.g. before the first clone) is not an error — this module simply
# doesn't manage ~/.ssh/config until the clone exists.
{ lib, ... }:
let
  path = builtins.toPath (builtins.getEnv "HOME" + "/.config/flexos-private-sync/ssh-config");
in
{
  home.file = lib.optionalAttrs (builtins.pathExists path) {
    ".ssh/config".source = path;
  };
}
