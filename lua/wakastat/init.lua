local M = {}

local uv = vim.loop

-- Default config
local config = {
	args = { "--today" },
	format = "Today Coding Time: %s",
	update_interval = 300,
}

local wakatime_cache = "WakaTime: N/A"
local last_update = 0

local function update_wakatime()
	---@diagnostic disable-next-line: undefined-field
	local stdout = uv.new_pipe(false)
	local handle
	---@diagnostic disable-next-line: undefined-field
	handle = uv.spawn("wakatime-cli", {
		args = config.args,
		stdio = { nil, stdout, nil },
	}, function()
		handle:close()
		stdout:close()
	end)

	local data = {}
	---@diagnostic disable-next-line: undefined-field
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

function M.setup(user_config)
	config = vim.tbl_deep_extend("force", config, user_config or {})
end

function M.wakatime()
	if os.time() - last_update > config.update_interval then
		update_wakatime()
	end
	return wakatime_cache
end

return M
