-- Set Ctrl+S to save buffer
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"

-- Use which-key to add extra bindings with the leader-key prefix

lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }

lvim.builtin.which_key.mappings["t"] = {
  name = "+Trouble",
  r = { "<cmd>Trouble lsp_references<cr>", "References" },
  f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
  d = { "<cmd>Trouble lsp_document_diagnostics<cr>", "Diagnostics" },
  q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
  l = { "<cmd>Trouble loclist<cr>", "LocationList" },
  w = { "<cmd>Trouble lsp_workspace_diagnostics<cr>", "Diagnostics" },
  t = { "<cmd>TroubleToggle<cr>", "Toggle" }
}

lvim.builtin.which_key.mappings["Q"] = { "<cmd>q!<CR>", "Quit" }
lvim.builtin.which_key.mappings["q"] = { "<cmd>TodoTelescope<CR>", "To Do List" }
lvim.builtin.which_key.mappings["y"] = {
  name = "+Tasks",
  a = { "<cmd>Telescope yabs tasks<CR>", "All Tasks" },
  g = { "<cmd>Telescope yabs global_tasks<CR>", "Global Tasks" },
  c = { "<cmd>Telescope yabs current_language_tasks<CR>", "Current Language Tasks" },
}
lvim.builtin.which_key.mappings.b.p = { "<cmd>!pst %<CR>", "Send to Pastebin" }

lvim.builtin.which_key.mappings["r"] = { "<cmd>lua require('rest-nvim').run()<CR>", "Run HTTP Under Cursor" }

lvim.builtin.which_key.mappings["v"] = { "<cmd>ALEPopulateQuickfix<CR><cmd>cclose<CR><cmd>Trouble quickfix<CR>",
  "Vale QuickFix List" }
-- # unmap a default keymapping
-- lvim.keys.normal_mode["<C-Up>"] = false

-- # edit a default keymapping
-- lvim.keys.normal_mode["<C-q>"] = ":q<cr>"

-- Change Telescope navigation to use j and k for navigation and n and p for history in both input and normal mode.
-- we use protected-mode (pcall) just in case the plugin wasn't loaded yet.
-- local _, actions = pcall(require, "telescope.actions")
-- lvim.builtin.telescope.defaults.mappings = {
--   -- for input mode
--   i = {
--     ["<C-j>"] = actions.move_selection_next,
--     ["<C-k>"] = actions.move_selection_previous,
--     ["<C-n>"] = actions.cycle_history_next,
--     ["<C-p>"] = actions.cycle_history_prev,
--   },
--   -- for normal mode
--   n = {
--     ["<C-j>"] = actions.move_selection_next,
--     ["<C-k>"] = actions.move_selection_previous,
--   },
--
