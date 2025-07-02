return {
	"APZelos/blamer.nvim",
	config = function()
		vim.g.blamer_enabled = false
		vim.g.blamer_delay = 2000
		vim.blamer_show_in_insert_modes = 0
	end,
}
