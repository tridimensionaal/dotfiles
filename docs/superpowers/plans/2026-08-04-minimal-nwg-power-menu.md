# Minimal nwg-bar Power Menu Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the wmenu power strip with a compact centered nwg-bar card containing only Suspend, Restart, and Shutdown.

**Architecture:** Keep the power UI inside the existing Waybar Stow package: Waybar invokes `nwg-bar -i 64`, while nwg-bar reads tracked JSON actions and GTK CSS from `~/.config/nwg-bar`. Replace the helper script with declarative configuration, retain `wmenu` solely for Sway's `wmenu-run` launcher, and install every runtime from Arch's official repositories.

**Tech Stack:** nwg-bar 0.1.6, GTK3 CSS, JSON, Waybar, Bash installer tests, Python 3 JSON parser, GNU Stow, Arch pacman

## Global Constraints

- The menu contains exactly three horizontal actions in this order: Suspend, Restart, Shutdown.
- Actions run `systemctl suspend`, `systemctl reboot`, and `systemctl poweroff` directly without a confirmation dialog.
- Use nwg-bar's compact centered mode with 64-pixel upstream icons; do not use `-f` full-screen mode.
- Do not add a title, description, clock, user information, logout, lock, animations, wrapper script, or another Stow package.
- Reuse the existing Waybar dark blue/teal palette with restrained hover and focus styling.
- Keep `wmenu` installed and `wmenu-run` checked for Sway's application launcher.
- Add only the official Arch `nwg-bar` package; do not add an AUR dependency.

---

### Task 1: Specify the declarative power-menu contract

**Files:**
- Create: `test-nwg-bar-config.sh`
- Test: `test-nwg-bar-config.sh`

**Interfaces:**
- Consumes: `waybar/.config/nwg-bar/bar.json`, `waybar/.config/nwg-bar/style.css`, and `waybar/.config/waybar/config`
- Produces: a regression test that rejects missing, reordered, additional, or incorrectly wired power actions and rejects a full-screen invocation

- [ ] **Step 1: Write the failing configuration test**

Create an executable Bash test that parses `bar.json` with Python and compares it with this literal value:

```python
expected = [
    {
        "label": "Suspend",
        "exec": "systemctl suspend",
        "icon": "/usr/share/nwg-bar/images/system-suspend.svg",
    },
    {
        "label": "Restart",
        "exec": "systemctl reboot",
        "icon": "/usr/share/nwg-bar/images/system-reboot.svg",
    },
    {
        "label": "Shutdown",
        "exec": "systemctl poweroff",
        "icon": "/usr/share/nwg-bar/images/system-shutdown.svg",
    },
]
```

The test must also require the literal Waybar click action `"on-click": "nwg-bar -i 64"`, reject `nwg-bar -f`, and require the GTK selectors `window`, `#outer-box`, `#inner-box`, `button`, `button:hover`, `button:focus`, `image`, and `label` in `style.css`.

- [ ] **Step 2: Run the new test and verify it fails**

Run: `./test-nwg-bar-config.sh`

Expected: FAIL because `waybar/.config/nwg-bar/bar.json` does not exist.

- [ ] **Step 3: Commit the failing test**

```bash
git add test-nwg-bar-config.sh
git commit -m "test(waybar): specify minimal nwg-bar menu"
```

### Task 2: Replace the wmenu helper with nwg-bar configuration

**Files:**
- Create: `waybar/.config/nwg-bar/bar.json`
- Create: `waybar/.config/nwg-bar/style.css`
- Modify: `waybar/.config/waybar/config`
- Delete: `waybar/.config/waybar/scripts/power-menu`
- Delete: `test-power-menu.sh`
- Test: `test-nwg-bar-config.sh`

**Interfaces:**
- Consumes: nwg-bar's JSON `label`, `exec`, and `icon` fields and documented GTK widget names
- Produces: `~/.config/nwg-bar/bar.json`, `~/.config/nwg-bar/style.css`, and a Waybar click action that launches `nwg-bar -i 64`

- [ ] **Step 1: Add the exact three-action JSON template**

Create `bar.json` with the literal three dictionaries from Task 1 and no other actions or metadata.

- [ ] **Step 2: Add the minimal GTK CSS**

Use a transparent window and outer box, one `rgba(7, 17, 23, 0.96)` inner card with a 16-pixel radius and subtle `rgba(125, 168, 184, 0.30)` border, and three 112-pixel minimum-width buttons. Buttons use white labels, 12-pixel radii, 14-pixel padding, and transparent backgrounds; hover and focus use `rgba(0, 153, 153, 0.24)`. Set labels to Hack Nerd Font at 14 pixels and give images 8 pixels of bottom margin.

- [ ] **Step 3: Point Waybar directly at nwg-bar**

Change only the custom power module's action:

```json
"on-click": "nwg-bar -i 64"
```

- [ ] **Step 4: Remove the obsolete shell implementation**

Delete `waybar/.config/waybar/scripts/power-menu` and `test-power-menu.sh`. No replacement wrapper script is allowed.

- [ ] **Step 5: Run the focused test and verify it passes**

Run: `./test-nwg-bar-config.sh`

Expected: PASS with no output.

- [ ] **Step 6: Commit the menu replacement**

```bash
git add waybar/.config/nwg-bar waybar/.config/waybar/config test-nwg-bar-config.sh
git add -u waybar/.config/waybar/scripts/power-menu test-power-menu.sh
git commit -m "feat(waybar): use minimal nwg-bar power menu"
```

### Task 3: Wire the official dependency and update validation

**Files:**
- Modify: `install-arch.sh`
- Modify: `install.sh`
- Modify: `test-install-arch.sh`
- Modify: `test-install-profiles.sh`
- Modify: `README.md`
- Modify: `dependencies.md`
- Modify: `waybar/README.md`
- Modify: `docs/arch-vm-test.md`
- Test: `test-install-arch.sh`
- Test: `test-install-profiles.sh`

**Interfaces:**
- Consumes: Arch package `nwg-bar` and executable `nwg-bar`
- Produces: official-package installation, Waybar preflight reporting, and documentation for the new menu

- [ ] **Step 1: Add failing installer expectations**

In `test-install-arch.sh`, require `nwg-bar` and `wmenu` as separate words in the pacman log. In `test-install-profiles.sh`, add a fake `nwg-bar`, require it in the GUI dry-run output, and add `waybar_preflight_requires_nwg_bar`, modeled on `zsh_preflight_requires_starship`, that removes the fake, runs `install.sh waybar --dry-run` with the closed test PATH, and requires `[waybar] command not found: nwg-bar`.

- [ ] **Step 2: Run installer tests and verify they fail**

Run:

```bash
./test-install-arch.sh
./test-install-profiles.sh
```

Expected: at least one test fails because nwg-bar is not yet installed or checked by the scripts.

- [ ] **Step 3: Update install dependencies**

Add `nwg-bar` beside `waybar` in `PACMAN_GUI_PACKAGES`. In `check_waybar_dependencies`, replace the `wmenu` command check with `nwg-bar`; leave the Sway `wmenu-run` check unchanged.

- [ ] **Step 4: Update documentation**

Add `nwg-bar` to the Arch VM package command and runtime checks. Replace every user-facing description of the wmenu power selector with the compact three-action nwg-bar card. In `dependencies.md`, list `nwg-bar` under Waybar and explicitly retain `wmenu-run` under Sway. In the root package table, record that the `waybar` Stow package owns both `~/.config/waybar` and `~/.config/nwg-bar`.

- [ ] **Step 5: Run installer and documentation checks**

Run:

```bash
./test-install-arch.sh
./test-install-profiles.sh
rg -n 'power-menu|wmenu.*power|power.*wmenu' README.md dependencies.md waybar docs sway install.sh install-arch.sh
```

Expected: both tests pass; the reference scan returns no obsolete production or user-documentation references.

- [ ] **Step 6: Commit dependency and documentation changes**

```bash
git add install-arch.sh install.sh test-install-arch.sh test-install-profiles.sh README.md dependencies.md waybar/README.md docs/arch-vm-test.md
git commit -m "docs: wire official nwg-bar dependency"
```

### Task 4: Verify and activate the menu locally

**Files:**
- Verify only: all changed files

**Interfaces:**
- Consumes: committed repository state and the official Arch `nwg-bar` executable
- Produces: a clean tested branch and an active `~/.config/nwg-bar` Stow link when local package installation is available

- [ ] **Step 1: Run repository verification**

Run:

```bash
bash -n install.sh install-arch.sh test-install-arch.sh test-install-profiles.sh test-nwg-bar-config.sh
python -m json.tool waybar/.config/nwg-bar/bar.json >/dev/null
./test-nwg-bar-config.sh
./test-install-arch.sh
./test-install-profiles.sh
./test-toggle-output-layout.sh
sway --validate --config sway/.config/sway/config
git diff main...HEAD --check
```

Expected: all commands exit 0; the known TPM-not-installed warning may still appear.

- [ ] **Step 2: Install the official package if local sudo is available**

Run:

```bash
sudo -n pacman -S --needed --noconfirm nwg-bar
```

If cached/noninteractive sudo is unavailable, stop only the local activation step and report the exact manual install command; repository verification remains valid.

- [ ] **Step 3: Restow Waybar configuration**

Run: `./install.sh waybar`

Expected: Stow links both `~/.config/waybar` and `~/.config/nwg-bar`, with no conflict.

- [ ] **Step 4: Confirm local installation state**

Run:

```bash
nwg-bar -v
readlink "$HOME/.config/nwg-bar"
git status --short --branch
```

Expected: nwg-bar reports version 0.1.6, the config link resolves into this repository's Waybar package, and the feature branch is clean.
