local wezterm = require("wezterm")
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
local mux = wezterm.mux
local act = wezterm.action

tabline.setup({
	options = {
		icons_enabled = true,
		theme = "Tokyo Night Storm",
		section_separators = {
			left = wezterm.nerdfonts.pl_left_hard_divider,
			right = wezterm.nerdfonts.pl_right_hard_divider,
		},
		component_separators = {
			left = wezterm.nerdfonts.pl_left_soft_divider,
			right = wezterm.nerdfonts.pl_right_soft_divider,
		},
		tab_separators = {
			left = wezterm.nerdfonts.pl_left_hard_divider,
			right = wezterm.nerdfonts.pl_right_hard_divider,
		},
	},
	sections = {
		tabline_a = { "mode" },
		tabline_b = { "workspace" },
		tabline_c = { " " },
		tab_active = {
			"index",
			{ "parent", padding = 0 },
			"/",
			{ "cwd",    padding = { left = 0, right = 1 } },
			{ "zoomed", padding = 0 },
		},
		tab_inactive = { "index", { "process", padding = { left = 0, right = 1 } } },
		tabline_x = { "ram", "cpu" },
		tabline_y = { "datetime" },
		tabline_z = { "hostname" },
	},
})

local function list_files(directory)
	local files = {}
	local handle = io.popen('ls -1 "' .. directory .. '"')
	if handle then
		for file in handle:lines() do
			-- Remove the file extension
			local name_without_ext = file:match("(.+)%..+$") or file
			table.insert(files, { id = name_without_ext, label = name_without_ext })
		end
		handle:close()
	end
	return files
end

local function load_workspace(window, name)
	wezterm.log_info("Attempting to load workspace: " .. name)

	-- Check if the workspace already exists
	local existing_workspaces = wezterm.mux.get_workspace_names()
	local existing_workspace = false
	print(existing_workspaces)
	for _, wsp in ipairs(existing_workspaces) do
		if wsp == name then
			existing_workspace = true
		end
	end

	if existing_workspace then
		wezterm.log_info("Workspace " .. name .. " already exists. Switching to it.")
		for _, window in ipairs(wezterm.mux.all_windows()) do
			if window:get_workspace() == name then
				mux.set_active_workspace(name)
				return
			end
		end
		wezterm.log_warn("Couldn't find a window for existing workspace " .. name)
		return
	end

	if not window then
		wezterm.log_error("Window object is nil")
		return
	end

	local config_path = wezterm.home_dir .. "/.wezterm_workspaces/" .. name .. ".lua"
	wezterm.log_info("Loading config from: " .. config_path)

	local success, config = pcall(dofile, config_path)
	if not success then
		wezterm.log_error("Failed to load workspace config: " .. tostring(config))
		return
	end

	wezterm.log_info("Workspace config loaded successfully")
	wezterm.log_info("Config contains " .. tostring(#config.tabs or 0) .. " tabs")

	local _, workspace_tab, workspace_pane, workspace_window = pcall(function()
		return wezterm.mux.spawn_window({
			workspace = name,
			cwd = config.cwd,
		})
	end)
	local used_default_tab = false

	for i, tab_config in ipairs(config.tabs or {}) do
		wezterm.log_info("Processing tab " .. i)

		local tab, pane
		if used_default_tab then
			success, tab, pane = pcall(function()
				return workspace_window:spawn_tab({})
			end)
			if not success then
				wezterm.log_error("Failed to spawn window: " .. tostring(tab))
				return
			end
		else
			tab = workspace_tab
			pane = workspace_pane
			used_default_tab = true
		end

		wezterm.log_info("Window spawned successfully")

		if tab_config.title then
			success, _ = pcall(function()
				tab:set_title(tab_config.title)
			end)
			if not success then
				wezterm.log_warn("Failed to set tab title: " .. tab_config.title)
			end
		end

		for _, cmd in ipairs(tab_config.commands or {}) do
			success, _ = pcall(function()
				pane:send_text(cmd .. "\n")
			end)
			if not success then
				wezterm.log_warn("Failed to send command: " .. cmd)
			end
		end

		if tab_config.split then
			local split_pane
			success, split_pane = pcall(function()
				return pane:split(tab_config.split)
			end)
			if not success then
				wezterm.log_warn("Failed to split pane: " .. tostring(split_pane))
			else
				for _, cmd in ipairs(tab_config.split_commands or {}) do
					success, _ = pcall(function()
						split_pane:send_text(cmd .. "\n")
					end)
					if not success then
						wezterm.log_warn("Failed to send command to split pane: " .. cmd)
					end
				end
			end
		end

		wezterm.log_info("Finished processing tab " .. i)
	end

	if workspace_window then
		mux.set_active_workspace(name)
		workspace_tab:activate({})
		wezterm.log_info("Workspace " .. name .. " loaded successfully")
	end
end

local config = {
	color_scheme = "Tokyo Night Storm",
	font = wezterm.font("Monaspace Neon Light"),
	window_close_confirmation = "NeverPrompt",
	animation_fps = 60,
	max_fps = 120,
	scrollback_lines = 5000,
	tab_bar_at_bottom = true,
	enable_wayland = false,
	-- Add custom tab bar style
	colors = {
		tab_bar = {
			background = "#1a1b26",
			active_tab = {
				bg_color = "#7aa2f7",
				fg_color = "#1a1b26",
			},
			inactive_tab = {
				bg_color = "#24283b",
				fg_color = "#545c7e",
			},
		},
	},

	-- Custom tab bar with time and current directory
	tab_bar_style = {
		new_tab = wezterm.format({
			{ Foreground = { Color = "#7aa2f7" } },
			{ Text = "+" },
		}),
		new_tab_hover = wezterm.format({
			{ Foreground = { Color = "#bb9af7" } },
			{ Text = "+" },
		}),
	},
	keys = {
		{
			key = "O",
			mods = "CTRL|SHIFT",
			action = act.InputSelector({
				action = wezterm.action_callback(function(window, pane, id, label)
					if id then
						print(window)
						load_workspace(window, id)
					end
				end),
				title = "Select Workspace",
				choices = list_files("/home/taigi100/.wezterm_workspaces/"),
			}),
		},
		{
			key = "w",
			mods = "CTRL|SHIFT",
			action = act.ShowLauncherArgs({ flags = "WORKSPACES" }),
		},
		-- Split vertically
		{ key = "\\", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
		-- Split horizontally
		{ key = "|",  mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		-- Navigate splits
		{ key = "h",  mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
		{ key = "j",  mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },
		{ key = "k",  mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
		{ key = "l",  mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },
		{ key = "x",  mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = false }) },
	},
}

tabline.apply_to_config(config)
return config
