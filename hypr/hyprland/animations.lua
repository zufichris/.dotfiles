hl.curve("easeOutQuint", {
	type = "bezier",
	points = {
		{ 0.23, 1 },
		{ 0.32, 1 },
	},
})

hl.curve("easeInOutCubic", {
	type = "bezier",
	points = {
		{ 0.65, 0.05 },
		{ 0.36, 1 },
	},
})

hl.curve("linear", {
	type = "bezier",
	points = {
		{ 0, 0 },
		{ 1, 1 },
	},
})

hl.curve("almostLinear", {
	type = "bezier",
	points = {
		{ 0.5, 0.5 },
		{ 0.75, 1 },
	},
})

hl.curve("bounce", {
	type = "bezier",
	points = {
		{ 0.60, 0.3 },
		{ 0.50, 1.3 },
	},
})

hl.curve("quick", {
	type = "bezier",
	points = {
		{ 0.15, 0 },
		{ 0.1, 1 },
	},
})

hl.curve("easy", {
	type = "spring",
	mass = 1,
	stiffness = 75,
	dampening = 16,
})

hl.curve("wind", {
	type = "bezier",
	points = {
		{ 0.05, 0.9 },
		{ 0.1, 1.05 },
	},
})

hl.curve("winIn", {
	type = "bezier",
	points = {
		{ 0.1, 1.1 },
		{ 0.1, 1.1 },
	},
})

hl.curve("winOut", {
	type = "bezier",
	points = {
		{ 0.3, -0.3 },
		{ 0, 1 },
	},
})

hl.curve("menu_decel", {
	type = "bezier",
	points = {
		{ 0.1, 1 },
		{ 0, 1 },
	},
})

hl.curve("menu_accel", {
	type = "bezier",
	points = {
		{ 0.38, 0.04 },
		{ 1, 0.07 },
	},
})

hl.curve("md3_decel", {
	type = "bezier",
	points = {
		{ 0.05, 0.7 },
		{ 0.1, 1 },
	},
})

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 1, bezier = "linear" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 30, bezier = "linear", style = "loop" })
hl.animation({ leaf = "windows", enabled = true, speed = 6, bezier = "wind", style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 6, bezier = "winIn", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "winOut", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 2.5, bezier = "md3_decel" })
hl.animation({ leaf = "fade", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "layers", enabled = true, speed = 4, bezier = "menu_decel" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "menu_decel", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 2, bezier = "menu_accel", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 3, bezier = "menu_decel" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 3, bezier = "menu_accel" })

hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "wind" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4.5, bezier = "menu_decel", style = "slidevert" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })
hl.config({
	dwindle = {
		preserve_split = true,
	},
})

hl.config({
	master = {
		new_status = "master",
	},
})

hl.config({
	scrolling = {
		fullscreen_on_one_column = true,
	},
})
