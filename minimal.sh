#!/bin/bash
set -x
set -e

[ -z "$GITHUB_ACTION" ] && sudo -v
# Quick install script for mac

if [ "$(uname)" == "Darwin" ]; then
	# Install homebrew
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

	# Save Homebrew’s installed location.
	BREW_PREFIX=$(brew --prefix)

	# Brew install all packages
	brew upgrade

	brew install \
		neovim
fi

# Creates symlinks for dotfiles
if [ -z "$GITHUB_ACTION" ]; then
	DOT_FILES="$HOME/dotfiles"
else
	DOT_FILES="$GITHUB_WORKSPACE"
fi

echo "Dot files folder: $DOT_FILES"

cd $DOT_FILES

rm -rf $HOME/.config/nvim
ln -s $DOT_FILES/nvim $HOME/.config
ln -sf $DOT_FILES/nvim/init.vim $HOME/.vimrc

# Install Vim Plugins
python3 -m pip install pynvim
curl -fLo "$HOME/.config/nvim/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
nvim +PlugInstall +GoInstallBinaries +qa

