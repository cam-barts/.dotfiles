--[[
  Cam's Neovim Config
  Based on kickstart.nvim, migrated from AstroNvim v4.
  Single-file config using lazy.nvim.
--]]

-- Set <space> as the leader key (must happen before plugins load)
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Nerd Font is available
vim.g.have_nerd_font = true

-- [[ Options ]]
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.o.showmode = false
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = "yes"
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.o.inccommand = "split"
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.o.wrap = false
vim.opt.colorcolumn = "88"
vim.o.conceallevel = 0

-- Sync clipboard after UiEnter to avoid slow startup
vim.schedule(function() vim.o.clipboard = "unnamedplus" end)

-- [[ Diagnostics ]]
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
  underline = true,
  virtual_text = true,
  virtual_lines = false,
  jump = { float = true },
}

-- [[ Basic Keymaps ]]
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Disable arrow keys (get gud nerd)
vim.keymap.set("n", "<up>", "<nop>", { desc = "Get Gud Nerd" })
vim.keymap.set("n", "<down>", "<nop>", { desc = "Get Gud Nerd" })
vim.keymap.set("n", "<left>", "<nop>", { desc = "Get Gud Nerd" })
vim.keymap.set("n", "<right>", "<nop>", { desc = "Get Gud Nerd" })

-- Window navigation with Ctrl+hjkl
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Buffer navigation (ported from astrocore)
vim.keymap.set("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "[b", "<cmd>bprevious<CR>", { desc = "Previous buffer" })

-- [[ Autocommands ]]
-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- [[ Install lazy.nvim ]]
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system { "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then error("Error cloning lazy.nvim:\n" .. out) end
end
---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- [[ Plugins ]]
require("lazy").setup({

  -- ============================================================
  -- CORE: guess-indent
  -- ============================================================
  { "NMAC427/guess-indent.nvim", opts = {} },

  -- ============================================================
  -- GIT: gitsigns (with kickstart recommended keymaps + line blame)
  -- ============================================================
  {
    "lewis6991/gitsigns.nvim",
    ---@module 'gitsigns'
    ---@type Gitsigns.Config
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      current_line_blame = true,
      signs = {
        add = { text = "+" }, ---@diagnostic disable-line: missing-fields
        change = { text = "~" }, ---@diagnostic disable-line: missing-fields
        delete = { text = "_" }, ---@diagnostic disable-line: missing-fields
        topdelete = { text = "‾" }, ---@diagnostic disable-line: missing-fields
        changedelete = { text = "~" }, ---@diagnostic disable-line: missing-fields
      },
      on_attach = function(bufnr)
        local gitsigns = require "gitsigns"
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal { "]c", bang = true }
          else
            gitsigns.nav_hunk "next"
          end
        end, { desc = "Jump to next git [c]hange" })

        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal { "[c", bang = true }
          else
            gitsigns.nav_hunk "prev"
          end
        end, { desc = "Jump to previous git [c]hange" })

        -- Actions
        map(
          "v",
          "<leader>hs",
          function() gitsigns.stage_hunk { vim.fn.line ".", vim.fn.line "v" } end,
          { desc = "git [s]tage hunk" }
        )
        map(
          "v",
          "<leader>hr",
          function() gitsigns.reset_hunk { vim.fn.line ".", vim.fn.line "v" } end,
          { desc = "git [r]eset hunk" }
        )
        map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "git [s]tage hunk" })
        map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "git [r]eset hunk" })
        map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "git [S]tage buffer" })
        map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "git [R]eset buffer" })
        map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "git [p]review hunk" })
        map("n", "<leader>hi", gitsigns.preview_hunk_inline, { desc = "git preview hunk [i]nline" })
        map("n", "<leader>hb", function() gitsigns.blame_line { full = true } end, { desc = "git [b]lame line" })
        map("n", "<leader>hd", gitsigns.diffthis, { desc = "git [d]iff against index" })
        map("n", "<leader>hD", function() gitsigns.diffthis "@" end, { desc = "git [D]iff against last commit" })
        map(
          "n",
          "<leader>hQ",
          function() gitsigns.setqflist "all" end,
          { desc = "git hunk [Q]uickfix list (all files)" }
        )
        map("n", "<leader>hq", gitsigns.setqflist, { desc = "git hunk [q]uickfix list (this file)" })

        -- Toggles
        map("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "[T]oggle git show [b]lame line" })
        map("n", "<leader>tw", gitsigns.toggle_word_diff, { desc = "[T]oggle git intra-line [w]ord diff" })

        -- Text object
        map({ "o", "x" }, "ih", gitsigns.select_hunk)
      end,
    },
  },

  -- ============================================================
  -- UI: which-key
  -- ============================================================
  {
    "folke/which-key.nvim",
    event = "VimEnter",
    ---@module 'which-key'
    ---@type wk.Opts
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      delay = 0,
      icons = { mappings = vim.g.have_nerd_font },
      spec = {
        { "<leader>f", group = "[F]ind (AstroNvim)", mode = { "n" } },
        { "<leader>s", group = "[S]earch", mode = { "n", "v" } },
        { "<leader>t", group = "[T]oggle" },
        { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
        { "<leader>b", group = "[B]uffer" },
        { "<leader>d", group = "[D]ebug" },
        { "<leader>x", group = "Trouble" },
        { "<leader>l", group = "[L]SP" },
        { "gr", group = "LSP Actions", mode = { "n" } },
      },
    },
  },

  -- ============================================================
  -- SEARCH: telescope
  -- ============================================================
  {
    "nvim-telescope/telescope.nvim",
    enabled = true,
    event = "VimEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function() return vim.fn.executable "make" == 1 end,
      },
      { "nvim-telescope/telescope-ui-select.nvim" },
      { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
    },
    config = function()
      require("telescope").setup {
        extensions = {
          ["ui-select"] = { require("telescope.themes").get_dropdown() },
        },
      }

      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "ui-select")

      local builtin = require "telescope.builtin"
      -- Kickstart-style search keymaps (leader-s prefix)
      vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
      vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
      vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
      vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
      vim.keymap.set({ "n", "v" }, "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
      vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
      vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
      vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
      vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set("n", "<leader>sc", builtin.commands, { desc = "[S]earch [C]ommands" })
      vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

      -- AstroNvim-style aliases (leader-f prefix) for muscle memory
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[F]ind [F]iles" })
      vim.keymap.set(
        "n",
        "<leader>fF",
        function() builtin.find_files { hidden = true, no_ignore = true } end,
        { desc = "[F]ind all [F]iles (hidden+ignored)" }
      )
      vim.keymap.set("n", "<leader>fw", builtin.live_grep, { desc = "[F]ind [W]ords (grep)" })
      vim.keymap.set("n", "<leader>fW", function()
        builtin.live_grep {
          additional_args = function() return { "--hidden", "--no-ignore" } end,
        }
      end, { desc = "[F]ind all [W]ords (hidden+ignored)" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[F]ind [B]uffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[F]ind [H]elp" })
      vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "[F]ind [O]ld files" })
      vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "[F]ind [K]eymaps" })
      vim.keymap.set("n", "<leader>fc", builtin.commands, { desc = "[F]ind [C]ommands" })
      vim.keymap.set("n", "<leader>fq", builtin.quickfix, { desc = "[F]ind [Q]uickfix" })
      vim.keymap.set(
        "n",
        "<leader>fn",
        function() builtin.find_files { cwd = vim.fn.stdpath "config" } end,
        { desc = "[F]ind [N]eovim files" }
      )

      -- LSP keymaps on attach (telescope-powered)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("telescope-lsp-attach", { clear = true }),
        callback = function(event)
          local buf = event.buf
          vim.keymap.set("n", "grr", builtin.lsp_references, { buffer = buf, desc = "[G]oto [R]eferences" })
          vim.keymap.set("n", "gri", builtin.lsp_implementations, { buffer = buf, desc = "[G]oto [I]mplementation" })
          vim.keymap.set("n", "grd", builtin.lsp_definitions, { buffer = buf, desc = "[G]oto [D]efinition" })
          vim.keymap.set("n", "gO", builtin.lsp_document_symbols, { buffer = buf, desc = "Open Document Symbols" })
          vim.keymap.set(
            "n",
            "gW",
            builtin.lsp_dynamic_workspace_symbols,
            { buffer = buf, desc = "Open Workspace Symbols" }
          )
          vim.keymap.set("n", "grt", builtin.lsp_type_definitions, { buffer = buf, desc = "[G]oto [T]ype Definition" })
        end,
      })

      -- Fuzzy search in current buffer
      vim.keymap.set(
        "n",
        "<leader>/",
        function()
          builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown {
            winblend = 10,
            previewer = false,
          })
        end,
        { desc = "[/] Fuzzily search in current buffer" }
      )

      -- Live grep in open files
      vim.keymap.set(
        "n",
        "<leader>s/",
        function()
          builtin.live_grep {
            grep_open_files = true,
            prompt_title = "Live Grep in Open Files",
          }
        end,
        { desc = "[S]earch [/] in Open Files" }
      )

      -- Search neovim config files
      vim.keymap.set(
        "n",
        "<leader>sn",
        function() builtin.find_files { cwd = vim.fn.stdpath "config" } end,
        { desc = "[S]earch [N]eovim files" }
      )
    end,
  },

  -- ============================================================
  -- LSP
  -- ============================================================
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      { "j-hui/fidget.nvim", opts = {} },
    },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          -- AstroNvim-style LSP keymaps (leader-l prefix) for muscle memory
          map("<leader>la", vim.lsp.buf.code_action, "[L]SP Code [A]ction")
          map("<leader>lr", vim.lsp.buf.rename, "[L]SP [R]ename")
          map("<leader>lf", function() vim.lsp.buf.format { async = true } end, "[L]SP [F]ormat")
          map("<leader>ld", vim.diagnostic.open_float, "[L]SP [D]iagnostic float")
          map("<leader>li", "<cmd>LspInfo<cr>", "[L]SP [I]nfo")
          map("<leader>lS", require("telescope.builtin").lsp_document_symbols, "[L]SP Document [S]ymbols")
          map("<leader>ls", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[L]SP Workspace [s]ymbols")

          map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
          map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
          map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

          -- Document highlight on CursorHold
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method("textDocument/documentHighlight", event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = "kickstart-lsp-highlight", buffer = event2.buf }
              end,
            })
          end

          -- Toggle inlay hints
          if client and client:supports_method("textDocument/inlayHint", event.buf) then
            map(
              "<leader>th",
              function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end,
              "[T]oggle Inlay [H]ints"
            )
          end

          -- Toggle semantic token highlighting (ported from astrolsp)
          if
            client
            and client:supports_method "textDocument/semanticTokens/full"
            and vim.lsp.semantic_tokens ~= nil
          then
            map("<leader>uY", function()
              if client.server_capabilities.semanticTokensProvider then
                client.server_capabilities.semanticTokensProvider = nil
                vim.lsp.semantic_tokens.stop(event.buf, client.id)
              else
                -- Re-request semantic tokens by detaching/reattaching is heavy;
                -- simpler: just tell the user to reload the buffer.
                vim.notify(
                  "Semantic tokens disabled for this session. Reopen buffer to re-enable.",
                  vim.log.levels.INFO
                )
              end
            end, "Toggle LSP semantic highlight (buffer)")
          end
        end,
      })

      -- Server configurations
      ---@type table<string, vim.lsp.Config>
      local servers = {
        -- Pyright (ported from astrolsp)
        pyright = {
          settings = {
            pyright = {
              autoImportCompletion = true,
              openFilesOnly = true,
            },
            python = {
              analysis = {
                autoSearchPaths = true,
                diagnosticMode = "openFilesOnly",
                useLibraryCodeForTypes = true,
                typeCheckingMode = "off",
                venvPath = ".venv",
              },
            },
          },
        },

        -- Oxlint (ported from astrolsp)
        oxlint = {
          workspace_required = false,
        },

        stylua = {}, -- Lua formatter

        -- Lua LS (kickstart default config)
        lua_ls = {
          on_init = function(client)
            client.server_capabilities.documentFormattingProvider = false
            if client.workspace_folders then
              local path = client.workspace_folders[1].name
              if
                path ~= vim.fn.stdpath "config"
                and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
              then
                return
              end
            end
            client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
              runtime = {
                version = "LuaJIT",
                path = { "lua/?.lua", "lua/?/init.lua" },
              },
              workspace = {
                checkThirdParty = false,
                library = vim.tbl_extend("force", vim.api.nvim_get_runtime_file("", true), {
                  "${3rd}/luv/library",
                  "${3rd}/busted/library",
                }),
              },
            })
          end,
          ---@type lspconfig.settings.lua_ls
          settings = {
            Lua = {
              format = { enable = false },
            },
          },
        },
      }

      -- Ensure servers + tools are installed via Mason
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        "debugpy", -- Python debug adapter
      })
      require("mason-tool-installer").setup { ensure_installed = ensure_installed }

      for name, server in pairs(servers) do
        vim.lsp.config(name, server)
        vim.lsp.enable(name)
      end
    end,
  },

  -- ============================================================
  -- FORMATTING: conform.nvim
  -- ============================================================
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>f",
        function() require("conform").format { async = true } end,
        mode = "",
        desc = "[F]ormat buffer",
      },
    },
    ---@module 'conform'
    ---@type conform.setupOpts
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Ported from astrolsp: format on save is enabled globally.
        -- Customize per-filetype here if needed.
        return { timeout_ms = 1000, lsp_format = "fallback" }
      end,
      default_format_opts = {
        lsp_format = "fallback",
      },
      formatters_by_ft = {
        -- Add formatters per filetype as needed
        -- python = { 'black', 'isort' },
      },
    },
  },

  -- ============================================================
  -- COMPLETION: blink.cmp
  -- ============================================================
  {
    "saghen/blink.cmp",
    event = "VimEnter",
    version = "1.*",
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        version = "2.*",
        build = (function()
          if vim.fn.has "win32" == 1 or vim.fn.executable "make" == 0 then return end
          return "make install_jsregexp"
        end)(),
        opts = {},
      },
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = { preset = "default" },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
      },
      sources = { default = { "lsp", "path", "snippets" } },
      snippets = { preset = "luasnip" },
      fuzzy = { implementation = "lua" },
      signature = { enabled = true },
    },
  },

  -- ============================================================
  -- COLORSCHEME: tokyonight
  -- ============================================================
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("tokyonight").setup {
        styles = { comments = { italic = false } },
      }
      vim.cmd.colorscheme "tokyonight-night"
    end,
  },

  -- ============================================================
  -- UI: noice.nvim + nvim-notify (ported from user.lua)
  -- ============================================================
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      lsp = {
        hover = { enabled = false },
        signature = { enabled = false },
      },
      presets = {
        long_message_to_split = true,
      },
      -- Use telescope, not fzf-lua
      picker = "telescope",
    },
  },

  -- ============================================================
  -- UI: nvim-colorizer (color hex codes inline)
  -- ============================================================
  {
    "norcalli/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = {},
  },

  -- ============================================================
  -- UI: bufferline.nvim (lightweight buffer tabs)
  -- ============================================================
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VimEnter",
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        show_buffer_close_icons = false,
        show_close_icon = false,
        separator_style = "slant",
      },
    },
    config = function(_, opts)
      require("bufferline").setup(opts)
      -- Buffer close keymap: close current buffer
      vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "[B]uffer [D]elete" })
    end,
  },

  -- ============================================================
  -- UI: snacks.nvim dashboard
  -- ============================================================
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      dashboard = {
        enabled = true,
        preset = {
          header = [[
   _____ __         __  __          _
  / ___// /______  / /_/ /_  ___  (_)___  _____
  \__ \/ __/ ___/ / __/ __ \/ _ \/ / __ \/ ___/
 ___/ / /_/ /    / /_/ / / /  __/ / / / (__  )
/____/\__/_/     \__/_/ /_/\___/_/_/ /_/____/
          ]],
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ':lua require("telescope.builtin").find_files()' },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ':lua require("telescope.builtin").live_grep()' },
            { icon = " ", key = "r", desc = "Recent Files", action = ':lua require("telescope.builtin").oldfiles()' },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
      -- Disable other snacks modules we don't need
      bigfile = { enabled = false },
      notifier = { enabled = false }, -- using nvim-notify via noice
      quickfile = { enabled = false },
      statuscolumn = { enabled = false },
      words = { enabled = false },
    },
  },

  -- ============================================================
  -- COMMENTS: todo-comments
  -- ============================================================
  {
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      signs = true,
      sign_priority = 8,
      keywords = {
        FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        QUESTION = { icon = "❓", color = "hint" },
        TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
      highlight = {
        multiline = true,
        before = "",
        keyword = "wide",
        after = "fg",
        comments_only = true,
      },
    },
  },

  -- ============================================================
  -- EDITOR: mini.nvim (ai, surround, statusline)
  -- ============================================================
  {
    "nvim-mini/mini.nvim",
    config = function()
      require("mini.ai").setup {
        mappings = { around_next = "aa", inside_next = "ii" },
        n_lines = 500,
      }
      require("mini.surround").setup()

      local statusline = require "mini.statusline"
      statusline.setup { use_icons = vim.g.have_nerd_font }
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function() return "%2l:%-2v" end
    end,
  },

  -- ============================================================
  -- TREESITTER
  -- ============================================================
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    branch = "main",
    config = function()
      local parsers = {
        "bash",
        "c",
        "css",
        "diff",
        "html",
        "javascript",
        "json",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
        "toml",
      }
      require("nvim-treesitter").install(parsers)

      ---@param buf integer
      ---@param language string
      local function treesitter_try_attach(buf, language)
        if not vim.treesitter.language.add(language) then return end
        vim.treesitter.start(buf, language)
        local has_indent_query = vim.treesitter.query.get(language, "indents") ~= nil
        if has_indent_query then vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
      end

      local available_parsers = require("nvim-treesitter").get_available()
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local buf, filetype = args.buf, args.match
          local language = vim.treesitter.language.get_lang(filetype)
          if not language then return end
          local installed_parsers = require("nvim-treesitter").get_installed "parsers"
          if vim.tbl_contains(installed_parsers, language) then
            treesitter_try_attach(buf, language)
          elseif vim.tbl_contains(available_parsers, language) then
            require("nvim-treesitter").install(language):await(function() treesitter_try_attach(buf, language) end)
          else
            treesitter_try_attach(buf, language)
          end
        end,
      })
    end,
  },

  -- ============================================================
  -- LANGUAGE: nvim-ts-autotag (auto close/rename HTML tags)
  -- ============================================================
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },

  -- ============================================================
  -- LANGUAGE: nvim-ts-context-commentstring (context-aware comments)
  -- ============================================================
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    opts = { enable_autocmd = false },
  },

  -- ============================================================
  -- EDITOR: Comment.nvim (integrates with context-commentstring)
  -- ============================================================
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      pre_hook = function(ctx)
        -- Use ts-context-commentstring for JSX/TSX etc.
        local ok, integration = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
        if ok then return integration.create_pre_hook()(ctx) end
      end,
    },
  },

  -- ============================================================
  -- EDITOR: autopairs
  -- ============================================================
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- ============================================================
  -- EDITOR: indent-blankline
  -- ============================================================
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    ---@module 'ibl'
    ---@type ibl.config
    opts = {},
  },

  -- ============================================================
  -- DIAGNOSTICS: trouble.nvim
  -- ============================================================
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
      {
        "<leader>xl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references (Trouble)",
      },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
    },
    opts = {},
  },

  -- ============================================================
  -- DEBUG: nvim-dap + dap-ui (configured for Python/debugpy)
  -- ============================================================
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "mason-org/mason.nvim",
      "jay-babu/mason-nvim-dap.nvim",
      "mfussenegger/nvim-dap-python",
    },
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "Debug: Start/Continue" },
      { "<F1>", function() require("dap").step_into() end, desc = "Debug: Step Into" },
      { "<F2>", function() require("dap").step_over() end, desc = "Debug: Step Over" },
      { "<F3>", function() require("dap").step_out() end, desc = "Debug: Step Out" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
      {
        "<leader>dB",
        function() require("dap").set_breakpoint(vim.fn.input "Breakpoint condition: ") end,
        desc = "Debug: Set Breakpoint",
      },
      { "<F7>", function() require("dapui").toggle() end, desc = "Debug: Toggle DAP UI" },
    },
    config = function()
      local dap = require "dap"
      local dapui = require "dapui"

      require("mason-nvim-dap").setup {
        automatic_installation = true,
        handlers = {},
        ensure_installed = { "debugpy" },
      }

      ---@diagnostic disable-next-line: missing-fields
      dapui.setup {
        icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
        ---@diagnostic disable-next-line: missing-fields
        controls = {
          icons = {
            pause = "⏸",
            play = "▶",
            step_into = "⏎",
            step_over = "⏭",
            step_out = "⏮",
            step_back = "b",
            run_last = "▶▶",
            terminate = "⏹",
            disconnect = "⏏",
          },
        },
      }

      dap.listeners.after.event_initialized["dapui_config"] = dapui.open
      dap.listeners.before.event_terminated["dapui_config"] = dapui.close
      dap.listeners.before.event_exited["dapui_config"] = dapui.close

      -- Python debugger setup via nvim-dap-python
      -- Uses debugpy; will look for python in .venv or system path
      local python_path = vim.fn.getcwd() .. "/.venv/bin/python"
      if vim.fn.executable(python_path) ~= 1 then python_path = "python3" end
      require("dap-python").setup(python_path)
    end,
  },

  -- ============================================================
  -- TERMINAL: toggleterm.nvim
  -- ============================================================
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "[T]oggle [T]erminal", mode = { "n", "t" } },
    },
    opts = {
      open_mapping = false, -- We use our own keymap above
      direction = "float",
      float_opts = { border = "curved" },
    },
  },

  -- ============================================================
  -- NAVIGATION: neo-tree (ported from user.lua — right side, show hidden)
  -- ============================================================
  {
    "nvim-neo-tree/neo-tree.nvim",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    lazy = false,
    keys = {
      { "<leader>e", "<cmd>Neotree right toggle<cr>", desc = "Toggle Explorer (right)", silent = true },
    },
    opts = {
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_hidden = false,
        },
        hijack_netrw_behavior = "open_default",
        window = {
          mappings = {
            ["<leader>e"] = "close_window",
          },
        },
      },
    },
  },

  -- ============================================================
  -- TRACKING: vim-wakatime
  -- ============================================================
  { "wakatime/vim-wakatime", lazy = false },
}, { ---@diagnostic disable-line: missing-fields
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = "⌘",
      config = "🛠",
      event = "📅",
      ft = "📂",
      init = "⚙",
      keys = "🗝",
      plugin = "🔌",
      runtime = "💻",
      require = "🌙",
      source = "📄",
      start = "🚀",
      task = "📌",
      lazy = "💤 ",
    },
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "zipPlugin",
      },
    },
  },
})

-- vim: ts=2 sts=2 sw=2 et
