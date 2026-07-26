# Kitty

Glass-styled terminal: translucent background (0.6 opacity) over compositor blur, cursor trail, zsh as shell.

## Required packages

- `kitty`
- `ttf-jetbrains-mono-nerd` (JetBrainsMono Nerd Font, the configured `font_family`)

Install on Arch:
```bash
sudo pacman -S kitty ttf-jetbrains-mono-nerd
```

## Files

- `kitty.conf` — main config: font, cursor trail, padding, opacity; includes the theme file.
- `kitty-theme.conf` — matugen-generated colors (`matugen/templates/kitty-colors.conf`). The repo copy is a snapshot; every wallpaper change rewrites the deployed copy and live-reloads kitty via `SIGUSR1`.

## Notes

- The ANSI palette doubles as the zsh `glass` prompt palette, so the prompt re-tints with the wallpaper.
- Do not hand-edit `kitty-theme.conf`; change `matugen/templates/kitty-colors.conf` instead.
