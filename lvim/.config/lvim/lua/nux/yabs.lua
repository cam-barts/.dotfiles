require("yabs"):setup({
	languages = { -- List of languages in vim's `filetype` format
		python = { tasks = { run_python_file = { command = "python %", output = "terminal" } } },
		-- lua = {
		-- 	tasks = {
		-- 		run = {
		-- 			command = "luafile %", -- The command to run (% and other
		-- 			-- wildcards will be automatically
		-- 			-- expanded)
		-- 			type = "vim", -- The type of command (can be `vim`, `lua`, or
		-- 			-- `shell`, default `shell`)
		-- 		},
		-- 	},
		-- },
		-- c = {
		-- 	default_task = "build_and_run",
		-- 	tasks = {
		-- 		build = {
		-- 			command = "gcc main.c -o main",
		-- 			output = "quickfix", -- Where to show output of the
		-- 			-- command. Can be `buffer`,
		-- 			-- `consolation`, `echo`,
		-- 			-- `quickfix`, `terminal`, or `none`
		-- 			opts = { -- Options for output (currently, there's only
		-- 				-- `open_on_run`, which defines the behavior
		-- 				-- for the quickfix list opening) (can be
		-- 				-- `never`, `always`, or `auto`, the default)
		-- 				open_on_run = "always",
		-- 			},
		-- 		},
		-- 		run = { -- You can specify as many tasks as you want per
		-- 			-- filetype
		-- 			command = "./main",
		-- 			output = "terminal",
		-- 		},
		-- 		build_and_run = { -- Setting the type to lua means the command
		-- 			-- is a lua function
		-- 			command = function()
		-- 				-- The following api can be used to run a task when a
		-- 				-- previous one finishes
		-- 				-- WARNING: this api is experimental and subject to
		-- 				-- changes
		-- 				require("yabs"):run_task("build", {
		-- 					-- Job here is a plenary.job object that represents
		-- 					-- the finished task, read more about it here:
		-- 					-- https://github.com/nvim-lua/plenary.nvim#plenaryjob
		-- 					on_exit = function(Job, exit_code)
		-- 						-- The parameters `Job` and `exit_code` are optional,
		-- 						-- you can omit extra arguments or
		-- 						-- skip some of them using _ for the name
		-- 						if exit_code == 0 then
		-- 							require("yabs").languages.c:run_task("run")
		-- 						end
		-- 					end,
		-- 				})
		-- 			end,
		-- 			type = "lua",
		-- 		},
		-- 	},
		-- },
	},
	tasks = { -- Same values as `language.tasks`, but global
		Zen_of_Python = { command = "python -c 'import this'", output = "echo" },
		Docker_Processes = { command = "docker ps", output = "echo" },
		Docker_Containers = { command = "docker container ls", output = "echo" },
		Docker_Images = { command = "docker image ls", output = "echo" },
		Docker_Cleanup = { command = "docker container prune -f && docker image prune -a", output = "terminal" },
		-- 	build = {
		-- 		command = "echo building project...",
		-- 		output = "terminal",
		-- 	},
		-- 	run = {
		-- 		command = "echo running project...",
		-- 		output = "echo",
		-- 	},
		Docker_Compose_Pull = {
			command = "docker-compose pull",
			output = "echo",
			condition = require("yabs.conditions").file_exists("docker-compose.yml"),
		},
		Docker_Compose_Build = {
			command = "docker-compose build",
			output = "echo",
			condition = require("yabs.conditions").file_exists("docker-compose.yml"),
		},
		Docker_Compose_Up = {
			command = "docker-compose up --remove-orphans --force-recreate",
			output = "terminal",
			condition = require("yabs.conditions").file_exists("docker-compose.yml"),
		},
		Docker_Compose_Up_Daemon = {
			command = "docker-compose up --remove-orphans --force-recreate -d",
			output = "terminal",
			condition = require("yabs.conditions").file_exists("docker-compose.yml"),
		},
		Docker_Compose_Down = {
			command = "docker-compose down",
			output = "echo",
			condition = require("yabs.conditions").file_exists("docker-compose.yml"),
		},

		Docker_Compose_Restart = {
			command = "docker-compose restart",
			output = "echo",
			condition = require("yabs.conditions").file_exists("docker-compose.yml"),
		},
		Docker_Compose_Logs = {
			command = "docker-compose logs -f --tail 20",
			output = "terminal",
			condition = require("yabs.conditions").file_exists("docker-compose.yml"),
		},
		Docker_Compose_Rm = {
			command = "docker-compose rm",
			output = "terminal",
			condition = require("yabs.conditions").file_exists("docker-compose.yml"),
		},
		-- TODO: Create Optional Tasks For Pipfile

		-- optional = {
		-- command = "echo runs on condition",
		-- output = "terminal",
		-- You can specify a condition which determines whether to enable a
		-- specific task
		-- It should be a function that returns boolean,
		-- not a boolean directly
		-- Here we use a helper from yabs that returns such function
		-- to check if the files exists
		-- condition = require("yabs.conditions").file_exists("filename.txt"),
		-- },
		-- },
		-- opts = { -- Same values as `language.opts`
		-- 	output_types = {
		-- 		quickfix = {
		-- 			open_on_run = "always",
		-- 		},
		-- 	},
	},
})
