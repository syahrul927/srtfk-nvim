local jdtls_dir = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
local config_dir = jdtls_dir .. "/config_mac_arm"
local plugins_dir = jdtls_dir .. "/plugins"
local path_to_jar = plugins_dir .. "/org.eclipse.equinox.launcher_1.6.900.v20240613-2009.jar"
local lombok_dir = jdtls_dir .. "/lombok.jar"
local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
local root_dir = require("jdtls.setup").find_root(root_markers)
if root_dir == "" then
	return
end
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath("data") .. "/site/java/workspace-root/" .. project_name

local on_attach = function(client, bufnr)
	local function buf_set_option(...)
		vim.api.nvim_buf_set_option(bufnr, ...)
	end

	-- Enable completion triggered by <c-x><c-o>
	buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

	-- Ensure we use the global handlers for progress messages
	client.server_capabilities.window = client.server_capabilities.window or {}
	client.server_capabilities.window.workDoneProgress = true

	-- Mappings.
	local opts = { noremap = true, silent = true }

	-- buf_set_keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
	-- buf_set_keymap("n", "<leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
	-- buf_set_keymap("n", "<leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
	-- buf_set_keymap("n", "<leader>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
	-- buf_set_keymap("n", "<leader>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
	-- buf_set_keymap("n", "<leader>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
	-- buf_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
	-- buf_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
	-- buf_set_keymap("n", "<leader>q", "<cmd>lua vim.diagnostic.set_loclist()<CR>", opts)
	-- buf_set_keymap("n", "<leader>fm", "<cmd>lua vim.lsp.buf.format { async = true} <CR>", opts)

	-- Java Ones

	-- DAP
	-- jdtls.setup_dap({ hotcodereplace = 'auto' })
	-- jdtls.setup_dap()

	-- local dap = require('dap')
	-- dap.configurations.java = {
	--   {
	--     type = 'java';
	--     request = 'attach';
	--     name = "Debug (Attach) - Remote";
	--     hostName = "127.0.0.1";
	--     port = 5005;
	--   },
	-- }
end
-- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
local config = {
	-- The command that starts the language server
	-- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
	cmd = {
		--
		"java", -- or '/path/to/java17_or_newer/bin/java'
		-- depends on if `java` is in your $PATH env variable and if it points to the right version.
		-- config java 8 command
		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=false",
		"-Dlog.level=WARNING",
		"-javaagent:" .. lombok_dir,
		-- Memory and Performance Optimizations
		"-Xms2g",                                    -- Initial heap size (reduced from 3g for faster startup)
		"-Xmx8g",                                    -- Maximum heap size (adjust based on your system RAM)
		"-XX:+UseG1GC",                              -- Use G1 garbage collector for better performance
		"-XX:+UseStringDeduplication",               -- Reduce memory usage by deduplicating strings
		"-XX:MaxGCPauseMillis=200",                  -- Target max GC pause time
		"-Djava.awt.headless=true",                  -- Headless mode for better performance
		"-Dfile.encoding=UTF-8",                     -- Explicit encoding
		"-XX:+TieredCompilation",                    -- Enable tiered compilation
		"-XX:TieredStopAtLevel=4",                   -- Use highest tier compilation
		"-XX:+UseCompressedOops",                    -- Use compressed object pointers for memory efficiency
		"-XX:+UseCompressedClassPointers",           -- Use compressed class pointers
		"-XX:ReservedCodeCacheSize=512m",            -- Increase code cache for better JIT performance
		"--add-modules=ALL-SYSTEM",
		"--add-opens",
		"java.base/java.util=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.lang=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.io=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.nio=ALL-UNNAMED",
		"-jar",
		path_to_jar,
		-- Must point to the eclipse.jdt.ls installation
		"-configuration",
		config_dir,
		-- Must point to the eclipse.jdt.ls installation
		-- Change to one of `linux`, `win` or `mac` depending on your system.
		-- See `data directory configuration` section in the README
		"-data",
		workspace_dir,
	},
	-- on attach add function keymap
	on_attach = on_attach,
	-- This is the default if not provided, you can remove it. Or adjust as needed.
	-- One dedicated LSP server & client will be started per unique root_dir
	-- root_dir = root_dir,
	root_dir = vim.fn.getcwd(),
	-- Here you can configure eclipse.jdt.ls specific settings
	-- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
	-- for a list of options
	settings = {
		java = {
			-- Performance optimizations
			autobuild = { enabled = false },                    -- Disable auto-build for better performance
			maxConcurrentBuilds = 2,                           -- Limit concurrent builds
			
			-- Code completion optimizations
			completion = {
				maxResults = 50,                               -- Limit completion results
				enabled = true,
				guessMethodArguments = false,                  -- Disable argument guessing for speed
				favoriteStaticMembers = {
					"org.junit.Assert.*",
					"org.junit.Assume.*",
					"org.junit.jupiter.api.Assertions.*",
					"org.junit.jupiter.api.Assumptions.*",
					"org.junit.jupiter.api.DynamicContainer.*",
					"org.junit.jupiter.api.DynamicTest.*",
					"org.mockito.Mockito.*",
					"org.mockito.ArgumentMatchers.*",
				},
			},
			
			-- Import optimizations
			imports = {
				gradle = { enabled = false },                  -- Disable gradle imports if not needed
				maven = { enabled = true },
				includeDecompiledSources = false,              -- Faster startup
			},
			
			-- Format settings
			format = {
				enabled = true,
				settings = {
					url = vim.fn.stdpath("config") .. "/lang-servers/eclipse-java-google-style.xml",
					profile = "GoogleStyle",
				},
			},
			
			-- Disable resource filters for better performance
			eclipse = {
				downloadSources = false,                       -- Don't auto-download sources
			},
			
			-- Maven settings
			maven = {
				downloadSources = false,                       -- Don't auto-download sources
				updateSnapshots = false,                       -- Don't auto-update snapshots
			},
			
			-- References and implementations
			references = {
				includeDecompiledSources = false,              -- Faster reference search
			},
			
			-- Signature help optimization
			signatureHelp = {
				enabled = true,
				description = { enabled = false },             -- Disable descriptions for speed
			},
			
			-- Content provider optimizations
			contentProvider = {
				preferred = "fernflower",                      -- Faster decompiler
			},
			
			-- Sources organization
			sources = {
				organizeImports = {
					starThreshold = 99,                        -- Reduce star imports
					staticStarThreshold = 99,
				},
			},
			
			-- Disable unnecessary features
			implementationsCodeLens = { enabled = false },     -- Disable code lens for performance
			referencesCodeLens = { enabled = false },
			
			-- configuration = {
			--   runtimes = {
			--     {
			--       name = "JavaSE-1.8",
			--       path = "/home/srtfk/.sdkman/candidates/java/8.0.345-tem/"
			--     }
			--   }
			-- }
		},
	},
	-- Language server `initializationOptions`
	-- You need to extend the `bundles` with paths to jar files
	-- if you want to use additional eclipse.jdt.ls plugins.
	--
	-- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
	--
	-- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
	init_options = {
		bundles = {},
	},
}
-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
require("jdtls").start_or_attach(config)