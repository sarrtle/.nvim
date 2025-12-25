local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    -- css = { "prettierd" },
    -- html = { "prettierd" },
    -- ruff clean up unused imports, and other might
    -- useful stuffs.
    python = { "black", "ruff" },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 5000,
    lsp_fallback = true,
  },
}

return options
