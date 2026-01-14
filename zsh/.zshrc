# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# activate vim mode
bindkey -v
bindkey -M viins 'jj' vi-cmd-mode

# update PATH
export PATH=$PATH:$HOME/bin
export PATH="$PATH:/opt/nvim/"


if [ -s /usr/share/nvm/init-nvm.sh ]; then
  source /usr/share/nvm/init-nvm.sh
fi

source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# enable completion with case-insensitive matching for Tab.
autoload -Uz compinit
compinit
# insensitive case only if there are no case-sensitive matches,
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'

# load aliases if present.
[[ -r ~/.zsh_aliases ]] && source ~/.zsh_aliases
