-- Fuzzy Finder (files, lsp, etc)
return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		-- Fuzzy Finder Algorithm which requires local dependencies to be built.
		-- Only load if `make` is available. Make sure you have the system
		-- requirements installed.
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},
		"nvim-telescope/telescope-ui-select.nvim",

		-- Useful for getting pretty icons, but requires a Nerd Font.
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local actions = require("telescope.actions")
		local builtin = require("telescope.builtin")

		require("telescope").setup({
			defaults = {
				path_display = { truncate = "2" },
				layout_strategy = "horizontal",
				layout_config = {
					horizontal = {
						preview_width = 0.55, -- Adjust this value to set the preview area's width
						prompt_position = "bottom", -- Optional: Position the prompt at the top
					},
					width = 0.9,            -- Overall width of Telescope window
					height = 0.9,           -- Overall height of Telescope window
					preview_cutoff = 120,
				},
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous, -- move to prev result
						["<C-j>"] = actions.move_selection_next, -- move to next result
						["<C-l>"] = actions.select_default,    -- open file
					},
					n = {
						["q"] = actions.close,
					},
				},
			},
			pickers = {
				find_files = {
					file_ignore_patterns = { "node_modules", ".git", ".venv", ".next" },
					hidden = true,
				},
				buffers = {
					initial_mode = "insert",
					sort_lastused = true,
					-- sort_mru = true,
					mappings = {
						n = {
							["d"] = actions.delete_buffer,
							["l"] = actions.select_default,
						},
					},
				},
				-- Multi-line display for LSP references
				lsp_references = {
					layout_strategy = "horizontal",
					layout_config = {
						vertical = {
							width = 0.95,
							height = 0.95,
							preview_height = 0.6,
							prompt_position = "bottom",
						},
					},
					path_display = function(opts, path)
						-- Custom path display for better Java file visibility
						local tail = require("telescope.utils").path_tail(path)
						local parent = vim.fn.fnamemodify(path, ":h:t")
						if parent and parent ~= "." then
							return string.format("%s/%s", parent, tail)
						else
							return tail
						end
					end,
					show_line = false,
					trim_text = true,
					include_declaration = false,
					include_current_line = false,
					fname_width = 60,
					results_title = "References",
					prompt_title = "Find References",
				},
			},
			live_grep = {
				file_ignore_patterns = { "node_modules", ".git", ".venv", ".next" },
				additional_args = function(_)
					return { "--hidden" }
				end,
			},
			extensions = {
				["ui-select"] = {
					require("telescope.themes").get_dropdown(),
				},
			},
			git_files = {
				previewer = false,
			},
		})

		-- Enable telescope fzf native, if installed
		pcall(require("telescope").load_extension, "fzf")
		pcall(require("telescope").load_extension, "ui-select")

		vim.keymap.set("n", "<leader>?", builtin.oldfiles, { desc = "[?] Find recently opened files" })
		vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "[S]earch existing [B]uffers" })
		vim.keymap.set("n", "<leader>sm", builtin.marks, { desc = "[S]earch [M]arks" })
		vim.keymap.set("n", "<leader>gf", builtin.git_files, { desc = "Search [G]it [F]iles" })
		vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "Search [G]it [C]ommits" })
		vim.keymap.set("n", "<leader>gcf", builtin.git_bcommits, { desc = "Search [G]it [C]ommits for current [F]ile" })
		vim.keymap.set("n", "<leader>gb", builtin.git_branches, { desc = "Search [G]it [B]ranches" })
		vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "Search [G]it [S]tatus (diff view)" })
		vim.keymap.set("n", ";f", builtin.find_files, { desc = "[S]earch [F]iles" })
		vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
		vim.keymap.set("n", ";w", builtin.grep_string, { desc = "[S]earch current [W]ord" })
		vim.keymap.set("n", ";g", builtin.live_grep, { desc = "[S]earch by [G]rep" })
		vim.keymap.set("n", ";d", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
		vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]resume" })
		vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
		vim.keymap.set("n", "<leader>sds", function()
			builtin.lsp_document_symbols({
				symbols = { "Class", "Function", "Method", "Constructor", "Interface", "Module", "Property" },
			})
		end, { desc = "[S]each LSP document [S]ymbols" })

		-- Custom LSP references with vertical layout for better Java file visibility
		vim.keymap.set("n", "ghr", function()
			builtin.lsp_references({
				layout_strategy = "vertical",
				layout_config = {
					vertical = {
						width = 0.95,
						height = 0.95,
						preview_height = 0.6,
						prompt_position = "bottom",
					},
				},
				path_display = function(opts, path)
					-- Custom path display for better Java file visibility
					local tail = require("telescope.utils").path_tail(path)
					local parent = vim.fn.fnamemodify(path, ":h:t")
					if parent and parent ~= "." then
						return string.format("%s/%s", parent, tail)
					else
						return tail
					end
				end,
				show_line = true,
				trim_text = true,
				include_declaration = false,
				include_current_line = false,
				fname_width = 60,
				results_title = "References",
				prompt_title = "Find References (Vertical)",
			})
		end, { desc = "LSP References (Vertical Layout)" })

		vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
		vim.keymap.set("n", "<leader>s/", function()
			builtin.live_grep({
				grep_open_files = true,
				prompt_title = "Live Grep in Open Files",
			})
		end, { desc = "[S]earch [/] in Open Files" })
		vim.keymap.set("n", "<leader>/", function()
			-- You can pass additional configuration to telescope to change theme, layout, etc.
			builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
				previewer = false,
			}))
		end, { desc = "[/] Fuzzily search in current buffer" })
	end,
}

