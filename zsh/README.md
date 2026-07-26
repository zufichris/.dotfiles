# ZSH Utilities

Terminal wallpaper picker and the `glass` prompt theme.

## Required packages

- `zsh`
- `wpaperd` (image wallpapers; `mpvpaper` additionally for videos)
- `matugen` (dynamic theming from wallpaper)

Install on Arch:
```bash
sudo pacman -S zsh wpaperd matugen
```

## Setup

Source the utilities in your `~/.zshrc` (`install.sh` appends this automatically):

```zsh
if [ -f ~/.config/zsh/wallpaper.zsh ]; then
    source ~/.config/zsh/wallpaper.zsh
fi
```

## Commands

- `wallpaper` — numbered picker over `~/Pictures/wallpapers` (images and videos, one subdirectory level deep); the selection is applied through `hypr/scripts/set-wallpaper.sh`, which sets the wallpaper (wpaperd for images, mpvpaper for videos) and regenerates the matugen palette. Adapted from haikal-hakim/athena.

## Theme

- `glass.zsh-theme` — oh-my-zsh prompt theme (recolored agnosterzak fork). It draws from the terminal's ANSI palette, which is matugen-generated (`kitty/kitty-theme.conf`), so the prompt re-tints with the wallpaper. `install.sh` copies it to `~/.oh-my-zsh/custom/themes/` if oh-my-zsh is present; set `ZSH_THEME="glass"` in `~/.zshrc`.
