local suppressMaximizeRule = hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

hl.layer_rule({
	name = "blur-eww",
	match = { namespace = "^eww" },
	blur = true,
	ignore_alpha = 0.05,
})

for ns, cutoff in pairs({ waybar = 0.05, rofi = 0.05, swaync = 0.5, wlogout = 0.05 }) do
	hl.layer_rule({
		name = "blur-" .. ns,
		match = { namespace = "^" .. ns },
		blur = true,
		ignore_alpha = cutoff,
	})
end

hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },

	move = "20 monitor_h-120",
	float = true,
})

hl.window_rule({
	name = "float-satty",
	match = { class = "com.gabm.satty" },

	float = true,
	size = "70% 75%",
	center = true,
})

-- floating gif overlay (hypr/scripts/gif-overlay.sh): pinned above all
-- workspaces, no decorations; drag with SUPER+LMB, resize with SUPER+RMB
hl.window_rule({
	name = "gif-overlay",
	match = { class = "^gif-overlay$" },

	float = true,
	pin = true,
	border_size = 0,
	rounding = 0,
	no_shadow = true,
	no_blur = true,
	no_initial_focus = true,
	move = "monitor_w-480 monitor_h-500",
})

hl.window_rule({
	name = "float-spotify-player",
	match = { class = "spotify-player" },

	float = true,
	size = "1100 700",
	center = true,
})
