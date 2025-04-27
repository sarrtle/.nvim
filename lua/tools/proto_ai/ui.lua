local Layout = require "nui.layout"
local Popup = require "nui.popup"

local mappings = require "tools.proto_ai.mappings"
local system_prompt = require "tools.proto_ai.prompts"

-- import AI library
local ai_response = require "tools.proto_ai.proto_ai"

-- important variables
local message_turn = 0
local system_instructions = {}
local end_to_end_conversation = {}

local function create_messages()
  -- concatenate system instructions and end-to-end conversation
  local messages = {}
  for _, v in pairs(system_instructions) do
    table.insert(messages, v)
  end
  for _, v in pairs(end_to_end_conversation) do
    table.insert(messages, v)
  end
  return messages
end

---@param instruction string
local function add_system_instruction(instruction)
  table.insert(system_instructions, { role = "system", content = instruction })
end

---@param message string
local function add_user_message(message)
  table.insert(end_to_end_conversation, { role = "user", content = message })
end

---@param message string
local function add_ai_message(message)
  table.insert(end_to_end_conversation, { role = "assistant", content = message })
end

-- response popup
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
}, { dir = "col", size = "80%" })

-- Input popup
local input_popup = Popup {
  enter = false,
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

-- @param icon_text string
function CreateButton(icon_text)
  local button = Popup {
    enter = false,
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

---@param text string
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

local history_text = CreateText "0/0"
local delete_button = CreateButton ""
local left_button = CreateButton ""
local right_button = CreateButton ""
local options_layout = Layout.Box({
  Layout.Box(delete_button, { size = "10%" }),
  Layout.Box({}, { size = 0, grow = 2 }), -- filler
  Layout.Box(history_text, { size = "20%" }),
  Layout.Box({}, { size = 0, grow = 1 }), -- filler
  Layout.Box(left_button, { size = "10%" }),
  Layout.Box(right_button, { size = "10%" }),
}, { dir = "row", size = "5%" })

---@type nui_layout_options
local main_layout_opts = {
  relative = "editor",
  size = {
    height = "100%",
    width = "30%",
  },
  position = {
    row = vim.o.lines,
    col = vim.o.columns,
  },
}

-- setup layout
local main_layout = Layout(
  main_layout_opts,
  Layout.Box({ response_layout, input_layout, options_layout }, { dir = "col", size = "100%" })
)

mappings.setup_mappings(main_layout, input_popup, response_popup, delete_button, left_button, right_button)

local get_ai_response

-- Callbacks
---@param chunk string
local function chunk_cb(chunk)
  vim.schedule(function()
    -- trim empty spaces from the beginning and the end
    chunk = chunk:match "^%s*(.-)%s*$"

    -- clear buffer
    vim.api.nvim_buf_set_lines(response_popup.bufnr, 0, -1, false, {})

    -- display already preprocessed chunk
    local line_count = vim.api.nvim_buf_line_count(response_popup.bufnr)
    local lines = vim.split(chunk, "\n", { plain = true, trimempty = false })

    vim.api.nvim_buf_set_lines(response_popup.bufnr, 0, -1, false, lines)

    -- auto scroll
    if response_popup.winid then
      vim.api.nvim_win_set_cursor(response_popup.winid, { line_count - 1 + #lines, 0 })
    end

    -- force redraw so changes are available instantly
    vim.cmd "redraw"
  end)
end

---@param fullResponse string
local function done_cb(fullResponse)
  vim.schedule(function()
    add_ai_message(fullResponse)
  end)
end

---@return table
local function get_message_turns(messages)
  local group = {}
  local current_turn = nil

  for _, msg in ipairs(messages) do
    if msg.role == "user" then
      -- start a new conversation turn
      current_turn = {
        { role = msg.role, content = msg.content },
      }
      table.insert(group, current_turn)
    elseif msg.role == "assistant" then
      -- add assistant response to current turn
      if current_turn then
        table.insert(current_turn, {
          role = msg.role,
          content = msg.content,
        })
      end
      current_turn = nil
    end
  end

  return group
end

local function error_callback(text)
  -- clear buffer
  vim.api.nvim_buf_set_lines(response_popup.bufnr, 0, -1, false, {})

  -- add text
  vim.api.nvim_buf_set_lines(response_popup.bufnr, 0, -1, false, { "[ERROR] " .. text })

  -- last user message
  local last_user_message = end_to_end_conversation[#end_to_end_conversation]

  -- remove the last user message
  table.remove(end_to_end_conversation, #end_to_end_conversation)

  -- calculate message history length
  local length = #get_message_turns(create_messages())
  message_turn = length

  -- reset history text
  vim.api.nvim_buf_set_lines(history_text.bufnr, 0, -1, false, { tostring(message_turn) .. "/" .. tostring(length) })

  -- re add previous message
  vim.api.nvim_buf_set_lines(input_popup.bufnr, 0, -1, false, { last_user_message.content })
end

function get_ai_response()
  local cor = coroutine.create(function()
    ai_response.generate_response(create_messages(), chunk_cb, done_cb, error_callback)
  end)

  -- Resume the coroutine repeatedly.
  local function step()
    local ok, _ = coroutine.resume(cor)
    if not ok then
      -- will display unhandled error
      error_callback()
    elseif coroutine.status(cor) ~= "dead" then
      vim.schedule(step)
    end
  end
  step()
end

-- component mappings
input_popup:map("n", "<CR>", function()
  -- craft prompt
  system_instructions = {} -- reset prompt
  add_system_instruction(system_prompt.character_prompt)

  -- get user input
  local user_input = table.concat(vim.api.nvim_buf_get_lines(input_popup.bufnr, 0, -1, false), "\n")
  add_user_message(user_input)

  -- calculate message history length
  local length = #get_message_turns(create_messages())
  message_turn = length

  -- update history text
  vim.api.nvim_buf_set_lines(history_text.bufnr, 0, -1, false, { tostring(message_turn) .. "/" .. tostring(length) })

  -- clear input and output
  vim.api.nvim_buf_set_lines(input_popup.bufnr, 0, -1, false, {})
  vim.api.nvim_buf_set_lines(response_popup.bufnr, 0, -1, false, {})

  get_ai_response()
end, { noremap = true, silent = true })

left_button:map("n", "<CR>", function()
  local messages = get_message_turns(create_messages())
  local message_length = #messages

  if message_turn == 0 or message_turn == 1 then
    return
  end

  message_turn = message_turn - 1

  local user_input = messages[message_turn][1].content
  local ai_generated_response = messages[message_turn][2].content

  -- apply to buffer
  local user_lines = vim.split(user_input, "\n", { plain = true, trimempty = false })
  vim.api.nvim_buf_set_lines(input_popup.bufnr, 0, -1, false, user_lines)

  local ai_lines = vim.split(ai_generated_response, "\n", { plain = true, trimempty = false })
  vim.api.nvim_buf_set_lines(response_popup.bufnr, 0, -1, false, ai_lines)

  -- update history text
  vim.api.nvim_buf_set_lines(
    history_text.bufnr,
    0,
    -1,
    false,
    { tostring(message_turn) .. "/" .. tostring(message_length) }
  )
end)

delete_button:map("n", "<CR>", function()
  message_turn = 0
  end_to_end_conversation = {}

  -- clear input and output
  vim.api.nvim_buf_set_lines(input_popup.bufnr, 0, -1, false, {})
  vim.api.nvim_buf_set_lines(response_popup.bufnr, 0, -1, false, {})

  -- update history text
  vim.api.nvim_buf_set_lines(history_text.bufnr, 0, -1, false, { "0/0" })
end)

right_button:map("n", "<CR>", function()
  local messages = get_message_turns(create_messages())
  local message_length = #messages

  if message_turn == message_length then
    return
  end

  message_turn = message_turn + 1

  local user_input = messages[message_turn][1].content
  local ai_generated_response = messages[message_turn][2].content

  -- apply to buffer
  local user_lines = vim.split(user_input, "\n", { plain = true, trimempty = false })
  vim.api.nvim_buf_set_lines(input_popup.bufnr, 0, -1, false, user_lines)

  local ai_lines = vim.split(ai_generated_response, "\n", { plain = true, trimempty = false })
  vim.api.nvim_buf_set_lines(response_popup.bufnr, 0, -1, false, ai_lines)

  -- update history text
  vim.api.nvim_buf_set_lines(
    history_text.bufnr,
    0,
    -1,
    false,
    { tostring(message_turn) .. "/" .. tostring(message_length) }
  )
end)
