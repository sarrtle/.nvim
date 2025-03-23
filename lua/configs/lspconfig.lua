local configs = require "nvchad.configs.lspconfig"

-- load defaults i.e lua_lsp
configs.defaults()

local on_attach = configs.on_attach
local on_init = configs.on_init
local capabalities = configs.capabalities

local lspconfig = require "lspconfig"

-- -- LUA: diagnostics, static checker, auto completion, lazyvim support.
-- --      Only enable this incase the plugin won't work or abandoned.
-- -- Notes: This is slow and loading a lot of files, might optimize this in the future.
-- lspconfig.lua_ls.setup {
--   on_init = on_init,
--   on_attach = on_attach,
--   capabalities = capabalities,
--   settings = {
--     Lua = {
--       runtime = {
--         -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
--         version = "LuaJIT",
--       },
--       diagnostics = {
--         -- Get the language server to recognize the `vim` global
--         globals = { "vim" },
--       },
--       workspace = {
--         -- Make the server aware of Neovim runtime files
--         library = {
--           vim.env.VIMRUNTIME,
--           -- Add LazyVim plugins
--           vim.fn.stdpath "data" .. "/lazy",
--           -- Add your plugin directory
--           -- ~/path/to/custom/plugins
--         },
--         checkThirdParty = false,
--       },
--       completion = {
--         callSnippet = "Replace",
--       },
--       -- Do not send telemetry data containing a randomized but unique identifier
--       telemetry = {
--         enable = false,
--       },
--     },
--   },
-- }

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
  -- disable ruff hover capabilities, since it doesn't have one
  -- but trying to hover and it throws `no information available`
  -- message
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
    "svelte",
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

-- SVELTE: diagnostics and auto completion, with typescript support.
lspconfig.svelte.setup {
  on_init = on_init,
  on_attach = on_attach,
  capabalities = capabalities,
}

-- TAILWIND: tailwind css auto completion
lspconfig.tailwindcss.setup {
  on_init = on_init,
  on_attach = on_attach,
  capabalities = capabalities,
  -- remove hover capabilities because it throws `no information available`
  handlers = {
    ["textDocument/hover"] = function() end,
  },
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
