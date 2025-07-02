return {
	"folke/noice.nvim",
	event = "VeryLazy",
	opts = {
		-- add any options here
	},
	config = function()
		require("noice").setup({
			routes = {
				{
					filter = {
						event = "msg_show",
						kind = "search_count",
						find = "written",
					},
					opts = { skip = true },
				},
			},
			views = {
				cmdline_popup = {
					border = {
						style = "none",
						padding = { 1, 1 },
					},
					filter_options = {},
					win_options = {
						winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
					},
				},
			},
		})
	end,
	dependencies = {
		-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
		"MunifTanjim/nui.nvim",
		-- OPTIONAL:
		--   `nvim-notify` is only needed, if you want to use the notification view.
		--   If not available, we use `mini` as the fallback
		{

			"rcarriga/nvim-notify",
			config = function()
				require("notify").setup({
					timeout = 1000, -- Set the desired timeout in milliseconds (e.g., 3000ms = 3 seconds)
					render = "wrapped-compact",
					level = vim.log.levels.WARN,
					max_width = 50,
				})
			end,
		},
	},
}
