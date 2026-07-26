# spotify-player

TUI Spotify client with built-in playback and MPRIS (waybar/eww music widgets pick it up via playerctl). Requires Spotify Premium.

## Required packages

- `spotify-player`

Install on Arch:
```bash
sudo pacman -S spotify-player
```

## Notes

- First run walks through OAuth in the terminal; credentials cache under `~/.cache/spotify-player`.
- The configured `glass` theme is matugen-generated: `matugen/templates/spotify-player-theme.toml` → `~/.config/spotify-player/theme.toml`, re-tinted on every wallpaper change.
