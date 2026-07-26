local config_root = arg[1]
package.path = config_root .. "/?.lua;" .. package.path

local programs = require("hyprland.programs")

local cmd_names = {}
for name, program in pairs(programs) do
	local pretty = name:gsub("%d+$", ""):gsub("(%l)(%u)", "%1 %2"):lower()
	cmd_names[program.cmd] = pretty:sub(1, 1):upper() .. pretty:sub(2)
end

local function describe_exec(cmd)
	if cmd_names[cmd] then
		return cmd_names[cmd]
	end
	if cmd:find("hyprshutdown") then
		return "Exit Hyprland"
	end
	if cmd:find("set%-volume") then
		return cmd:find("%%%+") and "Volume up" or "Volume down"
	end
	if cmd:find("set%-mute") then
		return cmd:find("SOURCE") and "Mute microphone" or "Mute audio"
	end
	if cmd:find("brightnessctl") then
		return cmd:find("%%%+") and "Brightness up" or "Brightness down"
	end
	if cmd:find("playerctl next") then
		return "Next track"
	end
	if cmd:find("playerctl previous") then
		return "Previous track"
	end
	if cmd:find("playerctl play%-pause") then
		return "Play / pause"
	end
	return "Run: " .. cmd
end

local function describe(path, a)
	if path == "exec_cmd" then
		return describe_exec(a)
	elseif path == "window.close" then
		return "Close window"
	elseif path == "window.float" then
		return "Toggle floating"
	elseif path == "window.pseudo" then
		return "Pseudo-tile window"
	elseif path == "window.drag" then
		return "Drag window"
	elseif path == "window.resize" then
		return "Resize window"
	elseif path == "window.move" then
		local ws = a and a.workspace
		if type(ws) == "string" and ws:find("^special:") then
			return "Move window to scratchpad (" .. ws:sub(9) .. ")"
		end
		return "Move window to workspace " .. tostring(ws)
	elseif path == "layout" then
		return a == "togglesplit" and "Toggle split direction" or "Layout: " .. tostring(a)
	elseif path == "focus" then
		if a and a.direction then
			return "Focus " .. a.direction
		end
		local ws = a and a.workspace
		if ws == "e+1" then
			return "Next workspace"
		elseif ws == "e-1" then
			return "Previous workspace"
		end
		return "Go to workspace " .. tostring(ws)
	elseif path == "workspace.toggle_special" then
		return "Toggle scratchpad" .. (a and (" (" .. tostring(a) .. ")") or "")
	end
	return path:gsub("%.", " ") .. (type(a) == "string" and " " .. a or "")
end

local binds = {}

local function make_proxy(path)
	return setmetatable({}, {
		__index = function(_, key)
			return make_proxy(path == "" and key or path .. "." .. key)
		end,
		__call = function(_, a)
			return { path = path, arg = a }
		end,
	})
end

local function noop()
	return setmetatable({}, { __index = function() return noop end })
end

hl = setmetatable({
	dsp = make_proxy(""),
	bind = function(keys, action)
		table.insert(binds, { keys = keys, action = action })
		return noop()
	end,
}, { __index = function() return noop end })

dofile(config_root .. "/hyprland/keybinds.lua")

local key_names = {
	["mouse:272"] = "LMB drag",
	["mouse:273"] = "RMB drag",
	["mouse_down"] = "Scroll down",
	["mouse_up"] = "Scroll up",
}

local function pango_escape(s)
	return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

for _, bind in ipairs(binds) do
	local keys = bind.keys
	for raw, pretty in pairs(key_names) do
		keys = keys:gsub(raw, pretty)
	end
	local action = describe(bind.action.path, bind.action.arg)
	io.write(string.format('<b>%-34s</b><span alpha="70%%">%s</span>\n', pango_escape(keys), pango_escape(action)))
end
