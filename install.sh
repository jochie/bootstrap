#!/usr/bin/env bash

# Inspiration taken from these notes and scripts:
# - https://gist.github.com/llimllib/c4dd0a98a426022b0365d4c0a9090460
# - https://github.com/sanderginn/dotfiles/blob/main/executable_dot_macos_config
# - https://wilsonmar.github.io/dotfiles/

fancy_echo() {
  local fmt="$1"; shift

  # shellcheck disable=SC2059
  printf "\n$fmt\n" "$@"
}

# Things I don't know (yet) how to automate, or handle separately:
# - Set up Touch ID
# - Configure Chrome to restore the tabs at startup
# - Configure Dropbox (for 1Password6)
# - Ditto for Firefox
# - Configure account in 1Password6
# - Configure account for App Store
# - Configure Thunderbird
# - Configure Calendar.app
# - Configure Slack
# - Configure NetNewsWire
# - Emacs configuration

# handle failures
trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Hot corners

# Hot corners
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center

# Top left screen corner → Start screen saver
defaults write com.apple.dock wvous-tl-corner -int 5
defaults write com.apple.dock wvous-tl-modifier -int 0

# Top right screen corner → Disable screen saver
defaults write com.apple.dock wvous-tr-corner -int 6
defaults write com.apple.dock wvous-tr-modifier -int 0

# Bottom left screen corner → Start screen saver
defaults write com.apple.dock wvous-bl-corner -int 5
defaults write com.apple.dock wvous-bl-modifier -int 0

# Bottom right screen corner → Disable screen saver
defaults write com.apple.dock wvous-br-corner -int 6
defaults write com.apple.dock wvous-br-modifier -int 0

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Wipe all (default) app icons from the Dock
defaults write com.apple.dock persistent-apps -array

# Let settinsg take effecct
killall Dock

# Use dark mode
defaults write NSGlobalDomain AppleInterfaceStyle Dark

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Enable full keyboard access for all controls (e.g. enable tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# show battery percentage
defaults write com.apple.menuextra.battery ShowPercent -bool true
# Doesn't work anymore?

# show the date in the toolbar
defaults write com.apple.menuextra.clock ShowDate -int 1
# defaults write com.apple.menuextra.clock ShowDayOfMonth -bool true

# Show 24h time
defaults write com.apple.menuextra.clock Show24Hour -bool true

# Show volume in the menu bar
defaults -currentHost write com.apple.controlcenter.plist Sound -int 18

# Show Bluetooth in the menu bar
defaults -currentHost write com.apple.controlcenter.plist Bluetooth -int 18
 
# Zoom with trackpad and modifier key
defaults write com.apple.universalaccess.plist closeViewScrollWheelToggle -bool true
defaults write com.apple.AppleMultitouchTrackpad HIDScrollZoomModifierMask -int 262144
# does that work?

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# don't hide files
defaults write com.apple.finder AppleShowAllFiles TRUE

# Show the ~/Library folder
chflags nohidden ~/Library

# Show the /Volumes folder
# Avoid sudo if unnecessary
ls -Old /Volumes | grep -qw hidden
if [ $? -eq 0 ]; then
    fancy_echo "Sudo for chflags on /Volumes"
    sudo chflags nohidden /Volumes
fi

# Restart systemUIServer to enable defaults to take effect
killall SystemUIServer

# This seems to have to be Spotlight, in order to work
defaults write com.apple.Spotlight orderedItems -array \
   '{"enabled" = 1;"name" = "APPLICATIONS";}' \
   '{"enabled" = 1;"name" = "SYSTEM_PREFS";}' \
   '{"enabled" = 1;"name" = "DIRECTORIES";}' \
   '{"enabled" = 1;"name" = "PDF";}' \
   '{"enabled" = 1;"name" = "FONTS";}' \
   '{"enabled" = 1;"name" = "DOCUMENTS";}' \
   '{"enabled" = 1;"name" = "MESSAGES";}' \
   '{"enabled" = 1;"name" = "CONTACT";}' \
   '{"enabled" = 1;"name" = "EVENT_TODO";}' \
   '{"enabled" = 1;"name" = "IMAGES";}' \
   '{"enabled" = 1;"name" = "BOOKMARKS";}' \
   '{"enabled" = 1;"name" = "MUSIC";}' \
   '{"enabled" = 1;"name" = "MOVIES";}' \
   '{"enabled" = 1;"name" = "PRESENTATIONS";}' \
   '{"enabled" = 1;"name" = "SPREADSHEETS";}' \
   '{"enabled" = 1;"name" = "SOURCE";}' \
   '{"enabled" = 1;"name" = "MENU_DEFINITION";}' \
   '{"enabled" = 1;"name" = "MENU_OTHER";}' \
   '{"enabled" = 1;"name" = "MENU_CONVERSION";}' \
   '{"enabled" = 1;"name" = "MENU_EXPRESSION";}' \
   '{"enabled" = 0;"name" = "MENU_WEBSEARCH";}' \
   '{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}'

defaults write com.apple.Spotlight showedFTE -int 1
defaults write com.apple.Spotlight showedLearnMore -int 1

# Load new settings before rebuilding the index
killall mds > /dev/null 2>&1

fancy_echo "Reindexing Spotlight data"

# Make sure indexing is enabled for the main volume
sudo mdutil -i on / > /dev/null 2>&1

# Rebuild the index from scratch
sudo mdutil -E / > /dev/null 2>&1

# add brew to path
export PATH=/opt/homebrew/bin:$PATH

if [ ! -f $HOME/.bashrc ]; then
    (
	echo 'export BASH_SILENCE_DEPRECATION_WARNING=1'
	echo 'export HOMEBREW_NO_AUTO_UPDATE=1'
	echo 'export PATH=/opt/homebrew/bin:$PATH'
    ) > $HOME/.bashrc
fi

if [ ! -f $HOME/.bash_profile ]; then
    (
	echo '[ -e $HOME/.bashrc ] && source $HOME/.bashrc'
    ) > $HOME/.bash_profile
fi

if ! command -v brew > /dev/null; then
  fancy_echo "Installing Homebrew ..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# make sure you sign in to the app store before you get here, mas cannot work without being signed in I guess
if ! command -v mas > /dev/null; then
    brew install mas
fi

# Change to bash, even if that is an old bash.
chsh -s /bin/bash

brew install ansible
brew install awscli
brew install bash
brew install bash-completion
brew install coreutils
brew install csshx
brew install curl
brew install git
brew install git-lfs
brew install gnuplot
brew install jq
brew install lua lua@5.1 luarocks
brew install mpack
brew install mtr
brew install nmap
brew install parallel
brew install pyenv
brew install rsync
brew install screen
brew install stow
brew install telnet
brew install terraform
brew install tree
brew install watch
brew install yq

# For "git-lfs"
git lfs install

# These may have come pre-installed through something other than brew
if [ ! -d "/Applications/Google Chrome.app" ]; then
    brew install --cask chrome
fi
if [ ! -d "/Applications/zoom.us.app" ]; then
    brew install --cask zoom
fi
if [ ! -d "/Applications/Slack.app" ]; then
    brew install --cask slack
fi

brew install --cask firefox
brew install --cask iterm2
brew install --cask hammerspoon
brew install --cask docker
brew install --cask atom
brew install --cask emacs
brew install --cask dropbox
brew install --cask nvalt
brew install --cask thunderbird
brew install --cask netnewswire

# To get older versions of applications:
brew tap homebrew/cask-versions
brew install 1password6

if ! command -v puppet-lint > /dev/null; then
    fancy_echo "Sudo to install puppet-lint"
    sudo gem install puppet-lint -v 3.4.0
fi

if ! command -v luacov > /dev/null; then
    luarocks install luacov
fi
