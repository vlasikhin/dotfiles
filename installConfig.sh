#!/bin/sh
#
# for the run use this file on the home directory: ./installConfig.sh
#
# Brew packages that I use
#
brew install imagemagick git postgres redis gnupg gnupg2 libmaxminddb wget vips
# run: brew services list
brew tap homebrew/services

# Some cask packages
brew tap caskroom/fonts
brew cask install font-fira-code
brew cask install chromedriver
brew cask install phantomjs

#
# Settings
#
# open apps from unidentified developers
sudo spctl --master-disable

# эту команду использовать при подключенном к сети ноуте
# отключает долгий выход из сна
# проверить статус: sudo pmset -g
sudo pmset -c autopoweroff 0

printf ".DS_Store\nThumbs.db\n.idea\/" >> ~/.gitignore
git config --global core.excludesfile ~/.gitignore
git config --global core.autocrlf input
git config --global core.safecrlf true
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit -m
git config --global alias.st status
git config --global user.name "Pavel Vlasikhin"
git config --global user.email vlasikhin@me.com

defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
killall Dock