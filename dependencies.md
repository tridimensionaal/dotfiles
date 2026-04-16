# Dependencies

This inventory is derived from the configs tracked in this repository. Package names vary by distro, so this file lists tools by their upstream command or project name instead of trying to maintain `apt` and `pacman` translations inline.

## Install-Time Dependencies Enforced By `install.sh`

- `stow`: required for the install flow
- `fontconfig` tools such as `fc-list`: used to verify configured font families for `alacritty` and `waybar`

### `nvim`

- `neovim >= 0.12.0`
- `git`
- one of: `curl`, `wget`
- `unzip`
- `gzip`
- one of: `tar`, `gtar`
- one of: `cc`, `gcc`, `clang`
- `tree-sitter`

### `tmux`

- `tmux >= 1.9`
- `git`
- `bash`
- one of: `wl-copy`, `xsel`, `xclip`

### `alacritty`

- `alacritty`
- font family: `Hack Nerd Font`

### `zsh`

- `zsh >= 5.1`
- readable file: `/usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme`

### `sway`

- `sway`
- `alacritty`
- `wmenu-run`
- `waybar`
- `pactl`
- `brightnessctl`
- `grim`
- `swaynag`
- `thunar`
- `pkill`
- readable file: `/usr/share/backgrounds/sway/Sway_Wallpaper_Blue_1920x1080.png`

### `waybar`

- `waybar`
- `nm-connection-editor`
- `wireplumber`
- `pavucontrol`
- `wlogout`
- `gnome-calendar`
- `gnome-power-statistics` provided by `gnome-power-manager`
- font families: `Hack Nerd Font`, `Font Awesome 7 Free`, `Font Awesome 7 Brands`

### `gtk`

- `gtk-launch` from the GTK stack
- font family: `Hack Nerd Font`
- GTK applications that read `~/.config/gtk-3.0/settings.ini` and `~/.config/gtk-4.0/settings.ini`

## Post-Stow Bootstrap State Not Enforced By `install.sh`

- `lazy.nvim` clone under Neovim data directories: bootstrapped by Neovim on first run
- Mason-installed tool binaries derived from the tracked language config:
  - LSP servers: `bash-language-server`, `basedpyright`, `css-lsp`, `lua-language-server`, `marksman`, `rust-analyzer`, `tailwindcss-language-server`
  - formatters and linters: `prettierd`, `selene`, `shellcheck`, `shfmt`, `stylua`, `stylelint`
- Treesitter parser artifacts derived from the tracked parser list:
  - core: `git_config`, `git_rebase`, `gitcommit`, `gitignore`, `json`, `ssh_config`, `toml`, `vim`, `vimdoc`, `yaml`
  - languages: `bash`, `css`, `html`, `javascript`, `lua`, `luadoc`, `luap`, `markdown`, `markdown_inline`, `python`, `rust`, `svelte`, `typescript`
- `tmux-plugins/tpm` clone at `~/.tmux/plugins/tpm` and the plugins it installs after tmux is running
  Basic tmux settings still work without TPM, but theme and plugin-managed behavior do not.

## Optional Extras

- `nvm`: `.zshrc` sources `/usr/share/nvm/init-nvm.sh` when present, but the config works without it
- `Bash-scripts-for-daily-task`: `.zshrc` loads it only when `${BASH_SCRIPTS_INIT}` or the default path exists

## Assumptions And Uncertain Dependencies

- Neovim plugin bootstrapping, Treesitter parser installs, and Mason installs typically need network access the first time they run.
- Some Neovim-managed tools depend on additional language runtimes beyond the install-time checks:
  - `node`/`npm` are commonly needed for `bash-language-server`, `prettierd`, `stylelint`, `tailwindcss-language-server`, and `css-lsp`
  - `python3` may be required by some tooling or plugins, but this repo does not directly shell out to it in the tracked config
- The Waybar config assumes:
  - the battery device is `BAT0`
  - the Wi-Fi interface matches `wlp*`
- The Sway window rules assume Thunar identifies itself as `app_id="thunar"` or `class="Thunar"`.
- The Sway wallpaper path and the Powerlevel10k theme path are distro-specific and may need adjustment on systems that package them differently.
- GTK dark preference is a best-effort hint, not a universal Linux-wide theme switch; some future apps will ignore it.
