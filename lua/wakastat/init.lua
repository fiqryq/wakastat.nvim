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

---@return nil
local function update_wakatime()
	local stdout = uv.new_pipe(false)
	if not stdout then
		return
	end

	local handle = uv.spawn("wakatime-cli", {
		args = config.args,
		stdio = { nil, stdout, nil },
	}, function()
		if handle then
			handle:close()
		end
		stdout:close()
	end)

	if not handle then
		stdout:close()
		return
	end

	local data = {}
	stdout:read_start(function(err, chunk)
		assert(not err, err)
		if chunk then
			table.insert(data, chunk)
		else
			wakatime_cache = config.format:format(table.concat(data):gsub("\n", "  "))
			last_update = os.time()
		end
	end)
end

---@param user_config? WakastatConfig
---@return nil
function M.setup(user_config)
	config = vim.tbl_deep_extend("force", config, user_config or {})
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
		provider = M.wakatime,
		hl = { fg = "cyan", bg = "NONE" },
	}

	-- Insert WakaTime component at the end of existing statusline
	local new_statusline = vim.tbl_deep_extend("force", {}, existing_statusline)
	table.insert(new_statusline, wakatime_component)
	return new_statusline
end

return M
