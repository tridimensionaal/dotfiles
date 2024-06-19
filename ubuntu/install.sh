# vim
sudo apt install vim
# xclip
sudo apt install xclip
# curl
sudo apt install curl
# git
sudo apt install git
ssh-keygen -t ed25519 -C "matiaseda@hotmail.cl"
ssh-add ~/.ssh/id_ed25519
# add ssh key to git

# custom bash scripts
OTHERS_DIR="$HOME/Documents/others"
BASH_SCRIPTS_DIR="$OTHERS_DIR/Bash-scripts-for-daily-task"

mkdir "$OTHERS_DIR"
git clone git@github.com:tridimensionaal/Bash-scripts-for-daily-task.git  "$BASH_SCRIPTS_DIR"
mkdir ~/bin
ln -s "$BASH_SCRIPTS_DIR/scripts" ~/bin

# fonts
FONTS_DIR="$HOME/.fonts"
mkdir "$FONTS_DIR"
wget -O "$FONTS_DIR/fonts.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Hack.zip"
unzip "$FONTS_DIR/fonts.zip" -d "$FONTS_DIR"
rm "$FONTS_DIR/fonts.zip"

# dotfiles
git clone "git@github.com:tridimensionaal/dotfiles.git" "$OTHERS_DIR/dotfiles"

# alacritty
sudo add-apt-repository ppa:aslatter/ppa -y
sudo apt install alacritty
sudo update-alternatives --config x-terminal-emulator

CONFIG_DIR="$HOME/.config"
mkdir "$CONFIG_DIR/alacritty"
ln -s "$OTHERS_DIR/dotfiles/alacritty/alacritty.toml" "$CONFIG_DIR/alacritty"

# oh-my-zsh
sudo apt install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
csh -s $(which zsh)

##################################### RESTART PC #####################################
rm "$HOME/.zshrc"
ln -s "$OTHERS_DIR/dotfiles/oh-my-zsh/.zshrc" "$HOME"

# tmux
sudo apt install tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
mkdir "$CONFIG_DIR/tmux"
ln -s "$OTHERS_DIR/dotfiles/tmux/tmux.conf" "$CONFIG_DIR/tmux"
# hay que entrar al archivo ~/.config/tmux/tmux.conf y apretar [prefix] + [I]
# tmux source "$CONFIG_DIR/tmux/tmux.conf"

# discord
mkdir "$HOME/Programs"
wget -O ~/Programs/discord.deb "https://discord.com/api/download?platform=linux&format=deb"
sudo apt install ~/Programs/discord.deb

# neovim
sudo apt install fuse
curl -Lo ~/Programs/nvim.appimage https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x ~/Programs/nvim.appimage
# ~/Programs/nvim.appimage
sudo mkdir -p /opt/nvim
sudo cp ~/Programs/nvim.appimage /opt/nvim/nvim
sudo chown $USER /opt/nvim/nvim
# echo 'export PATH="$PATH:/opt/nvim/"' >> ~/.zshrc

# lunarvim
sudo apt install git make npm python3-pip cargo
curl https://sh.rustup.rs -sSf | sh
LV_BRANCH='release-1.3/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.sh)
##
NPM_GLOBAL_DIR="$HOME/.npm-global"
mkdir "$NPM_GLOBAL_DIR"
npm config set prefix "$NPM_GLOBAL_DIR"
echo "export PATH=$NPM_GLOBAL_DIR/bin:\$PATH" >> ~/.profile

##
ln -s "$OTHERS_DIR/dotfiles/lvim/config.lua" "$HOME/.config/lvim"
# go 
wget -O ~/Programs/go.tar.gz https://go.dev/dl/go1.22.0.linux-amd64.tar.gz
sudo  rm -rf /usr/local/go && sudo tar -C /usr/local -xzf ~/Programs/go.tar.gz
echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.profile
