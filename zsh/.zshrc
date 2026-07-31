# Compatibility file for tools that write to ~/.zshrc without respecting ZDOTDIR.
# The interactive configuration in ~/.config/zsh/.zshrc sources this file.

# PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/bin"

if [[ -x /opt/nvim/nvim ]]; then
  export PATH="$PATH:/opt/nvim"
fi
