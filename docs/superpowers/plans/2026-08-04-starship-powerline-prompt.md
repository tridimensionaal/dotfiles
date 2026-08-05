# Starship Powerline Prompt Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the plain Starship prompt styling with a tested two-line Powerline prompt that closely matches the repository's former Powerlevel10k layout.

**Architecture:** Keep Starship as the only prompt engine and express the complete layout in `starship.toml`. Adapt the supported separator and background-color pattern from Starship's official Powerline presets, use `$fill` to align first-line contextual modules, and retain Starship's conditional built-in modules instead of adding shell hooks or helper executables.

**Tech Stack:** Starship 1.26.0, TOML, Zsh 5.9, Bash regression tests, Python 3 `tomllib`, Nerd Font v3 glyphs

## Global Constraints

- Starship must remain installable from Arch's official repository; do not add an AUR package, cloned theme, or runtime download.
- The prompt must restore the two-line `╭─` / `╰─` frame and filled Powerline separators.
- First-line left modules are OS, directory, Git branch, and Git status; first-line right modules are failure status, duration, jobs, Python, Node.js, Rust, and time.
- `$fill` must align modules on the first line; do not use `right_format`, which Starship renders on the input line.
- Modules must remain conditional and paths must truncate to three components without truncating past a Git repository root.
- The configuration must validate with Starship 1.26.0 and Python's TOML parser.

---

### Task 1: Lock down the P10k-style prompt contract

**Files:**
- Modify: `test-install-profiles.sh`
- Test: `test-install-profiles.sh`

**Interfaces:**
- Consumes: `STARSHIP_CONFIG`, the path to `zsh/.config/starship.toml`
- Produces: `starship_config_matches_p10k_layout`, a regression test that exits nonzero when layout tokens, module order, or core style settings drift

- [ ] **Step 1: Add a failing structural regression test**

Add this function after `starship_config_is_valid_toml`:

```bash
starship_config_matches_p10k_layout() {
  python - "${STARSHIP_CONFIG}" <<'PY'
import pathlib
import sys
import tomllib

config = tomllib.loads(pathlib.Path(sys.argv[1]).read_text())
prompt = config["format"]
tokens = (
    "╭─", "$os", "$directory", "$git_branch", "$git_status", "$fill",
    "$status", "$cmd_duration", "$jobs", "$python", "$nodejs", "$rust",
    "$time", "$line_break", "╰─", "$character",
)
positions = [prompt.index(token) for token in tokens]
assert positions == sorted(positions), positions
module_formats = "".join(
    value.get("format", "")
    for value in config.values()
    if isinstance(value, dict)
)
assert "" in prompt + module_formats
assert "" in prompt + module_formats
assert config["add_newline"] is True
assert config["directory"]["truncation_length"] == 3
assert config["directory"]["truncate_to_repo"] is True
assert config["status"]["disabled"] is False
assert config["time"]["disabled"] is False
assert config["character"]["success_symbol"].find("❯") >= 0
assert config["character"]["vimcmd_symbol"].find("❮") >= 0
PY
}
```

Invoke it after the TOML syntax test:

```bash
starship_config_matches_p10k_layout || fail 'starship P10k-style prompt layout'
```

- [ ] **Step 2: Run the regression test and verify it fails**

Run: `./test-install-profiles.sh`

Expected: FAIL with a Python `ValueError` because the current prompt has neither `╭─` nor `╰─` and does not contain Powerline separators.

- [ ] **Step 3: Commit the failing test**

```bash
git add test-install-profiles.sh
git commit -m "test(zsh): specify P10k-style Starship layout"
```

### Task 2: Build the supported Starship Powerline layout

**Files:**
- Modify: `zsh/.config/starship.toml`
- Modify: `zsh/README.md`
- Test: `test-install-profiles.sh`

**Interfaces:**
- Consumes: Starship built-in modules and the existing `dracula` palette
- Produces: a multiline `format` string with framed Powerline segments; conditional module format strings with background styles; documented Nerd Font requirement

- [ ] **Step 1: Replace the prompt-wide format**

Use a multiline basic TOML string, with backslash line continuations preventing source-formatting newlines, in this exact module order:

```toml
format = """
[╭─](comment)\
$os\
[](fg:current_line bg:blue)\
$directory\
[](fg:blue bg:green)\
$git_branch\
$git_status\
$fill\
$status\
$cmd_duration\
$jobs\
$python\
$nodejs\
$rust\
$time\
$line_break\
[╰─](comment)\
$character"""
```

Add `blue = "#6272A4"` to the Dracula palette and retain `add_newline = true`.

- [ ] **Step 2: Style the left Powerline blocks**

Configure the OS module with `fg:foreground bg:current_line`, the directory with `fg:foreground bg:blue`, and Git branch with `fg:background bg:green`. Give each module internal padding but no trailing ordinary space. The Git branch format must close its own green block with ``. Configure Git status as a separate conditional yellow capsule with its own leading `` and trailing ``; this prevents a dirty-state block from leaving a separator behind in clean repositories. Use concise symbols for conflicts (`~`), ahead (`⇡`), behind (`⇣`), diverged (`⇕`), untracked (`?`), stashed (`*`), modified (`!`), staged (`+`), renamed (`»`), and deleted (`✘`).

- [ ] **Step 3: Style conditional right-side blocks**

Make each conditional right-side module include its own leading `` separator so hidden modules leave no empty colored block. Use red for failed status, yellow for duration, cyan for jobs, and the existing Python/Node.js/Rust colors. End the time block at the terminal edge with current-line background and `%H:%M:%S`, matching the old prompt's seconds display.

- [ ] **Step 4: Preserve the second-line vi prompt**

Keep `❯` for insert mode and `❮` for command mode, with green success, red error, purple replace, and yellow visual styles. The literal `╰─` before `$character` supplies the old frame without a Zsh hook.

- [ ] **Step 5: Document the visual dependency**

Add a Zsh README note stating that the Powerline separators and icons require a Nerd Font configured in the terminal, and that the tracked prompt intentionally mirrors the former Powerlevel10k two-line layout.

- [ ] **Step 6: Run focused verification**

Run:

```bash
python -c 'import pathlib, tomllib; tomllib.loads(pathlib.Path("zsh/.config/starship.toml").read_text())'
STARSHIP_CONFIG="$PWD/zsh/.config/starship.toml" starship print-config >/dev/null
./test-install-profiles.sh
```

Expected: all commands exit 0.

- [ ] **Step 7: Inspect rendered success and failure prompts**

Run:

```bash
STARSHIP_CONFIG="$PWD/zsh/.config/starship.toml" starship prompt --status=0 --cmd-duration=0 --jobs=0
STARSHIP_CONFIG="$PWD/zsh/.config/starship.toml" starship prompt --status=7 --cmd-duration=2500 --jobs=1
```

Expected: both prompts have the `╭─` first line, `╰─` second line, left Powerline blocks, and right-aligned time; the failure sample additionally renders red status, duration, and jobs blocks.

- [ ] **Step 8: Run repository regression checks**

Run:

```bash
bash -n test-install-profiles.sh install.sh install-arch.sh remote-install.sh
zsh -n zsh/.config/zsh/.zshrc zsh/.zshrc zsh/.zshenv
./test-power-menu.sh
./test-install-arch.sh
./test-install-profiles.sh
./test-toggle-output-layout.sh
git diff --check
```

Expected: all commands exit 0; the known TPM-not-installed warning may still appear.

- [ ] **Step 9: Commit the prompt implementation**

```bash
git add zsh/.config/starship.toml zsh/README.md
git commit -m "feat(zsh): restore Powerline prompt styling"
```
