# ./overlays/vscode-ripgrep/default.nix
# 2026-11-13: nixpkgs-unstable is pinned to 1c89083e (see flake.nix — newer
# unstable head ships patchelf 0.15.2, which breaks hermes-agent's
# patchelfFixed workaround). That pinned rev ships vscode 1.144.0, whose
# tarball renamed the bundled ripgrep package (@vscode/ripgrep →
# @vscode/ripgrep-universal, path now node_modules.asar.unpacked/.../bin/linux-x64/rg),
# while generic.nix at this rev still rm/ln-symlinks the old path:
#   rm: cannot remove 'resources/app/node_modules/@vscode/ripgrep/bin/rg': No such file or directory
# Rewrite the path inside the (already interpolated) postPatch string so the
# bundled binary is removed and system ripgrep symlinked at the new location —
# exactly what the fixed nixpkgs generic.nix does.
# REMOVE once the nixpkgs-unstable pin is lifted (i.e. nixpkgs ships a
# patchelf containing NixOS/patchelf#672 again and hermes-agent drops
# patchelfFixed) — the ripgrep-universal-aware generic.nix is already on
# nixos-unstable head (d4f25a3e, 2026-11-11).
(final: prev: {
  vscode = prev.vscode.overrideAttrs (old: {
    postPatch = builtins.replaceStrings
      [ "node_modules/@vscode/ripgrep/bin/rg" ]
      [ "node_modules.asar.unpacked/@vscode/ripgrep-universal/bin/linux-x64/rg" ]
      (old.postPatch or "");
  });
})
