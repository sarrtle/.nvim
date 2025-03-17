require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- enable disable inlay hint
map("n", "m", function()
  local is_enabled = vim.lsp.inlay_hint.is_enabled()
  vim.lsp.inlay_hint.enable(not is_enabled)
end, { desc = "Enable Disable inlay hints" })

-- Markdown mapping
map("n", "mm", function()
  require("markview").commands.toggle(vim.api.nvim_get_current_buf())
end, { desc = "Markview Toggle markdown preview" })
map("n", "md", function()
  require("markview").commands.splitToggle(vim.api.nvim_get_current_buf())
end, { desc = "Markview Toggle markdown split preview" })

-- neocodeium mappings
vim.keymap.set("i", "<A-f>", function()
  require("neocodeium").accept()
end, { desc = "Neocodeium accept suggestions" })
vim.keymap.set("i", "<A-w>", function()
  require("neocodeium").accept_word()
end, { desc = "Neocodeium accept word" })
vim.keymap.set("i", "<A-a>", function()
  require("neocodeium").accept_line()
end, { desc = "Neocodeium accept line" })
-- INFO for neocodeium: using shift because of mapping conflicts of terminal
vim.keymap.set("i", "<A-E>", function()
  require("neocodeium").cycle_or_complete()
end, { desc = "Neocodeium cycle through suggestions" })
vim.keymap.set("i", "<A-R>", function()
  require("neocodeium").cycle_or_complete(-1)
  -- INFO end
end, { desc = "Neocodeium cycle through suggestions in reverse" })
vim.keymap.set("i", "<A-c>", function()
  require("neocodeium").clear()
end, { desc = "Neocodeium clear current suggestions" })

-- aerial mappings
vim.keymap.set("n", "<C-a>", function()
  require("aerial").toggle { focus = false, direction = "right" }
end, { desc = "Aerial toggle" })
vim.keymap.set("n", "nt", function()
  require("aerial").nav_toggle()
end, { desc = "Aerial nav toggle" })
