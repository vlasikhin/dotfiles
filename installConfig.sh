#!/bin/sh
#
# for the run use this file on the home directory: ./installConfig.sh
# 
# Brew packages that I use 
#
brew install ruby
brew install python
brew install python3
brew install neovim/neovim/neovim
brew install imagemagick
brew install git

#
# Some cask packages 
#
brew tap caskroom/fonts
brew cask install font-fira-code
brew cask install google-chrome
brew cask install google-drive
brew cask install iterm2
brew cask install slack
brew cask install telegram
brew cask install virtualbox
brew cask install vagrant
brew cask install simplenote
brew cask install rubymine
brew cask install adobe-reader
brew cask install appcleaner
brew cask install easyfind
brew cask install vlc
brew cask install aerial

#
# Some gems
#
gem install bundler
gem install homesick
gem install neovim
pip install neovim
pip3 install neovim

#
# Settings
#
# open apps from unidentified developers
sudo spctl --master-disable

printf ".DS_Store\nThumbs.db\n" >> ~/.gitignore
git config --global core.excludesfile ~/.gitignore
git config --global core.autocrlf input
git config --global core.safecrlf true
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.hist log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short

defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
killall Dock
