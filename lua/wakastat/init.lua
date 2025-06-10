local M = {}
local uv = vim.uv

---@class WakastatConfig
---@field args string[]
---@field format string
---@field update_interval number

-- Default config
---@type WakastatConfig
local config = {
	args = { "--today" },
	format = "Today Coding Time: %s",
	update_interval = 300,
}

local wakatime_cache = "WakaTime: N/A"
local last_update = 0
local updating = false

---@return nil
local function update_wakatime()
	-- Prevent multiple simultaneous updates
	if updating then
		return
	end
	updating = true

	local stdout = uv.new_pipe(false)
	if not stdout then
		updating = false
		return
	end

	local handle = uv.spawn("wakatime-cli", {
		args = config.args,
		stdio = { nil, stdout, nil },
	}, function(code, signal)
		updating = false
		if handle then
			handle:close()
		end
		if stdout and not stdout:is_closing() then
			stdout:close()
		end
		-- Update timestamp even if command failed
		last_update = os.time()
	end)

	if not handle then
		stdout:close()
		updating = false
		return
	end

	local data = {}
	stdout:read_start(function(err, chunk)
		if err then
			wakatime_cache = "WakaTime: Error"
			return
		end

		if chunk then
			table.insert(data, chunk)
		else
			local result = table.concat(data):gsub("\n", ""):gsub("^%s*(.-)%s*$", "%1")
			if result and result ~= "" then
				wakatime_cache = config.format:format(result)
			else
				wakatime_cache = "WakaTime: No data"
			end
		end
	end)
end

---@param user_config? WakastatConfig
---@return nil
function M.setup(user_config)
	config = vim.tbl_deep_extend("force", config, user_config or {})
	-- Initial update
	update_wakatime()
end

---@return string
function M.wakatime()
	if os.time() - last_update > config.update_interval then
		update_wakatime()
	end
	return wakatime_cache
end

-- Function to add WakaTime component to existing heirline statusline
---@param existing_statusline table
---@return table
function M.add_to_heirline(existing_statusline)
	local wakatime_component = {
		provider = function()
			return " " .. M.wakatime() .. " "
		end,
		hl = { fg = "cyan", bg = "NONE" },
	}

	-- Insert WakaTime component at the end of existing statusline
	local new_statusline = vim.tbl_deep_extend("force", {}, existing_statusline)
	table.insert(new_statusline, wakatime_component)

	return new_statusline
end

return M
