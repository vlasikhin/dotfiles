#!/bin/bash
set -e
mkdir -p ~/.claude/
cp settings.json ~/.claude/settings.json
install -m 755 statusline.sh ~/.claude/statusline.sh
