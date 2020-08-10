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
		autojump \
		bat \
		bash \
		bash-completion2 \
		coreutils \
		curl \
		diff-so-fancy \
		exa \
		findutils \
		fzf \
		git \
		gnu-sed \
		go \
		grep \
		htop \
		neovim \
		nvm \
		openssh \
		packer \
		pandoc \
		protobuf \
		pyenv \
		ripgrep \
		terraform \
		thefuck \
		tmux \
		tree \
		wget

	# Switch to using brew-installed bash as default shell
	if ! fgrep -q "${BREW_PREFIX}/bin/bash" /etc/shells; then
		echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells;
		sudo chsh -s "${BREW_PREFIX}/bin/bash" $(whoami)
	fi;

	brew cask install \
		1password \
		alfred \
		docker \
		dropbox \
		firefox \
		go2shell \
		google-chrome \
		iterm2 \
		muzzle \
		notion \
		postman \
		rectangle \
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
if [ -z "$GITHUB_ACTION" ]; then
	DOT_FILES="$HOME/dotfiles"
else
	DOT_FILES="$GITHUB_WORKSPACE"
fi

echo "Dot files folder: $DOT_FILES"

cd $DOT_FILES

ln -s $DOT_FILES/tmux/tmux.conf $HOME/.tmux.conf
ln -s $DOT_FILES/tmux/tmux.conf.local $HOME/.tmux.conf.local

rm -rf $HOME/.config/nvim
ln -s $DOT_FILES/nvim $HOME/.config
ln -sf $DOT_FILES/shell/bash_profile.sh $HOME/.bash_profile

ln -sf $DOT_FILES/nvim/init.vim $HOME/.vimrc

ln -sf $DOT_FILES/git/gitconfig $HOME/.gitconfig
ln -sf $DOT_FILES/git/gitignore $HOME/.gitignore

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
#nvim +PlugInstall +GoInstallBinaries +qa

if [ "$(uname)" == "Darwin" ]; then
	echo "Configuring MacOS"
	# Close any open System Preferences panes, to prevent them from overriding
	# settings we’re about to change
	osascript -e 'tell application "System Preferences" to quit'

	# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
	while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

	###############################################################################
	# General UI/UX                                                               #
	###############################################################################

	# Disable the sound effects on boot
	sudo nvram SystemAudioVolume=" "

	# Disable transparency in the menu bar and elsewhere on Yosemite
	defaults write com.apple.universalaccess reduceTransparency -bool true
	# Save to disk (not to iCloud) by default
	defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

	# Automatically quit printer app once the print jobs complete
	defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

	# Disable the “Are you sure you want to open this application?” dialog
	defaults write com.apple.LaunchServices LSQuarantine -bool false

	# Remove duplicates in the “Open With” menu (also see `lscleanup` alias)
	/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

	# Disable Resume system-wide
	defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

	# Disable automatic termination of inactive apps
	defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true
	# Disable smart dashes as they’re annoying when typing code
	defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

	# Disable automatic period substitution as it’s annoying when typing code
	defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

	# Disable smart quotes as they’re annoying when typing code
	defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

	# Disable auto-correct
	defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

	# Set language and text formats
	# Note: if you’re in the US, replace `EUR` with `USD`, `Centimeters` with
	# `Inches`, `en_GB` with `en_US`, and `true` with `false`.
	defaults write NSGlobalDomain AppleLanguages -array "en"
	defaults write NSGlobalDomain AppleLocale -string "en_US@currency=USD"
	defaults write NSGlobalDomain AppleMeasurementUnits -string "Inches"
	defaults write NSGlobalDomain AppleMetricUnits -bool false

	# Require password immediately after sleep or screen saver begins
	defaults write com.apple.screensaver askForPassword -int 1
	defaults write com.apple.screensaver askForPasswordDelay -int 0

	###############################################################################
	# Finder                                                                      #
	###############################################################################

	# Finder: disable window animations and Get Info animations
	defaults write com.apple.finder DisableAllAnimations -bool true

	# Finder: show all filename extensions
	defaults write NSGlobalDomain AppleShowAllExtensions -bool true

	# Finder: show status bar
	defaults write com.apple.finder ShowStatusBar -bool true

	# Finder: show path bar
	defaults write com.apple.finder ShowPathbar -bool true

	# Display full POSIX path as Finder window title
	defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

	# Keep folders on top when sorting by name
	defaults write com.apple.finder _FXSortFoldersFirst -bool true

	# When performing a search, search the current folder by default
	defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

	# Disable the warning when changing a file extension
	defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

	# Enable spring loading for directories
	defaults write NSGlobalDomain com.apple.springing.enabled -bool true

	# Remove the spring loading delay for directories
	defaults write NSGlobalDomain com.apple.springing.delay -float 0

	# Avoid creating .DS_Store files on network or USB volumes
	defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
	defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

	# Use list view in all Finder windows by default
	# Four-letter codes for the other view modes: `icnv`, `clmv`, `glyv`
	defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

	# Expand the following File Info panes:
	# “General”, “Open with”, and “Sharing & Permissions”
	defaults write com.apple.finder FXInfoPanesExpanded -dict \
		General -bool true \
		OpenWith -bool true \
		Privileges -bool true

	# Increase Key Repeat
	defaults write -g InitialKeyRepeat -int 10 # normal minimum is 15 (225 ms)
	defaults write -g KeyRepeat -int 1 # normal minimum is 2 (30 ms)

	# Hide Dock
	defaults write com.apple.Dock autohide -bool TRUE
	defaults delete com.apple.dock persistent-apps
	defaults delete com.apple.dock persistent-others
	defaults write com.apple.dock tilesize -int 48

	# Don’t animate opening applications from the Dock
	defaults write com.apple.dock launchanim -bool false

	# Don’t group windows by application in Mission Control
	# (i.e. use the old Exposé behavior instead)
	defaults write com.apple.dock expose-group-by-app -bool false

	# Disable Dashboard
	defaults write com.apple.dashboard mcx-disabled -bool true

	# Don’t show Dashboard as a Space
	defaults write com.apple.dock dashboard-in-overlay -bool true

	# Don’t automatically rearrange Spaces based on most recent use
	defaults write com.apple.dock mru-spaces -bool false

	# Remove the auto-hiding Dock delay
	defaults write com.apple.dock autohide-delay -float 0

	# Automatically hide and show the Dock
	defaults write com.apple.dock autohide -bool true

	# Make Dock icons of hidden applications translucent
	defaults write com.apple.dock showhidden -bool true

	# Don’t show recent applications in Dock
	defaults write com.apple.dock show-recents -bool false

	killall Dock

	# Show Battery Percentage
	defaults write com.apple.menuextra.battery ShowPercent YES

	# Show Bluetooth and Clock
	defaults write com.apple.systemuiserver menuExtras -array \
		"/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
		"/System/Library/CoreServices/Menu Extras/Clock.menu"

	defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
	defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
	defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
	defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
	defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

	defaults write com.googlecode.iterm2 PromptOnQuit -bool false

	###############################################################################
	# Mac App Store                                                               #
	###############################################################################

	# Enable the automatic update check
	defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

	# Download newly available updates in background
	defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

	# Install System data files & security updates
	defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

	# Turn on app auto-update
	defaults write com.apple.commerce AutoUpdate -bool true

	# Allow the App Store to reboot machine on macOS updates
	defaults write com.apple.commerce AutoUpdateRestartRequired -bool true

	###############################################################################
	# Photos                                                                      #
	###############################################################################

	# Prevent Photos from opening automatically when devices are plugged in
	defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

	cp fonts/Fira-Code-Retina-Nerd-Font-Complete.ttf "$HOME/Library/Fonts"

	killall SystemUIServer
elif [ "$(uname)" == "Linux" ]; then
	echo "Configuring Linux"
fi
