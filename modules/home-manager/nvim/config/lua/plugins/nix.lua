-- NixOS adjustments (flexos flake: modules/home-manager/nvim/).
--
-- All LSP servers, formatters, linters and the tree-sitter CLI come from
-- nixpkgs and are therefore on PATH declaratively. Mason would download
-- prebuilt binaries into ~/.local/share/nvim/mason at runtime, which are
-- unreliable on NixOS (foreign-dynamic-linker issues), so it is disabled
-- entirely. The language extras enabled in lua/config/lazy.lua put the
-- matching servers into opts.servers; LazyVim's lspconfig integration
-- falls back to `vim.lsp.enable` for servers not managed by Mason, which
-- finds them on PATH.
--
-- Known limitation: DAP debug adapters (codelldb for C/Rust, delve for Go)
-- are normally Mason-installed by the extras. Configure them natively in a
-- plugin override here if debugging in nvim is needed.
return {
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },
}
