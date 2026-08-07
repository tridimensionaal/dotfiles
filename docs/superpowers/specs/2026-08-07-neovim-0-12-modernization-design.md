# Neovim 0.12 Modernization Design

## Goal

Bring the existing Neovim configuration up to current Neovim 0.12 and plugin APIs without changing its established editor behavior, except that Markdown and plain-text buffers must start with soft word-boundary wrapping enabled.

## Constraints

- Target the installed stable Neovim 0.12 series; verification runs on Neovim 0.12.4.
- Preserve existing mappings, UI choices, language tooling, completion, diagnostics, formatting, linting, and plugin-visible behavior.
- Do not replace a working plugin merely because an alternative exists. Remove or replace one only when it is deprecated, unmaintained, redundant, or superseded by an equivalent supported Neovim capability.
- Use public Neovim APIs. Do not introduce private APIs whose names begin with an underscore.
- Prefer lazy.nvim's declarative `opts`, `main`, `keys`, `cmd`, and dependency metadata over one-off setup callbacks when the declarative form expresses the same behavior.
- Keep language-specific configuration modular and data-driven.
- Keep the plugin lockfile untracked as established by `nvim/.gitignore`.
- Base compatibility and modernization decisions only on official Neovim documentation and each plugin's upstream documentation or repository. Record direct source links in the audit and label any inference explicitly.

## Considered Approaches

### Conservative in-place modernization — selected

Audit every direct and transitive plugin, retain the current architecture, update deprecated API calls and redundant plugin specifications, and add focused tests. This gives the requested extensibility and compatibility with the least behavioral risk.

### Native-first plugin replacement

Replace any plugin that overlaps with a Neovim 0.12 feature. This could reduce dependencies, but it risks subtle mapping and UI changes and therefore conflicts with the behavior-preservation requirement.

### Full configuration restructure

Rebuild the configuration around a new distribution or a single large plugin table. This would simplify some wiring but make review harder, erase the current language-module boundaries, and create broad behavior drift.

## Plugin Audit Scope

The audit covers every plugin represented by the current lazy.nvim specification or lockfile:

- lazy.nvim
- blink.cmp and LuaSnip
- nvim-lspconfig
- mason.nvim, mason-lspconfig.nvim, and mason-tool-installer.nvim
- none-ls.nvim and plenary.nvim
- nvim-treesitter
- rustaceanvim and crates.nvim
- nvim-tree.lua and nvim-web-devicons
- bufferline.nvim
- lualine.nvim
- gitsigns.nvim
- indent-blankline.nvim
- Comment.nvim
- dracula.nvim
- vim-tmux-navigator

For each plugin, the resulting review records maintenance/deprecation status, whether the current integration uses supported APIs, and whether a more declarative configuration is appropriate. Configuration changes are limited to findings that preserve observable behavior. Every finding cites its primary upstream source.

## Neovim API Audit

Review every use of `vim.api`, `vim.diagnostic`, `vim.lsp`, `vim.loop`/`vim.uv`, `vim.fn`, option APIs, keymap APIs, Treesitter APIs, and autocommand APIs against official Neovim 0.12 help and release notes. Replace compatibility aliases and deprecated calls with their public Neovim 0.12 forms. Retain valid APIs when changing them would only be cosmetic.

The LSP architecture remains data-driven: language modules describe servers, shared code registers them with `vim.lsp.config`, and `vim.lsp.enable` starts them. Rust remains owned by rustaceanvim to avoid duplicate clients.

## Wrapping Behavior

A small shared filetype helper will enable both `wrap` and `linebreak` as local window options. Markdown and `text` ftplugins will call it. This preserves the global `nowrap` default, enables wrapping only for the two requested filetypes, and prevents display lines from breaking in the middle of words without modifying buffer text.

## Testing and Verification

- Add a headless Neovim behavior test that opens Markdown, text, and a control source file and asserts the local `wrap` and `linebreak` values.
- Prove the new wrapping test fails before implementation and passes after implementation.
- Run a headless startup smoke test with the real configuration.
- Run `:checkhealth vim.deprecated` and inspect its generated report.
- Load every Lua module through Neovim to catch syntax and runtime-load errors without relying on unavailable external Lua linters.
- Run lazy.nvim's plugin health/status checks where they are non-interactive.
- Run the repository's existing `./check.sh` suite.
- Review the final diff against this design and the plugin audit before publication.

## Documentation

Update `nvim/README.md` with the Neovim version expectation, validation command, and link to a plugin/API audit report. The report is a durable record of plugins retained, removed, or modernized and the primary upstream evidence used for each decision.
