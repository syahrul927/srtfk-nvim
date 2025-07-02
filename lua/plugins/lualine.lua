-- Set lualine as statusline
return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		{ "jesseleite/nvim-noirbuddy" },
		{ "tjdevries/colorbuddy.nvim" },
	},
	config = function()
		local function macro_recording()
			local reg = vim.fn.reg_recording()
			if reg == "" then
				return ""
			end
			return " @" .. reg -- You can use any icon (󰑋, , ●, , etc.)
		end
		local status_ok_colors, colors = pcall(require, "noirbuddy.colors")
		if not status_ok_colors then
			return
		end
		local c = colors.all()
		local theme = {
			normal = {
				a = { fg = c.gray_2, bg = c.gray_8, gui = "bold" },
				b = { fg = c.gray_2, bg = c.gray_8 },
				c = { fg = c.gray_2, bg = c.gray_8 },
			},
			insert = { a = { fg = c.gray_2, bg = c.gray_8, gui = "bold" } },
			visual = { a = { fg = c.gray_2, bg = c.gray_8, gui = "bold" } },
			replace = { a = { fg = c.gray_2, bg = c.gray_8, gui = "bold" } },
			inactive = {
				a = { fg = c.gray_1, bg = c.black },
				b = { fg = c.gray_1, bg = c.black },
				c = { fg = c.gray_1, bg = c.black },
			},
		}
		-- Create a minimal safe configuration with no dynamic components
		local ok, lualine = pcall(require, "lualine")
		if not ok then
			vim.notify("Failed to load lualine: " .. tostring(lualine), vim.log.levels.ERROR)
			return
		end

		-- Safe sanitization function for any text
		local function safe_text(str)
			if not str or str == "" then
				return ""
			end
			-- Convert to string and remove problematic characters
			local result = tostring(str)
					:gsub("[<>]", "")                      -- Remove angle brackets
					:gsub("[\r\n\t]", " ")                 -- Replace newlines/tabs with spaces
					:gsub("[%c]", "")                      -- Remove control characters
					:gsub("%s+", " ")                      -- Collapse multiple spaces
					:gsub("[^\32-\126\194-\244[\128-\191]]", "") -- Allow UTF-8 characters

			return result
		end

		-- Create a safe LSP indicator
		local lsp_status = function()
			-- First check if there's an active progress notification
			local ok, progress = pcall(require, "plugins.lsp-log")
			local progress_msg = ""
			if ok then
				progress_msg = progress.status()
			end

			-- If there's a progress message, return it
			if progress_msg and progress_msg ~= "" then
				return safe_text(progress_msg)
			end

			-- Otherwise show connected LSP clients
			local clients = vim.lsp.get_active_clients({ bufnr = 0 })
			if #clients > 0 then
				local names = {}
				for _, client in ipairs(clients) do
					table.insert(names, safe_text(client.name))
				end
				return "LSP:" .. table.concat(names, ",")
			end
			return ""
		end

		-- Set up lualine with carefully selected components
		lualine.setup({
			options = {
				icons_enabled = true,                           -- Enable icons for git branch
				theme = theme,                                  -- ✅ use flattened custom theme
				globalstatus = true,
				section_separators = { left = "", right = "" }, -- Empty separators
				component_separators = { left = "|", right = "|" }, -- Simple separators
				disabled_filetypes = { "alpha", "neo-tree", "Avante" },
				always_divide_middle = true,
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = {
					"filename",
					{
						"branch",
						icon = " ", -- Text-based git icon
					},
				},
				lualine_c = {
					{
						"diagnostics",
						sources = { "nvim_diagnostic" },
						sections = { "error", "warn" },
						symbols = {
							error = " ", -- Text-based error indicator
							warn = " ", -- Text-based warning indicator
						},
						colored = true,
						update_in_insert = false,
						always_visible = false,
					},
					macro_recording,
				},
				lualine_x = { lsp_status, "filetype" },
				lualine_y = { "location" },
				lualine_z = { "progress" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = {},
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {},
			extensions = {},
		})

		-- Create a fallback mechanism in case lualine still fails
		vim.api.nvim_create_autocmd("VimEnter", {
			callback = function()
				vim.defer_fn(function()
					local status_ok, _ = pcall(function()
						return vim.api.nvim_get_option_value("statusline", {})
					end)

					if not status_ok then
						-- If statusline is broken, revert to a simple statusline
						vim.o.statusline = " %f %m%r%h%w%=%l,%c %p%%"
						vim.notify("Lualine failed, using simple statusline", vim.log.levels.WARN)
					else
						-- Load statusline debugging utility
						pcall(require, "plugins.statusline-debug")
					end
				end, 1000)
			end,
			once = true,
		})

		-- Create a command to completely disable lualine and use a simple statusline
		vim.api.nvim_create_user_command("DisableLualine", function()
			vim.o.statusline = " %f %m%r%h%w%=%l,%c %p%%"
			vim.notify("Lualine disabled, using simple statusline", vim.log.levels.INFO)
		end, {})

		-- Create commands to switch between minimal and enhanced configurations
		vim.api.nvim_create_user_command("LualineMinimal", function()
			lualine.setup({
				options = {
					icons_enabled = false,
					theme = theme, -- ✅ use flattened custom theme
					globalstatus = true,
					section_separators = { left = "", right = "" },
					component_separators = { left = "|", right = "|" },
					disabled_filetypes = { "alpha", "neo-tree", "Avante" },
					always_divide_middle = true,
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "filename" },
					lualine_c = {},
					lualine_x = { "filetype" },
					lualine_y = { "location" },
					lualine_z = { "progress" },
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = { "filename" },
					lualine_x = {},
					lualine_y = {},
					lualine_z = {},
				},
			})
			vim.notify("Switched to minimal lualine configuration", vim.log.levels.INFO)
		end, {})

		vim.api.nvim_create_user_command("LualineEnhanced", function()
			lualine.setup({
				options = {
					icons_enabled = true,
					theme = theme, -- ✅ use flattened custom theme
					globalstatus = true,
					section_separators = { left = "", right = "" },
					component_separators = { left = "|", right = "|" },
					disabled_filetypes = { "alpha", "neo-tree", "Avante" },
					always_divide_middle = true,
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = {
						"filename",
						{
							"branch",
							icon = " ", -- Text-based git icon
						},
					},
					lualine_c = {
						{
							"diagnostics",
							sources = { "nvim_diagnostic" },
							sections = { "error", "warn" },
							symbols = {
								error = " ", -- Text-based error indicator
								warn = " ", -- Text-based warning indicator
							},
							colored = true,
							update_in_insert = false,
							always_visible = false,
						},
					},
					lualine_x = { lsp_status, "filetype" },
					lualine_y = { "location" },
					lualine_z = { "progress" },
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = { "filename" },
					lualine_x = {},
					lualine_y = {},
					lualine_z = {},
				},
			})
			vim.notify("Switched to enhanced lualine configuration", vim.log.levels.INFO)
		end, {})

		-- Create a command to toggle icons
		vim.api.nvim_create_user_command("LualineToggleIcons", function()
			local current_config = vim.deepcopy(lualine.get_config())
			current_config.options.icons_enabled = not current_config.options.icons_enabled
			lualine.setup(current_config)
			vim.notify(
				"Lualine icons " .. (current_config.options.icons_enabled and "enabled" or "disabled"),
				vim.log.levels.INFO
			)
		end, {})
	end,
}
