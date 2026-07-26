# Fastfetch

System info fetcher whose logo is the current wallpaper.

## Required packages

- `fastfetch`

Install on Arch:
```bash
sudo pacman -S fastfetch
```

## Wallpaper logo

The logo source is `~/.cache/current_wallpaper` — a PNG copy of the active wallpaper kept in sync by `hypr/scripts/current-wallpaper.sh` (runs on wallpaper changes via the wallpaper watcher). It is drawn with the Kitty image protocol, so the logo always matches the current theme.

Fallbacks:

- If the terminal does not support the Kitty image protocol, fastfetch falls back to the ASCII Arch logo.
- If `~/.cache/current_wallpaper` does not exist yet, change the wallpaper once (or run `~/.config/hypr/scripts/current-wallpaper.sh`) to create it. A static `logo.png` also ships in this directory if you prefer a fixed logo — point `logo.source` at it.
