local M = {}

local uv = vim.uv or vim.loop

---@class WakastatConfig
---@field binary string
---@field args string[]
---@field format string
---@field update_interval integer
---@field enable_timer boolean
---@field highlight string|nil
---@field on_output fun(raw:string):string|nil

local defaults = {
	binary = "wakatime-cli",
	args = { "--today" },
	format = "WakaTime: %s",
	update_interval = 300,
	enable_timer = true,
	highlight = "Wakastat",
	on_output = function(s)
		s = s:gsub("%s+$", ""):gsub("^%s+", "")
		if s == "" then
			return nil
		end
		return s
	end,
}

local cfg = vim.deepcopy(defaults)

local state = {
	cache = "WakaTime: N/A",
	last_update = 0,
	last_success = 0,
	updating = false,
	timer = nil,
}

local function notify(msg, level)
	vim.notify("[wakastat] " .. msg, level or vim.log.levels.INFO)
end

local function fire_updated()
	pcall(vim.api.nvim_exec_autocmds, "User", { pattern = "WakastatUpdated", modeline = false })
end

---@param text string|nil
---@param err string|nil
local function set_cache(text, err)
	if text then
		state.cache = string.format(cfg.format, text)
		state.last_success = os.time()
	else
		state.cache = err or "WakaTime: No data"
	end
	state.last_update = os.time()
	fire_updated()
end

local function run_wakatime(on_done)
	if vim.system then
		vim.system({ cfg.binary, unpack(cfg.args) }, { text = true }, function(obj)
			local ok = (obj.code or 1) == 0
			local out = obj.stdout or ""
			local parsed = cfg.on_output and cfg.on_output(out) or out
			if ok and parsed then
				on_done(true, parsed)
			elseif ok then
				on_done(false, "WakaTime: No data")
			else
				on_done(false, ("WakaTime: Error (%d)"):format(obj.code or -1))
			end
		end)
		return
	end

	local stdout = uv.new_pipe(false)
	if not stdout then
		on_done(false, "WakaTime: Error (pipe)")
		return
	end

	local chunks = {}
	local handle
	handle = uv.spawn(cfg.binary, { args = cfg.args, stdio = { nil, stdout, nil } }, function(code, _)
		if handle and not handle:is_closing() then
			handle:close()
		end
		if stdout and not stdout:is_closing() then
			stdout:close()
		end

		local out = table.concat(chunks)
		local parsed = cfg.on_output and cfg.on_output(out) or out
		if code == 0 and parsed then
			on_done(true, parsed)
		elseif code == 0 then
			on_done(false, "WakaTime: No data")
		else
			on_done(false, ("WakaTime: Error (%d)"):format(code or -1))
		end
	end)

	if not handle then
		if stdout and not stdout:is_closing() then
			stdout:close()
		end
		on_done(false, "WakaTime: Error (spawn)")
		return
	end

	stdout:read_start(function(err, chunk)
		if err then
			return
		end
		if chunk then
			table.insert(chunks, chunk)
		end
	end)
end

function M.update_now()
	if state.updating then
		return
	end
	state.updating = true
	run_wakatime(function(ok, msg)
		vim.schedule(function()
			set_cache(ok and msg or nil, not ok and msg or nil)
			state.updating = false
		end)
	end)
end

---@return string
function M.status()
	if (os.time() - state.last_update) > cfg.update_interval and not state.updating then
		M.update_now()
	end
	return state.cache
end

---@param opts? {prefix?:string, suffix?:string, hl?:table|string}
function M.heirline_component(opts)
	opts = opts or {}
	local prefix = opts.prefix or " "
	local suffix = opts.suffix or " "
	local hl = opts.hl or cfg.highlight
	return {
		provider = function()
			return prefix .. M.status() .. suffix
		end,
		hl = hl,
	}
end

---@param user_cfg? WakastatConfig
function M.setup(user_cfg)
	user_cfg = user_cfg or {}
	cfg = vim.tbl_deep_extend("force", defaults, user_cfg)

	vim.validate({
		binary = { cfg.binary, "string" },
		args = { cfg.args, "table" },
		format = { cfg.format, "string" },
		update_interval = { cfg.update_interval, "number" },
		enable_timer = { cfg.enable_timer, "boolean" },
	})

	vim.api.nvim_set_hl(0, cfg.highlight, { link = "Type" })

	vim.api.nvim_create_user_command("WakastatRefresh", function()
		M.update_now()
		notify("Refreshing…")
	end, {})

	vim.api.nvim_create_user_command("WakastatStatus", function()
		notify(M.status())
	end, {})

	if cfg.enable_timer then
		if state.timer and not state.timer:is_closing() then
			state.timer:stop()
		end
		state.timer = uv.new_timer()
		state.timer:start(
			0,
			math.max(1000, cfg.update_interval * 1000),
			vim.schedule_wrap(function()
				M.update_now()
			end)
		)
	end

	M.update_now()
end

function M.teardown()
	if state.timer and not state.timer:is_closing() then
		state.timer:stop()
		state.timer:close()
	end
	state.timer = nil
end

return M
