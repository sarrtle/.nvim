local configs = require "nvchad.configs.lspconfig"

-- load defaults i.e lua_lsp
configs.defaults()

local on_attach = configs.on_attach
local on_init = configs.on_init
local capabalities = configs.capabalities

local lspconfig = require "lspconfig"

-- PYTHON: diagnostics, static checker, auto completion
lspconfig.pyright.setup {
  filetypes = { "python" },
  on_init = on_init,
  on_attach = on_attach,
  capabalities = capabalities,
  root_dir = function()
    return vim.fn.getcwd()
  end,
  -- handlers = {
  --   ["textDocument/publishDiagnostics"] = function() end,
  -- },
}

-- PYTHON: Linter and formatter
lspconfig.ruff.setup {
  -- disable ruff hover capabilities, since it doesn't have one
  -- but trying to hover and it throws `no information available`
  -- message
  mason = false,
  handlers = {
    ["textDocument/hover"] = function() end,
  },
  init_options = {
    settings = {
      -- Ruff language server settings go here
      lineLength = 100,

      -- Add additional linting
      lint = {
        select = {
          -- for missing docstring
          "D",
        },
        ignore = {
          -- docstring for class init
        },
      },
    },
  },
}

-- RUST: diagnostics, static checker, auto completion
lspconfig.rust_analyzer.setup {
  filetypes = { "rust" },
  on_attach = on_attach,
  on_init = on_init,
  capabalities = capabalities,
  mason=false,
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
        buildScripts = {
          enable = true,
        },
      },
      imports = {
        granularity = {
          group = "module",
        },
        prefix = "self",
      },
      procMacro = {
        enable = true,
      },
    },
  },
}
