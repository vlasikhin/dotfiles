#!/bin/sh
set -e
#
# for the run use this file on the home directory: ./installConfig.sh


# Brew packages that I use
brew install postgresql redis eza

# Some cask packages
brew install --cask font-fira-code \
raycast \
appcleaner \
orbstack \
outline-manager \
slack \
sublime-merge \
sublime-text \
transmission \
vlc \
claude


# Settings
# open apps from unidentified developers
sudo spctl --master-disable

# эту команду использовать при подключенном к сети ноуте
# отключает долгий выход из сна
# проверить статус: sudo pmset -g
sudo pmset -c autopoweroff 0

defaults write -g CGFontRenderingFontSmoothingDisabled -bool NO
grep -qF 'Sublime Text.app/Contents/SharedSupport/bin' ~/.zprofile 2>/dev/null || echo 'export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"' >> ~/.zprofile

touch ~/.gitignore
for pattern in .DS_Store Thumbs.db .idea; do
    grep -qF "$pattern" ~/.gitignore || echo "$pattern" >> ~/.gitignore
done
git config --global core.excludesfile ~/.gitignore
git config --global core.autocrlf input
git config --global core.safecrlf true
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit -m
git config --global alias.st status
git config --global user.name "Pavel Vlasikhin"
git config --global user.email pavel@vlasikhin.com

defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
killall Dock
