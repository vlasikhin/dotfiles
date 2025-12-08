# One Light Sublime Text 4


## Install

### Option 1: Manual installation

1. Open Sublime Text
2. Go to **Settings → Browse Packages...**
3. Create a folder named `One Light`
4. Copy the files:
   - `One Light.sublime-color-scheme`
   - `One Light.sublime-theme`

## Activation

### Color scheme only (syntax highlighting)

**Preferences → Color Scheme** → select **One Light**

Or add to your settings (`Preferences.sublime-settings`):
```json
{
    "color_scheme": "Packages/One Light/One Light.sublime-color-scheme"
}
```

### Full theme (UI + syntax)

**Preferences → Theme** → select **One Light**

Or add to your settings:
```json
{
    "theme": "One Light.sublime-theme",
    "color_scheme": "Packages/One Light/One Light.sublime-color-scheme"
}
```

## Recommended settings

For best appearance:
```json
{
    "theme": "One Light.sublime-theme",
    "color_scheme": "Packages/One Light/One Light.sublime-color-scheme",
    "font_face": "Fira Code",
    "font_size": 14,
    "line_padding_top": 2,
    "line_padding_bottom": 2,
    "caret_style": "smooth",
    "highlight_line": true,
    "draw_white_space": ["selection"],
    "indent_guide_options": ["draw_normal", "draw_active"]
}
```
