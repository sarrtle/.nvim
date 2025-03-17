local aerial = require "aerial"

aerial.setup {
  -- backend of choice, since treesitter is available on this config, we will use it instead
  -- of lsp and markdown as fallbacks if treesitter is not available
  backends = { "treesitter" },

  -- window will only work on the current file even switching to a new buffer
  -- global will make aerial work on all file[window, global]
  attach_mode = "global",

  -- make sure the placement is always on the right side
  layout = {
    default_direction = "right",
    placement = "edge",
  },

  close_automatic_events = { "unsupported" },

  keymaps = {
    -- overwrite tab keymap on aerial buffer to avoid opening
    -- the code in the current aerial buffer
    ["<Tab>"] = "actions.jump",
  },

  -- Don't use this, implement manually instead
  -- Found some bunch of problems like, can't be closed using :q
  -- or after toggling to close, switching to terminal and switch
  -- back to the code again will automatically open aerial on left side
  -- even it is for the right side only.
  open_automatic = false,

  -- other options are already default, no need to implement
  nav = {
    keymaps = {
      -- overwrite tab keymap on aerial buffer to avoid switching
      -- to other tapsjjjthe code in the current aerial buffer
      ["<Tab>"] = "actions.jump",
    },
  },
}
