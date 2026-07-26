# dotfiles

Arch Linux + Hyprland rice with wallpaper-driven theming: every wallpaper change re-themes the bar, launcher, terminal, notifications, lock screen, and login screen through [matugen](https://github.com/InioX/matugen).

## Install

```bash
./install.sh                # everything: configs + packages + SDDM theme + backlight udev rule
./install.sh --select       # pick which configs to install interactively
./install.sh --no-sddm      # skip the SDDM theme
./install.sh --no-backlight # skip the backlight udev rule
./install.sh --no-home      # skip home dotfiles (~/.zshrc, ~/.gitconfig, mimeapps.list)
```

Configs are **copied** into `~/.config` (not symlinked); existing files are backed up to `~/.config/dotfiles-backup-<timestamp>` first. After editing files in this repo, re-run `./install.sh` to deploy the changes.

## Theming pipeline

`wpaperd` rotates wallpapers; picking one (rofi picker, `wallpaper` zsh function) or an automatic rotation triggers `matugen`, which renders the templates in `matugen/templates/` into color tokens for each app. `hypr/scripts/current-wallpaper.sh` keeps `~/.cache/current_wallpaper` as a copy of the active image — it backs the hyprlock background and the rofi launcher side panel. The generated color files committed in this repo are static snapshots; matugen overwrites the deployed copies.

## Layout

| Directory | What it is |
| --- | --- |
| `hypr/` | Hyprland (native Lua config), hyprlock, hypridle, hyprsunset, and the scripts driving wallpapers/theming/screenshots |
| `waybar/` | Status bar |
| `eww/` | Dashboard widgets (toggled from the waybar clock) |
| `rofi/` | Launcher, clipboard, power menu, wallpaper picker, keybinds help |
| `swaync/` | Notification center |
| `wlogout/` | Power menu styling |
| `kitty/` | Terminal |
| `fastfetch/` | System info with image logo |
| `wpaperd/` | Wallpaper rotation (hourly, `~/Pictures/wallpapers`) |
| `matugen/` | Theming templates and output mapping |
| `sddm/` | Custom Qt6 login theme with daily background rotation |
| `zsh/` | `wallpaper` helper function and the glass prompt theme |
| `home/` | Files deployed outside `~/.config`: `.zshrc`, `.gitconfig`, `mimeapps.list` |
| `nvim/` | Neovim (lazy.nvim) |
| `zellij/`, `btop/` | Terminal multiplexer and system monitor |
| `spotify-player/`, `satty/` | Music TUI and screenshot annotator, both matugen-themed |
| `gtk-3.0/`, `gtk-4.0/`, `qt5ct/`, `qt6ct/`, `Thunar/` | Toolkit theming and file manager tweaks |

Most directories have their own README with required packages and usage details.
