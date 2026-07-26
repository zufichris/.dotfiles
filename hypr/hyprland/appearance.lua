local theme = require("hyprland.theme")

hl.config({
	general = {
		gaps_in = 2,
		gaps_out = 6,

		border_size = 2,

		col = {
			active_border = { colors = { theme.accent, theme.surface_high }, angle = 90 },
			inactive_border = theme.background,
		},

		resize_on_border = true,
		allow_tearing = false,
		layout = "dwindle",
	},

	decoration = {
		rounding = 10,
		rounding_power = 2,

		active_opacity = 1.0,
		inactive_opacity = 0.9,

		shadow = {
			enabled = true,
			range = 32,
			render_power = 2,
			color = "#00000050",
		},

		blur = {
			enabled = true,
			size = 8,
			passes = 2,
			noise = 0.03,
			contrast = 1.0,
			brightness = 1.0,
		},
	},

	animations = {
		enabled = true,
	},
})
