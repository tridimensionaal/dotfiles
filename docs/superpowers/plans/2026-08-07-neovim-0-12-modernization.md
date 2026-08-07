# Neovim 0.12 Modernization Implementation Plan

> **For Codex:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task by task.

**Goal:** Move the existing configuration to documented Neovim 0.12 APIs, modernize every plugin specification where there is a behavior-preserving improvement, and enable word-boundary wrapping for Markdown and text buffers.

**Architecture:** Keep the existing lazy.nvim and language-module structure. Add only one shared filetype-option helper, make LSP metadata declarative and generically forwarded, and move plugin setup data into lazy.nvim `opts`/`init` fields. Use clean headless Neovim behavior tests for the two extensibility boundaries and a fresh XDG data directory for integration verification.

**Tech Stack:** Neovim 0.12 Lua API, lazy.nvim, native `vim.lsp`, Mason, nvim-treesitter, shell-based headless tests, Git/GitHub CLI.

---

## Task 1: Add behavior tests for wrapping and LSP configuration

**Files:**

- Create: `tests/nvim/wrapping_spec.lua`
- Create: `tests/nvim/lsp_config_spec.lua`
- Create: `tests/test-neovim.sh`

### Step 1: Write the failing wrapping behavior test

Load the repository's config directory into a `--clean` Neovim runtime, enable
filetype plugins, and assert:

- Markdown enables local `wrap` and `linebreak` while retaining two-space indentation.
- Text enables local `wrap` and `linebreak`.
- Both checks start with the local options disabled so the ftplugin must cause the result.

### Step 2: Write the failing LSP forwarding test

Stub `config.languages`, mappings, shared capabilities, `vim.lsp.config`, and
`vim.lsp.enable`. Assert that setup:

- registers shared capabilities through the `"*"` configuration;
- forwards supported fields not named in the old whitelist, such as `handlers`;
- removes local metadata (`server`, `mason`, `skip_builtin`, `servers`);
- enables declared servers and skips opt-out languages.

### Step 3: Add the test runner and prove the tests fail

Run:

```sh
./tests/test-neovim.sh
```

Expected: non-zero, first because Markdown lacks `linebreak` and text lacks an
ftplugin; after isolating that test, the LSP test also fails because the
wildcard configuration and generic forwarding are absent.

## Task 2: Implement word-boundary wrapping

**Files:**

- Create: `nvim/.config/nvim/lua/config/wrapping.lua`
- Modify: `nvim/.config/nvim/after/ftplugin/markdown.lua`
- Create: `nvim/.config/nvim/after/ftplugin/text.lua`

### Step 1: Add the shared local-option helper

Expose an `enable()` function that sets `vim.opt_local.wrap = true` and
`vim.opt_local.linebreak = true`.

### Step 2: Use it from both ftplugins

Keep Markdown's indentation settings exactly as they are, replace its direct
wrap assignment with the helper, and call the same helper from the new text
ftplugin.

### Step 3: Run the focused test

```sh
NVIM_CONFIG_ROOT="$PWD/nvim/.config/nvim" nvim --headless --clean -l tests/nvim/wrapping_spec.lua
```

Expected: exit 0.

### Step 4: Commit

```sh
git add tests/nvim/wrapping_spec.lua tests/test-neovim.sh \
  nvim/.config/nvim/lua/config/wrapping.lua \
  nvim/.config/nvim/after/ftplugin/markdown.lua \
  nvim/.config/nvim/after/ftplugin/text.lua
git commit -m "feat(nvim): wrap prose at word boundaries"
```

## Task 3: Migrate to Neovim 0.12 APIs and extensible LSP metadata

**Files:**

- Modify: `nvim/.config/nvim/init.lua`
- Modify: `nvim/.config/nvim/lua/lazy_init.lua`
- Modify: `nvim/.config/nvim/lua/autocmds.lua`
- Modify: `nvim/.config/nvim/after/plugin/diagnostics.lua`
- Modify: `nvim/.config/nvim/lua/config/lsp/init.lua`
- Modify: `nvim/.config/nvim/lua/config/lsp/mappings.lua`
- Modify: `nvim/.config/nvim/lua/config/treesitter/languages.lua`
- Modify: `nvim/.config/nvim/lua/config/languages/markdown/lsp.lua`
- Modify: `nvim/.config/nvim/lua/config/languages/{bash,css,lua,markdown,python,rust}/lsp.lua`
- Modify: `nvim/.config/nvim/lua/config/languages/rust/plugins/rustaceanvim.lua`
- Include: `tests/nvim/lsp_config_spec.lua`

### Step 1: Modernize core and diagnostic calls

- Replace `nvim_err_writeln` with `nvim_echo(..., { err = true })`.
- Replace `vim.loop` with `vim.uv`.
- Replace `vim.highlight.on_yank` with `vim.hl.on_yank`.
- Replace deprecated diagnostic traversal with closures around
  `vim.diagnostic.jump`, using `on_jump` to retain the floating diagnostic.
- Change only `vim.keymap.set` option tables from `buffer` to `buf`; retain the
  current `buffer` autocmd fields.
- Test the return from `vim.treesitter.get_parser` rather than expecting an exception.

### Step 2: Make native LSP setup generic

Register completion capabilities once with `vim.lsp.config("*", ...)`. For
each language server, deep-copy its configuration, strip configuration-only
metadata, pass the remaining fields to `vim.lsp.config`, and enable the server.
Do not pass the nonexistent `mappings.on_attach` field.

### Step 3: Correct language metadata

Add explicit registry package names:

- `bashls` -> `bash-language-server`
- `cssls` -> `css-lsp`
- `tailwindcss` -> `tailwindcss-language-server`
- `lua_ls` -> `lua-language-server`
- `marksman` -> `marksman`
- `basedpyright` -> `basedpyright`
- `rust_analyzer` -> `rust-analyzer`

Move Marksman's `cmd`, `filetypes`, and `root_markers` out of `settings`.

### Step 4: Modernize rustaceanvim integration

Change the compatible release to `^9`, build `vim.g.rustaceanvim` in lazy.nvim's
`init` phase, and disable semantic tokens with
`vim.lsp.semantic_tokens.enable(false, { bufnr = bufnr, client_id = client.id })`.
Keep format-on-save selection and bang-write behavior unchanged.

### Step 5: Run the tests and deprecation scan

```sh
./tests/test-neovim.sh
nvim --headless -u "$PWD/nvim/.config/nvim/init.lua" \
  '+checkhealth vim.deprecated' '+qa'
```

Expected: tests exit 0 and the health output reports no deprecated functions.

### Step 6: Commit

```sh
git add nvim/.config/nvim tests/nvim/lsp_config_spec.lua
git commit -m "refactor(nvim): adopt 0.12 APIs"
```

## Task 4: Simplify plugin specifications and dependencies

**Files:**

- Modify: `nvim/.config/nvim/lua/plugins/blink.lua`
- Modify: `nvim/.config/nvim/lua/plugins/mason.lua`
- Modify: `nvim/.config/nvim/lua/plugins/mason-tool-installer.lua`
- Modify: `nvim/.config/nvim/lua/plugins/none-ls.lua`
- Delete: `nvim/.config/nvim/lua/plugins/plenary.lua`
- Modify: `nvim/.config/nvim/lua/plugins/comments.lua`
- Modify: `nvim/.config/nvim/lua/plugins/bufferline.lua`
- Modify: `nvim/.config/nvim/lua/plugins/statusline.lua`
- Modify: `nvim/.config/nvim/lua/plugins/tmux_navigator.lua`
- Modify: `nvim/.config/nvim/lua/config/none-ls/init.lua`
- Modify: `nvim/.config/nvim/lua/config/ui/statusline.lua`
- Modify: `nvim/.config/nvim/lua/config/languages/rust/plugins/crates.lua`

### Step 1: Remove unused/redundant dependency declarations

- Remove LuaSnip because Blink uses native `vim.snippet` and no LuaSnip preset
  or snippets are configured.
- Remove mason-lspconfig because explicit Mason package metadata replaces its
  unused implicit translation role.
- Remove the standalone Plenary spec while keeping it on its consumers.

### Step 2: Use lazy.nvim's declarative setup fields

- Remove setup-only `config` callbacks from Blink, Comment.nvim, and crates.nvim.
- Return none-ls and lualine option tables from their config modules and let
  lazy.nvim call each plugin's `setup` function.
- Remove none-ls debug logging.
- Keep plugin-specific callbacks only where they perform real initialization.

### Step 3: Simplify Mason and lazy.nvim

- Keep only non-default lazy.nvim options and disable unused LuaRocks support.
- Keep Mason's upstream-recommended eager setup/build and project-specific UI
  icons/installer limit; remove copied defaults.
- Build mason-tool-installer options once from explicit `mason` metadata and
  remove its duplicate `run_on_start()` call.

### Step 4: Preserve mappings while improving load behavior

- Fix bufferline's misplaced `desc` key.
- Use attached clients for the lualine LSP label.
- Apply vim-tmux-navigator's upstream lazy.nvim command/key declaration, with
  the same Ctrl-h/j/k/l/backslash mappings.

### Step 5: Smoke-test syntax and startup

```sh
./tests/test-neovim.sh
nvim --headless -u "$PWD/nvim/.config/nvim/init.lua" '+qa'
```

Expected: both commands exit 0 without errors.

### Step 6: Commit

```sh
git add nvim/.config/nvim
git commit -m "refactor(nvim): modernize plugin specifications"
```

## Task 5: Document and integrate validation

**Files:**

- Modify: `nvim/README.md`
- Modify: `check.sh`

### Step 1: Document the supported version and audit

State the Neovim 0.12 minimum, link `PLUGIN_AUDIT.md`, describe the local
wrapping behavior, and document `./tests/test-neovim.sh`.

### Step 2: Include the headless tests in repository checks

Invoke `./tests/test-neovim.sh` from `check.sh` so future changes exercise the
wrapping and LSP metadata contracts.

### Step 3: Run repository validation

```sh
./check.sh
git diff --check
```

Expected: both exit 0.

### Step 4: Commit

```sh
git add nvim/README.md check.sh
git commit -m "docs(nvim): document 0.12 support and checks"
```

## Task 6: Clean integration verification and review

### Step 1: Install plugins into disposable XDG directories

Create a directory with `mktemp -d`, point `XDG_DATA_HOME`, `XDG_STATE_HOME`,
and `XDG_CACHE_HOME` at its children, point `XDG_CONFIG_HOME` at the worktree's
`nvim/.config`, and run:

```sh
nvim --headless '+Lazy! sync' '+qa'
```

Expected: lazy.nvim bootstraps and resolves the revised specs, including
rustaceanvim major 9, without LuaSnip or mason-lspconfig.

### Step 2: Run final checks against that clean plugin set

Run the test suite, startup smoke test, `checkhealth vim.deprecated lazy
nvim-treesitter rustaceanvim`, `git diff --check`, and `git status --short`.
Treat optional external-tool health warnings separately from config failures.

### Step 3: Request code review

Ask a reviewer agent to compare `origin/main` with `HEAD`, focusing on behavior
regressions, incorrect 0.12 API assumptions, plugin-loading regressions, and
missing tests. Address every critical or important finding and rerun relevant
checks.

## Task 7: Publish the requested branch and pull request

### Step 1: Confirm publication scope

Inspect the final log, status, and diff summary; verify GitHub authentication.

### Step 2: Push and open a draft PR

Push `agent/modernize-neovim-0.12` to `origin` and create a draft PR targeting
`main`. The PR body must summarize the API/plugin decisions, link the audit,
and list the exact verification commands.

### Step 3: Report the handoff

Return the branch name, PR URL, major decisions, and verification result.
