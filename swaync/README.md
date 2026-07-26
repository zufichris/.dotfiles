# SwayNC

Sway Notification Center: navy-glass control center with quick-action buttons, volume/backlight sliders, and an MPRIS player card.

## Required packages

- `swaync`
- `hyprpicker` (color picker button)
- `galculator` (calculator button)
- `grim` + `slurp` and `wl-screenrec` — used by the `hypr/scripts/` screenshot/record scripts the buttons call

Install on Arch:
```bash
sudo pacman -S swaync hyprpicker galculator grim slurp
```

## Usage

Toggle with `SUPER + N` (`swaync-client -t`, bound in `hypr/hyprland/programs.lua`), the bell icon in Waybar, or the bell button on the eww dashboard.

## Buttons grid

Four actions, each closing the panel first: region screenshot (`~/.config/hypr/scripts/screenshot.sh region`), screen-record toggle (`~/.config/hypr/scripts/record.sh`), color picker (`hyprpicker -a`), and calculator (`galculator`).

## Backlight

The brightness slider writes the sysfs backlight file directly, so your user needs write access. `90-backlight.rules` is a udev rule that grants the `video` group write access to `/sys/class/backlight/*/brightness`; `install.sh` installs it to `/etc/udev/rules.d/` and adds you to `video` (skip with `--no-backlight`, re-login required).

The device is set to `intel_backlight` in `config.json` — adjust to match `ls /sys/class/backlight`.

## Styling

`style.css` only holds the shell (panel, scrollbar, groups) and imports `tokens/*.css`: `variables.css` (matugen-generated palette as CSS custom properties — edit `matugen/templates/swaync-colors.css`, not the snapshot), plus hand-written `title-dnd`, `button-grid`, `slider`, `mpris`, and `notification` sheets.
