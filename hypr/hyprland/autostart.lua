local programs = require("hyprland.programs")

local function autostart()
	for _, value in pairs(programs) do
		if value.autostart then
			hl.exec_cmd(value.cmd)
		end
	end
end

hl.on("hyprland.start", autostart)
