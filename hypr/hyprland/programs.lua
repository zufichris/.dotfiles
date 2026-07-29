local programs = {
	authAgent = {
		cmd = "/usr/lib/hyprpolkitagent/hyprpolkitagent",
		autostart = true,
	},
	clipboardTextWatcher = {
		cmd = "wl-paste --type text --watch cliphist store",
		autostart = true,
	},
	clipboardImageWatcher = {
		cmd = "wl-paste --type image --watch cliphist store",
		autostart = true,
	},
	-- Also starts wallpaper-watcher.sh, but only once the restore has landed;
	-- autostarting the watcher in parallel lets it clobber the saved wallpaper.
	wallpaper = {
		cmd = "~/.config/hypr/scripts/wallpaper-restore.sh",
		autostart = true,
	},
	waybar = {
		cmd = "waybar",
		autostart = true,
	},
	powerMenu = {
		cmd = "~/.config/hypr/scripts/power-menu.sh",
		keybind = "SHIFT + P",
	},
	toolbar = {
		cmd = "killall -SIGUSR1 waybar",
		keybind = "F9",
		useMainMod = false,
	},
	browser = {
		cmd = "brave",
		keybind = "B",
	},
	fileManager = {
		cmd = "thunar",
		keybind = "E",
	},
	terminal = {
		cmd = "kitty",
		keybind = "Return",
	},
	screenshotRegion0 = {
		cmd = "~/.config/hypr/scripts/screenshot.sh region",
		keybind = "SHIFT + S",
	},
	screenshotRegion1 = {
		cmd = "~/.config/hypr/scripts/screenshot.sh region",
		keybind = "Print",
		useMainMod = false,
	},
	screenshotFull = {
		cmd = "~/.config/hypr/scripts/screenshot.sh full",
		keybind = "Print",
		useMainMod = true,
	},
	wallpaperPicker = {
		cmd = "~/.config/hypr/scripts/wallpaper-picker.sh",
		keybind = "W",
	},
	appPicker = {
		cmd = "~/.config/hypr/scripts/launcher.sh",
		keybind = "A",
	},
	rofiClipboard = {
		cmd = "cliphist list | rofi -dmenu -config ~/.config/rofi/clipboard.rasi | cliphist decode | wl-copy",
		keybind = "SHIFT + V",
	},
	swayncToggle = {
		cmd = "swaync-client -t",
		keybind = "N",
	},
	notifLogger = {
		cmd = "~/.config/eww/scripts/notif-log.sh daemon",
		autostart = true,
	},
	ewwDaemon = {
		cmd = "eww daemon",
		autostart = true,
	},
	idleDaemon = {
		cmd = "hypridle",
		autostart = true,
	},
	nightLight = {
		cmd = "sh -c 'command -v hyprsunset >/dev/null && exec hyprsunset'",
		autostart = true,
	},
	autoMount = {
		cmd = "sh -c 'command -v udiskie >/dev/null && exec udiskie'",
		autostart = true,
	},
	cursorTheme = {
		cmd = "sh -c '[ -d /usr/share/icons/Bibata-Modern-Ice ] && hyprctl setcursor Bibata-Modern-Ice 24'",
		autostart = true,
	},
	dashboard = {
		cmd = "~/.config/hypr/scripts/dashboard.sh toggle",
		keybind = "D",
	},
	keybindsHelp = {
		cmd = "~/.config/hypr/scripts/keybinds-help.sh",
		keybind = "SHIFT + H",
	},
	gifOverlay = {
		cmd = "~/.config/hypr/scripts/gif-overlay.sh",
		keybind = "G",
	},
	screenRecorder = {
		cmd = "~/.config/hypr/scripts/screen-record.sh",
		keybind = "SHIFT + G",
	},
}

return programs
