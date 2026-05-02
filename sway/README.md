# Sway

The Sway config lives under `~/.config/sway`.

## Layout

- `config` is the entrypoint and includes ordered files from `config.d/`
- `00-vars.conf` defines the modifier, direction keys, terminal, browser, and launcher
- `10-input.conf` sets the keyboard layout to `latam`
- `20-output.conf` sets the wallpaper
- `30-appearance.conf` sets gaps, borders, focus behavior, and colors
- `40-bindings.conf` defines launch, focus, workspace, layout, and hardware keybindings
- `50-rules.conf` defines workspace assignment and floating utility windows
- `60-modes.conf` defines resize mode
- `70-scratchpad.conf` defines scratchpad bindings
- `80-startup.conf` starts desktop services

## Notable Bindings

- `Mod+t`: open Alacritty
- `Mod+d`: open `wmenu-run`
- `Mod+Shift+b`: open Firefox
- `Mod+q`: close the focused window
- `Mod+Shift+c`: reload Sway
- `Mod+Shift+e`: confirm and exit Sway
- `Mod+h/j/k/l`: move focus
- `Mod+Shift+h/j/k/l`: move windows
- `Mod+1..0`: switch workspaces
- `Mod+Shift+1..0`: move window to workspace
- `Mod+r`: resize mode
- `Mod+minus`: show scratchpad
- `Mod+Shift+minus`: move window to scratchpad
- `Print`: run `grim`

## Startup

Sway starts:

- `gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'`
- `waybar`, restarted on reload
- `nm-applet --indicator`
- `polkit-gnome-authentication-agent-1`

## Desktop Rules

Firefox is assigned to workspace 2. Utility windows such as NetworkManager, Pavucontrol, Thunar, GNOME Calendar, and GNOME Power Statistics open as centered floating windows.

## Assumptions

- Wallpaper path: `~/Pictures/wallpapers/picture_1.jpg`
- Polkit agent path: `/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1`
- GUI profile installs this package together with `alacritty`, `waybar`, and `gtk`.
