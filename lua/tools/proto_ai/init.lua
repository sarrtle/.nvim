-- AI Assistant prototype for this neovim configs

require "tools.proto_ai.ui"

-- create auto commands
vim.api.nvim_create_user_command("ProtoAiSetToken", function(_)
  local secret = vim.fn.inputsecret "API TOKEN: "

  if secret == "" then
    print "Secret is empty"
    return
  end
  -- Write to a temporary file (use proper encryption in real cases!)
  local file = io.open(vim.env.HOME .. "/.deepinfra_token", "w")
  if not file then
    print "Failed to create file"
    return
  end
  file:write(secret)
  file:close()
  print(" -- saved to " .. vim.env.HOME .. "/.deepinfra_token")
end, {})

vim.api.nvim_create_user_command("ProtoAiDeleteToken", function(_)
  local path = vim.env.HOME .. "/.deepinfra_token"
  vim.fn.system("rm " .. path)
  print(" Api token deleted: " .. vim.env.HOME .. "/.deepinfra_token")
  vim.g.deepinfra_token = nil
end, {})
