local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action

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
	enable_tab_bar = false,

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
	},
}
return config
