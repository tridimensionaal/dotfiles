# Arch VM Test Guide

This is the supported GUI validation path for these dotfiles on Arch Linux. It uses `virt-manager` on the host, an Arch guest installed with `archinstall`, and the repo-root [install.sh](../install.sh).

## Scope

- Host hypervisor: `virt-manager`
- Guest OS: Arch Linux ISO `2026.04.01`
- Guest desktop preset: `archinstall` -> `Desktop` -> `Sway`
- Dotfiles entrypoint under test: [install.sh](../install.sh)

## Host Setup

Install the host packages:

```sh
sudo pacman -S --needed virt-manager qemu-desktop libvirt dnsmasq edk2-ovmf iptables
sudo systemctl enable --now libvirtd
ls -l /dev/kvm
```

Use these VM defaults in `virt-manager`:

- firmware: UEFI via OVMF
- machine type: `q35`
- CPU: `4` vCPU
- memory: `8 GiB`
- disk: `50 GiB` `qcow2`
- network: default NAT
- disk and NIC: virtio

If `/dev/kvm` is missing, fix host acceleration first. The plan assumes KVM-backed QEMU, not software emulation.

## Guest Install

Boot the Arch ISO `2026.04.01` and run `archinstall`.

Inside `archinstall`, choose:

- profile: `Desktop` -> `Sway`
- audio: `PipeWire`
- network: `NetworkManager`
- bootloader: `Systemd-boot`
- users: one normal user with sudo
- storage: simple single-disk layout
- locale and timezone: your real values

Before starting the install, use `Save configuration` from the running ISO and keep both generated files:

- `user_configuration.json`
- `user_credentials.json`

Do not hand-write these files. Let the ISO generate them so they stay schema-compatible with the installed `archinstall` version.

After the first boot, update the guest and install the repo prerequisites from official Arch repos:

```sh
sudo pacman -Syu --needed \
  stow git base-devel curl unzip gzip tar gcc fontconfig gtk3 neovim tree-sitter-cli \
  tmux wl-clipboard alacritty zsh sway swaybg waybar wmenu thunar grim brightnessctl \
  nm-connection-editor network-manager-applet pavucontrol gnome-calendar \
  gnome-power-manager wireplumber libpulse xorg-xwayland xdg-desktop-portal-gtk \
  xdg-desktop-portal-wlr polkit polkit-gnome ttf-hack-nerd otf-font-awesome firefox nodejs npm \
  python-pynvim
```

Install the two repo-required AUR packages:

```sh
git clone https://aur.archlinux.org/zsh-theme-powerlevel10k.git
cd zsh-theme-powerlevel10k
makepkg -si
cd ..

git clone https://aur.archlinux.org/wlogout.git
cd wlogout
makepkg -si
cd ..
```

## Snapshots

Create these VM snapshots:

- `00-clean-vm`: first boot after install
- `10-post-archinstall`: after the official repo packages are installed
- `20-post-deps`: after the AUR packages are installed

Re-run dotfiles validation from `20-post-deps`.

## Programmatic Bootstrap

Downloading only [install.sh](../install.sh) is not enough. That script expects the full repo checkout because it stows package directories such as `nvim`, `sway`, and `waybar`.

There are two supported automation paths:

### Repo-local bootstrap

Clone the repo first, then run [arch-vm-bootstrap.sh](../arch-vm-bootstrap.sh):

```sh
git clone https://github.com/tridimensionaal/dotfiles.git ~/dotfiles
cd ~/dotfiles
./arch-vm-bootstrap.sh --yes
```

That script:

- installs the official Arch packages required by the tracked configs
- builds and installs the two required AUR packages
- clones or updates the dotfiles repo under `~/dotfiles`
- downloads the wallpaper expected by [sway/.config/sway/config.d/20-output.conf](../sway/.config/sway/config.d/20-output.conf)
- runs `./install.sh --dry-run` and then `./install.sh`

### One-command remote bootstrap

Use [remote-install.sh](../remote-install.sh) as the `curl | bash` entrypoint:

```sh
curl -fsSL https://raw.githubusercontent.com/tridimensionaal/dotfiles/core/v1.0/remote-install.sh | \
  bash -s -- --yes
```

`remote-install.sh` stays intentionally thin:

- installs `git` if needed
- clones this repo into `~/dotfiles`
- delegates to the repo-local `./arch-vm-bootstrap.sh`

Useful options:

- `--deps-only`: install dependencies without running `./install.sh`; when used through `remote-install.sh`, the initial repo clone still happens first
- `--skip-aur`: skip `wlogout` and `zsh-theme-powerlevel10k`; only use this if they are already installed or if you are also skipping `./install.sh`
- `--skip-install`: install dependencies and clone the repo, but stop before `./install.sh`
- `--repo-url URL`: clone from a different Git remote
- `--repo-dir DIR`: clone into a different directory
- `--repo-ref REF`: clone or update to a specific branch or tag

When using `remote-install.sh`, pass bootstrap options after `--`:

```sh
curl -fsSL https://raw.githubusercontent.com/tridimensionaal/dotfiles/core/v1.0/remote-install.sh | \
  bash -s -- --repo-ref core/v1.0 -- --yes --skip-install
```

## Dotfiles Validation

Clone the repo in the guest and dry-run the installer first:

```sh
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh --dry-run
./install.sh
```

The dry run should succeed without missing dependency errors. A normal run should stow:

- `nvim`
- `tmux`
- `alacritty`
- `zsh`
- `sway`
- `waybar`
- `gtk`

If you are not using `arch-vm-bootstrap.sh`, create the wallpaper file expected by [sway/.config/sway/config.d/20-output.conf](../sway/.config/sway/config.d/20-output.conf) before logging into Sway:

```sh
mkdir -p "$HOME/Pictures/wallpapers"
curl -fsSL 'https://64.media.tumblr.com/5418cfe910d3aacbd338b62f8e902920/4d297239ab123154-5a/s1280x1920/2c8f9cd34d432881a820204145fd71216e4938a0.jpg' \
  -o "$HOME/Pictures/wallpapers/picture_1.jpg"
```

## Runtime Checks

Log into Sway and verify the startup commands from [80-startup.conf](../sway/.config/sway/config.d/80-startup.conf):

- `waybar` starts
- `nm-applet --indicator` starts

Open and validate:

- `alacritty`
- `zsh`
- `tmux`
- `nvim`
- `firefox`
- `nm-applet`
- `nm-connection-editor`
- `pavucontrol`
- `gnome-calendar`
- `gnome-power-statistics`
- `wlogout`

Confirm these bindings from [00-vars.conf](../sway/.config/sway/config.d/00-vars.conf):

- terminal launcher uses `alacritty`
- browser launcher uses `firefox`
- app launcher uses `wmenu-run`

Confirm these Waybar click actions from [waybar/.config/waybar/config](../waybar/.config/waybar/config):

- clock opens `gnome-calendar`
- speaker opens `pavucontrol -t 3`
- microphone opens `pavucontrol -t 4`
- battery opens `gnome-power-statistics`
- power opens `wlogout`

`nm-connection-editor` is part of the guest package set for manual validation, but it is not launched from Waybar.

Waybar should render with both configured font families:

- `Hack Nerd Font`
- `Font Awesome`

Battery and brightness behavior are not meaningful pass/fail signals in a VM because the bar config assumes `BAT0`.

## Neovim First Run

In `nvim`, allow first-run bootstrap to complete with network access enabled:

- plugin bootstrap
- Mason installs
- Treesitter parser installs

Exit Neovim and open it a second time. The second start should be clean enough to be considered usable.
