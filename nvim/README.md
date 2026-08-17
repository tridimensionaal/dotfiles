# Neovim

The Neovim config lives under `~/.config/nvim`.
It targets Neovim 0.12 or newer.

Install it with:

```sh
./install.sh nvim
```

## Configuration layout

- `init.lua` lives at `~/.config/nvim/init.lua`
- core editor modules live under `~/.config/nvim/lua/`
- language-specific modules live under `~/.config/nvim/lua/config/languages/`
- plugin specs live under `~/.config/nvim/lua/plugins/`
- filetype overrides live under `~/.config/nvim/after/ftplugin/`
- post-plugin setup lives under `~/.config/nvim/after/plugin/`

## Tooling

- plugin management is handled by `lazy.nvim`
- validated plugin revisions are recorded in `lazy-lock.json`
- editor tooling installation is handled by Mason plus `mason-tool-installer`

The complete 0.12 API and plugin review, including the decision for every
configured dependency, is in [PLUGIN_AUDIT.md](PLUGIN_AUDIT.md).

The package also keeps repo-only lint configuration such as `selene.toml` and
`neovim.yml`, but those files are ignored by Stow and are not linked into
`$HOME`.

First launch may need network access so Lazy.nvim, Mason, and Treesitter can bootstrap plugins, tool binaries, and parsers.

## Fuzzy finding

`fzf-lua` uses the system `fzf`, `fd`, `ripgrep`, and `bat`. File and text
searches include hidden files while respecting Git ignore rules.

- `Space f f` finds files
- `Space f g` searches text across files
- `Space f b` switches buffers
- `Space f h` searches help
- `Space f r` resumes the previous picker
- `Ctrl-j` and `Ctrl-k` move down and up through picker results
