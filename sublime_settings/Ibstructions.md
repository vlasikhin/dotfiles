### Snippets path

```
~/Library/Application Support/Sublime Text/Packages/User/
```

### Installed Pacages

* Package Control
* FileIcons
* rubyfmt

settings -> key bindings:

```json
[
  { "keys": ["super+`"], "command": "goto_definition" },
  { "keys": ["super+="], "command": "reveal_in_side_bar"}
]
```

Sublime Text -> Preferences -> Package Settings -> Rubyfmt -> Settings - User

```ruby
{
  "ruby_executable": "ruby",
  "rubyfmt_executable": "rubyfmt",
  "format_on_save": false,
}
```
