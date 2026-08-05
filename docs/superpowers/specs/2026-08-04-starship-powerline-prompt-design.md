# Starship Powerline Prompt Design

## Goal

Make the official-repository Starship prompt closely resemble the previous
Powerlevel10k prompt without restoring an AUR or manually cloned theme.

Success means the prompt restores the familiar two-line frame, colored
Powerline segments, module placement, icons, and vi-mode prompt character while
remaining a valid Starship 1.26.0 configuration.

## Researched Foundation

Starship does not ship an official Powerlevel10k migration preset. Its official
Pastel Powerline, Gruvbox Rainbow, and Catppuccin Powerline presets demonstrate
the supported pattern: module backgrounds joined by Nerd Font Powerline
separators in a custom `format` string.

The old Powerlevel10k configuration placed contextual modules on the first
line, with less important information aligned to its right, and accepted input
on the second line. Starship's documentation says `right_format` renders on the
input line; it recommends the `fill` module for right-aligning content above the
input line. The implementation will therefore keep `$fill` in the main format
instead of using `right_format`.

References:

- <https://starship.rs/presets/>
- <https://starship.rs/presets/pastel-powerline>
- <https://starship.rs/presets/gruvbox-rainbow>
- <https://starship.rs/advanced-config/#enable-right-prompt>

## Prompt Layout

The first line will begin with a dim `╭─` frame and contain:

- left side: Arch icon, current directory, Git branch, and Git status;
- flexible empty space from `$fill`;
- right side: failed exit status, command duration, background jobs, active
  Python/Node.js/Rust environment, and time.

The second line will begin with a dim `╰─` frame followed by Starship's
`character` module. The character remains `❯` in vi insert mode and `❮` in vi
command mode, with success/error color changes.

Powerline separators will use the same filled triangular glyph family as the
old prompt. Segments will use Dracula-compatible colors while preserving the
old visual hierarchy: neutral OS, blue directory, green Git branch, and
attention colors for dirty Git state, failures, and long-running commands.

## Behavior and Constraints

- The prompt depends only on Starship and the already-required Nerd Font.
- Modules remain conditional: status appears only on failure, command duration
  only after its threshold, jobs only when present, and language environments
  only in relevant projects.
- Long paths remain truncated to three components and stop truncating at a Git
  repository root.
- Git status retains concise ahead, behind, modified, staged, untracked,
  renamed, deleted, stashed, and conflicted indicators.
- The prompt keeps one blank line between commands, matching the previous
  Powerlevel10k setting.
- No custom executable, shell hook, downloaded theme, or runtime network access
  is introduced.

Starship cannot dynamically recolor the complete Git branch segment based on
every repository state in exactly the same way as Powerlevel10k's custom Git
formatter. Instead, the branch keeps a stable green block and the adjacent
conditional status block provides state-specific attention coloring.

## Error Handling

The existing Zsh installer preflight continues to reject installation when
`starship` is unavailable. Missing Nerd Font glyphs are a terminal font issue;
the Zsh documentation will call out the requirement. Conditional modules hide
themselves when their underlying runtime or context is absent.

## Validation

- Parse `starship.toml` with Python's TOML parser.
- Run `starship print-config` with Starship 1.26.0.
- Render prompts in clean and dirty Git repositories and inspect the ANSI output
  for the two-line frame, module order, Powerline separators, and status
  indicators.
- Render success and failure prompts to verify character and status behavior.
- Run the existing installer/profile tests and Zsh syntax check.

