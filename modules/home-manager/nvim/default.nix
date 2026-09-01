# LazyVim-based Neovim as an editor alternative to VSCode (currently only
# imported by caladan; giedi-prime can add the same import to its home.nix).
#
# The editor config in ./config is symlinked to ~/.config/nvim by
# home-manager and managed declaratively like the other module configs
# (niri, herdr, ...) — edit here, then rebuild.
#
# lazy.nvim bootstraps itself and all plugins (clones from GitHub) into
# ~/.local/share/nvim/lazy on first start; treesitter parsers are compiled
# at runtime into ~/.local/share/nvim — that is why gcc, make and the
# tree-sitter CLI are on PATH.
#
# Mason is disabled in config/lua/plugins/nix.lua (prebuilt runtime
# downloads are unreliable on NixOS); everything is provided by nixpkgs:
#   * language extras in config/lua/config/lazy.lua enable the matching
#     LSP servers, which LazyVim picks up from PATH
#   * extras: python (pyright/ruff), go (gopls), rust (rustaceanvim),
#     typescript (vtsls), json, yaml, c (clangd), nix (nil_ls)
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    neovim
    ripgrep
    fd
    lazygit
    wl-clipboard
    gcc
    gnumake
    tree-sitter
    nodejs # runtime for eslint-language-server and friends
    statix # nix linter, run by nvim-lint on save (lang.nix extra)

    # LSP servers
    pyright
    ruff
    gopls
    gotools # goimports formatter
    rust-analyzer
    clang-tools # clangd + clang-format
    vtsls
    vscode-langservers-extracted # jsonls, cssls, htmlls, eslint
    yaml-language-server
    lua-language-server
    nil

    # formatters
    stylua
    shfmt
    nixfmt
    prettierd
  ];

  xdg.configFile."nvim" = {
    source = ./config;
    recursive = true;
  };
}
