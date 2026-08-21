# History lives under XDG state so the repo only needs one home-level Zsh entrypoint.
_zsh_state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/zsh"
mkdir -p "$_zsh_state_dir"
HISTFILE="$_zsh_state_dir/history"
HISTSIZE=20000
SAVEHIST=20000
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY

_zsh_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
mkdir -p "$_zsh_cache_dir"
ZCOMPDUMP="$_zsh_cache_dir/.zcompdump"

# activate vim mode
KEYTIMEOUT=25
bindkey -v
bindkey -M viins 'jj' vi-cmd-mode
bindkey -M viins '^?' backward-delete-char

# User command paths belong to the tracked config, not the local integration hook.
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/bin"

if [[ -x /opt/nvim/nvim ]]; then
  export PATH="$PATH:/opt/nvim"
fi

# Prefer Neovim for CLI editor integrations.
export EDITOR=nvim
export VISUAL=nvim
export GIT_EDITOR="${GIT_EDITOR:-$EDITOR}"

if [ -s /usr/share/nvm/init-nvm.sh ]; then
  source /usr/share/nvm/init-nvm.sh
fi

# enable completion with case-insensitive matching for Tab.
autoload -Uz compinit
compinit -d "$ZCOMPDUMP"
# insensitive case only if there are no case-sensitive matches,
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'

# Use fd as fzf's filesystem source so hidden entries are visible while Git
# ignore rules and the repository metadata directory remain excluded.
if [[ -t 0 ]] && (( $+commands[fzf] && $+commands[fd] )); then
  export FZF_DEFAULT_COMMAND='fd --type f --type l --strip-cwd-prefix --hidden --exclude .git'
  export FZF_CTRL_T_COMMAND='fd --type f --type d --type l --strip-cwd-prefix --hidden --exclude .git'
  export FZF_ALT_C_COMMAND='fd --type d --strip-cwd-prefix --hidden --exclude .git'
  export FZF_DEFAULT_OPTS='--height=80% --layout=reverse --border'
  source <(fzf --zsh)
fi

# load aliases if present.
[[ -r ${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/.zsh_aliases ]] && source "${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/.zsh_aliases"

if [[ -z "${SSH_CONNECTION:-}" ]]; then
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"
fi

# Load integrations added by tools that do not respect ZDOTDIR.
[[ -r "$HOME/.zshrc" ]] && source "$HOME/.zshrc"

eval "$(starship init zsh)"
