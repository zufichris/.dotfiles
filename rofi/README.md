# Rofi

App launcher, wallpaper picker, clipboard history, power menu, and keybinds cheatsheet.

## Required packages

- `rofi-wayland` (Wayland build of Rofi)
- `cliphist` + `wl-copy` (clipboard history)
- `papirus-icon-theme` (app icons)

Install on Arch:
```bash
sudo pacman -S rofi-wayland cliphist wl-clipboard papirus-icon-theme
```

## Keybinds

| Keybind | Action | Script |
| --- | --- | --- |
| `SUPER + A` | App launcher | `hypr/scripts/launcher.sh` |
| `SUPER + W` | Wallpaper picker | `hypr/scripts/wallpaper-picker.sh` |
| `SUPER + SHIFT + P` | Power menu | `hypr/scripts/power-menu.sh` |
| `SUPER + SHIFT + H` | Keybinds cheatsheet | `hypr/scripts/keybinds-help.sh` |
| `SUPER + SHIFT + V` | Clipboard history | inline `cliphist \| rofi` bind |

## Files

- `launcher.rasi` — standalone app launcher: wallpaper panel on the left (thumbnail from `~/.cache/current_wallpaper`), results on the right.
- `wallpaper.rasi` — wallpaper picker grid with square thumbnails.
- `powermenu.rasi` — power menu list (lock/logout/hibernate/sleep/restart/poweroff).
- `keybinds.rasi` — searchable keybinds cheatsheet list.
- `clipboard.rasi` — clipboard history list.
- `config.rasi` — shared base theme the list-style menus above import.
- `colors.rasi` — matugen-generated color tokens; the repo copy is a snapshot, matugen overwrites the deployed copy on every wallpaper change.
