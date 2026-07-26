# Matugen

Dynamic color generation from the current wallpaper (Material You palette, `scheme-fidelity`).

## Required packages

- `matugen`
- `imagemagick` + `python` (accent/surface extraction in `hypr/scripts/apply-theme.sh`)

Install on Arch:
```bash
sudo pacman -S matugen imagemagick python
```

## Templates

| Template | Output | Post-hook |
| --- | --- | --- |
| `waybar-colors.css` | `~/.config/waybar/tokens/colors.css` | `pkill -SIGUSR2 waybar` |
| `hyprland-theme.lua` | `~/.config/hypr/hyprland/theme.lua` | `hyprctl reload` |
| `rofi-colors.rasi` | `~/.config/rofi/colors.rasi` | — |
| `hyprlock-colors.conf` | `~/.config/hypr/hyprlock-colors.conf` | — |
| `sddm-colors.conf` | `~/.config/sddm/theme-colors.conf` | — |
| `gtk-colors.css` | `~/.config/gtk-3.0/gtk.css` | — |
| `gtk-colors.css` | `~/.config/gtk-4.0/gtk.css` | — |
| `eww-colors.scss` | `~/.config/eww/_colors.scss` | `eww reload` |
| `kitty-colors.conf` | `~/.config/kitty/kitty-theme.conf` | `pkill -SIGUSR1 -x kitty` |
| `wlogout-colors.css` | `~/.config/wlogout/colors.css` | — |
| `qt-palette.conf` | `~/.config/qt6ct/colors/matugen.conf` | — |
| `qt-palette.conf` | `~/.config/qt5ct/colors/matugen.conf` | — |
| `satty-overrides.css` | `~/.config/satty/overrides.css` | — |
| `spotify-player-theme.toml` | `~/.config/spotify-player/theme.toml` | — |
| `swaync-colors.css` | `~/.config/swaync/tokens/variables.css` | `swaync-client -rs` |

## Triggers

All paths funnel through `hypr/scripts/set-wallpaper.sh` → `apply-theme.sh`, which runs matugen with wallpaper-extracted accent/surface overrides:

- Rofi wallpaper picker (`SUPER + W`)
- zsh `wallpaper` function (`zsh/wallpaper.zsh`)
- `hypr/scripts/wallpaper-watcher.sh` — catches wpaperd auto-rotations (and Thunar's "Set as wallpaper" via `wpaperctl`)

Manual run: `matugen image /path/to/wallpaper`. Generated files (e.g. `rofi/colors.rasi`, `kitty/kitty-theme.conf`) are snapshots — never edit them by hand.
