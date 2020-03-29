#!/bin/bash
set -x

# Quick install script for mac

if [ "$(uname)" == "Darwin" ]; then
	# Install homebrew
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

	# Brew install all packages
	brew upgrade

	brew install \
		autojump \
		bat \
		bash-completion \
		curl \
		exa \
		fzf \
		git \
		gnu-sed \
		go \
		htop \
		neovim \
		nvm \
		pyenv \
		ripgrep \
		terraform \
		thefuck \
		tmux \
		wget

	brew cask install \
		alfred \
		docker \
		dropbox \
		evernote \
		firefox \
		go2shell \
		google-chrome \
		iterm2 \
		postman \
		slack \
		spotify \
		sublime-text \
		zoom

	$(brew --prefix)/opt/fzf/install

elif [ "$(uname)" == "Linux" ]; then
	echo "Installing for Linux"


	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

	sudo add-apt-repository -y ppa:longsleep/golang-backports
	sudo add-apt-repository -y ppa:neovim-ppa/stable

	sudo apt update
	sudo apt install -y --no-install-recommends \
		autojump \
		bash-completion \
		build-essential \
		curl \
		docker-ce \
		git \
		golang-go \
		htop \
		neovim \
		nodejs \
		python3-neovim \
		python3-pip \
		sed \
		unzip \
		tmux

	sudo systemctl reload docker
	sudo usermod -aG docker $USER

	curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

	# install exa
	wget https://github.com/ogham/exa/releases/download/v0.9.0/exa-linux-x86_64-0.9.0.zip -O /tmp/exa.zip
	unzip /tmp/exa.zip
	sudo mv exa-linux-x86_64 /usr/local/bin/exa-linux-x86_64
	sudo ln -s /usr/local/bin/exa-linux-x86_64 /usr/local/bin/exa
	sudo curl https://raw.githubusercontent.com/ogham/exa/master/contrib/man/exa.1 > /usr/share/man/man1/exa.1
	sudo curl https://raw.githubusercontent.com/ogham/exa/master/contrib/completions.bash > /etc/bash_completion.d/exa

	# install ripgrep
	curl -LO https://github.com/BurntSushi/ripgrep/releases/download/11.0.2/ripgrep_11.0.2_amd64.deb > ripgrep_11.0.2_amd64.deb
	sudo dpkg -i ripgrep_11.0.2_amd64.deb
	rm ripgrep_11.0.2_amd64.deb

	# install fzf
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install --key-bindings --completion --no-update-rc

	# install terraform
	curl https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip > /tmp/terraform.zip
	sudo unzip /tmp/terraform.zip /usr/local/bin
fi

# Creates symlinks for dotfiles
DOT_FILES="$HOME/dotfiles"

echo "Dot files folder: $DOT_FILES"

cd $DOT_FILES

ln -s $DOT_FILES/tmux/tmux.conf $HOME/.tmux.conf
ln -s $DOT_FILES/tmux/tmux.conf.local $HOME/.tmux.conf.local

rm -rf $HOME/.config/nvim
ln -s $DOT_FILES/nvim $HOME/.config
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

sudo npm i -g prettier dockerfile-language-server-nodejs bash-language-server

# Set up go mono repo
mkdir -p "$HOME/go"
mkdir -p "$HOME/go/bin"
mkdir -p "$HOME/go/pkg"
mkdir -p "$HOME/go/src"

# Install Vim Plugins
python3 -m pip install pynvim
curl -fLo "$HOME/.config/nvim/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
nvim +PlugInstall +GoInstallBinaries +qa

if [ "$(uname)" == "Darwin" ]; then
	echo "Configuring MacOS"
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

	cp fonts/Fira-Code-Retina-Nerd-Font-Complete.ttf "$HOME/Library/Fonts"

	killall SystemUIServer
elif [ "$(uname)" == "Linux" ]; then
	echo "Configuring Linux"
fi
