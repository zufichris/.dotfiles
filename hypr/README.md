# Hyprland

Window manager configuration, written in Hyprland's native Lua config format.

## Required packages

- `hyprland` (Lua config support)
- `wpaperd` (wallpaper daemon), `mpvpaper` (video wallpapers, optional)
- `mpv` (floating gif overlays)
- `hypridle` + `hyprlock` (idle ladder, lock screen)
- `hyprsunset` (night light; autostart skips it when missing)
- `hyprpolkitagent` (polkit agent)
- `kitty` (terminal)
- `waybar` (status bar)
- `rofi` (launcher, power menu, clipboard, wallpaper picker, keybinds help)
- `swaync` (notifications), `eww` (dashboard)
- `cliphist` + `wl-clipboard` (clipboard history)
- `brave` (browser), `thunar` (file manager)
- `grim` + `slurp` + `satty` (screenshots; `swappy` works as fallback)
- `wl-screenrec` (screen recording)
- `brightnessctl` (backlight), `wireplumber`/`pipewire` (volume), `playerctl` (media keys)
- `matugen` + `imagemagick` + `python` + `ffmpeg` + `jq` (theming pipeline)
- `lua` (keybinds cheatsheet generator)
- `libnotify` (script notifications), `udiskie` (automount, optional)

Install on Arch:
```bash
sudo pacman -S hyprland wpaperd mpv mpvpaper hypridle hyprlock hyprsunset hyprpolkitagent kitty waybar rofi-wayland swaync cliphist wl-clipboard thunar grim slurp satty brightnessctl wireplumber pipewire playerctl imagemagick python ffmpeg jq lua libnotify udiskie
```
From the AUR: `eww`, `matugen-bin`, `wl-screenrec`, `brave-bin`, `bibata-cursor-theme`.

## Layout

`hyprland.lua` is the entry point; it requires the modules in `hyprland/`:

- `programs.lua` — one table of programs (command + optional `autostart`/`keybind`)
- `autostart.lua` — launches everything in `programs.lua` marked `autostart`
- `keybinds.lua` — all binds; program binds are generated from `programs.lua`
- `env.lua` — cursor theme, GTK/Qt theming, `EDITOR`/`TERMINAL`
- `appearance.lua` — gaps, borders, blur, shadow; colors come from `theme.lua`
- `theme.lua` — matugen-generated palette snapshot (do not edit by hand)
- `animations.lua` — curves, animation tree, layout options
- `rules.lua` — window rules and blur layer rules for the shell surfaces
- `monitors.lua`, `input.lua`, `misc.lua`, `permissions.lua` — the rest

`hypridle.conf` dims, locks, blanks, then suspends; `hyprlock.conf` sources the
matugen-generated `hyprlock-colors.conf`; `hyprsunset.conf` schedules night light.

## Scripts

- `set-wallpaper.sh` — set image (wpaperd) or video (mpvpaper) wallpaper, then retheme
- `apply-theme.sh` — matugen palette from an image + retints, reloads apps, themed avatar
- `wallpaper-picker.sh` — rofi thumbnail grid over `~/Pictures/wallpapers` (images + videos)
- `wallpaper-restore.sh` — replays the last wallpaper at login
- `wallpaper-watcher.sh` — retheme when wpaperd rotates wallpapers on its own
- `current-wallpaper.sh` — keeps `~/.cache/current_wallpaper` in sync (used by hyprlock/rofi)
- `lock.sh` — refresh wallpaper cache and avatar, run hyprlock
- `lock-nowplaying.sh` — now-playing glass card and labels for the lock screen
- `launcher.sh` — rofi app launcher
- `power-menu.sh` — rofi power menu (lock/logout/hibernate/sleep/restart/poweroff)
- `screenshot.sh` — grim/slurp capture piped into satty (or swappy)
- `record.sh` — toggle wl-screenrec screen recording
- `keybinds-help.sh` + `keybinds-help.lua` — cheatsheet generated from `keybinds.lua`
- `gif-overlay.sh` — floating pinned gif overlays (mpv); rofi picker with previews,
  auto chroma-key background removal, max-overlays cap in `~/.config/hypr/gif-overlay.conf`

## Keybinds

Highlights only — `SUPER + SHIFT + H` opens a searchable cheatsheet of every bind.

| Keys | Action |
| --- | --- |
| `SUPER + Return` | Terminal (kitty) |
| `SUPER + A` | App launcher |
| `SUPER + B` / `SUPER + E` | Browser / file manager |
| `SUPER + Q` | Close window |
| `SUPER + V` | Toggle floating |
| `SUPER + arrows` or `H J K L` | Move focus |
| `SUPER + 1..0` (`+ SHIFT` to move) | Workspaces |
| `SUPER + S` | Scratchpad |
| `SUPER + D` | Dashboard (eww) |
| `SUPER + N` | Notification center |
| `SUPER + W` | Wallpaper picker |
| `SUPER + G` | Gif overlay picker |
| `SUPER + SHIFT + S` or `Print` | Region screenshot (`SUPER + Print` full) |
| `SUPER + SHIFT + V` | Clipboard history |
| `SUPER + SHIFT + P` | Power menu |
| `SUPER + M` | Exit Hyprland |
| `F9` | Toggle waybar |
