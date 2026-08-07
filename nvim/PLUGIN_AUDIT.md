# Neovim 0.12 plugin and API audit

Audited on 2026-08-07 for Neovim 0.12.4. This review uses Neovim's
versioned documentation and each plugin's upstream repository or documentation
as primary sources. "Supported" below means that the upstream repository is
not archived and contains no deprecation notice; it is not a prediction about
future maintenance.

## Neovim 0.12 API review

The authoritative baseline is Neovim's
[`news-0.12.txt`](https://github.com/neovim/neovim/blob/v0.12.4/runtime/doc/news-0.12.txt),
[`deprecated.txt`](https://github.com/neovim/neovim/blob/v0.12.4/runtime/doc/deprecated.txt),
[`lsp.txt`](https://github.com/neovim/neovim/blob/v0.12.4/runtime/doc/lsp.txt), and
[`treesitter.txt`](https://github.com/neovim/neovim/blob/v0.12.4/runtime/doc/treesitter.txt).

| Current use | 0.12 finding | Decision |
| --- | --- | --- |
| `vim.loop.fs_stat` | `vim.loop` is deprecated in favor of `vim.uv`. | Use `vim.uv.fs_stat` in the lazy.nvim bootstrap. |
| `vim.api.nvim_err_writeln` | Deprecated; `nvim_echo()` with `err = true` is the documented replacement. | Route startup errors through `nvim_echo`. |
| `vim.highlight.on_yank` | `vim.highlight` was renamed to `vim.hl`. | Use `vim.hl.on_yank`. |
| `vim.diagnostic.goto_next()` / `goto_prev()` | Deprecated in favor of `vim.diagnostic.jump()`. | Preserve the two mappings and their diagnostic float with `jump({ count = ... })`. |
| `client.supports_method()` | Dot-style invocation is deprecated in favor of the `Client:supports_method()` method. | Use colon syntax in none-ls and rustaceanvim attach callbacks. |
| `{ buffer = event.buf }` in `vim.keymap.set()` | The keymap option was renamed to `buf`. | Use the 0.12 `buf` spelling. The `buffer` field used by autocmd APIs is still current and is intentionally unchanged. |
| `pcall(vim.treesitter.get_parser, ...)` | In 0.12, parser creation failure returns `nil` instead of throwing. | Test the return value before starting Tree-sitter. |
| Mutating `client.server_capabilities.semanticTokensProvider` | This changes negotiated client state directly; 0.12 exposes a public semantic-token switch. | Use `vim.lsp.semantic_tokens.enable(false, { bufnr = ..., client_id = ... })`. |
| Repeating completion capabilities for each LSP | `vim.lsp.config('*', ...)` is the supported way to define defaults inherited by every configuration. | Define shared capabilities once, then forward each language's server-specific fields. |
| `vim.lsp.config()` and `vim.lsp.enable()` | These are the current 0.12 APIs. The legacy `require('lspconfig')` framework is deprecated, but this configuration does not use it. | Retain and simplify the existing native LSP setup. |
| Marksman launch fields nested below `settings` | `cmd`, `filetypes`, and `root_markers` are client configuration fields, not server settings. | Move them to the top level. Their values match nvim-lspconfig's Marksman defaults, so activation behavior is retained. |
| `vim.fn.*`, `vim.opt*`, `vim.keymap.set`, and autocmd APIs | All inspected uses are documented 0.12 APIs. | Keep them; rewriting valid APIs would add churn without an extensibility benefit. |
| Selene `std = "neovim"` without a matching standard-library file | Selene only resolves built-in standard libraries or YAML files in the project; the missing file prevents Lua diagnostics from running. | Add a LuaJIT-based `neovim.yml` that declares the documented `vim` host global. API validity remains covered by this versioned audit and `checkhealth vim.deprecated`. |

The file-local wrapping change uses the documented
[`'wrap'`](https://neovim.io/doc/user/options/#'wrap') and
[`'linebreak'`](https://neovim.io/doc/user/options/#'linebreak') options.
`linebreak` changes only screen wrapping and keeps words intact without adding
line breaks to the file.

## Plugin-by-plugin review

| Plugin | Status and current use | Decision |
| --- | --- | --- |
| [lazy.nvim](https://github.com/folke/lazy.nvim) | Supported. The bootstrap uses deprecated `vim.loop`; several setup values repeat documented defaults, and the recommended lockfile is ignored. | Use `vim.uv`, handle clone failure explicitly, keep only project-specific options, disable the unused LuaRocks integration, and version the cleanly resolved lockfile. Continue using lazy.nvim rather than the experimental `vim.pack`. |
| [blink.cmp](https://github.com/saghen/blink.cmp) | Supported. Upstream's v1 installation guide recommends the existing `version = '1.*'` pin. Its default snippet backend is native `vim.snippet`. | Keep the v1 pin and options; let lazy.nvim apply `opts` declaratively. Remove the unused LuaSnip dependency. |
| [LuaSnip](https://github.com/L3MON4D3/LuaSnip) | Supported, but it is not selected as blink.cmp's snippet preset and no snippets or LuaSnip APIs are configured. | Remove it from this configuration. Native `vim.snippet` continues to provide Blink's current snippet behavior. |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | Supported. It supplies server configurations consumed by native `vim.lsp.config`; the deprecated legacy setup API is not used. | Keep it and make the language configuration forwarding generic. |
| [mason.nvim](https://github.com/mason-org/mason.nvim) | Supported under the `mason-org` organization. The current UI keymaps and PATH mode duplicate Mason defaults. | Use the canonical owner and a concise declarative `opts` table containing only custom UI and installer limits. |
| [mason-lspconfig.nvim](https://github.com/mason-org/mason-lspconfig.nvim) | Supported, but this config does not call its setup API; it is present only for implicit server-name translation. | Remove it and give every language an explicit Mason package name. This also decouples tool installation from LSP integration internals. |
| [mason-tool-installer.nvim](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim) | Supported. Setup with `run_on_start = true` already starts installation, so the explicit `run_on_start()` repeats the work. | Build `ensure_installed` from explicit package metadata and use one declarative setup call. |
| [none-ls.nvim](https://github.com/nvimtools/none-ls.nvim) | Supported community continuation of null-ls. Upstream warns that debug logging noticeably slows Neovim. | Keep the plugin and formatting policy, return `opts` declaratively, and remove always-on debug logging. |
| [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) | Supported and required by none-ls/crates.nvim. The standalone spec is redundant because consumers already declare it. | Keep it as a dependency and remove the duplicate top-level spec. |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Supported. Its current `main` branch requires Neovim 0.12 and uses the new `install()` plus native `vim.treesitter.start()` flow already present here. | Keep the eager setup and parser list; update only the 0.12 parser-failure handling. |
| [rustaceanvim](https://github.com/mrcjkb/rustaceanvim) | Supported. Major 9 targets Neovim 0.12; its documented breaking changes do not conflict with this configuration. | Move from `^6` to `^9`, initialize `vim.g.rustaceanvim` in lazy.nvim's `init` phase, and use the public semantic-token API. |
| [crates.nvim](https://github.com/saecki/crates.nvim) | Supported. The empty `setup({})` callback can be represented directly by lazy.nvim `opts`. | Keep the stable release pin and filetype trigger; use `opts = {}`. |
| [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) | Supported. Its options, commands, and keys are already declarative. | Keep the setup. Do not move netrw-disabling globals earlier because that could alter directory-startup behavior. |
| [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) | Supported and used by nvim-tree, bufferline, and lualine. | Keep it as a dependency. |
| [bufferline.nvim](https://github.com/akinsho/bufferline.nvim) | Supported. The configuration is declarative, but one lazy key description is nested as an unused positional table. | Keep the stable pin and options; place `desc` in the documented key-spec field. |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Supported. The statusline module performs setup as a side effect and scans every configured client rather than attached clients. | Return an options table, let lazy.nvim run setup, and query clients attached to the current buffer. Visible sections and separators remain unchanged. |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Supported and already configured with declarative `opts`. | No change. |
| [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) | Supported. Its v3 module name, event, and `opts` follow the upstream setup. | No change. |
| [Comment.nvim](https://github.com/numToStr/Comment.nvim) | Not archived and has no upstream deprecation notice. Neovim has native commenting, but this setup also exposes Comment.nvim's blockwise `gb` behavior. | Retain it to avoid a mapping/behavior change; replace the setup-only callback with `opts = {}`. |
| [dracula.nvim](https://github.com/Mofiqul/dracula.nvim) | Supported. Applying custom palette options before `:colorscheme` is the documented shape. | Keep the existing configuration. |
| [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) | Supported. It is eagerly loaded although upstream documents commands and keys suitable for lazy loading. | Declare the upstream commands and the same Ctrl navigation keys so loading becomes demand-driven without changing the mappings. |

## Neovim 0.12 features evaluated

| Feature | Outcome |
| --- | --- |
| Experimental [`vim.pack`](https://neovim.io/doc/user/pack/#vim.pack) | Not adopted. It is intentionally experimental, while lazy.nvim currently supplies lock/version semantics and declarative loading used throughout this config. |
| Built-in completion and native snippets | Native `vim.snippet` is already Blink's backend, so LuaSnip can be removed. Blink remains because its completion UI, sources, fuzzy matching, and keymap behavior exceed the built-in completion configuration currently requested. |
| Built-in [`commenting`](https://neovim.io/doc/user/various/#commenting) | Not substituted for Comment.nvim because native `gc` would not preserve the configured blockwise `gb` surface. |
| New default statusline diagnostics/progress | Not substituted for lualine because the custom statusline contains git, filename, encoding, filetype, progress, and location sections. |
| Default Markdown Tree-sitter highlighting | Retained within the common parser/start framework so Markdown behaves consistently with the other configured languages. |
| Native LSP configuration inheritance | Adopted through `vim.lsp.config('*', ...)`; per-language files remain the extensibility boundary. |

## Formal configuration references

- [lazy.nvim plugin spec](https://lazy.folke.io/spec)
- [lazy.nvim lockfile guidance](https://lazy.folke.io/usage/lockfile)
- [blink.cmp installation](https://cmp.saghen.dev/installation) and
  [snippet configuration](https://cmp.saghen.dev/configuration/snippets)
- [Mason package registry](https://github.com/mason-org/mason-registry)
- [none-ls setup and debugging guidance](https://github.com/nvimtools/none-ls.nvim/blob/main/doc/MAIN.md)
- [nvim-treesitter main-branch README](https://github.com/nvim-treesitter/nvim-treesitter/blob/main/README.md)
- [rustaceanvim documentation](https://github.com/mrcjkb/rustaceanvim/blob/master/doc/rustaceanvim.txt)
- [vim-tmux-navigator lazy.nvim example](https://github.com/christoomey/vim-tmux-navigator#lazy-loading)
- [Selene standard-library format](https://kampfkarren.github.io/selene/usage/std.html)
