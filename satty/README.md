# Satty

Screenshot annotator, used by `hypr/scripts/screenshot.sh` (grim + slurp pipe into it).

## Required packages

- `satty` + `grim` + `slurp`

Install on Arch:
```bash
sudo pacman -S satty grim slurp
```

## Notes

- Enter saves to `~/Pictures/screenshots`, Ctrl+C copies to clipboard, Esc discards.
- Matugen-themed: `matugen/templates/satty-overrides.css` writes libadwaita color overrides to `~/.config/satty/overrides.css` on every wallpaper change.
