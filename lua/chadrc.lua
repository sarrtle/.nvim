-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "solarized_osaka",

  -- hl_override = {
  -- Comment = { italic = true },
  -- ["@comment"] = { italic = true },
  -- },
}

M.ui = {
  statusline = {
    theme = "vscode",
    -- warning: Always check the order if things are updated in
    -- https://github.com/NvChad/base46/blob/v3.0/lua/base46/statusline.lua
    order = { "mode", "file", "git", "%=", "lsp_msg", "%=", "diagnostics", "neocodeium", "lsp", "cursor", "cwd" },
    modules = {
      neocodeium = function()
        return require("configs.neocodeium_config").status .. " "
      end,
    },
  },
}

M.mason = {
  pkgs = {
    -- For python
    "basedpyright",
    "black",
    "ruff",
    -- For Web Development
    "typescript-language-server",
    "svelte-language-server",
    "tailwindcss-language-server",
    "prettierd",
    "emmet-language-server",
    -- For Lua
    "lua-language-server",
    "stylua",
    -- For rust
    "rust-analyzer",
  },
}

return M
