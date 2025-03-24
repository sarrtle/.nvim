local Layout = require "nui.layout"
local Popup = require "nui.popup"
local api_request = require "tools.proto_ai.api_request"

local system_prompt = require "tools.proto_ai.prompts"

-- GLOBALS
MessageHistory = {}
api_request.add_system_input(MessageHistory, system_prompt.character)
MessageTurn = 0

-- Response popup
local response_popup = Popup {
  enter = false,
  focusable = true,
  border = {
    padding = { top = 1, left = 1, bottom = 0, right = 1 },
    style = "rounded",
    text = { top = "[AI Response]", top_align = "right" },
  },
  win_options = {
    winhighlight = "Normal:Normal",
    wrap = true,
    linebreak = true,
  },
}
-- set response filetype into markdown
vim.bo[response_popup.bufnr].filetype = "markdown"

local response_layout = Layout.Box({
  Layout.Box(response_popup, { size = "100%" }),
}, { dir = "col", size = 0.8 })

-- options layout
function CreateButton(icon_text)
  local button = Popup {
    enter = true,
    focusable = true,
    border = {
      padding = { top = 0, left = 1, bottom = 0, right = 1 },
      style = "rounded",
    },
    win_options = {
      winhighlight = "Normal:Normal",
    },
  }
  -- set button text
  vim.api.nvim_buf_set_lines(button.bufnr, 0, -1, false, { icon_text })
  return button
end

-- text
function CreateText(text)
  local text_widget = Popup {
    enter = false,
    focusable = false,
    border = {
      padding = { top = 0, left = 1, bottom = 0, right = 1 },
      style = "solid",
    },
    win_options = {
      winhighlight = "Normal:Normal",
    },
  }
  vim.api.nvim_buf_set_lines(text_widget.bufnr, 0, -1, false, { text })
  return text_widget
end

-- options layout
local history_text = CreateText "0/0"
local delete_button = CreateButton ""
local left_button = CreateButton ""
local right_button = CreateButton ""
local options_layout = Layout.Box({
  Layout.Box(delete_button, { size = 0.10 }),
  Layout.Box({}, { size = 0.35 }),
  Layout.Box(history_text, { size = 0.3 }),
  Layout.Box({}, { size = 0.10 }),
  Layout.Box(left_button, { size = 0.10 }),
  Layout.Box(right_button, { size = 0.10 }),
}, { dir = "row", size = "10%" })

-- input layout
local input_popup = Popup {
  enter = true,
  focusable = true,
  border = {
    padding = { top = 0, left = 1, bottom = 0, right = 1 },
    style = "rounded",
    text = { top = "[Ask AI]", top_align = "right" },
  },
  win_options = {
    winhighlight = "Normal:Normal",
    wrap = true,
    linebreak = true,
  },
}
local input_layout = Layout.Box({
  Layout.Box(input_popup, { size = "100%" }),
}, { dir = "col", size = "10%" })

-- MAIN LAYOUT
local main_layout_opts = {
  relative = "editor",
  size = {
    height = 0.9,
    width = 0.3,
  },
  position = {
    row = vim.o.lines - (vim.o.lines * 0.9) - 3,
    col = vim.o.columns - (vim.o.columns * 0.3) - 2,
  },
}
local main_layout = Layout(
  main_layout_opts,
  Layout.Box({
    response_layout,
    input_layout,
    options_layout,
  }, { dir = "col" })
)

input_popup:map("n", "<CR>", function()
  local user_input_lines = vim.api.nvim_buf_get_lines(input_popup.bufnr, 0, -1, false)
  local user_input = table.concat(user_input_lines, "\n")
  api_request.add_user_input(MessageHistory, user_input)

  -- calculate message history length
  local group_message = api_request.group_messages(MessageHistory)
  local length = #group_message
  MessageTurn = length

  -- update history text
  vim.api.nvim_buf_set_lines(history_text.bufnr, 0, -1, false, { tostring(MessageTurn) .. "/" .. tostring(length) })

  -- clear input and output
  vim.api.nvim_buf_set_lines(input_popup.bufnr, 0, -1, false, {})
  vim.api.nvim_buf_set_lines(response_popup.bufnr, 0, -1, false, {})

  local is_thinking = false
  local think_buffer = ""
  local think_line = nil -- Tracks the line number of our thinking display

  api_request.get_ai_response_async_stream(MessageHistory, function(chunk)
    -- Handle thinking state management
    if is_thinking then
      think_buffer = think_buffer .. chunk
      local think_end = think_buffer:find "</think>"

      if think_end then
        -- Process final thinking content
        local think_content = think_buffer:sub(1, think_end - 1)
        ProcessThinkContent(think_content)

        -- Exit thinking mode
        is_thinking = false
        think_buffer = ""

        -- Remove thinking line
        if think_line then
          vim.api.nvim_buf_set_lines(response_popup.bufnr, think_line, think_line + 1, false, {})
          think_line = nil
        end
      else
        -- Process intermediate thinking content
        ProcessThinkContent(think_buffer)
      end
    else
      local think_start = chunk:find "<think>"
      if think_start then
        -- Split chunk into normal content and thinking content
        local after_think = chunk:sub(think_start + #"<think>")

        -- Enter thinking mode
        is_thinking = true
        think_buffer = after_think
      else
        -- Normal content processing
        ProcessNormalChunk(chunk)
      end
    end
  end, function(fullResponse)
    api_request.add_ai_response(MessageHistory, fullResponse)
    vim.schedule(function()
      if response_popup.winid then
        vim.api.nvim_set_current_win(response_popup.winid)
      end
    end)
  end)

  -- Helper function for normal content processing
  function ProcessNormalChunk(chunk)
    if #chunk == 0 then
      return
    end

    local line_count = vim.api.nvim_buf_line_count(response_popup.bufnr)
    local last_line = vim.api.nvim_buf_get_lines(response_popup.bufnr, -2, -1, false)[1] or ""

    if line_count == 1 then
      -- trim new lines on before text like this: "\nHey"
      chunk = chunk:gsub("^%s*\n", "")
    end

    -- Merge with last line and split
    local new_content = last_line .. chunk
    local lines = vim.split(new_content, "\n", { plain = true, trimempty = false })

    -- Update buffer
    vim.api.nvim_buf_set_lines(response_popup.bufnr, math.max(0, line_count - 1), line_count, false, lines)

    -- Auto-scroll
    if response_popup.winid then
      vim.api.nvim_win_set_cursor(response_popup.winid, { line_count - 1 + #lines, 0 })
    end
  end

  -- Helper function to process thinking content
  function ProcessThinkContent(content)
    -- Split into paragraphs (simple newline separation)
    local paragraphs = vim.split(content:gsub("\r", ""), "\n")

    for _, para in ipairs(paragraphs) do
      if #para > 0 then
        -- Extract first sentence or first line
        local first_sentence = para:match "^([^%.!?\n]+[%.!?]?)" or para:match "^[^\n]+"
        first_sentence = first_sentence:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")

        -- Create or update thinking line
        local display_text = "... " .. first_sentence

        if not think_line then
          -- Add new thinking line
          local line_count = vim.api.nvim_buf_line_count(response_popup.bufnr) - 1
          vim.api.nvim_buf_set_lines(response_popup.bufnr, line_count, line_count, false, { display_text })
          think_line = line_count
        else
          -- Update existing thinking line
          vim.api.nvim_buf_set_lines(response_popup.bufnr, think_line, think_line + 1, false, { display_text })
        end

        -- Keep cursor on the thinking line
        if response_popup.winid then
          vim.api.nvim_win_set_cursor(response_popup.winid, { think_line + 1, #display_text })
        end
      end
    end
  end
end)

-- reset message history
delete_button:map("n", "<CR>", function()
  MessageTurn = 0
  MessageHistory = {}
  api_request.add_system_input(MessageHistory, system_prompt.character)

  local group_message = api_request.group_messages(MessageHistory)
  local length = #group_message
  vim.api.nvim_buf_set_lines(history_text.bufnr, 0, -1, false, { tostring(MessageTurn) .. "/" .. tostring(length) })
  vim.api.nvim_buf_set_lines(response_popup.bufnr, 0, -1, false, {})
  vim.api.nvim_buf_set_lines(input_popup.bufnr, 0, -1, false, {})
end)

right_button:map("n", "<CR>", function()
  local messages = api_request.group_messages(MessageHistory)
  local message_length = #messages

  -- early return on unsupported pagination
  if MessageTurn == message_length then
    return
  end

  MessageTurn = MessageTurn + 1

  local user_input = messages[MessageTurn][1].content
  local ai_response = messages[MessageTurn][2].content

  -- apply to buffer
  local user_lines = vim.split(user_input, "\n", { plain = true, trimempty = false })
  vim.api.nvim_buf_set_lines(
    input_popup.bufnr,
    0, -- Start line
    -1, -- End line (end of buffer)
    false,
    user_lines
  )

  local ai_lines = vim.split(ai_response, "\n", { plain = true, trimempty = false })
  vim.api.nvim_buf_set_lines(
    response_popup.bufnr,
    0, -- Start line
    -1, -- End line (end of buffer)
    false,
    ai_lines
  )

  -- change history text
  vim.api.nvim_buf_set_lines(
    history_text.bufnr,
    0,
    -1,
    false,
    { tostring(MessageTurn) .. "/" .. tostring(message_length) }
  )
end)

left_button:map("n", "<CR>", function()
  local messages = api_request.group_messages(MessageHistory)
  local message_length = #messages

  -- early return on unsupported pagination
  if MessageTurn == 0 or MessageTurn == 1 then
    return
  end

  MessageTurn = MessageTurn - 1

  local user_input = messages[MessageTurn][1].content
  local ai_response = messages[MessageTurn][2].content

  -- apply to buffer
  local user_lines = vim.split(user_input, "\n", { plain = true, trimempty = false })
  vim.api.nvim_buf_set_lines(
    input_popup.bufnr,
    0, -- Start line
    -1, -- End line (end of buffer)
    false,
    user_lines
  )

  local ai_lines = vim.split(ai_response, "\n", { plain = true, trimempty = false })
  vim.api.nvim_buf_set_lines(
    response_popup.bufnr,
    0, -- Start line
    -1, -- End line (end of buffer)
    false,
    ai_lines
  )

  -- change history text
  vim.api.nvim_buf_set_lines(
    history_text.bufnr,
    0,
    -1,
    false,
    { tostring(MessageTurn) .. "/" .. tostring(message_length) }
  )
end)

-- setup mappings
require("tools.proto_ai.mapping").setup_mappings(
  main_layout,
  input_popup,
  response_popup,
  delete_button,
  left_button,
  right_button
)
