return {
  n = {
    ["<leader>tt"] = { "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" }, -- requires terminal that supports binding <C-'>
    ["<up>"] = { "<nop>", desc = "Get Gud Nerd" },
    ["<down>"] = { "<nop>", desc = "Get Gud Nerd" },
    ["<left>"] = { "<nop>", desc = "Get Gud Nerd" },
    ["<right>"] = { "<nop>", desc = "Get Gud Nerd" },
    ["<leader>fo"] = {"<cmd>ObsidianQuickSwitch<cr>", desc = "Obsidian Quick Switcher"}, -- requires obsidian.nvim
    ["<leader>fq"] = {"<cmd>lua require('telescope.builtin').quickfix()<cr>", desc="QuickFix List"},
    ["<leader>e"] = { "<cmd>Neotree right toggle<cr>", desc = "Toggle Explorer to the right" }
  },
  t = {
    ["<leader>tt"] = { "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" }, -- requires terminal that supports binding <C-'>
  },
}

