return {
	"jesseleite/nvim-noirbuddy",
	dependencies = {
		{ "tjdevries/colorbuddy.nvim" },
	},
	lazy = false,
	priority = 1000,
	config = function()
		require("noirbuddy").setup({
			preset = "miami-nights",
		})

		-- Load the color palette
		local colors = require("noirbuddy.colors").all()
		vim.api.nvim_set_hl(0, "LineNr", { fg = colors.gray_1, bg = colors.bg })
		vim.api.nvim_set_hl(0, "CursorLineNr", { fg = colors.gray_2, bg = colors.bg, bold = true })
		vim.api.nvim_set_hl(0, "WinSeparator", {
			fg = colors.gray_4,
			bold = false,
		})

		-- Treesitter / syntax groups color overrides:
		-- Function argument names
		vim.api.nvim_set_hl(0, "@parameter", { fg = colors.primary, italic = true })

		-- Variables
		vim.api.nvim_set_hl(0, "@variable", { fg = colors.secondary })

		-- Object properties (sub-variables)
		vim.api.nvim_set_hl(0, "@property", { fg = colors.gray5 })

		-- If you want to add local variables differently (optional)
		vim.api.nvim_set_hl(0, "Identifier", { fg = colors.secondary })

		-- Optional: add slight styling for function names to distinguish
		vim.api.nvim_set_hl(0, "Function", { fg = colors.primary, bold = true })

		vim.api.nvim_create_user_command("ExportHighlightGroup", function()
			local line = vim.fn.line(".")
			local col = vim.fn.col(".")

			local group = vim.fn.synIDattr(vim.fn.synID(line, col, 1), "name")
			local trans = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.synID(line, col, 1)), "name")

			local file = vim.fn.expand("~") .. "/highlight-info.txt"
			local f = io.open(file, "w")

			f:write("== Neovim Highlight Info ==\n")
			f:write("Cursor position: line " .. line .. ", col " .. col .. "\n")
			f:write("Syntax group   : " .. group .. "\n")
			f:write("Transformed    : " .. trans .. "\n")

			f:write("\n(Treesitter capture info requires playground plugin)\n")

			f:close()

			print("Highlight info exported to: " .. file)
		end, {})
	end,
}
