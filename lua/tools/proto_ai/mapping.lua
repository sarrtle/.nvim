-- mappings for this tool

local M = {}

M.setup_mappings = function(main_layout, input_popup, response_popup, delete_button, left_button, right_button)
  -- open tool
  vim.keymap.set("n", "tt", function()
    if input_popup.winid == nil then
      main_layout:show()
    end
    vim.api.nvim_set_current_win(input_popup.winid)
    vim.cmd "startinsert"
  end, { noremap = true })

  -- hide tool
  vim.keymap.set("n", "td", function()
    main_layout:hide()
  end)

  -- navigate response
  vim.keymap.set("n", "tu", function()
    if response_popup.winid ~= nil then
      vim.api.nvim_set_current_win(response_popup.winid)
    end
  end, { noremap = true })

  -- navigate delete
  vim.keymap.set("n", "tr", function()
    if delete_button.winid ~= nil then
      vim.api.nvim_set_current_win(delete_button.winid)
    end
  end, { noremap = true })

  -- navigate history
  vim.keymap.set("n", "tl", function()
    if right_button.winid ~= nil then
      vim.api.nvim_set_current_win(right_button.winid)
    end
  end, { noremap = true })

  vim.keymap.set("n", "th", function()
    if left_button.winid ~= nil then
      vim.api.nvim_set_current_win(left_button.winid)
    end
  end, { noremap = true })
end

return M
