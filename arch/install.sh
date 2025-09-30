# directories
GITHUB_DIR="$HOME/github"
BASH_SCRIPTS_DIR="$GITHUB_DIR/Bash-scripts-for-daily-task"
BIN_DIR="$HOME/bin"
FONTS_DIR="$HOME/.fonts"
CONFIG_DIR="$HOME/.config"
DOTFILES_DIR="$GITHUB_DIR/dotfiles"

mkdir -p "$GITHUB_DIR" "$FONTS_DIR" "$BIN_DIR"  "$CONFIG_DIR" "$CONFIG_DIR/tmux"

sudo pacman -S git curl xclip less alacritty firefox zsh tmux discord neovim go unzip

# clone custom repos
git clone "git@github.com:tridimensionaal/dotfiles.git" "$GITHUB_DIR/dotfiles"
git clone git@github.com:tridimensionaal/Bash-scripts-for-daily-task.git  "$BASH_SCRIPTS_DIR"

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

##################################### RESTART PC #####################################
rm "$HOME/.zshrc"
ln -s "$GITHUB_DIR/dotfiles/oh-my-zsh/.zshrc" "$HOME"

# install custom bash scripts
ln -s "$BASH_SCRIPTS_DIR/scripts/*" "$BIN_DIR"

# instal gnome conf
dconf load / < "$DOTFILES_DIR/arch/user.conf"

# install custom fonts 
wget -O "$FONTS_DIR/fonts.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Hack.zip"
unzip "$FONTS_DIR/fonts.zip" -d "$FONTS_DIR"
rm "$FONTS_DIR/fonts.zip"

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
ln -s "$GITHUB_DIR/dotfiles/tmux/tmux.conf" "$CONFIG_DIR/tmux"
# Enter to $CONFIG_DIR/tmux/tmux.conf y apretar [prefix] + [I]
# tmux source "$CONFIG_DIR/tmux/tmux.conf"

# install astro vim
sudo rm -r "$CONFIG_DIR/nvim"
git clone --depth 1 https://github.com/AstroNvim/template "$CONFIG_DIR/nvim"
rm -rf ~/.config/nvim/.git

