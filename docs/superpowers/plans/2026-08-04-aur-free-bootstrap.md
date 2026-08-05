# AUR-Free Bootstrap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace Powerlevel10k and wlogout with official-repository Starship and a repository-owned three-action wmenu script, then delete the AUR bootstrap path.

**Architecture:** Zsh initializes a tracked Starship configuration installed through the full Arch profile. Waybar calls an independently executable shell script that maps a fixed wmenu choice to one systemctl action. The Arch installers use pacman exclusively.

**Tech Stack:** Bash, Zsh, Starship TOML, Waybar JSONC, Arch Linux pacman, GNU Stow

## Global Constraints

- The power menu exposes exactly Shutdown, Suspend, and Restart.
- Cancelling the menu performs no action and exits successfully.
- All system packages come from official Arch repositories.
- Existing AUR packages are not uninstalled by the bootstrap.
- Implementation follows test-first red-green cycles.

---

### Task 1: Three-action power menu

**Files:**
- Create: `test-power-menu.sh`
- Create: `waybar/.config/waybar/scripts/power-menu`
- Modify: `waybar/.config/waybar/config`
- Modify: `install.sh`

**Interfaces:**
- Consumes: `wmenu` on `PATH` and the systemd user session.
- Produces: executable `~/.config/waybar/scripts/power-menu` called by Waybar.

- [ ] **Step 1: Write the failing behavior test**

Create a temporary `PATH` with a `wmenu` double that emits `WMENU_CHOICE` and a `systemctl` double that records arguments. Run the real script once for each choice and assert the literal calls `poweroff`, `suspend`, and `reboot`. Run it with an empty choice and assert success with an empty log.

- [ ] **Step 2: Verify the test fails because the script is missing**

Run: `./test-power-menu.sh`

Expected: non-zero exit identifying the missing `waybar/.config/waybar/scripts/power-menu`.

- [ ] **Step 3: Implement the minimal script and integration**

The script obtains a choice with:

```bash
choice=$(printf '%s\n' Shutdown Suspend Restart | wmenu -i -p 'Power') || exit 0
```

It maps only the three specified literal values to their corresponding `systemctl` command. Point Waybar's power button at `$HOME/.config/waybar/scripts/power-menu` and replace the `wlogout` preflight with `wmenu` plus the script file.

- [ ] **Step 4: Verify the power-menu test passes**

Run: `./test-power-menu.sh`

Expected: exit 0 with no output.

### Task 2: Starship prompt and pacman-only bootstrap

**Files:**
- Modify: `test-install-arch.sh`
- Modify: `test-install-profiles.sh`
- Modify: `install-arch.sh`
- Modify: `remote-install.sh`
- Modify: `zsh/.config/zsh/.zshrc`
- Create: `zsh/.config/starship.toml`
- Delete: `zsh/.config/zsh/.p10k.zsh`

**Interfaces:**
- Consumes: official Arch package `starship` in the full profile.
- Produces: `starship init zsh` shell initialization using `~/.config/starship.toml`.

- [ ] **Step 1: Change installer tests to express the AUR-free behavior**

Require `starship` in the full package transaction, forbid `wlogout` and `base-devel` in the GUI transaction, fail if the fake `makepkg` is invoked, and require `install.sh` to preflight the `starship` command for Zsh.

- [ ] **Step 2: Verify the tests fail on the current AUR implementation**

Run: `./test-install-arch.sh && ./test-install-profiles.sh`

Expected: non-zero because makepkg still runs and Starship is not installed or preflighted.

- [ ] **Step 3: Remove AUR code and add Starship**

Delete the AUR arrays, `SKIP_AUR`, keyserver and makepkg state, signing-key helpers, `--skip-aur` parsing, makepkg configuration, package build functions, cleanup branch, and AUR phase. Add `starship` to `PACMAN_FULL_PACKAGES`, change the Zsh dependency check to the `starship` command, initialize Starship from `.zshrc`, and add a compact Dracula-style prompt configuration.

- [ ] **Step 4: Verify installer and profile tests pass**

Run: `./test-install-arch.sh && ./test-install-profiles.sh`

Expected: exit 0; the only acceptable output is the existing optional TPM warning.

### Task 3: Documentation and complete verification

**Files:**
- Modify: `README.md`
- Modify: `dependencies.md`
- Modify: `docs/arch-vm-test.md`
- Modify: `zsh/README.md`
- Modify: `waybar/README.md`

**Interfaces:**
- Consumes: completed power-menu and Starship behavior.
- Produces: installation and validation instructions containing no active AUR workflow.

- [ ] **Step 1: Update documentation**

Describe Starship and the three-action wmenu script, remove manual AUR installation and AUR snapshot steps, remove `--skip-aur`, and update expected VM validation commands.

- [ ] **Step 2: Run static validation**

Run:

```bash
bash -n install.sh install-arch.sh remote-install.sh test-install-arch.sh test-install-profiles.sh test-power-menu.sh waybar/.config/waybar/scripts/power-menu
zsh -n zsh/.config/zsh/.zshrc
python -c 'import pathlib,tomllib; tomllib.loads(pathlib.Path("zsh/.config/starship.toml").read_text())'
```

Expected: all commands exit 0.

- [ ] **Step 3: Run the complete test suite**

Run:

```bash
./test-power-menu.sh
./test-install-arch.sh
./test-install-profiles.sh
./test-toggle-output-layout.sh
```

Expected: all tests exit 0; the only acceptable output is the existing optional TPM warning.

- [ ] **Step 4: Audit the final dependency surface and diff**

Run:

```bash
rg -n -i '\b(aur|makepkg|wlogout|powerlevel10k|p10k)\b' --glob '!docs/superpowers/**' .
git diff --check
git status --short
git diff --stat main...HEAD
```

Expected: no active AUR, makepkg, wlogout, or Powerlevel10k references outside historical design documents; no whitespace errors; only intended files changed.
