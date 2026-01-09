
### vpa-light.sublime-color-theme

Light theme for Sublime Text editor

### Installation

1. Download the `vpa-light.sublime-color-theme` file, and copy in Sublime Text `Packages` folder:

```bash
cp vpa-light.sublime-color-theme ~/Library/Application\ Support/Sublime\ Text/Packages/
```

2. Select `Preferences → Color Scheme ...`

3. Pick `Auto`, then `vpa-light`


### Snippets path

```
~/Library/Application Support/Sublime Text/Packages/User/
```

### Installed Pacages

* Package Control
* FileIcons
* SideBarEnhancements


```bash
# https://github.com/titoBouzout/SideBarEnhancements/issues/446
touch ~/Library/Application\ Support/Sublime\ Text/Packages/Default/Side\ Bar.sublime-menu
```



settings -> key bindings:

```json
  [
    { "keys": ["ctrl+`"], "command": "goto_definition" },
    { "keys": ["super+="], "command": "reveal_in_side_bar"}
  ]
```
