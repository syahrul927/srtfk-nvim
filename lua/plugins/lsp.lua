return { -- LSP Configuration & Plugins
	"neovim/nvim-lspconfig",
	dependencies = {
		-- Automatically install LSPs and related tools to stdpath for neovim
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",

		-- Useful status updates for LSP.
		-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
		{
			"j-hui/fidget.nvim",
			tag = "v1.4.0",
			opts = {
				progress = {
					display = {
						done_icon = "✓", -- Icon shown when all LSP progress tasks are complete
					},
				},
				notification = {
					window = {
						winblend = 0, -- Background color opacity in the notification window
					},
				},
			},
		},
	},
	config = function()
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
			-- Create a function that lets us more easily define mappings specific LSP related items.
			-- It sets the mode, buffer and description for us each time.
			callback = function(event)
				local map = function(keys, func, desc)
					vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end

				local bufnr = event.buf

				local function go_to_implementation()
					local lsp = vim.lsp

					-- Request implementations from the LSP server
					lsp.buf_request(
						0, -- Current buffer
						"textDocument/implementation",
						lsp.util.make_position_params(),
						function(err, result)
							if err then
								vim.notify("Error fetching implementations: " .. err.message, vim.log.levels.ERROR)
								return
							end

							if not result or vim.tbl_isempty(result) then
								vim.notify("No implementations found", vim.log.levels.INFO)
								return
							end

							if #result == 1 then
								-- Jump directly to the implementation if only one result
								lsp.util.jump_to_location(result[1])
							else
								require("lspsaga.finder"):new({ "imp" })
							end
						end
					)
				end
				local organize_imports_map = {
					ts_ls = function()
						local params = {
							command = "_typescript.organizeImports",
							arguments = { vim.api.nvim_buf_get_name(bufnr) },
						}

						vim.lsp.buf_request(bufnr, "workspace/executeCommand", params, function(err, _, result)
							if err then
								print("Error organizing imports (tsserver):", err)
							else
								print("Imports organized (tsserver)!")
							end
						end)
					end,

					jdtls = function()
						vim.lsp.buf_request(bufnr, "workspace/executeCommand", {
							command = "java.edit.organizeImports",
						}, function(err, _, result)
							if err then
								print("Error organizing imports (jdtls):", err)
							else
								print("Imports organized (jdtls)!")
							end
						end)
					end,
				}

				-- Set keymap for organizing imports
				vim.keymap.set("n", "<leader>co", function()
					local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
					local handled = false

					for _, client in pairs(clients) do
						local organize_fn = organize_imports_map[client.name]
						if organize_fn then
							organize_fn()
							handled = true
							break
						end
					end

					if not handled then
						print("No supported LSP client for organizing imports: " .. client.name)
					end
				end, { buffer = bufnr, desc = "Organize Imports" })
				--lspsaga
				map("gh", "<cmd>Lspsaga finder ref<CR>", "Find references")
				map("gr", "<cmd>Lspsaga rename<CR>", "Rename")
				map("gp", "<cmd>Lspsaga peek_definition<CR>", "Peek Definition")
				map("gi", go_to_implementation, "Goto Implementation")
				map("gd", "<cmd>Lspsaga goto_definition<CR>", "Goto Definition")
				map("gD", "<cmd>Lspsaga goto_type_definition<CR>", "Goto Type Definition")
				map("K", "<cmd>Lspsaga hover_doc<cr>", "Hover Document")
				map("<leader>ca", "<cmd>Lspsaga code_action<CR>", "Code Action")
				map("<leader>o", "<cmd>Lspsaga outline<CR>", "Outline")
				map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
				map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
				map("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
				map("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
				map("<leader>wl", function()
					print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
				end, "[W]orkspace [L]ist Folders")

				-- goto error
				map(
					"]e",
					"<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.ERROR})<CR>",
					"Goto Next Error"
				)
				map(
					"[e",
					"<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.ERROR})<CR>",
					"Goto Prev Error"
				)

				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if client and client.server_capabilities.documentHighlightProvider then
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = event.buf,
						callback = vim.lsp.buf.document_highlight,
					})

					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = event.buf,
						callback = vim.lsp.buf.clear_references,
					})
				end
			end,
		})

		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

		-- Enable the following language servers
		local servers = {
			-- jdtls = {
			-- 	filetypes = { "java" },
			-- 	cmd = {
			-- 		"java",
			-- 		"-javaagent:" .. vim.fn.expand("~/.local/share/java/lombok.jar"), -- Add Lombok agent
			-- 		"-Xms1g", -- Minimum heap size
			-- 		"-Xmx3g", -- Maximum heap size
			-- 		"-Djava.version=8", -- Ensure Java 8 compatibility
			-- 		"-jar",
			-- 		vim.fn.expand(
			-- 			"~/.local/share/nvim/mason/share/jdtls/plugins/org.eclipse.equinox.launcher_1.6.900.v20240613-2009.jar"
			-- 		),
			-- 		"-configuration",
			-- 		vim.fn.expand("~/.local/share/nvim/mason/share/jdtls/config"),
			-- 		"-data",
			-- 		vim.fn.stdpath("data") .. "/jdtls/workspace",
			-- 	},
			-- },
			html = { filetypes = { "html", "twig", "hbs" } },
			-- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
			ts_ls = {
				filetypes = { "typescript", "typescriptreact", "javascript" },
			},
			prismals = {},
			lua_ls = {
				-- cmd = {...},
				-- filetypes { ...},
				-- capabilities = {},
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						workspace = {
							checkThirdParty = false,
							-- Tells lua_ls where to find all the Lua files that you have loaded
							-- for your neovim configuration.
							library = {
								"${3rd}/luv/library",
								unpack(vim.api.nvim_get_runtime_file("", true)),
							},
							-- If lua_ls is really slow on your computer, you can try this instead:
							-- library = { vim.env.VIMRUNTIME },
						},
						completion = {
							callSnippet = "Replace",
						},
						telemetry = { enable = false },
						diagnostics = { disable = { "missing-fields" } },
					},
				},
			},
			dockerls = {},
			docker_compose_language_service = {},
			pylsp = {
				settings = {
					pylsp = {
						plugins = {
							pyflakes = { enabled = false },
							pycodestyle = { enabled = false },
							autopep8 = { enabled = false },
							yapf = { enabled = false },
							mccabe = { enabled = false },
							pylsp_mypy = { enabled = false },
							pylsp_black = { enabled = false },
							pylsp_isort = { enabled = false },
						},
					},
				},
			},
			-- basedpyright = {
			--   -- Config options: https://github.com/DetachHead/basedpyright/blob/main/docs/settings.md
			--   settings = {
			--     basedpyright = {
			--       disableOrganizeImports = true, -- Using Ruff's import organizer
			--       disableLanguageServices = false,
			--       analysis = {
			--         ignore = { '*' },                 -- Ignore all files for analysis to exclusively use Ruff for linting
			--         typeCheckingMode = 'off',
			--         diagnosticMode = 'openFilesOnly', -- Only analyze open files
			--         useLibraryCodeForTypes = true,
			--         autoImportCompletions = true,     -- whether pyright offers auto-import completions
			--       },
			--     },
			--   },
			-- },
			ruff = {
				-- Notes on code actions: https://github.com/astral-sh/ruff-lsp/issues/119#issuecomment-1595628355
				-- Get isort like behavior: https://github.com/astral-sh/ruff/issues/8926#issuecomment-1834048218
				commands = {
					RuffAutofix = {
						function()
							vim.lsp.buf.execute_command({
								command = "ruff.applyAutofix",
								arguments = {
									{ uri = vim.uri_from_bufnr(0) },
								},
							})
						end,
						description = "Ruff: Fix all auto-fixable problems",
					},
					RuffOrganizeImports = {
						function()
							vim.lsp.buf.execute_command({
								command = "ruff.applyOrganizeImports",
								arguments = {
									{ uri = vim.uri_from_bufnr(0) },
								},
							})
						end,
						description = "Ruff: Format imports",
					},
				},
			},
			rust_analyzer = {
				["rust-analyzer"] = {
					cargo = {
						features = "all",
					},
					checkOnSave = true,
					check = {
						command = "clippy",
					},
				},
			},
			tailwindcss = {},
			jsonls = {},
			sqlls = {},
			terraformls = {},
			yamlls = {},
			bashls = {},
			graphql = {},
			cssls = {},
			ltex = {},
			texlab = {},
		}

		-- Ensure the servers and tools above are installed
		require("mason").setup()

		-- You can add other tools here that you want Mason to install
		-- for you, so that they are available from within Neovim.
		local ensure_installed = vim.tbl_keys(servers or {})
		vim.list_extend(ensure_installed, {
			"stylua", -- Used to format lua code
		})
		require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

		require("mason-lspconfig").setup({
			handlers = {
				function(server_name)
					if server_name == "jdtls" then
						return
					end
					local server = servers[server_name] or {}
					-- This handles overriding only values explicitly passed
					-- by the server configuration above. Useful when disabling
					-- certain features of an LSP (for example, turning off formatting for tsserver)
					server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})

					require("lspconfig")[server_name].setup(server)
				end,
			},
		})
	end,
}
