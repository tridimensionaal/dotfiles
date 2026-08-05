# Minimal nwg-bar Power Menu Design

## Goal

Replace the current `wmenu` power selector with a small, centered power dialog
that is comfortable to click and visually consistent with the Sway desktop.
Keep the implementation in Arch's official repositories and avoid recreating a
desktop shell, dashboard, or full logout screen.

## Chosen Tool

Use `nwg-bar`, available from Arch's official `extra` repository. It is designed
for wlroots compositors, displays a centered button bar from a JSON template,
and supports GTK CSS styling. This matches the requested interaction better
than a dmenu-style launcher while avoiding the AUR-only `wlogout` package.

The alternatives were rejected for this use case:

- Fuzzel and rofi are polished launchers, but a three-action power menu would
  still look and behave like a searchable application list.
- Zenity and Yad create conventional dialogs, but their stock button layout is
  less direct and less consistent with the existing Waybar theme.

References:

- <https://archlinux.org/packages/extra/x86_64/nwg-bar/>
- <https://github.com/nwg-piotr/nwg-bar>

## Interaction

Clicking Waybar's existing power icon launches `nwg-bar` in its normal compact,
centered mode. The card contains exactly three horizontal buttons, in this
order:

1. Suspend — `systemctl suspend`
2. Restart — `systemctl reboot`
3. Shutdown — `systemctl poweroff`

Each button has one upstream nwg-bar system icon and one short label. Activating
a button runs its command directly. There is no second confirmation dialog,
title, description, clock, user information, logout action, lock action, or
animation layer. Escape dismisses the card, and nwg-bar closes it shortly after
the pointer leaves the window.

## Visual Design

Use nwg-bar's default centered window size instead of its full-screen `-f` mode.
This keeps the result closer to a floating dialog and preserves its pointer-leave
dismissal behavior. The compact rounded card reuses the existing Waybar dark
blue/teal palette, a subtle border, white labels, and a restrained teal
hover/focus state.

Buttons are large enough to be clear click targets, but the card must not span
the screen or resemble a top bar. Icons use the SVG files shipped by nwg-bar at
64 pixels. Styling uses only the GTK selectors provided by nwg-bar: `window`,
`#outer-box`, `#inner-box`, `button`, `image`, and `label`.

## Repository Structure

Keep the implementation inside the existing `waybar` Stow package because the
power dialog is launched by the Waybar module and replaces its current helper:

- add `waybar/.config/nwg-bar/bar.json` for the three actions;
- add `waybar/.config/nwg-bar/style.css` for the minimal centered card;
- point Waybar's power click action to `nwg-bar -i 64`;
- delete `waybar/.config/waybar/scripts/power-menu`;
- delete the obsolete power-menu script test.

This avoids adding another Stow package or wrapper script. The `wmenu` package
remains installed because Sway still uses `wmenu-run` as its application
launcher.

## Dependency and Documentation Changes

- Add `nwg-bar` to the official pacman GUI/full package set.
- Change the Waybar preflight dependency from `wmenu` to `nwg-bar`.
- Keep Sway's `wmenu-run` dependency unchanged.
- Update dependency and component documentation to distinguish `wmenu-run`
  application launching from the `nwg-bar` power dialog.

## Validation

- Parse `bar.json` and assert the exact three labels, commands, and upstream icon
  paths in order.
- Assert the Waybar click command invokes `nwg-bar -i 64` without full-screen
  mode.
- Assert installer dry runs include official `nwg-bar` and retain `wmenu` for
  `wmenu-run`.
- Assert Waybar preflight fails clearly when `nwg-bar` is unavailable.
- Run shell syntax, installer/profile, JSON, and Sway validation checks.
- When `nwg-bar` is installed locally, launch the tracked configuration under
  Sway and confirm the overlay is centered, compact, dismissible, and usable by
  mouse and keyboard.
