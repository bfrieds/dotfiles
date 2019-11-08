#!/bin/bash
set -x

# Quick install script for mac

# Install homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Brew install all packages
brew upgrade

brew install \
	go \
	autojump \
	bash-completion \
	fzf \
	git \
	htop \
	neovim \
	nvm \
	ripgrep \
	tmux

$(brew --prefix)/opt/fzf/install

# Creates symlinks for dotfiles
DOT_FILES="$HOME/dotfiles"

echo "Dot files folder: $DOT_FILES"

cd $DOT_FILES

ln -s $DOT_FILES/tmux/tmux.conf $HOME/.tmux.conf
ln -s $DOT_FILES/tmux/tmux.conf.local $HOME/.tmux.conf.local

ln -s $DOT_FILES/nvim $HOME/.config/nvim
ln -s $DOT_FILES/shell/bash_profile.sh $HOME/.bash_profile

ln -s $DOT_FILES/nvim/init.vim $HOME/.vimrc

ln -s $DOT_FILES/git/gitconfig $HOME/.gitconfig
ln -s $DOT_FILES/git/gitignore $HOME/.gitignore

if [[ -d $HOME/bin ]]
then
	echo User level bin already exists
else
	ln -s $DOT_FILES/shell/bin ~/bin
	ln -s $DOT_FILES/shell/local_bin ~/local_bin
fi

# Install Node 10
nvm install 10
npm i -g prettier dockerfile-language-server-nodejs bash-language-server

# Set up go mono repo
mkdir -p "$HOME/go"
mkdir -p "$HOME/go/bin"
mkdir -p "$HOME/go/pkg"
mkdir -p "$HOME/go/src"

# Install Vim Plugins
pip install pynvim
nvim +PlugInstall +GoInstallBinaries +qa

# Increase Key Repeat
defaults write -g InitialKeyRepeat -int 10 # normal minimum is 15 (225 ms)
defaults write -g KeyRepeat -int 1 # normal minimum is 2 (30 ms)

# Hide Dock
defaults write com.apple.Dock autohide -bool TRUE
killall Dock

# Show Battery Percentage
defaults write com.apple.menuextra.battery ShowPercent YES

# Show Bluetooth and Clock
defaults write com.apple.systemuiserver menuExtras -array \
	"/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
	"/System/Library/CoreServices/Menu Extras/Clock.menu"

killall SystemUIServer

# Manual Installs

open -na "Google Chrome" --args --new-window \
	https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/SourceCodePro \
	https://iterm2colorschemes.com/ \
	https://www.alfredapp.com/ \
	https://www.spectacleapp.com/
