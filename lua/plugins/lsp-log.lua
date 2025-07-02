-- ~/.config/nvim/lua/lsp_spinner.lua
local M = {}

local spinner_active = false
local spinner_msg = ""
local initialized = false
local last_update = 0
local cached_status = ""

local icons = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

local function sanitize(msg)
	-- Remove < and > characters and other problematic characters, limit length to 30 chars, and truncate with ...
	if not msg or msg == "" then
		return ""
	end
	local sanitized = tostring(msg):gsub("[<>]", ""):gsub("[\r\n\t]", " ")
	if #sanitized > 30 then
		sanitized = sanitized:sub(1, 27) .. "..."
	end
	return sanitized
end

function M.setup()
	if initialized then
		return
	end
	initialized = true

	-- Set log level to WARNING to reduce noise
	vim.lsp.set_log_level(vim.log.levels.WARN)

	vim.lsp.handlers["$/progress"] = function(_, result, ctx)
		local value = result and result.value
		if type(value) ~= "table" then
			return
		end

		vim.schedule(function()
			local ok, err = pcall(function()
				if value.kind == "begin" then
					spinner_active = true
					spinner_msg = sanitize(value.title or value.message or "LSP Task")
				elseif value.kind == "end" then
					spinner_active = false
					spinner_msg = ""
				elseif value.kind == "report" then
					spinner_msg = sanitize(value.message or spinner_msg)
				end
			end)

			if not ok then
				vim.notify("LSP spinner error: " .. err, vim.log.levels.ERROR)
			end
		end)
	end
end

function M.status()
	-- Show spinner when LSP is working
	if not spinner_active then
		return ""
	end
	
	-- Use a simple spinner icon
	local now = vim.loop.hrtime()
	if now - last_update > 100 * 1e6 then
		local index = math.floor((now / 1e8) % #icons) + 1
		cached_status = "LSP:" .. icons[index]
		last_update = now
	end
	
	return cached_status
end

return M
