return {
	"projekt0n/github-nvim-theme",
	name = "github-theme",
	lazy = false, -- make sure we load this during startup if it is your main colorscheme
	priority = 1000, -- make sure to load this before all the other start plugins
	config = function()
		require("github-theme").setup({
			options = {
				transparent = false,
				terminal_colors = true,
				dim_inactive = false,
				module_default = true,
				styles = {
					comments = "italic",
					keywords = "bold",
					types = "italic,bold",
				},
			},
			palettes = {
				github_dark_tritanopia = {
					bg0 = "#18181a", -- Main background
					bg1 = "#18181a", -- Secondary background
					bg2 = "#1f1f23", -- Tertiary background
					bg3 = "#26262a", -- Quaternary background
				},
			},
			groups = {
				github_dark_tritanopia = {
					-- Main backgrounds
					Normal = { bg = "#18181a" },
					NormalFloat = { bg = "#18181a" },
					NormalNC = { bg = "#18181a" }, -- Inactive window background
					SignColumn = { bg = "#18181a" },
					EndOfBuffer = { bg = "#18181a" },
					
					-- Sidebar and plugin backgrounds
					NeoTreeNormal = { bg = "#18181a" },
					NeoTreeNormalNC = { bg = "#18181a" },
					NeoTreeEndOfBuffer = { bg = "#18181a" },
					
					-- Telescope backgrounds
					TelescopeNormal = { bg = "#18181a" },
					TelescopePromptNormal = { bg = "#18181a" },
					TelescopeResultsNormal = { bg = "#18181a" },
					TelescopePreviewNormal = { bg = "#18181a" },
					TelescopeBorder = { bg = "#18181a" },
					TelescopePromptBorder = { bg = "#18181a" },
					TelescopeResultsBorder = { bg = "#18181a" },
					TelescopePreviewBorder = { bg = "#18181a" },
					
					-- Other common plugin backgrounds
					WhichKeyFloat = { bg = "#18181a" },
					LspInfoBorder = { bg = "#18181a" },
					LspInfo = { bg = "#18181a" },
					
					-- Status and tab line backgrounds
					StatusLine = { bg = "#18181a" },
					StatusLineNC = { bg = "#18181a" },
					TabLine = { bg = "#18181a" },
					TabLineFill = { bg = "#18181a" },
					
					-- Popup and menu backgrounds
					Pmenu = { bg = "#18181a" },
					PmenuSbar = { bg = "#18181a" },
					PmenuThumb = { bg = "#26262a" },
					
					-- Split and window separators
					WinSeparator = { bg = "#18181a" },
					VertSplit = { bg = "#18181a" },
					
					-- Floating window backgrounds
					FloatBorder = { bg = "#18181a" },
					FloatTitle = { bg = "#18181a" },
				},
			},
		})

		vim.cmd("colorscheme github_dark_tritanopia")
	end,
}
