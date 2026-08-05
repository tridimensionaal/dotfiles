# Arch VM Test Guide

This is an internal validation guide for maintainers testing these dotfiles on Arch Linux. It uses `virt-manager` on the host, an Arch guest installed with `archinstall`, and the repo-root installer scripts.

## Scope

- Host hypervisor: `virt-manager`
- Guest OS: Arch Linux ISO `2026.04.01`
- Guest desktop preset: `archinstall` -> `Desktop` -> `Sway`
- Dotfiles entrypoints under test: [remote-install.sh](../remote-install.sh), [install-arch.sh](../install-arch.sh), and [install.sh](../install.sh)

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
  stow git less gcr-4 gnome-keyring seahorse jq curl unzip gzip tar gcc \
  fontconfig gtk3 neovim tree-sitter-cli \
  tmux wl-clipboard alacritty zsh starship sway swaybg waybar nwg-bar wmenu thunar grim brightnessctl \
  nm-connection-editor network-manager-applet pavucontrol gnome-calendar \
  gnome-power-manager pipewire pipewire-pulse wireplumber xorg-xwayland xdg-desktop-portal-gtk \
  xdg-desktop-portal-wlr polkit polkit-gnome ttf-hack-nerd otf-font-awesome firefox nodejs npm \
  python-pynvim
```

## Snapshots

Create these VM snapshots:

- `00-clean-vm`: first boot after install
- `10-post-deps`: after the official repo packages are installed

Re-run dotfiles validation from `10-post-deps`.

## Programmatic Bootstrap

Downloading only [install.sh](../install.sh) is not enough. That script expects the full repo checkout because it stows package directories such as `nvim`, `sway`, and `waybar`.

For validation runs, there are two convenient automation paths:

### Repo-local bootstrap

Clone the repo first, then run [install-arch.sh](../install-arch.sh). Use `--profile full` for the complete workstation or `--profile gui` for only the Sway desktop stack.

```sh
git clone https://github.com/tridimensionaal/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install-arch.sh --profile full --yes
./install-arch.sh --profile gui --yes
```

That script:

- installs the official Arch packages required by the selected profile
- clones or updates the dotfiles repo under `~/dotfiles`
- downloads the wallpaper expected by [sway/.config/sway/config.d/20-output.conf](../sway/.config/sway/config.d/20-output.conf)
- runs `./install.sh --profile <profile> --dry-run` and then `./install.sh --profile <profile>`

### One-command remote bootstrap

Use [remote-install.sh](../remote-install.sh) as the `curl | bash` entrypoint:

```sh
curl -fsSL https://raw.githubusercontent.com/tridimensionaal/dotfiles/main/remote-install.sh | \
  bash -s -- --profile full --yes
```

For GUI-only validation:

```sh
curl -fsSL https://raw.githubusercontent.com/tridimensionaal/dotfiles/main/remote-install.sh | \
  bash -s -- --profile gui --yes
```

`remote-install.sh` stays intentionally thin:

- installs `git` if needed
- clones this repo into `~/dotfiles`
- delegates to the repo-local `./install-arch.sh`

Useful options:

- `--profile full|gui`: select the complete workstation or GUI-only desktop profile
- `--deps-only`: install dependencies without running `./install.sh`; when used through `remote-install.sh`, the initial repo clone still happens first
- `--skip-install`: install dependencies and clone the repo, but stop before `./install.sh`
- `--repo-url URL`: clone from a different Git remote
- `--repo-dir DIR`: clone into a different directory
- `--repo-ref REF`: clone or update to a specific branch or tag

`remote-install.sh` accepts the common bootstrap flags directly. Use `--` only
for passthrough flags the wrapper does not recognize yet:

```sh
curl -fsSL https://raw.githubusercontent.com/tridimensionaal/dotfiles/main/remote-install.sh | \
  bash -s -- --repo-ref main --profile gui --yes --skip-install
```

## Dotfiles Validation

Clone the repo in the guest and dry-run the installer first:

```sh
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh --profile full --dry-run
./install.sh --profile full
./install.sh --profile gui --dry-run
./install.sh --profile gui
```

The dry run should succeed without missing dependency errors. A normal full-profile run should stow:

- `nvim`
- `tmux`
- `alacritty`
- `zsh`
- `sway`
- `waybar`
- `gtk`

A normal GUI-profile run should stow:

- `alacritty`
- `sway`
- `waybar`
- `gtk`

If you are not using `install-arch.sh`, create the wallpaper file expected by [sway/.config/sway/config.d/20-output.conf](../sway/.config/sway/config.d/20-output.conf) before logging into Sway:

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
- `starship`
- `nwg-bar`

Confirm these bindings from [00-vars.conf](../sway/.config/sway/config.d/00-vars.conf):

- terminal launcher uses `alacritty`
- browser launcher uses `firefox`
- app launcher uses `wmenu-run`

Confirm these Waybar click actions from [waybar/.config/waybar/config](../waybar/.config/waybar/config):

- clock opens `gnome-calendar`
- speaker opens `pavucontrol -t 3`
- microphone opens `pavucontrol -t 4`
- battery opens `gnome-power-statistics`
- power opens a compact centered `nwg-bar` card with Suspend, Restart, and Shutdown

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
