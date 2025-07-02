return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	opts = {
		indent = {
			char = "▏",
		},
		scope = {
			show_start = false,
			show_end = false,
			show_exact_scope = false,
		},
		exclude = {
			filetypes = {
				"help",
				"startify",
				"dashboard",
				"packer",
				"neogitstatus",
				"NvimTree",
				"Trouble",
			},
		},
	},
	config = function(_, opts)
		require("ibl").setup(opts)
		-- Function to enable indent-blankline
		local function enable_indent_blankline()
			vim.b.indent_blankline_enabled = true
			require("ibl").refresh()
		end

		-- Function to disable indent-blankline
		local function disable_indent_blankline()
			vim.b.indent_blankline_enabled = false
			require("ibl").refresh()
		end

		-- Autocommand group for managing indent-blankline
		vim.api.nvim_create_augroup("IndentBlanklineToggle", { clear = true })

		-- Enable indent-blankline in the active buffer
		vim.api.nvim_create_autocmd("BufEnter", {
			group = "IndentBlanklineToggle",
			callback = function()
				enable_indent_blankline()
			end,
		})

		-- Disable indent-blankline in inactive buffers
		vim.api.nvim_create_autocmd("BufLeave", {
			group = "IndentBlanklineToggle",
			callback = function()
				disable_indent_blankline()
			end,
		})
	end,
}
