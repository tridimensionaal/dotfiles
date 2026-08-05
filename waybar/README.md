# Waybar

The Waybar and power-menu configs live under `~/.config/waybar` and `~/.config/nwg-bar`.

## Modules

- Left: Sway workspaces and Sway mode
- Center: clock and idle inhibitor
- Right: tray, speaker volume, microphone volume, battery, and power

## Actions

- Clock opens `gnome-calendar`
- Speaker opens `pavucontrol -t 3`
- Microphone opens `pavucontrol -t 4`
- Battery opens `gnome-power-statistics`
- Power opens a compact centered `nwg-bar` card with Suspend, Restart, and Shutdown actions

## Styling

The Waybar CSS uses a translucent dark bar with grouped module backgrounds. The nwg-bar CSS uses a compact dark card with a restrained teal hover and focus state. They expect these font families:

- `Hack Nerd Font`
- `Font Awesome 7 Free`
- `Font Awesome 7 Brands`

## Assumptions

- Battery device is `BAT0`
- AC adapter is `AC`
- Audio status comes from WirePlumber
- GUI profile installs this package together with `alacritty`, `sway`, and `gtk`
