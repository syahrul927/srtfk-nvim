return {
	"nvimdev/lspsaga.nvim",
	config = function()
		require("lspsaga").setup({
			lightbulb = {
				enable = false,
			},
			ui = {
				border = "rounded",
			},
			finder = {
				layout = "float",
				left_width = 0.2,
				right_width = 0.8,
			},
			symbol_in_winbar = {
				enable = true,
				separator = " 󰬪 ",
				hide_keyword = true,
				show_file = true,
				folder_level = 2,
				respect_root = false,
				color_mode = true,
			},
			request_timeout = 5000,
		})
	end,
	dependencies = {
		"nvim-treesitter/nvim-treesitter", -- optional
		"nvim-tree/nvim-web-devicons", -- optional
	},
}
