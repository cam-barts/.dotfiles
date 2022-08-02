require("nux.options")
-- require("nux.plugins")
require("nux.keymaps")
require("nux.autocmd")

-- additional plugins
lvim.plugins = {
	{
		"folke/todo-comments.nvim",
		event = "BufRead",
		config = function()
			require("todo-comments").setup()
		end,
	},
	{ "folke/trouble.nvim", cmd = "TroubleToggle" },
	{
		"windwp/nvim-ts-autotag",
		event = "InsertEnter",
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},
	{ "p00f/nvim-ts-rainbow" },
	-- { "metakirby5/codi.vim", cmd = "Codi" },
	{
		"Pocco81/AutoSave.nvim",
		config = function()
			require("autosave").setup()
		end,
	},
	{
		"iamcco/markdown-preview.nvim",
		run = "cd app && npm install",
		ft = "markdown",
		config = function()
			vim.g.mkdp_auto_start = 1
		end,
	},
	{ "felipec/vim-sanegx", event = "BufRead" },
	{ "sudormrfbin/cheatsheet.nvim" },
	{ "ThePrimeagen/vim-be-good" },
	{ "tpope/vim-repeat" },
	{ "andweeb/presence.nvim" },
	{ "Mofiqul/vscode.nvim" },
	{ "mattn/emmet-vim" },
	{ "Glench/Vim-Jinja2-Syntax" },
	{ "lambdalisue/suda.vim" },
	{
		"itchyny/vim-cursorword",
		event = { "BufEnter", "BufNewFile" },
		config = function()
			vim.api.nvim_command("augroup user_plugin_cursorword")
			vim.api.nvim_command("autocmd!")
			vim.api.nvim_command("autocmd FileType NvimTree,lspsagafinder,dashboard,vista let b:cursorword = 0")
			vim.api.nvim_command("autocmd WinEnter * if &diff || &pvw | let b:cursorword = 0 | endif")
			vim.api.nvim_command("autocmd InsertEnter * let b:cursorword = 0")
			vim.api.nvim_command("autocmd InsertLeave * let b:cursorword = 1")
			vim.api.nvim_command("augroup END")
		end,
	},
	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup({ "*" }, {
				RGB = true, -- #RGB hex codes
				RRGGBB = true, -- #RRGGBB hex codes
				RRGGBBAA = true, -- #RRGGBBAA hex codes
				rgb_fn = true, -- CSS rgb() and rgba() functions
				hsl_fn = true, -- CSS hsl() and hsla() functions
				css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
				css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
			})
		end,
	},
	{
		"ahmedkhalf/lsp-rooter.nvim",
		event = "BufRead",
		config = function()
			require("lsp-rooter").setup()
		end,
	},
	{ "HallerPatrick/py_lsp.nvim" },
	{ "akinsho/toggleterm.nvim" },
	{
		"pianocomposer321/yabs.nvim",
	},
	{ "NTBBloodbath/rest.nvim" },
	{ "NoahTheDuke/vim-just" },
	{ "IndianBoy42/tree-sitter-just" },
	{
		"simrat39/rust-tools.nvim",
		config = function()
			local lsp_installer_servers = require("nvim-lsp-installer.servers")
			local _, requested_server = lsp_installer_servers.get_server("rust_analyzer")
			require("rust-tools").setup({
				tools = {
					autoSetHints = true,
					hover_with_actions = true,
					runnables = {
						use_telescope = true,
					},
				},
				server = {
					cmd_env = requested_server._default_options.cmd_env,
					on_attach = require("lvim.lsp").common_on_attach,
					on_init = require("lvim.lsp").common_on_init,
				},
			})
		end,
		ft = { "rust", "rs" },
	},
}

local formatters = require("lvim.lsp.null-ls.formatters")
formatters.setup({
	{ exe = "black", filetypes = { "python" } },
	{ exe = "isort", filetypes = { "python" } },
	{ exe = "prettier" },
	{ exe = "stylua" },
	{ exe = "rustfmt", filetypes = { "rust" } },
})

require("py_lsp").setup({
	-- This is optional, but allows to create virtual envs from nvim
	host_python = "/usr/bin/python",
})

require("nux.yabs")
lvim.builtin.telescope.on_config_done = function(telescope)
	pcall(telescope.load_extension, "yabs")
	-- any other extensions loading
end

vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "rust_analyzer" })
