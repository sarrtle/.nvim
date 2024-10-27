local configs = require "nvchad.configs.lspconfig"

-- load defaults i.e lua_lsp
configs.defaults()

local on_attach = configs.on_attach
local on_init = configs.on_init
local capabalities = configs.capabalities

local lspconfig = require "lspconfig"

-- PYTHON: diagnostics, static checker, auto completion
lspconfig.basedpyright.setup {
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

-- HTML: Abbreviation expansion
lspconfig.emmet_language_server.setup {
  filetypes = {
    "css",
    "eruby",
    "html",
    "javascript",
    "javascriptreact",
    "less",
    "sass",
    "scss",
    "pug",
    "typescriptreact",
  },
  -- Read more about this options in the [vscode docs](https://code.visualstudio.com/docs/editor/emmet#_emmet-configuration).
  -- **Note:** only the options listed in the table are supported.
  init_options = {
    ---@type table<string, string>
    includeLanguages = {},
    --- @type string[]
    excludeLanguages = {},
    --- @type string[]
    extensionsPath = {},
    --- @type table<string, any> [Emmet Docs](https://docs.emmet.io/customization/preferences/)
    preferences = {},
    --- @type boolean Defaults to `true`
    showAbbreviationSuggestions = true,
    --- @type "always" | "never" Defaults to `"always"`
    showExpandedAbbreviation = "always",
    --- @type boolean Defaults to `false`
    showSuggestionsAsSnippets = false,
    --- @type table<string, any> [Emmet Docs](https://docs.emmet.io/customization/syntax-profiles/)
    syntaxProfiles = {},
    --- @type table<string, string> [Emmet Docs](https://docs.emmet.io/customization/snippets/#variables)
    variables = {},
  },
}

-- TYPESCRIPT: typescript, node js auto completion, diagnostics and static checker
lspconfig.ts_ls.setup {
  on_init = on_init,
  on_attach = on_attach,
  capabalities = capabalities,
}

-- TAILWIND: tailwind css auto completion
lspconfig.tailwindcss.setup {
  on_init = on_init,
  on_attach = on_attach,
  capabalities = capabalities,
}

-- HTML: auto completion
lspconfig.html.setup {
  on_init = on_init,
  on_attach = on_attach,
  capabalities = capabalities,
}

-- CSS: auto completion
lspconfig.cssls.setup {
  on_init = on_init,
  on_attach = on_attach,
  capabalities = capabalities,
  settings = {
    css = {
      lint = {
        unknownAtRules = "ignore",
      },
    },
  },
}
