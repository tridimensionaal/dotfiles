# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# History lives under XDG state so the repo only needs one home-level Zsh entrypoint.
_zsh_state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/zsh"
mkdir -p "$_zsh_state_dir"
HISTFILE="$_zsh_state_dir/history"
HISTSIZE=20000
SAVEHIST=20000
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY

# activate vim mode
bindkey -v
bindkey -M viins 'jj' vi-cmd-mode

# update PATH
export PATH=$PATH:$HOME/bin

if [[ -x /opt/nvim/nvim ]]; then
  export PATH="$PATH:/opt/nvim/"
fi

# Prefer Neovim for CLI editor integrations.
export EDITOR=nvim
export VISUAL=nvim
export GIT_EDITOR="${GIT_EDITOR:-$EDITOR}"

if [ -s /usr/share/nvm/init-nvm.sh ]; then
  source /usr/share/nvm/init-nvm.sh
fi

if [ -r /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme ]; then
  source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
fi

# To customize prompt, run `p10k configure` or edit ${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/.p10k.zsh.
[[ ! -f ${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/.p10k.zsh ]] || source "${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/.p10k.zsh"

# enable completion with case-insensitive matching for Tab.
autoload -Uz compinit
compinit
# insensitive case only if there are no case-sensitive matches,
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'

# load aliases if present.
[[ -r ${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/.zsh_aliases ]] && source "${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/.zsh_aliases"

# ---start_of_bash_scripts_setup---
# Optional integration with Bash-scripts-for-daily-task.
_bash_scripts_init="${BASH_SCRIPTS_INIT:-$HOME/github/Bash-scripts-for-daily-task/setup/init}"
[[ -r "$_bash_scripts_init" ]] && source "$_bash_scripts_init"
# ---end_of_bash_scripts_setup---
