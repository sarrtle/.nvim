return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- Install all required language syntax
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "lua",
        "python",
        "javascript",
        "typescript",
        "tsx",
        "html",
        "css",
        "svelte",
        "rust",
      },
    },
  },

  -- Auto close tag for jsx, tsx
  {
    "windwp/nvim-ts-autotag",
    ft = {
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "svelte",
    },
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },

  -- Markdown plugin
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    ft = "markdown",

    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },

    config = function()
      local markview = require "markview"
      local presets = require "markview.presets"

      markview.setup {
        checkboxes = presets.checkboxes.nerd,
      }
    end,
  },

  -- Neocodeium plugin
  {
    "monkoose/neocodeium",
    event = "VeryLazy",
    config = function()
      local filetypes = require("configs.neocodeium_config").filetypes
      require("neocodeium").setup {
        silent = true,
        -- will work only important filetypes
        filter = function()
          if vim.tbl_contains(filetypes, vim.bo.filetype) then
            return true
          end
          return false
        end,
      }
    end,
  },

  -- Code outliner
  {
    "stevearc/aerial.nvim",
    event = "VeryLazy",
    config = function()
      require "configs.aerial_config"
    end,
  },

  -- Cargo crates auto completion
  {
    "saecki/crates.nvim",
    ft = { "toml" },
    event = "BufRead Cargo.toml",
    config = function()
      require("crates").setup {
        completion = {
          cmp = {
            enabled = true,
          },
        },
      }
      require("cmp").setup.buffer {
        sources = {
          { name = "crates" },
        },
      }
    end,
  },

  -- smooth scrolling
  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    config = function()
      require "configs.neoscroll"
    end,
  },
}
