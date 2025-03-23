-- AI API request functionality

---@diagnostic disable: missing-fields

local M = {}

M.add_system_input = function(message_history, system_input)
  table.insert(message_history, { role = "system", content = system_input })
end

M.add_user_input = function(message_history, user_input)
  table.insert(message_history, { role = "user", content = user_input })
end

M.add_ai_response = function(message_history, ai_response)
  table.insert(message_history, { role = "assistant", content = ai_response })
end

M.group_messages = function(messages)
  local grouped = {}
  local current_turn = nil

  for _, msg in ipairs(messages) do
    if msg.role == "user" then
      -- Start new conversation turn
      current_turn = {
        { role = msg.role, content = msg.content },
      }
      table.insert(grouped, current_turn)
    elseif msg.role == "assistant" then
      -- Add assistant response to current turn
      if current_turn then
        table.insert(current_turn, {
          role = msg.role,
          content = msg.content,
        })
      end
      current_turn = nil
    end
  end

  return grouped
end

-- Asynchronously calls the AI API with streaming enabled.
-- @param message_history Table containing your messages.
-- @param on_chunk Function to call with each incoming chunk (string).
-- @param on_done Function to call when streaming is finished (receives full response)
function M.get_ai_response_async_stream(message_history, on_chunk, on_done)
  local uv = vim.loop
  local payload = {
    model = "deepseek-ai/DeepSeek-R1-Turbo",
    stream = true,
    messages = message_history,
  }
  local jsonPayload = vim.fn.json_encode(payload)

  -- read token
  local file = io.open(vim.env.HOME .. "/.deepinfra_token", "r")
  if file then
    vim.g.deepinfra_token = file:read "*a"
    file:close()
  end

  local curlArgs = {
    "-sS",
    "--no-buffer",
    "https://api.deepinfra.com/v1/openai/chat/completions",
    "-H",
    "Content-Type: application/json",
    "-H",
    "Authorization: Bearer " .. (vim.g.deepinfra_token or "XXX"),
    "-d",
    jsonPayload,
  }

  local stdinPipe = assert(uv.new_pipe(false))
  local stdoutPipe = assert(uv.new_pipe(false))
  local stderrPipe = assert(uv.new_pipe(false))

  local accumulatedChunks = {}
  local buffer = ""

  -- Read stderr to capture curl errors
  uv.read_start(stderrPipe, function(err, data)
    if err then
      print("Error reading stderr: " .. err)
      return
    end
    if data then
      print("curl error: " .. data, vim.log.levels.ERROR)
    end
  end)

  local handle
  handle = uv.spawn("curl", {
    args = curlArgs,
    stdio = { stdinPipe, stdoutPipe, stderrPipe },
  }, function(_, _)
    uv.read_stop(stdoutPipe)
    uv.read_stop(stderrPipe)
    stdoutPipe:close()
    stdinPipe:close()
    stderrPipe:close()
    if handle then
      handle:close()
      handle = nil
    end
  end)

  uv.read_start(stdoutPipe, function(err, data)
    if err then
      print("Error reading stream: " .. err)
      return
    end

    -- Check for immediate error response
    local ok, error_data = pcall(vim.json.decode, buffer)
    if ok and error_data and (error_data.error or error_data.detail) then
      local error_msg = ""
      if error_data.error then
        error_msg = error_data.error.message or "Unknown error"
      elseif error_data.detail then
        error_msg = error_data.detail
      end

      if on_chunk then
        vim.schedule(function()
          on_chunk("[ERROR] " .. error_msg) -- Immediate error display
        end)
      end
      if on_done then
        vim.schedule(function()
          on_done("[ERROR] " .. error_msg) -- Final error message
        end)
      end
      -- Clean up resources
      uv.read_stop(stdoutPipe)
      stdoutPipe:close()
      if handle then
        handle:close()
      end
      return
    end

    if data then
      buffer = buffer .. data
      while true do
        local newlineIndex = buffer:find "\n"
        if not newlineIndex then
          break
        end
        local line = buffer:sub(1, newlineIndex - 1)
        buffer = buffer:sub(newlineIndex + 1)
        ProcessLine(line, accumulatedChunks, on_chunk)
      end
    else -- EOF: Process remaining buffer
      if buffer ~= "" then
        ProcessLine(buffer, accumulatedChunks, on_chunk)
        buffer = ""
      end
      if on_done then
        on_done(table.concat(accumulatedChunks))
      end
    end
  end)
end

-- Helper function to process each line
function ProcessLine(line, accumulatedChunks, on_chunk)
  local jsonStr = line:match "^data:%s*(.*)"
  if jsonStr then
    if jsonStr == "[DONE]" then
      return
    end
    local ok, chunkData = pcall(vim.json.decode, jsonStr)
    if ok and chunkData and chunkData.choices and chunkData.choices[1] then
      local delta = chunkData.choices[1].delta or {}
      local chunkContent = delta.content or ""
      table.insert(accumulatedChunks, chunkContent)
      if on_chunk then
        vim.schedule(function()
          on_chunk(chunkContent)
        end)
      end
    end
  end
end

return M
