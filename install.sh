#!/usr/bin/env bash

# Inspiration taken from these notes and scripts:
# - https://gist.github.com/llimllib/c4dd0a98a426022b0365d4c0a9090460
# - https://github.com/sanderginn/dotfiles/blob/main/executable_dot_macos_config
# - https://wilsonmar.github.io/dotfiles/
# - https://discussions.apple.com/thread/250016855
# - https://superuser.com/questions/342437/how-to-restore-chrome-without-restore-button-and-the-files-last-session-and
# - https://www.macworld.com/article/1144069/macos-ventura-system-settings-appearance-storage-extensions.html
# - https://github.com/geerlingguy/mac-dev-playbook/issues/22
# - https://apple.stackexchange.com/questions/59178/toggle-use-all-f1-f2-as-standard-keys-via-script
# - https://github.com/mathiasbynens/dotfiles/issues/288

if [ $# -ne 1 ]; then
    echo "Usage: $0 <personal|work>" 1>&2
    exit 1
fi
target="$1"

if [[ $OSTYPE != "darwin"* ]]; then
    echo "Aborting execution of macOS specific configuration."
    exit 1
fi


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

# FWIW: -g, -globalDomain, and NSGlobalDomain are all the same.

# Use dark mode
defaults write -g AppleInterfaceStyle Dark

# Disable auto-correct
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false

# Enable full keyboard access for all controls (e.g. enable tab in modal dialogs)
defaults write -g AppleKeyboardUIMode -int 3
# Activating the change is a different story.
# https://apple.stackexchange.com/questions/59178/toggle-use-all-f1-f2-as-standard-keys-via-script

# Disable smart quotes as they're annoying when typing code
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable smart dashes as they're annoying when typing code
defaults write -g NSAutomaticDashSubstitutionEnabled -bool false

# Require fn key to use special functionality of the F-keys. What needs to be killed
defaults write -g com.apple.keyboard.fnState 1

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
    echo "Sudo for chflags on /Volumes"
    sudo chflags nohidden /Volumes
fi

# Restart systemUIServer to enable defaults to take effect
killall SystemUIServer

# Reveal IP address, hostname, OS version, etc. when clicking the clock
# in the login window
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 5

# Save screenshots to the desktop
defaults write com.apple.screencapture location -string "${HOME}/Desktop"

# Save screenshots in lossless (bigger) PNG format
# rather than defaul JPG (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# Before editing:
killall Finder /System/Library/CoreServices/Finder.app

# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Privacy: don't send search queries to Apple
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

# Show the full URL in the address bar (note: this still hides the scheme)
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# Safari opens with: last session
defaults write com.apple.Safari AlwaysRestoreSessionAtLaunch -bool true

# Set Safari's home page to `about:blank` for faster loading
defaults write com.apple.Safari HomePage -string "about:blank"

# nvAlt:
defaults write net.elasticthreads.nv AlternatingRows -int 1
defaults write net.elasticthreads.nv AppActivationKeyCode -int 49
defaults write net.elasticthreads.nv AppActivationModifiers -int 4352
defaults write net.elasticthreads.nv TableSortColumn "Date Modified"

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

echo "Reindexing Spotlight data"

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
    echo "Installing Homebrew ..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# make sure you sign in to the app store before you get here, mas cannot work without being signed in I guess
if ! command -v mas > /dev/null; then
    brew install mas
fi

# Change to bash, even if that is an old bash.
chsh -s /bin/bash

# Go to town, install all these taps, brews, and casks:
brew bundle install --verbose --no-upgrade --file $(dirname $0)/Brewfile.all

if [ "x$target" = 'xpersonal' ]; then
    brew bundle install --verbose --no-upgrade --file $(dirname $0)/Brewfile.personal
elif [ "x$target" = 'xwork' ]; then
    brew bundle install --verbose --no-upgrade --file $(dirname $0)/Brewfile.work
fi

# For "git-lfs"
git lfs install

if ! command -v puppet-lint > /dev/null; then
    echo "Sudo to install puppet-lint"
    sudo gem install puppet-lint -v 3.4.0
fi

if ! command -v luacov > /dev/null; then
    luarocks install luacov
    luarocks install lpeg
    luarocks install luajson
fi

# Open and close iTerm so that the basic plist file has been created:
open /Applications/iTerm.app
sleep 10
osascript -e 'tell application "iTerm" to quit'

# Will this work before iTerm has potentially even been executed yet?
defaults write com.googlecode.iterm2 AlternateMouseScroll -int 0
defaults write com.googlecode.iterm2 DimBackgroundWindows -int 1
defaults write com.googlecode.iterm2 FlashTabBarInFullscreen -int 1
defaults write com.googlecode.iterm2 HapticFeedbackForEsc -int 0
defaults write com.googlecode.iterm2 HideTab -int 0
defaults write com.googlecode.iterm2 HideTabNumber -int 0
defaults write com.googlecode.iterm2 IRMemory -int 4
defaults write com.googlecode.iterm2 NoSyncPermissionToShowTip -bool false
defaults write com.googlecode.iterm2 UseBorder -bool true
defaults write com.googlecode.iterm2 ShowFullScreenTabBar -bool false
defaults write com.googlecode.iterm2 SoundForEsc -bool false
defaults write com.googlecode.iterm2 SplitPaneDimmingAmount -float 0.1490996
defaults write com.googlecode.iterm2 TabStyleWithAutomaticOption -int 4

# This changes ALL profiles to use the JetBrains font, which is a bit overkill, but whatever.
./terminal.sh

# Forcing the default profile's foreground color, font, and transparency
plist="$HOME/Library/Preferences/com.googlecode.iterm2.plist"
/usr/libexec/PlistBuddy -c 'add ":New Bookmarks:0:ASCII Ligatures" bool false' $plist
/usr/libexec/PlistBuddy -c 'set ":New Bookmarks:0:ASCII Ligatures" false' $plist

/usr/libexec/PlistBuddy -c 'add ":New Bookmarks:0:Foreground Color:Alpha Component" real 1.0' $plist
/usr/libexec/PlistBuddy -c 'set ":New Bookmarks:0:Foreground Color:Alpha Component" 1.0' $plist

/usr/libexec/PlistBuddy -c 'set ":New Bookmarks:0:Foreground Color:Blue Component" 0' $plist
/usr/libexec/PlistBuddy -c 'set ":New Bookmarks:0:Foreground Color:Green Component" 0.69' $plist
/usr/libexec/PlistBuddy -c 'set ":New Bookmarks:0:Foreground Color:Red Component" 1.0' $plist

/usr/libexec/PlistBuddy -c 'add ":New Bookmarks:0:Foreground Color:Color Space" string sRGB' $plist
/usr/libexec/PlistBuddy -c 'set ":New Bookmarks:0:Foreground Color:Color Space" sRGB' $plist

/usr/libexec/PlistBuddy -c 'set ":New Bookmarks:0:Normal Font" JetBrainsMonoNL-Regular 14' $plist

/usr/libexec/PlistBuddy -c 'set ":New Bookmarks:0:Transparency" 0.02305678934010152' $plist


# On work computer:
# sudo pmset repeat sleep MTWRF 19:00:00
#
# Enable remote SSH
sudo systemsetup -setremotelogin on

# Set timezone
sudo systemsetup -settimezone America/Los_Angeles
