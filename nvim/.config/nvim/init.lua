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
vim.keymap.set({ "n", "v" }, "<C-s>", "<cmd>w<CR>", { desc = "Save Buffer" })
vim.keymap.set("i", "<C-s>", "<Esc><cmd>w<CR>", { desc = "Save Buffer" })
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
        { "<leader>z", group = "[Z]k Notes", mode = { "n", "v" } },
        { "<leader>zs", group = "[S]ilverBullet (sb cli)" },
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
        pyright = {
          settings = {
            pyright = { disableOrganizeImports = true },
            python = {
              analysis = {
                typeCheckingMode = "basic",
                ignore = { "*" },
              },
            },
          },
        },

        ruff = {},

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
        "prettier", -- HTML formatter (conform: html only)
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
        "<leader>F",
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
        python = { "ruff_format" },
        html = { "prettier" },
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
        command_palette = true,
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

      -- Buffer close keymaps.
      -- Snacks.bufdelete is used instead of :bdelete because it swaps in the
      -- alternate buffer rather than closing any window showing the victim.
      -- Left/right go through bufferline so they follow the visible tab order,
      -- not buffer numbers.
      local map = function(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { desc = desc }) end
      map("<leader>bd", "<cmd>bdelete<CR>", "[B]uffer [D]elete")
      map("<leader>ba", function() Snacks.bufdelete.all() end, "[B]uffer close [A]ll")
      map("<leader>bo", function()
        local visible = {}
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          visible[vim.api.nvim_win_get_buf(win)] = true
        end
        Snacks.bufdelete { filter = function(buf) return not visible[buf] end }
      end, "[B]uffer close all except [O]pen")
      map("<leader>br", "<cmd>BufferLineCloseRight<CR>", "[B]uffer close all to the [R]ight")
      map("<leader>bl", "<cmd>BufferLineCloseLeft<CR>", "[B]uffer close all to the [L]eft")
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

      -- Macro recording is invisible here: cmdheight=0 hides nvim's native
      -- "recording @x" message and mini.statusline has no indicator. A stray
      -- recording also stops which-key attaching its triggers (it skips
      -- attach while reg_recording() is set), so <leader> silently goes dead.
      local section_mode = statusline.section_mode
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_mode = function(args)
        local mode, mode_hl = section_mode(args)
        local rec = vim.fn.reg_recording()
        return rec == "" and mode or (mode .. " REC@" .. rec), mode_hl
      end
      vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
        group = vim.api.nvim_create_augroup("MiniStatuslineRec", { clear = true }),
        desc = "Refresh statusline so the REC@ indicator appears/clears",
        -- RecordingLeave fires before reg_recording() clears, hence the schedule
        callback = function() vim.schedule(function() vim.cmd "redrawstatus" end) end,
      })
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
    config = function()
      require("Comment").setup {
        pre_hook = function(ctx)
          local ok, integration = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
          if ok then return integration.create_pre_hook()(ctx) end
        end,
      }
      local api = require "Comment.api"
      vim.keymap.set("n", "<leader>/", api.toggle.linewise.current, { desc = "Toggle comment line" })
      vim.keymap.set("x", "<leader>/", function()
        local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
        vim.api.nvim_feedkeys(esc, "nx", false)
        api.toggle.linewise(vim.fn.visualmode())
      end, { desc = "Toggle comment" })
    end,
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
      window = { position = "right" },
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

  -- zk setup
  {
    "zk-org/zk-nvim",
    name = "zk",
    opts = {
      -- Can be "telescope", "fzf", "fzf_lua", "minipick", "snacks_picker",
      -- or select" (`vim.ui.select`).
      picker = "telescope",

      lsp = {
        -- `config` is passed to `vim.lsp.start(config)`
        config = {
          name = "zk",
          cmd = { "zk", "lsp" },
          filetypes = { "markdown" },
          -- on_attach = ...
          -- etc, see `:h vim.lsp.start()`
        },

        -- automatically attach buffers in a zk notebook that match the given filetypes
        auto_attach = {
          enabled = true,
        },
      },
    },
    config = function(_, opts)
      require("zk").setup(opts)
      local tp = require("zk.pickers.telescope")
      tp.note_picker_list_api_selection = { "title", "absPath", "path", "filenameStem" }
      tp.create_note_entry_maker = function(_)
        return function(note)
          local display = note.filenameStem or note.title or note.path
          return {
            value = note,
            path = note.absPath,
            display = display,
            ordinal = display,
            text = display,
          }
        end
      end

      local function map(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { desc = desc }) end

      -- browse / search
      map("n", "<leader>zn", "<Cmd>ZkNotes { sort = { 'modified' } }<CR>", "[Z]k [N]otes")
      -- Alias of <leader>zn, in the [F]ind namespace.
      map("n", "<leader>fz", "<Cmd>ZkNotes { sort = { 'modified' } }<CR>", "[F]ind [Z]k notes")
      map("n", "<leader>zt", "<Cmd>ZkTags<CR>", "[Z]k [T]ags")
      map("n", "<leader>zo", "<Cmd>ZkBuffers<CR>", "[Z]k [O]pen buffers")
      map("n", "<leader>zf", function()
        local q = vim.fn.input "Search notes: "
        if q ~= "" then
          require("zk").edit({ sort = { "modified" }, match = { q } }, { title = "Zk: " .. q })
        end
      end, "[Z]k [F]ind by text")
      map("v", "<leader>zf", ":'<,'>ZkMatch<CR>", "[Z]k [F]ind by selection")

      -- links for the current note
      map("n", "<leader>zb", "<Cmd>ZkBacklinks<CR>", "[Z]k [B]acklinks (inbound)")
      map("n", "<leader>zl", "<Cmd>ZkLinks<CR>", "[Z]k [L]inks (outbound)")
      map("n", "<leader>zi", "<Cmd>ZkInsertLink<CR>", "[Z]k [I]nsert link")
      map("v", "<leader>zi", ":'<,'>ZkInsertLinkAtSelection<CR>", "[Z]k [I]nsert link for selection")

      -- create
      map("n", "<leader>zc", "<Cmd>ZkNew { title = vim.fn.input('Title: ') }<CR>", "[Z]k [C]reate note")
      map("v", "<leader>zc", ":'<,'>ZkNewFromTitleSelection<CR>", "[Z]k [C]reate from selection (title)")
      map("v", "<leader>zC", ":'<,'>ZkNewFromContentSelection<CR>", "[Z]k [C]reate from selection (content)")

      -- housekeeping
      map("n", "<leader>zd", "<Cmd>ZkCd<CR>", "[Z]k c[d] to notebook root")
      map("n", "<leader>zR", "<Cmd>ZkIndex<CR>", "[Z]k [R]eindex notebook")
    end,
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

-- ============================================================
-- NOTES: SilverBullet `sb` CLI (shell-outs, there is no plugin)
-- ============================================================
-- sb resolves its own space from ~/.config/sb/config.toml, so cwd never matters
-- here. Only the local mirror path does, for opening files directly.
-- ponytail: these mirror [sync].dir and [daily].path in that config file. If you
-- change them there, change them here.
local sb_dir = vim.fn.expand "~/silverbullet"
local function sb_daily_file() return sb_dir .. "/Inbox/" .. os.date "%Y-%m-%d" .. ".md" end

local function sb_notify(msg, level) vim.notify(msg, level, { title = "SilverBullet" }) end

-- sb prints this hint only when there really are conflicts, which makes it a
-- more honest signal than grepping for the word "conflicts" (every "Pull
-- complete: 0 downloaded, 0 conflicts" line contains that).
local function sb_level(code, body)
  if code ~= 0 then
    return vim.log.levels.ERROR
  elseif body:find("sb sync conflicts", 1, true) then
    return vim.log.levels.WARN
  end
  return vim.log.levels.INFO
end

-- Run sb async. Machine output lands on stdout, human summaries on stderr, so
-- both come back. --no-input because a prompt would hang with nowhere to type.
local function sb_run(args, on_done)
  local cmd = vim.list_extend({ "sb", "--no-input", "--no-color" }, args)
  vim.system(cmd, { text = true }, function(r)
    local trim = function(t) return vim.trim(t or "") end
    vim.schedule(function() on_done(r.code, trim(r.stdout), trim(r.stderr)) end)
  end)
end

-- Notify with whatever sb had to say.
local function sb_notify_run(args, label)
  sb_run(args, function(code, out, err)
    local body = out ~= "" and out or err
    sb_notify(label .. "\n" .. (body ~= "" and body or "(no output)"), sb_level(code, body))
  end)
end

-- Dump sb output into a throwaway split; `q` closes it.
local function sb_scratch(args, label)
  sb_run(args, function(code, out, err)
    local body = out ~= "" and out or err
    if body == "" then body = code == 0 and "(no output)" or "failed (exit " .. code .. ")" end
    vim.cmd "botright new"
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(body, "\n"))
    vim.api.nvim_buf_set_name(buf, "sb://" .. label)
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].filetype = "markdown"
    vim.bo[buf].modifiable = false
    vim.wo.wrap = true
    vim.keymap.set("n", "q", "<Cmd>close<CR>", { buffer = buf, desc = "Close sb output" })
  end)
end

-- Fetch JSON from sb and hand the decoded rows to `show`.
local function sb_json(args, show)
  sb_run(vim.list_extend({ "--format", "json" }, args), function(code, out, err)
    local body = out ~= "" and out or err
    if code ~= 0 then return sb_notify("sb failed\n" .. body, vim.log.levels.ERROR) end
    local ok, rows = pcall(vim.json.decode, out)
    if not ok or type(rows) ~= "table" then
      return sb_notify("Could not read sb output\n" .. body:sub(1, 300), vim.log.levels.ERROR)
    end
    if vim.tbl_isempty(rows) then return sb_notify "Nothing to show" end
    show(rows)
  end)
end

-- Open a page from the local mirror, landing on `anchor` text when given.
local function sb_open(page, anchor)
  if not page or page == "" then return end
  local f = sb_dir .. "/" .. page .. ".md"
  if vim.fn.filereadable(f) == 0 then
    return sb_notify("Not in the local mirror yet:\n" .. page .. "\n<leader>zss to sync", vim.log.levels.WARN)
  end
  vim.cmd.edit(vim.fn.fnameescape(f))
  if anchor and anchor ~= "" then
    -- The index stores character offsets while `:goto` counts bytes, so search
    -- for the text rather than converting. \V makes the pattern literal, and
    -- strcharpart trims by character so a multibyte tail is never cut in half.
    local pat = "\\V" .. vim.fn.strcharpart(anchor, 0, 40):gsub("\\", "\\\\")
    vim.fn.search(pat, "cw")
  end
end

-- One telescope picker over sb rows. `make(row)` returns a telescope entry
-- (display, plus whatever `on_select` needs); `preview` wants entry.path set.
local function sb_picker(title, rows, make, on_select, preview)
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local conf = require("telescope.config").values
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"
  pickers
    .new({}, {
      prompt_title = title,
      finder = finders.new_table {
        results = rows,
        entry_maker = function(row)
          local e = make(row)
          e.value = row
          e.ordinal = e.ordinal or e.display
          return e
        end,
      },
      sorter = conf.generic_sorter {},
      previewer = preview and conf.file_previewer {} or nil,
      attach_mappings = function(bufnr)
        actions.select_default:replace(function()
          local sel = action_state.get_selected_entry()
          actions.close(bufnr)
          if sel then on_select(sel) end
        end)
        return true
      end,
    })
    :find()
end

-- A row's text is wanted two ways: verbatim for the jump, and flattened to one
-- line for the picker, since an inbox snippet can run to thousands of characters.
local function sb_text(raw)
  raw = raw or ""
  local literal = vim.trim((raw:gsub("\n.*", ""))) -- must still match the page byte for byte
  local flat = vim.trim((raw:gsub("%s+", " ")))
  return literal, flat
end

-- Build a picker entry for a page, with an optional position to land on. The
-- ordinal keeps more text than the display so fuzzy search still reaches words
-- past the visible cut.
local function sb_entry(page, raw)
  local literal, flat = sb_text(raw)
  -- A page row carries no text of its own, so it gets no separator.
  local tail = flat ~= "" and ("  |  " .. vim.fn.strcharpart(flat, 0, 140)) or ""
  return {
    display = page .. tail,
    ordinal = page .. " " .. vim.fn.strcharpart(flat, 0, 400),
    path = sb_dir .. "/" .. page .. ".md",
    sb_page = page,
    sb_anchor = literal ~= "" and literal or nil,
  }
end

-- Index rows come in two shapes: page-tagged objects carry `name` and no `pos`,
-- data-tagged ones (highlight, task, ...) carry `page`, `text` and `pos`.
local function sb_row_entry(row)
  local page = row.page or row.name or (row.ref or ""):gsub("@%d+$", "")
  -- A page row *is* its page, so there is nothing within it to jump to.
  return sb_entry(page, row.page and (row.text or row.name) or nil)
end

local function sb_open_entry(sel) sb_open(sel.sb_page, sel.sb_anchor) end

-- Every object the server has indexed under one tag.
local function sb_objects(tag)
  sb_notify("Loading " .. tag .. "...")
  -- No `limit`: the biggest tags here are ~5.6k rows and come back in about a
  -- second, and any cap would silently hide the overflow.
  sb_json({ "query", ('from index.tag "%s"'):format(tag) }, function(rows)
    sb_picker("sb: " .. tag .. " (" .. #rows .. ")", rows, sb_row_entry, sb_open_entry, true)
  end)
end

local function sb_sync()
  -- Push uploads what is on disk, so an unsaved buffer would be quietly skipped.
  if vim.bo.modified and vim.api.nvim_buf_get_name(0):find(sb_dir, 1, true) == 1 then vim.cmd "update" end
  sb_notify "Syncing..."
  sb_notify_run({ "sync" }, "Sync")
end

local function sbmap(lhs, rhs, desc) vim.keymap.set("n", "<leader>zs" .. lhs, rhs, { desc = desc }) end

sbmap("s", sb_sync, "[S]ync (pull + push)")
sbmap(
  "n",
  function() sb_scratch({ "--format", "human", "sync", "--dry-run" }, "sync preview") end,
  "Sync preview (dry-ru[n])"
)
sbmap("t", function() sb_notify_run({ "--format", "human", "sync", "status" }, "Sync status") end, "Sync s[t]atus")
sbmap("c", function() sb_scratch({ "--format", "human", "sync", "conflicts" }, "conflicts") end, "[C]onflicts")
sbmap("i", function()
  sb_notify "Loading inbox..."
  sb_json({ "inbox" }, function(rows)
    sb_picker(
      "sb inbox (" .. #rows .. ")",
      rows,
      function(row) return sb_entry(row.page or "", row.snippet) end,
      sb_open_entry,
      true
    )
  end)
end, "[I]nbox (@mentions)")
sbmap("o", function()
  sb_notify "Loading tags..."
  -- `sb describe` lists every indexed tag with its row count, biggest first.
  sb_json({ "describe" }, function(tags)
    -- `count` is how many pages carry the tag, not how many objects it has:
    -- `highlight` reads 432 here and returns 5621 rows when queried.
    sb_picker("sb indexed tags (" .. #tags .. ") -- count = pages", tags, function(t)
      return {
        display = ("%6d  %-34s %s"):format(t.count or 0, t.name or "?", t.parents or ""),
        ordinal = t.name or "",
      }
    end, function(sel) sb_objects(sel.value.name) end, false)
  end)
end, "Indexed [o]bjects by tag")
sbmap("h", function() sb_objects "highlight" end, "[H]ighlights")
sbmap("l", function()
  vim.ui.input({ prompt = "Daily log entry: " }, function(text)
    if not text or vim.trim(text) == "" then return end
    -- `--` so an entry starting with `-` is not read as a flag.
    sb_run({ "daily", "--", text }, function(code, out, err)
      local body = err ~= "" and err or out
      sb_notify(code == 0 and ("Logged: " .. text) or ("Log failed\n" .. body), sb_level(code, body))
    end)
  end)
end, "[L]og entry to today's note")
sbmap("d", function()
  local f = sb_daily_file()
  -- A fresh entry written by `sb daily` lives on the server until the next pull.
  if vim.fn.filereadable(f) == 0 then sb_notify("No local copy yet, <leader>zss to sync", vim.log.levels.WARN) end
  vim.cmd.edit(f)
end, "Open to[d]ay's daily note")

-- vim: ts=2 sts=2 sw=2 et
